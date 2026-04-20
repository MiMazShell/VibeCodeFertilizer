import Foundation

// Pure functions that render and parse the ClaudeForge capture-file block format.
//
// File shape (per HAZARDS.md / BUGS.md / IDEAS.md):
//
//   <intro prose>
//   ---
//   ## <title>
//
//   **<field label>:** <field value>
//
//   **<field label>:** <field value>
//
//   ---
//
//   ## <next title>
//   ...
//
// Parser keeps the intro verbatim (user edits survive) and treats each `## ` heading
// below the first `---` as a capture block. Fields are extracted by label. Fields we
// don't recognize are ignored on read but preserved on write-only-if we render them
// ourselves. Manual field additions inside a block will be overwritten by the app's
// structured fields on the next write — the block IS the contract.

enum CaptureMarkdown {

    // MARK: - Block types

    struct Block {
        let title: String
        let fields: [(label: String, value: String)]
    }

    // MARK: - Render (one block at a time)

    static func renderHazardBlock(_ h: Hazard) -> String {
        let why = h.whyItBites.isEmpty ? "_(no explanation captured)_" : h.whyItBites
        let how = h.howToHandle.isEmpty ? "_(no handling guidance captured)_" : h.howToHandle
        return """
## \(h.title)

**Why it bites:** \(why)

**How to handle:** \(how)
"""
    }

    static func renderBugBlock(_ b: Bug) -> String {
        let symptom = b.symptom.isEmpty ? "_(no symptom captured)_" : b.symptom
        let area = b.suspectedArea.isEmpty ? "_(unspecified)_" : b.suspectedArea
        return """
## \(b.title)

**Symptom:** \(symptom)

**Suspected area:** \(area)
"""
    }

    static func renderIdeaBlock(_ i: Idea) -> String {
        let why = i.whyItMatters.isEmpty ? "_(no rationale captured)_" : i.whyItMatters
        let sketch = i.sketch.isEmpty ? "_(no sketch captured)_" : i.sketch
        return """
## \(i.title)

**Why it matters:** \(why)

**Sketch:** \(sketch)
"""
    }

    // MARK: - File composition

    static func composeFile(intro: String, blocks: [String]) -> String {
        let trimmedIntro = intro.trimmingCharacters(in: .whitespacesAndNewlines)
        let separator = "\n\n---\n\n"
        if blocks.isEmpty {
            return trimmedIntro + "\n"
        }
        return trimmedIntro + separator + blocks.joined(separator: separator) + "\n"
    }

    // MARK: - Parse

    /// Splits a capture file into (introText, blocks). The intro is everything before
    /// the first `## ` heading, with trailing separators/whitespace trimmed. Blocks are
    /// the `## <title>` sections with their labelled fields.
    static func parse(_ markdown: String) -> (intro: String, blocks: [Block]) {
        let lines = markdown.components(separatedBy: "\n")

        var introLines: [String] = []
        var blockStartIndex: Int? = nil
        for (i, line) in lines.enumerated() {
            if line.hasPrefix("## ") {
                blockStartIndex = i
                break
            }
            introLines.append(line)
        }

        let introRaw = introLines.joined(separator: "\n")
        let intro = stripTrailingSeparators(introRaw)

        guard let start = blockStartIndex else {
            return (intro, [])
        }

        let blockLines = Array(lines[start..<lines.count])
        var blocks: [Block] = []
        var current: (title: String, body: [String])? = nil

        func flush() {
            if let c = current {
                blocks.append(Block(title: c.title, fields: extractFields(from: c.body)))
            }
        }

        for line in blockLines {
            if line.hasPrefix("## ") {
                flush()
                let title = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                current = (title, [])
            } else {
                current?.body.append(line)
            }
        }
        flush()

        return (intro, blocks)
    }

