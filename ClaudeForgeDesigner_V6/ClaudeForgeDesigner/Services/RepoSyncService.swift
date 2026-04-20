import AppKit
import Foundation

enum RepoSyncError: LocalizedError {
    case noTargetRepo
    case gitFailed(exit: Int32, stderr: String)
    case notAGitRepo(URL)

    var errorDescription: String? {
        switch self {
        case .noTargetRepo:
            return "No target repo folder is set. Pick one in the HUD settings first."
        case .gitFailed(let exit, let stderr):
            return "git exited with code \(exit). \(stderr.isEmpty ? "" : "Details: \(stderr)")"
        case .notAGitRepo(let url):
            return "\(url.path) is not a git repository. Run `git init` in that folder first."
        }
    }
}

struct RemovedCaptureBlock: Identifiable, Hashable {
    var id: String { "\(file)//\(title)//\(commit)" }
    let file: String          // "HAZARDS.md" / "BUGS.md" / "IDEAS.md"
    let title: String
    let commit: String        // short hash where it was last present
    let removedAt: Date?      // best-effort date of the removal commit
    let fields: [String]      // raw field lines for preview (label + value pairs as rendered)
}

struct RepoSyncService {

    // MARK: - Target repo path (UserDefaults-backed)

    private static let targetRepoKey = "ClaudeForge.targetRepoPath"

    static var targetRepoURL: URL? {
        get {
            guard let path = UserDefaults.standard.string(forKey: targetRepoKey), !path.isEmpty else {
                return nil
            }
            return URL(fileURLWithPath: path)
        }
        set {
            if let url = newValue {
                UserDefaults.standard.set(url.path, forKey: targetRepoKey)
            } else {
                UserDefaults.standard.removeObject(forKey: targetRepoKey)
            }
        }
    }

