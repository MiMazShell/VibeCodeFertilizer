import AppKit
import SwiftUI

struct RepoStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(
            title: "Repository setup",
            subtitle: "Always prepare GitHub identity and local project-folder guidance. Optionally include repo-creation and a floating helper panel for browser/Terminal setup."
        ) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    InfoCard(title: "GitHub identity and local folder", symbol: "person.crop.circle") {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("GitHub username or owner", text: $viewModel.repoOwner)
                            TextField("GitHub repo name", text: $viewModel.repoName)
                            TextField("Local project folder name", text: $viewModel.localProjectFolderName)
                            TextField("Credential hint", text: $viewModel.repoKeyHint)
                        }
                    }

                    InfoCard(title: "Clone, push, and repo creation", symbol: "terminal") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Enable HTTPS clone instructions", isOn: $viewModel.useHTTPS)
                            Toggle("Enable SSH clone instructions", isOn: $viewModel.useSSH)
                            Toggle("Include GitHub API repo-creation guidance", isOn: $viewModel.includeRepoCreationGuide)
                            Toggle("Mark this pack as wanting repo creation via API", isOn: $viewModel.createRepoViaAPI)
                            Toggle("Include helper overlay guidance", isOn: $viewModel.includeFloatingSetupHelper)
                            Text(viewModel.enabledCloneFlowsDescription)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack(alignment: .top, spacing: 16) {
                    InfoCard(title: "Helper overlay", symbol: "macwindow.on.rectangle") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Open a floating always-on-top helper while you are in the browser or Terminal. Each command has a copy button.")
                                .foregroundStyle(.secondary)
                            HStack(spacing: 10) {
                                Button("Open helper overlay") {
                                    FloatingHelperWindowController.shared.show(commands: helperCommands)
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Close helper overlay") {
                                    FloatingHelperWindowController.shared.close()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }

                    InfoCard(title: "What gets written", symbol: "doc.plaintext") {
                        VStack(alignment: .leading, spacing: 10) {
                            PreviewBadgeRow(values: ["repo/github-setup.txt", "repo/terminal-cheatsheet.txt", "prompts/claude-repo-access.txt", "clone commands"])
                            Text("Repo creation is documented using GitHub token/API guidance, while SSH or HTTPS is used for clone and push flows.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                InfoCard(title: "Setup help", symbol: "questionmark.circle") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Use the helper overlay or this inline guide to set up GitHub auth, create a local project folder, and prepare a new repo if needed.")
                            .foregroundStyle(.secondary)
                        Button("Show inline auth helper") {
                            viewModel.showingSSHHelper = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingSSHHelper) {
            HelperGuideSheet(commands: helperCommands)
        }
    }

    private var helperCommands: [HelperCommand] {
        [
            .init(title: "Create local project folder", command: "mkdir -p ~/Projects/\(viewModel.localProjectFolderName) && cd ~/Projects/\(viewModel.localProjectFolderName)", detail: "Creates the local folder where Claude can clone or initialize the repo."),
            .init(title: "Check SSH keys", command: "ls ~/.ssh", detail: "Lists existing local SSH keys."),
            .init(title: "Create SSH key", command: ##"ssh-keygen -t ed25519 -C "your_email@example.com""##, detail: "Generates a modern SSH key for GitHub access if needed."),
            .init(title: "Copy public key", command: "pbcopy < ~/.ssh/id_ed25519.pub", detail: "Copies the public key so you can paste it into GitHub."),
            .init(title: "Test GitHub SSH", command: "ssh -T git@github.com", detail: "Checks whether your GitHub SSH authentication works."),
            .init(title: "Create repo with GitHub CLI", command: "gh repo create \(viewModel.repoOwner)/\(viewModel.repoName) --private --source=. --remote=origin", detail: "Creates a new repo if GitHub CLI auth is already configured."),
            .init(title: "Create repo with curl", command: #"curl -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer <YOUR_TOKEN>" https://api.github.com/user/repos -d '{"name":"\#(viewModel.repoName)","private":true}'"#, detail: "Creates a new personal repo using the GitHub REST API and a token."),
            .init(title: "Clone with SSH", command: "git clone git@github.com:\(viewModel.repoOwner)/\(viewModel.repoName).git", detail: "Clones the repo using SSH."),
            .init(title: "Clone with HTTPS", command: "git clone https://github.com/\(viewModel.repoOwner)/\(viewModel.repoName).git", detail: "Clones the repo using HTTPS."),
            .init(title: "Open project folder", command: "open .", detail: "Opens the current folder in Finder.")
        ]
    }
}

private struct HelperGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    let commands: [HelperCommand]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Repository helper")
                .font(.title2.bold())
            Text("This guide mirrors the floating helper panel and gives you copy-ready commands for GitHub, Terminal, and local-folder setup.")
                .foregroundStyle(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(commands) { item in
                        HelperCommandRow(item: item)
                    }
                }
            }

            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(minWidth: 700, minHeight: 420)
    }
}

private struct HelperCommand: Identifiable {
    let id = UUID()
    let title: String
    let command: String
    let detail: String
}

private struct HelperCommandRow: View {
    let item: HelperCommand

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(item.command, forType: .string)
                }
                .buttonStyle(.bordered)
            }
            Text(item.command)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

private final class FloatingHelperWindowController: NSWindowController {
    static let shared = FloatingHelperWindowController()

    private init() {
        let hosting = NSHostingController(rootView: AnyView(EmptyView()))
        let panel = NSPanel(
            contentRect: NSRect(x: 200, y: 200, width: 560, height: 520),
            styleMask: [.titled, .closable, .resizable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.title = "Repository Helper"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.contentViewController = hosting
        super.init(window: panel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(commands: [HelperCommand]) {
        let content = FloatingHelperPanel(commands: commands)
        if let hosting = window?.contentViewController as? NSHostingController<AnyView> {
            hosting.rootView = AnyView(content)
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

private struct FloatingHelperPanel: View {
    let commands: [HelperCommand]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Keep this panel above your browser or Terminal while you work through setup.")
                    .foregroundStyle(.secondary)
                ForEach(commands) { item in
                    HelperCommandRow(item: item)
                }
            }
            .padding(18)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