    private static func stripTrailingSeparators(_ text: String) -> String {
        var result = text
        while true {
            let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasSuffix("---") {
                if let range = result.range(of: "---", options: .backwards) {
                    result = String(result[..<range.lowerBound])
                    continue
                }
            }
            return result.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    /// Extracts `**Label:** value` fields from a block body. Values can span multiple
    /// lines until the next labelled field or a separator. Non-field lines (including
    /// `---` separators) end the current field.
    private static func extractFields(from body: [String]) -> [(label: String, value: String)] {
        var fields: [(String, String)] = []
        var currentLabel: String? = nil
        var currentValue: [String] = []

        func flush() {
            if let label = currentLabel {
                let value = currentValue.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                fields.append((label, value))
            }
            currentLabel = nil
            currentValue = []
        }

        for line in body {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "---" {
                flush()
                continue
            }
            if let match = parseFieldHeader(trimmed) {
                flush()
                currentLabel = match.label
                if !match.rest.isEmpty {
                    currentValue.append(match.rest)
                }
            } else if currentLabel != nil {
                currentValue.append(line)
            }
        }
        flush()
        return fields
    }

    private static func parseFieldHeader(_ line: String) -> (label: String, rest: String)? {
        guard line.hasPrefix("**") else { return nil }
        // Look for the closing `:**` pattern.
        guard let closeRange = line.range(of: ":**") else { return nil }
        let labelStart = line.index(line.startIndex, offsetBy: 2)
        guard labelStart <= closeRange.lowerBound else { return nil }
        let label = String(line[labelStart..<closeRange.lowerBound])
        let restStart = closeRange.upperBound
        let rest = restStart < line.endIndex
            ? String(line[restStart..<line.endIndex]).trimmingCharacters(in: .whitespaces)
            : ""
        return (label, rest)
    }

    // MARK: - Merge helpers (used when writing back to a repo file)

    /// Merge in-memory hazards with any blocks already in the file.
    /// In-memory wins on title collision. File-only blocks are preserved (likely
    /// added manually by the user or an AI agent) and appended to the returned list.
    static func mergeHazards(inMemory: [Hazard], fileBlocks: [Block]) -> [Hazard] {
        let knownTitles = Set(inMemory.map { $0.title })
        let orphans = fileBlocks.filter { !knownTitles.contains($0.title) }.map { block -> Hazard in
            let fieldsByLabel = Dictionary(uniqueKeysWithValues: block.fields.map { ($0.label, $0.value) })
            return Hazard(
                title: block.title,
                whyItBites: placeholderAware(fieldsByLabel["Why it bites"] ?? ""),
                howToHandle: placeholderAware(fieldsByLabel["How to handle"] ?? ""),
                syncState: .synced // already in the file → treat as already synced
            )
        }
        return inMemory + orphans
    }

    static func mergeBugs(inMemory: [Bug], fileBlocks: [Block]) -> [Bug] {
        let knownTitles = Set(inMemory.map { $0.title })
        let orphans = fileBlocks.filter { !knownTitles.contains($0.title) }.map { block -> Bug in
            let fieldsByLabel = Dictionary(uniqueKeysWithValues: block.fields.map { ($0.label, $0.value) })
            return Bug(
                title: block.title,
                symptom: placeholderAware(fieldsByLabel["Symptom"] ?? ""),
                suspectedArea: placeholderAware(fieldsByLabel["Suspected area"] ?? ""),
                syncState: .synced
            )
        }
        return inMemory + orphans
    }

    static func mergeIdeas(inMemory: [Idea], fileBlocks: [Block]) -> [Idea] {
        let knownTitles = Set(inMemory.map { $0.title })
        let orphans = fileBlocks.filter { !knownTitles.contains($0.title) }.map { block -> Idea in
            let fieldsByLabel = Dictionary(uniqueKeysWithValues: block.fields.map { ($0.label, $0.value) })
            return Idea(
                title: block.title,
                whyItMatters: placeholderAware(fieldsByLabel["Why it matters"] ?? ""),
                sketch: placeholderAware(fieldsByLabel["Sketch"] ?? ""),
                syncState: .synced
            )
        }
        return inMemory + orphans
    }

    private static func placeholderAware(_ value: String) -> String {
        // Our render emits italic placeholders like "_(no explanation captured)_" when
        // a field was empty. If we read one back, treat it as empty.
        if value.hasPrefix("_(") && value.hasSuffix(")_") {
            return ""
        }
        return value
    }
}