    static func promptForTargetRepo() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"
        panel.message = "Choose the repo folder ClaudeForge should write captures into."
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        targetRepoURL = url
        return url
    }

    // MARK: - File writes (read-merge-write)

    /// Pure write: the in-memory collections are the source of truth. Preserves the
    /// file's existing intro prose (if any) but overwrites the block section entirely
    /// with the current in-memory state. Use this after the user adds or removes a
    /// capture — it will not resurrect removed blocks.
    static func writeCapturesToRepo(
        targetRoot: URL,
        hazards: [Hazard],
        bugs: [Bug],
        ideas: [Idea],
        defaultHazardIntro: String,
        defaultBugIntro: String,
        defaultIdeaIntro: String
    ) throws {
        try writeFilePure(
            url: targetRoot.appendingPathComponent("HAZARDS.md"),
            defaultIntro: defaultHazardIntro,
            blocks: hazards.map(CaptureMarkdown.renderHazardBlock)
        )
        try writeFilePure(
            url: targetRoot.appendingPathComponent("BUGS.md"),
            defaultIntro: defaultBugIntro,
            blocks: bugs.map(CaptureMarkdown.renderBugBlock)
        )
        try writeFilePure(
            url: targetRoot.appendingPathComponent("IDEAS.md"),
            defaultIntro: defaultIdeaIntro,
            blocks: ideas.map(CaptureMarkdown.renderIdeaBlock)
        )
    }

    /// Read-merge-write: reads the repo's capture files, absorbs any blocks that exist
    /// in the files but not in the in-memory state (likely added by a user or AI agent
    /// outside the app), and writes the unified state back. Use on HUD appear or when
    /// the user explicitly refreshes — NOT on add/remove, because that would resurrect
    /// just-deleted blocks that are still present in the file pre-write.
    static func refreshFromRepo(
        targetRoot: URL,
        hazards: [Hazard],
        bugs: [Bug],
        ideas: [Idea],
        defaultHazardIntro: String,
        defaultBugIntro: String,
        defaultIdeaIntro: String
    ) throws -> (hazards: [Hazard], bugs: [Bug], ideas: [Idea]) {
        let mergedHazards = try writeFileMerging(
            url: targetRoot.appendingPathComponent("HAZARDS.md"),
            defaultIntro: defaultHazardIntro,
            inMemory: hazards,
            renderFn: CaptureMarkdown.renderHazardBlock,
            mergeFn: CaptureMarkdown.mergeHazards
        )
        let mergedBugs = try writeFileMerging(
            url: targetRoot.appendingPathComponent("BUGS.md"),
            defaultIntro: defaultBugIntro,
            inMemory: bugs,
            renderFn: CaptureMarkdown.renderBugBlock,
            mergeFn: CaptureMarkdown.mergeBugs
        )
        let mergedIdeas = try writeFileMerging(
            url: targetRoot.appendingPathComponent("IDEAS.md"),
            defaultIntro: defaultIdeaIntro,
            inMemory: ideas,
            renderFn: CaptureMarkdown.renderIdeaBlock,
            mergeFn: CaptureMarkdown.mergeIdeas
        )
        return (mergedHazards, mergedBugs, mergedIdeas)
    }

    private static func writeFilePure(url: URL, defaultIntro: String, blocks: [String]) throws {
        let fm = FileManager.default
        try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)

        let existing = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        let parsed = CaptureMarkdown.parse(existing)
        let introToUse = parsed.intro.isEmpty ? defaultIntro : parsed.intro

        let contents = CaptureMarkdown.composeFile(intro: introToUse, blocks: blocks)
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }

    private static func writeFileMerging<T>(
        url: URL,
        defaultIntro: String,
        inMemory: [T],
        renderFn: (T) -> String,
        mergeFn: ([T], [CaptureMarkdown.Block]) -> [T]
    ) throws -> [T] {
        let fm = FileManager.default
        try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)

        let existing = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        let parsed = CaptureMarkdown.parse(existing)
        let introToUse = parsed.intro.isEmpty ? defaultIntro : parsed.intro

        let merged = mergeFn(inMemory, parsed.blocks)
        let allBlocks = merged.map(renderFn)
        let contents = CaptureMarkdown.composeFile(intro: introToUse, blocks: allBlocks)
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return merged
    }

    // MARK: - Git ops

    /// Runs `git add / commit / push` in the target repo for the 3 capture files.
    /// Returns a human-readable summary line on success.
    static func syncCommit(
        targetRoot: URL,
        message: String,
        pendingHazards: Int,
        pendingBugs: Int,
        pendingIdeas: Int
    ) throws -> String {
        try requireGitRepo(targetRoot)

        let files = ["HAZARDS.md", "BUGS.md", "IDEAS.md"].filter { name in
            FileManager.default.fileExists(atPath: targetRoot.appendingPathComponent(name).path)
        }
        guard !files.isEmpty else {
            throw RepoSyncError.gitFailed(exit: 1, stderr: "No capture files exist in the target repo yet.")
        }

        _ = try runGit(["add"] + files, in: targetRoot)

        // If there is nothing staged, `git commit` will exit non-zero. We detect that
        // and report a friendly "nothing to commit" rather than an error.
        let statusResult = try runGit(["diff", "--cached", "--quiet"], in: targetRoot, allowNonZeroExit: true)
        if statusResult.exitCode == 0 {
            return "Nothing to commit — working tree matches the repo."
        }

        _ = try runGit(["commit", "-m", message], in: targetRoot)

        // Best-effort push. If no upstream is configured or auth fails, surface a clear error.
        let pushResult = try runGit(["push"], in: targetRoot, allowNonZeroExit: true)
        if pushResult.exitCode != 0 {
            return "Committed locally, but push failed:\n\(pushResult.stderr.trimmingCharacters(in: .whitespacesAndNewlines))"
        }

        return "Synced: \(pendingHazards) hazard\(pendingHazards == 1 ? "" : "s"), \(pendingBugs) bug\(pendingBugs == 1 ? "" : "s"), \(pendingIdeas) idea\(pendingIdeas == 1 ? "" : "s")."
    }

    private static func requireGitRepo(_ url: URL) throws {
        let gitDir = url.appendingPathComponent(".git")
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: gitDir.path, isDirectory: &isDir) {
            throw RepoSyncError.notAGitRepo(url)
        }
    }

    struct GitResult {
        let exitCode: Int32
        let stdout: String
        let stderr: String
    }

    @discardableResult
    static func runGit(_ args: [String], in dir: URL, allowNonZeroExit: Bool = false) throws -> GitResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = args
        process.currentDirectoryURL = dir

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        try process.run()
        process.waitUntilExit()

        let stdout = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        if process.terminationStatus != 0 && !allowNonZeroExit {
            throw RepoSyncError.gitFailed(exit: process.terminationStatus, stderr: stderr.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return GitResult(exitCode: process.terminationStatus, stdout: stdout, stderr: stderr)
    }

    // MARK: - History (git log parser)

    /// Walks git history for each capture file and returns blocks that existed in some
    /// past commit but are not present in the current HEAD.
    static func fetchRemovedBlocks(targetRoot: URL) throws -> [RemovedCaptureBlock] {
        try requireGitRepo(targetRoot)

        let fileNames = ["HAZARDS.md", "BUGS.md", "IDEAS.md"]
        var removed: [RemovedCaptureBlock] = []

        for fileName in fileNames {
            let filePresent = FileManager.default.fileExists(atPath: targetRoot.appendingPathComponent(fileName).path)
            let currentBlocks: Set<String>
            if filePresent {
                let current = (try? String(contentsOf: targetRoot.appendingPathComponent(fileName), encoding: .utf8)) ?? ""
                currentBlocks = Set(CaptureMarkdown.parse(current).blocks.map { $0.title })
            } else {
                currentBlocks = []
            }

            // List commits that touched this file.
            let logResult = try runGit(
                ["log", "--pretty=format:%H\t%ct", "--", fileName],
                in: targetRoot,
                allowNonZeroExit: true
            )
            guard logResult.exitCode == 0 else { continue }

            let commits: [(hash: String, date: Date)] = logResult.stdout
                .split(separator: "\n")
                .compactMap { line in
                    let parts = line.split(separator: "\t")
                    guard parts.count == 2 else { return nil }
                    let hash = String(parts[0])
                    let ts = Double(parts[1]).map { Date(timeIntervalSince1970: $0) } ?? Date()
                    return (hash, ts)
                }

            var seenTitles: [String: (commit: String, date: Date, fields: [String])] = [:]

            for commit in commits {
                let show = try runGit(
                    ["show", "\(commit.hash):\(fileName)"],
                    in: targetRoot,
                    allowNonZeroExit: true
                )
                guard show.exitCode == 0 else { continue }
                let parsed = CaptureMarkdown.parse(show.stdout)
                for block in parsed.blocks {
                    if !currentBlocks.contains(block.title) {
                        // Keep the most recent appearance (commits iterate newest-first by default).
                        if seenTitles[block.title] == nil {
                            let fieldStrings = block.fields.map { "\($0.label): \($0.value)" }
                            seenTitles[block.title] = (commit.hash, commit.date, fieldStrings)
                        }
                    }
                }
            }

            for (title, record) in seenTitles {
                removed.append(RemovedCaptureBlock(
                    file: fileName,
                    title: title,
                    commit: String(record.commit.prefix(7)),
                    removedAt: record.date,
                    fields: record.fields
                ))
            }
        }

        return removed.sorted { (a, b) in
            (a.removedAt ?? .distantPast) > (b.removedAt ?? .distantPast)
        }
    }
}
