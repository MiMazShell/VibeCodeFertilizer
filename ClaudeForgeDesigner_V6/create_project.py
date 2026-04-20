import os, textwrap, json, base64
from pathlib import Path
root = Path('/mnt/data/ClaudeForgeDesigner')
app = root/'ClaudeForgeDesigner'
(app/'Views').mkdir(parents=True, exist_ok=True)
(app/'Models').mkdir(exist_ok=True)
(app/'Services').mkdir(exist_ok=True)
(app/'Resources'/'Assets.xcassets'/'AccentColor.colorset').mkdir(parents=True, exist_ok=True)
(app/'Resources'/'Assets.xcassets'/'AppIcon.appiconset').mkdir(parents=True, exist_ok=True)
(app/'Resources'/'PreviewThemes').mkdir(parents=True, exist_ok=True)
(app/'Resources'/'Templates').mkdir(parents=True, exist_ok=True)
(app/'Resources'/'Assets.xcassets').joinpath('Contents.json').write_text(json.dumps({'info':{'author':'xcode','version':1}}, indent=2))
(app/'Resources'/'Assets.xcassets'/'AccentColor.colorset'/'Contents.json').write_text(json.dumps({
  'colors':[{'idiom':'universal','color':{'color-space':'srgb','components':{'red':'0.35','green':'0.60','blue':'0.95','alpha':'1.000'}}}],
  'info':{'author':'xcode','version':1}
}, indent=2))
(app/'Resources'/'Assets.xcassets'/'AppIcon.appiconset'/'Contents.json').write_text(json.dumps({'images':[],'info':{'author':'xcode','version':1}}, indent=2))

files = {}
files['ClaudeForgeDesignerApp.swift'] = '''
import SwiftUI

@main
struct ClaudeForgeDesignerApp: App {
    @StateObject private var viewModel = WizardViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 1100, minHeight: 760)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
'''
files['ContentView.swift'] = '''
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        } detail: {
            ZStack {
                LinearGradient(
                    colors: [Color(nsColor: .windowBackgroundColor), Color.accentColor.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Group {
                    switch viewModel.currentStep {
                    case .overview:
                        OverviewStepView()
                    case .project:
                        ProjectSetupStepView()
                    case .standards:
                        StandardsStepView()
                    case .rules:
                        RulesStepView()
                    case .theme:
                        ThemeStepView()
                    case .repo:
                        RepoStepView()
                    case .review:
                        ReviewExportStepView()
                    }
                }
                .padding(28)
            }
        }
    }
}
'''
files['Models/WizardModels.swift'] = '''
import Foundation

struct WizardStepItem: Identifiable, Hashable {
    let id: WizardStep
    let title: String
    let subtitle: String
    let symbol: String
}

enum WizardStep: String, CaseIterable, Identifiable {
    case overview
    case project
    case standards
    case rules
    case theme
    case repo
    case review

    var id: String { rawValue }
}

enum TargetPlatform: String, CaseIterable, Identifiable {
    case macOS
    case iPhone
    case iPad
    case universal

    var id: String { rawValue }
}

enum ThemePreset: String, CaseIterable, Identifiable {
    case macNative = "Mac Native"
    case iosElegant = "iPhone Elegant"
    case ipadProductive = "iPad Productive"
    case glassFocus = "Liquid Glass Focus"

    var id: String { rawValue }

    var summary: String {
        switch self {
        case .macNative: return "Sidebar-first, desktop density, toolbars, inspectors, keyboard-driven flows."
        case .iosElegant: return "Large titles, tap-friendly controls, vertically guided interactions."
        case .ipadProductive: return "Balanced split views, spacious canvases, contextual popovers."
        case .glassFocus: return "Modern layered materials, floating controls, softer chrome, richer depth."
        }
    }

    var filename: String {
        switch self {
        case .macNative: return "theme-mac-native"
        case .iosElegant: return "theme-ios-elegant"
        case .ipadProductive: return "theme-ipad-productive"
        case .glassFocus: return "theme-glass-focus"
        }
    }
}

struct TriggerRule: Identifiable, Hashable {
    let id = UUID()
    var phrase: String
    var instruction: String
}

struct GeneratedFile: Identifiable {
    let id = UUID()
    let relativePath: String
    let content: String
}
'''
files['ViewModels.swift'] = '''
import Foundation
import SwiftUI

final class WizardViewModel: ObservableObject {
    @Published var currentStep: WizardStep = .overview
    @Published var projectName = "New Product"
    @Published var productSummary = "A thoughtfully designed Apple-platform app guided by Claude Code files."
    @Published var targetPlatform: TargetPlatform = .macOS
    @Published var selectedTheme: ThemePreset = .glassFocus
    @Published var includeTestingRules = true
    @Published var includeArchitectureRules = true
    @Published var includeAccessibilityRules = true
    @Published var includePerformanceRules = true
    @Published var repoName = "my-app-repo"
    @Published var repoOwner = "your-github-name"
    @Published var repoKeyHint = "~/.ssh/id_ed25519 or GitHub PAT"
    @Published var generatedFiles: [GeneratedFile] = []
    @Published var triggerRules: [TriggerRule] = [
        TriggerRule(phrase: "When I say ship-ready", instruction: "Produce a release checklist, QA sweep, regression risks, and store-submission readiness list."),
        TriggerRule(phrase: "When I say design pass", instruction: "Audit spacing, typography, system materials, iconography, accessibility contrast, and platform consistency."),
        TriggerRule(phrase: "When I say refactor", instruction: "Propose low-risk structural cleanup with clear before/after tradeoffs and tests to protect behavior.")
    ]

    let steps: [WizardStepItem] = [
        .init(id: .overview, title: "Overview", subtitle: "Purpose and flow", symbol: "sparkles.rectangle.stack"),
        .init(id: .project, title: "Project", subtitle: "App and repo details", symbol: "square.and.pencil"),
        .init(id: .standards, title: "Standards", subtitle: "Base Claude.md rules", symbol: "checkmark.shield"),
        .init(id: .rules, title: "Rules", subtitle: "Trigger phrases and files", symbol: "text.badge.star"),
        .init(id: .theme, title: "Theme", subtitle: "Apple UI presets", symbol: "paintpalette"),
        .init(id: .repo, title: "Repository", subtitle: "Clone and Claude prompts", symbol: "point.3.connected.trianglepath.dotted"),
        .init(id: .review, title: "Export", subtitle: "Write files to repo", symbol: "tray.and.arrow.down"),
    ]

    var completionFraction: Double {
        Double(steps.firstIndex(where: { $0.id == currentStep }) ?? 0 + 1) / Double(steps.count)
    }

    func next() {
        guard let idx = steps.firstIndex(where: { $0.id == currentStep }), idx + 1 < steps.count else { return }
        currentStep = steps[idx + 1].id
    }

    func previous() {
        guard let idx = steps.firstIndex(where: { $0.id == currentStep }), idx > 0 else { return }
        currentStep = steps[idx - 1].id
    }

    func regenerateFiles() {
        generatedFiles = TemplateService().buildFiles(from: self)
    }
}
'''
files['Services/TemplateService.swift'] = '''
import Foundation

struct TemplateService {
    func buildFiles(from vm: WizardViewModel) -> [GeneratedFile] {
        let safeName = vm.projectName.replacingOccurrences(of: " ", with: "-")
        let root = safeName

        let claude = GeneratedFile(
            relativePath: "\(root)/Claude.md",
            content: baseClaude(vm: vm)
        )

        let planning = GeneratedFile(
            relativePath: "\(root)/planning/project-brief.txt",
            content: projectBrief(vm: vm)
        )

        let architecture = GeneratedFile(
            relativePath: "\(root)/planning/architecture-guidelines.txt",
            content: architectureGuidelines(vm: vm)
        )

        let triggers = GeneratedFile(
            relativePath: "\(root)/prompts/trigger-phrases.txt",
            content: triggerRules(vm: vm)
        )

        let uiGuide = GeneratedFile(
            relativePath: "\(root)/ui/ui-direction.txt",
            content: uiDirection(vm: vm)
        )

        let imagePrompts = GeneratedFile(
            relativePath: "\(root)/ui/image-prompts.txt",
            content: imagePrompts(vm: vm)
        )

        let githubSetup = GeneratedFile(
            relativePath: "\(root)/repo/github-setup.txt",
            content: githubSetup(vm: vm)
        )

        let claudeRepoPrompt = GeneratedFile(
            relativePath: "\(root)/prompts/claude-repo-access.txt",
            content: claudeRepoPrompt(vm: vm)
        )

        return [claude, planning, architecture, triggers, uiGuide, imagePrompts, githubSetup, claudeRepoPrompt]
    }

    private func baseClaude(vm: WizardViewModel) -> String {
        let standards = [
            vm.includeArchitectureRules ? "- Use a clean, modular SwiftUI + view-model architecture with small, testable components." : nil,
            vm.includeTestingRules ? "- Write or update unit tests for non-trivial logic and document test gaps when full coverage is not practical." : nil,
            vm.includeAccessibilityRules ? "- Preserve accessibility: semantic labels, keyboard navigation, Dynamic Type thinking for iOS outputs, contrast checks, and reduced-motion awareness." : nil,
            vm.includePerformanceRules ? "- Prefer native Apple APIs, measure before optimizing, and call out async or rendering hotspots early." : nil
        ].compactMap { $0 }.joined(separator: "\n")

        return """
# Claude.md

## Project identity
- Project name: \(vm.projectName)
- Primary target being designed: \(vm.targetPlatform.rawValue)
- Product summary: \(vm.productSummary)

## Role
You are Claude Code working inside this repository to help plan, design, and build Apple software with a strong native feel.

## Core operating rules
- Default to Swift and SwiftUI unless the repository clearly requires another Apple-native technology.
- Favor native patterns over heavy custom UI when platform conventions already solve the problem well.
- Break work into small, reviewable steps with explicit assumptions and risks.
- Before large changes, propose a short implementation plan, files to touch, and acceptance criteria.
- Keep repo documentation current whenever behavior, architecture, setup, or conventions change.
\(standards)
- Prefer maintainable code over clever code.
- Make naming explicit and domain-oriented.
- Surface tradeoffs when multiple approaches are viable.
- For UI work, align with Apple's current platform design language and use system materials, typography, iconography, and navigation idioms appropriately.

## Planning expectations
- Start each substantial task with scope, constraints, and acceptance criteria.
- Keep a running checklist for multi-step work.
- Separate must-have release work from nice-to-have polish.
- Call out missing product decisions quickly.

## Output expectations
- For implementation tasks, include files changed, why they changed, and verification notes.
- For design tasks, include layout structure, states, empty/loading/error handling, and accessibility notes.
- For repo tasks, keep generated guidance files synchronized with actual code structure.

## Apple-platform guidance
- Build interfaces that feel native on the target device.
- Use SF Symbols where appropriate.
- Prefer clarity, hierarchy, and restraint over visual noise.
- Keep glass/material effects supportive, not distracting.

## Repository guidance files
Read and apply the files in `/planning`, `/prompts`, `/ui`, and `/repo` alongside this root Claude.md.
"""
    }

    private func projectBrief(vm: WizardViewModel) -> String {
        return """
PROJECT BRIEF

Name: \(vm.projectName)
Target being designed: \(vm.targetPlatform.rawValue)
Theme preset: \(vm.selectedTheme.rawValue)

Summary:
\(vm.productSummary)

Goals:
1. Generate clear Claude Code guidance files inside the repo.
2. Keep design direction aligned with native Apple interface principles.
3. Make repo bootstrap steps easy for a human developer to copy/paste.
4. Support iterative prompt-based expansion of rules and trigger phrases.

Success criteria:
- A base Claude.md exists at the repo root.
- Supporting prompt and UI guidance files exist in clear subfolders.
- Theme choice creates concrete UI direction and image prompts.
- GitHub setup instructions are ready for HTTPS and SSH flows.
"""
    }

    private func architectureGuidelines(vm: WizardViewModel) -> String {
        return """
ARCHITECTURE GUIDELINES

- Keep the repository organized with top-level folders for app code, docs, prompts, UI guidance, and scripts when needed.
- Separate generated guidance artifacts from source code to reduce confusion.
- Prefer predictable file names so Claude Code can discover context quickly.
- For SwiftUI products, use small views, focused view models, and side-effect boundaries.
- Favor protocol-backed services only when the abstraction materially helps testing or replaceability.
- Use concise markdown and plain-text files for agent instructions.
- When expanding rules, append with headings rather than rewriting everything into one giant file.
"""
    }

    private func triggerRules(vm: WizardViewModel) -> String {
        let body = vm.triggerRules.enumerated().map { index, rule in
            "\(index + 1). Phrase: \(rule.phrase)\n   Action: \(rule.instruction)"
        }.joined(separator: "\n\n")

        return """
TRIGGER PHRASES

When these phrases appear in prompts or repo notes, Claude should apply the linked behavior.

\(body)
"""
    }

    private func uiDirection(vm: WizardViewModel) -> String {
        let themeDetail: String
        switch vm.selectedTheme {
        case .macNative:
            themeDetail = "Use a desktop-first information architecture with a sidebar, content area, inspector patterns, concise toolbars, and keyboard-friendly interactions."
        case .iosElegant:
            themeDetail = "Design iPhone-oriented outputs with strong hierarchy, large-touch comfort, concise modal usage, and focused one-handed flows."
        case .ipadProductive:
            themeDetail = "Design for broad canvases, balanced split views, drag/drop opportunities, and context-aware secondary panels."
        case .glassFocus:
            themeDetail = "Use layered materials, softer chrome, depth, floating controls, restrained translucency, and highly legible content over effects."
        }

        return """
UI DIRECTION

Preset: \(vm.selectedTheme.rawValue)

Direction:
\(themeDetail)

UI checklist:
- Use native navigation structures for the target form factor.
- Use SF Symbols consistently.
- Define empty, loading, success, and failure states.
- Keep copy concise and action-oriented.
- Avoid over-decorating surfaces.
- Make primary actions obvious.
- Specify spacing rhythm, typography hierarchy, and icon usage before building custom components.

Suggested deliverables:
- screen-map.txt
- ui-components.txt
- empty-states.txt
- motion-notes.txt
"""
    }

    private func imagePrompts(vm: WizardViewModel) -> String {
        return """
IMAGE / MOCK PROMPTS

1. Create a polished concept mockup for a \(vm.targetPlatform.rawValue) app called \(vm.projectName), following the \(vm.selectedTheme.rawValue) design direction, with native Apple controls, subtle materials, clear hierarchy, and realistic macOS-style spacing.

2. Create a UI moodboard showing typography, materials, sidebar structure, content panes, iconography, and accent usage for an Apple-native productivity application with a refined \(vm.selectedTheme.rawValue) feel.

3. Create a screen flow board for a wizard-based Mac application that generates Claude Code repo guidance files, including overview, project setup, rules, theme selection, GitHub setup, and export review.
"""
    }

    private func githubSetup(vm: WizardViewModel) -> String {
        return """
GITHUB SETUP

Repository owner: \(vm.repoOwner)
Repository name: \(vm.repoName)
Credential hint: \(vm.repoKeyHint)

HTTPS clone example:

git clone https://github.com/\(vm.repoOwner)/\(vm.repoName).git
cd \(vm.repoName)

SSH clone example:

git clone git@github.com:\(vm.repoOwner)/\(vm.repoName).git
cd \(vm.repoName)

Recommended repo structure after cloning:
- Claude.md
- planning/
- prompts/
- ui/
- repo/

After placing generated files in the repo:

git add .
git commit -m "Add Claude Code guidance pack"
git push origin main
"""
    }

    private func claudeRepoPrompt(vm: WizardViewModel) -> String {
        return """
CLAUDE REPO ACCESS PROMPTS

Prompt 1:
"You are working inside the repository \(vm.repoName). Start by reading Claude.md and all files in planning/, prompts/, ui/, and repo/. Summarize the project goals, repo rules, UI direction, and any missing decisions before writing code."

Prompt 2:
"Use the repository guidance files as operating instructions. When you propose changes, list the files to edit, the acceptance criteria, and any risks."

Prompt 3:
"Before implementing UI, produce a native Apple design plan aligned with the selected preset: \(vm.selectedTheme.rawValue)."
"""
    }
}
'''
files['Services/ExportService.swift'] = '''
import AppKit
import Foundation

struct ExportService {
    func export(files: [GeneratedFile]) throws -> URL? {
        guard !files.isEmpty else { return nil }

        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"
        panel.message = "Choose the destination folder for the generated repo guidance files."

        if panel.runModal() != .OK {
            return nil
        }

        guard let destination = panel.url else { return nil }

        for file in files {
            let target = destination.appendingPathComponent(file.relativePath)
            try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
            try file.content.write(to: target, atomically: true, encoding: .utf8)
        }

        return destination
    }
}
'''
files['Views/SharedViews.swift'] = '''
import SwiftUI

struct StepContainer<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 30, weight: .bold))
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .font(.title3)
            }

            content

            Spacer(minLength: 0)
            StepFooter()
        }
        .padding(28)
        .frame(maxWidth: 1000, maxHeight: .infinity, alignment: .topLeading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12))
        )
        .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
    }
}

struct PillTag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
    }
}

struct StepFooter: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        HStack {
            Button("Back") { viewModel.previous() }
                .disabled(viewModel.currentStep == .overview)

            Spacer()

            ProgressView(value: viewModel.completionFraction)
                .frame(width: 180)

            Spacer()

            Button(viewModel.currentStep == .review ? "Stay Here" : "Continue") {
                viewModel.next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.currentStep == .review)
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let symbol: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: symbol)
                .font(.headline)
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
'''
files['Views/SidebarView.swift'] = '''
import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("ClaudeForge")
                    .font(.system(size: 28, weight: .bold))
                Text("Wizard builder for Claude Code repo guidance")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            List(selection: Binding(get: { viewModel.currentStep }, set: { if let value = $0 { viewModel.currentStep = value } })) {
                ForEach(viewModel.steps) { step in
                    NavigationLink(value: step.id) {
                        VStack(alignment: .leading, spacing: 3) {
                            Label(step.title, systemImage: step.symbol)
                            Text(step.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tag(step.id)
                }
            }
            .listStyle(.sidebar)

            VStack(alignment: .leading, spacing: 10) {
                Text("Output")
                    .font(.headline)
                Text("Claude.md, prompt files, UI guidance, and GitHub helper text written into your repo.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}
'''
files['Views/OverviewStepView.swift'] = '''
import SwiftUI

struct OverviewStepView: View {
    var body: some View {
        StepContainer(
            title: "Build a repo-ready Claude Code guidance pack",
            subtitle: "This Mac app creates a base Claude.md plus supporting text files, theme guidance, image prompts, and GitHub setup helpers."
        ) {
            HStack(spacing: 18) {
                InfoCard(title: "What it generates", symbol: "doc.text") {
                    Text("A root Claude.md, planning notes, trigger-phrase files, UI direction, image prompts, and repo setup text.")
                        .foregroundStyle(.secondary)
                }
                InfoCard(title: "How it feels", symbol: "macwindow") {
                    Text("A macOS-first sidebar wizard with layered materials, clear hierarchy, and a modern native visual tone.")
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                PillTag(text: "Mac-only app")
                PillTag(text: "Claude Code focused")
                PillTag(text: "HTTPS + SSH repo help")
                PillTag(text: "Apple UI presets")
            }

            InfoCard(title: "Suggested workflow", symbol: "list.bullet.rectangle.portrait") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Enter project and repo details.")
                    Text("2. Choose the rules Claude should follow.")
                    Text("3. Pick a design preset for the Apple UI direction.")
                    Text("4. Export the files directly into your cloned GitHub repo.")
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}
'''
files['Views/ProjectSetupStepView.swift'] = '''
import SwiftUI

struct ProjectSetupStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(title: "Project setup", subtitle: "Define the app or design target that Claude Code will help build.") {
            VStack(alignment: .leading, spacing: 18) {
                TextField("Project name", text: $viewModel.projectName)
                    .textFieldStyle(.roundedBorder)
                TextField("One-paragraph product summary", text: $viewModel.productSummary, axis: .vertical)
                    .lineLimit(4, reservesSpace: true)
                    .textFieldStyle(.roundedBorder)

                Picker("Target being designed", selection: $viewModel.targetPlatform) {
                    ForEach(TargetPlatform.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
'''
files['Views/StandardsStepView.swift'] = '''
import SwiftUI

struct StandardsStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(title: "Base standards", subtitle: "These options shape the default best-practice section inside Claude.md.") {
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Include architecture guidance", isOn: $viewModel.includeArchitectureRules)
                Toggle("Include testing expectations", isOn: $viewModel.includeTestingRules)
                Toggle("Include accessibility standards", isOn: $viewModel.includeAccessibilityRules)
                Toggle("Include performance guidance", isOn: $viewModel.includePerformanceRules)
            }
            .toggleStyle(.switch)

            InfoCard(title: "Result", symbol: "text.document") {
                Text("The exported Claude.md will include coding, planning, and Apple-platform behavior rules tailored to these switches.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
'''
files['Views/RulesStepView.swift'] = '''
import SwiftUI

struct RulesStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(title: "Trigger phrases and expansion files", subtitle: "Store reusable prompts that tell Claude how to behave in specific situations.") {
            VStack(alignment: .leading, spacing: 14) {
                ForEach($viewModel.triggerRules) { $rule in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Trigger phrase", text: $rule.phrase)
                            .textFieldStyle(.roundedBorder)
                        TextField("Instruction", text: $rule.instruction, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(14)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }

                Button {
                    viewModel.triggerRules.append(TriggerRule(phrase: "When I say sprint plan", instruction: "Create a scoped implementation plan with milestones, risks, and acceptance criteria."))
                } label: {
                    Label("Add trigger phrase", systemImage: "plus")
                }
            }
        }
    }
}
'''
files['Views/ThemeStepView.swift'] = '''
import SwiftUI

struct ThemeStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    let columns = [GridItem(.adaptive(minimum: 220, maximum: 280), spacing: 16)]

    var body: some View {
        StepContainer(title: "Theme preset", subtitle: "Choose the design language the app should translate into UI guidance and image prompt files.") {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(ThemePreset.allCases) { preset in
                    Button {
                        viewModel.selectedTheme = preset
                    } label: {
                        VStack(alignment: .leading, spacing: 14) {
                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(gradient(for: preset))
                                    .frame(height: 150)
                                Text(preset.rawValue)
                                    .font(.headline)
                                    .padding(12)
                            }
                            Text(preset.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(viewModel.selectedTheme == preset ? Color.accentColor : Color.white.opacity(0.08), lineWidth: viewModel.selectedTheme == preset ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            InfoCard(title: "Export behavior", symbol: "wand.and.stars") {
                Text("The selected preset changes the UI direction file and the mockup/image prompt file so Claude has a concrete visual target.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func gradient(for preset: ThemePreset) -> LinearGradient {
        switch preset {
        case .macNative:
            return LinearGradient(colors: [.gray.opacity(0.7), .blue.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .iosElegant:
            return LinearGradient(colors: [.pink.opacity(0.7), .orange.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ipadProductive:
            return LinearGradient(colors: [.mint.opacity(0.7), .cyan.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .glassFocus:
            return LinearGradient(colors: [.white.opacity(0.7), .blue.opacity(0.28), .purple.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
'''
files['Views/RepoStepView.swift'] = '''
import SwiftUI

struct RepoStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(title: "GitHub repository setup", subtitle: "Prepare clone commands and Claude prompts for repo-aware work.") {
            VStack(alignment: .leading, spacing: 18) {
                TextField("GitHub owner", text: $viewModel.repoOwner)
                    .textFieldStyle(.roundedBorder)
                TextField("Repository name", text: $viewModel.repoName)
                    .textFieldStyle(.roundedBorder)
                TextField("SSH key or PAT hint", text: $viewModel.repoKeyHint)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 18) {
                    InfoCard(title: "HTTPS clone", symbol: "link") {
                        Text("git clone https://github.com/\(viewModel.repoOwner)/\(viewModel.repoName).git\ncd \(viewModel.repoName)")
                            .textSelection(.enabled)
                            .font(.system(.body, design: .monospaced))
                    }
                    InfoCard(title: "SSH clone", symbol: "lock.shield") {
                        Text("git clone git@github.com:\(viewModel.repoOwner)/\(viewModel.repoName).git\ncd \(viewModel.repoName)")
                            .textSelection(.enabled)
                            .font(.system(.body, design: .monospaced))
                    }
                }

                InfoCard(title: "Claude prompt", symbol: "ellipsis.bubble") {
                    Text("Tell Claude to read Claude.md plus planning/, prompts/, ui/, and repo/ before changing code.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
'''
files['Views/ReviewExportStepView.swift'] = '''
import SwiftUI
import AppKit

struct ReviewExportStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var exportMessage = ""

    var body: some View {
        StepContainer(title: "Review and export", subtitle: "Generate the text files and write them into a destination folder, ideally inside your cloned repo.") {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Button("Generate preview") {
                        viewModel.regenerateFiles()
                    }
                    .buttonStyle(.bordered)

                    Button("Export to folder") {
                        viewModel.regenerateFiles()
                        do {
                            if let url = try ExportService().export(files: viewModel.generatedFiles) {
                                exportMessage = "Exported to \(url.path)"
                                NSWorkspace.shared.activateFileViewerSelecting([url])
                            }
                        } catch {
                            exportMessage = "Export failed: \(error.localizedDescription)"
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                if !exportMessage.isEmpty {
                    Text(exportMessage)
                        .foregroundStyle(.secondary)
                }

                List(viewModel.generatedFiles.isEmpty ? TemplateService().buildFiles(from: viewModel) : viewModel.generatedFiles) { file in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(file.relativePath)
                            .font(.headline)
                        Text(file.content.prefix(160) + (file.content.count > 160 ? "…" : ""))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .frame(minHeight: 300)
            }
        }
        .onAppear {
            if viewModel.generatedFiles.isEmpty {
                viewModel.regenerateFiles()
            }
        }
    }
}
'''
files['README.md'] = '''
# ClaudeForgeDesigner

ClaudeForgeDesigner is a starter macOS SwiftUI app that helps a developer generate `Claude.md` and related repo guidance files for Claude Code projects.

## What the app does
- Builds a base `Claude.md` with coding, planning, and Apple-platform best practices.
- Lets the user add reusable trigger phrases and supporting prompt files.
- Creates Apple UI direction text and image prompt files based on a chosen design preset.
- Provides copy/paste-ready GitHub clone commands for HTTPS and SSH.
- Exports all generated files into a selected folder, intended for a cloned GitHub repository.

## Open in Xcode
1. Open `ClaudeForgeDesigner.xcodeproj`.
2. Choose the `ClaudeForgeDesigner` scheme.
3. Run on `My Mac`.

## Suggested next improvements
- Add template packs stored as editable bundled resources.
- Add image asset export and live preview thumbnails.
- Support loading an existing repo folder and diffing generated files.
- Add settings for multiple Claude.md variants by project type.
'''

for rel, content in files.items():
    path = app/rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(textwrap.dedent(content).strip()+"\n")

# Create simple preview pngs using Pillow if available; otherwise skip.
try:
    from PIL import Image, ImageDraw, ImageFont
    previews = {
        'theme-mac-native.png': ('Mac Native', (120,130,150)),
        'theme-ios-elegant.png': ('iPhone Elegant', (190,120,145)),
        'theme-ipad-productive.png': ('iPad Productive', (90,165,160)),
        'theme-glass-focus.png': ('Liquid Glass Focus', (150,170,210)),
    }
    for name, (label, rgb) in previews.items():
        img = Image.new('RGB', (900, 560), color=(245,245,248))
        dr = ImageDraw.Draw(img)
        dr.rounded_rectangle((50,40,850,520), radius=32, fill=(255,255,255), outline=(220,220,230), width=2)
        dr.rounded_rectangle((80,70,280,490), radius=24, fill=tuple(max(0,c-20) for c in rgb))
        dr.rounded_rectangle((310,70,820,160), radius=24, fill=tuple(min(255,c+35) for c in rgb))
        dr.rounded_rectangle((310,190,820,490), radius=24, fill=tuple(min(255,c+60) for c in rgb))
        dr.text((105,95), 'Sidebar', fill=(255,255,255))
        dr.text((340,95), label, fill=(40,40,50))
        dr.text((340,220), 'Content area / mock preview', fill=(60,60,70))
        img.save(app/'Resources'/'PreviewThemes'/name)
except Exception as e:
    print('Preview image generation skipped', e)

# xcode project
proj = root/'ClaudeForgeDesigner.xcodeproj'
(proj/'project.xcworkspace').mkdir(parents=True, exist_ok=True)
(proj/'project.xcworkspace'/'contents.xcworkspacedata').write_text('''<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
''')
(proj/'xcshareddata'/'xcschemes').mkdir(parents=True, exist_ok=True)
(proj/'xcshareddata'/'xcschemes'/'ClaudeForgeDesigner.xcscheme').write_text('''<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "B00000000000000000000020"
               BuildableName = "ClaudeForgeDesigner.app"
               BlueprintName = "ClaudeForgeDesigner"
               ReferencedContainer = "container:ClaudeForgeDesigner.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "B00000000000000000000020"
            BuildableName = "ClaudeForgeDesigner.app"
            BlueprintName = "ClaudeForgeDesigner"
            ReferencedContainer = "container:ClaudeForgeDesigner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "B00000000000000000000020"
            BuildableName = "ClaudeForgeDesigner.app"
            BlueprintName = "ClaudeForgeDesigner"
            ReferencedContainer = "container:ClaudeForgeDesigner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
''')

pbx = r'''
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
	B00000000000000000000100 /* ClaudeForgeDesignerApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000030 /* ClaudeForgeDesignerApp.swift */; };
	B00000000000000000000101 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000031 /* ContentView.swift */; };
	B00000000000000000000102 /* WizardModels.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000032 /* WizardModels.swift */; };
	B00000000000000000000103 /* ViewModels.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000033 /* ViewModels.swift */; };
	B00000000000000000000104 /* TemplateService.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000034 /* TemplateService.swift */; };
	B00000000000000000000105 /* ExportService.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000035 /* ExportService.swift */; };
	B00000000000000000000106 /* SharedViews.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000036 /* SharedViews.swift */; };
	B00000000000000000000107 /* SidebarView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000037 /* SidebarView.swift */; };
	B00000000000000000000108 /* OverviewStepView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000038 /* OverviewStepView.swift */; };
	B00000000000000000000109 /* ProjectSetupStepView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000039 /* ProjectSetupStepView.swift */; };
	B00000000000000000000110 /* StandardsStepView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000040 /* StandardsStepView.swift */; };
	B00000000000000000000111 /* RulesStepView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000041 /* RulesStepView.swift */; };
	B00000000000000000000112 /* ThemeStepView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000042 /* ThemeStepView.swift */; };
	B00000000000000000000113 /* RepoStepView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000043 /* RepoStepView.swift */; };
	B00000000000000000000114 /* ReviewExportStepView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000044 /* ReviewExportStepView.swift */; };
	B00000000000000000000115 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000045 /* Assets.xcassets */; };
	B00000000000000000000116 /* PreviewThemes in Resources */ = {isa = PBXBuildFile; fileRef = B00000000000000000000046 /* PreviewThemes */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
	B00000000000000000000020 /* ClaudeForgeDesigner.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = ClaudeForgeDesigner.app; sourceTree = BUILT_PRODUCTS_DIR; };
	B00000000000000000000030 /* ClaudeForgeDesignerApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ClaudeForgeDesignerApp.swift; sourceTree = "<group>"; };
	B00000000000000000000031 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
	B00000000000000000000032 /* WizardModels.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = WizardModels.swift; sourceTree = "<group>"; };
	B00000000000000000000033 /* ViewModels.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ViewModels.swift; sourceTree = "<group>"; };
	B00000000000000000000034 /* TemplateService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TemplateService.swift; sourceTree = "<group>"; };
	B00000000000000000000035 /* ExportService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ExportService.swift; sourceTree = "<group>"; };
	B00000000000000000000036 /* SharedViews.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SharedViews.swift; sourceTree = "<group>"; };
	B00000000000000000000037 /* SidebarView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SidebarView.swift; sourceTree = "<group>"; };
	B00000000000000000000038 /* OverviewStepView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = OverviewStepView.swift; sourceTree = "<group>"; };
	B00000000000000000000039 /* ProjectSetupStepView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProjectSetupStepView.swift; sourceTree = "<group>"; };
	B00000000000000000000040 /* StandardsStepView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StandardsStepView.swift; sourceTree = "<group>"; };
	B00000000000000000000041 /* RulesStepView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = RulesStepView.swift; sourceTree = "<group>"; };
	B00000000000000000000042 /* ThemeStepView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ThemeStepView.swift; sourceTree = "<group>"; };
	B00000000000000000000043 /* RepoStepView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = RepoStepView.swift; sourceTree = "<group>"; };
	B00000000000000000000044 /* ReviewExportStepView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ReviewExportStepView.swift; sourceTree = "<group>"; };
	B00000000000000000000045 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Resources/Assets.xcassets; sourceTree = "<group>"; };
	B00000000000000000000046 /* PreviewThemes */ = {isa = PBXFileReference; lastKnownFileType = folder; path = Resources/PreviewThemes; sourceTree = "<group>"; };
	B00000000000000000000047 /* README.md */ = {isa = PBXFileReference; lastKnownFileType = net.daringfireball.markdown; path = README.md; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
	B00000000000000000000070 /* Frameworks */ = {
		isa = PBXFrameworksBuildPhase;
		buildActionMask = 2147483647;
		files = (
		);
		runOnlyForDeploymentPostprocessing = 0;
	};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
	B00000000000000000000001 = {
		isa = PBXGroup;
		children = (
			B00000000000000000000010 /* ClaudeForgeDesigner */,
			B00000000000000000000011 /* Products */,
		);
		sourceTree = "<group>";
	};
	B00000000000000000000010 /* ClaudeForgeDesigner */ = {
		isa = PBXGroup;
		children = (
			B00000000000000000000030 /* ClaudeForgeDesignerApp.swift */,
			B00000000000000000000031 /* ContentView.swift */,
			B00000000000000000000050 /* Models */,
			B00000000000000000000051 /* Services */,
			B00000000000000000000052 /* Views */,
			B00000000000000000000053 /* Resources */,
			B00000000000000000000047 /* README.md */,
		);
		path = ClaudeForgeDesigner;
		sourceTree = SOURCE_ROOT;
	};
	B00000000000000000000011 /* Products */ = {
		isa = PBXGroup;
		children = (
			B00000000000000000000020 /* ClaudeForgeDesigner.app */,
		);
		name = Products;
		sourceTree = "<group>";
	};
	B00000000000000000000050 /* Models */ = {
		isa = PBXGroup;
		children = (
			B00000000000000000000032 /* WizardModels.swift */,
		);
		path = Models;
		sourceTree = "<group>";
	};
	B00000000000000000000051 /* Services */ = {
		isa = PBXGroup;
		children = (
			B00000000000000000000034 /* TemplateService.swift */,
			B00000000000000000000035 /* ExportService.swift */,
		);
		path = Services;
		sourceTree = "<group>";
	};
	B00000000000000000000052 /* Views */ = {
		isa = PBXGroup;
		children = (
			B00000000000000000000036 /* SharedViews.swift */,
			B00000000000000000000037 /* SidebarView.swift */,
			B00000000000000000000038 /* OverviewStepView.swift */,
			B00000000000000000000039 /* ProjectSetupStepView.swift */,
			B00000000000000000000040 /* StandardsStepView.swift */,
			B00000000000000000000041 /* RulesStepView.swift */,
			B00000000000000000000042 /* ThemeStepView.swift */,
			B00000000000000000000043 /* RepoStepView.swift */,
			B00000000000000000000044 /* ReviewExportStepView.swift */,
		);
		path = Views;
		sourceTree = "<group>";
	};
	B00000000000000000000053 /* Resources */ = {
		isa = PBXGroup;
		children = (
			B00000000000000000000045 /* Assets.xcassets */,
			B00000000000000000000046 /* PreviewThemes */,
		);
		path = Resources;
		sourceTree = "<group>";
	};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
	B00000000000000000000021 /* ClaudeForgeDesigner */ = {
		isa = PBXNativeTarget;
		buildConfigurationList = B00000000000000000000081 /* Build configuration list for PBXNativeTarget "ClaudeForgeDesigner" */;
		buildPhases = (
			B00000000000000000000060 /* Sources */,
			B00000000000000000000070 /* Frameworks */,
			B00000000000000000000061 /* Resources */,
		);
		buildRules = (
		);
		dependencies = (
		);
		name = ClaudeForgeDesigner;
		productName = ClaudeForgeDesigner;
		productReference = B00000000000000000000020 /* ClaudeForgeDesigner.app */;
		productType = "com.apple.product-type.application";
	};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
	B00000000000000000000000 /* Project object */ = {
		isa = PBXProject;
		attributes = {
			BuildIndependentTargetsInParallel = 1;
			LastSwiftUpdateCheck = 1600;
			LastUpgradeCheck = 1600;
			TargetAttributes = {
				B00000000000000000000021 = {
					CreatedOnToolsVersion = 16.0;
				};
			};
		};
		buildConfigurationList = B00000000000000000000080 /* Build configuration list for PBXProject "ClaudeForgeDesigner" */;
		compatibilityVersion = "Xcode 14.0";
		developmentRegion = en;
		hasScannedForEncodings = 0;
		knownRegions = (
			en,
			Base,
		);
		mainGroup = B00000000000000000000001;
		productRefGroup = B00000000000000000000011 /* Products */;
		projectDirPath = "";
		projectRoot = "";
		targets = (
			B00000000000000000000021 /* ClaudeForgeDesigner */,
		);
	};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
	B00000000000000000000061 /* Resources */ = {
		isa = PBXResourcesBuildPhase;
		buildActionMask = 2147483647;
		files = (
			B00000000000000000000115 /* Assets.xcassets in Resources */,
			B00000000000000000000116 /* PreviewThemes in Resources */,
		);
		runOnlyForDeploymentPostprocessing = 0;
	};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
	B00000000000000000000060 /* Sources */ = {
		isa = PBXSourcesBuildPhase;
		buildActionMask = 2147483647;
		files = (
			B00000000000000000000100 /* ClaudeForgeDesignerApp.swift in Sources */,
			B00000000000000000000101 /* ContentView.swift in Sources */,
			B00000000000000000000102 /* WizardModels.swift in Sources */,
			B00000000000000000000103 /* ViewModels.swift in Sources */,
			B00000000000000000000104 /* TemplateService.swift in Sources */,
			B00000000000000000000105 /* ExportService.swift in Sources */,
			B00000000000000000000106 /* SharedViews.swift in Sources */,
			B00000000000000000000107 /* SidebarView.swift in Sources */,
			B00000000000000000000108 /* OverviewStepView.swift in Sources */,
			B00000000000000000000109 /* ProjectSetupStepView.swift in Sources */,
			B00000000000000000000110 /* StandardsStepView.swift in Sources */,
			B00000000000000000000111 /* RulesStepView.swift in Sources */,
			B00000000000000000000112 /* ThemeStepView.swift in Sources */,
			B00000000000000000000113 /* RepoStepView.swift in Sources */,
			B00000000000000000000114 /* ReviewExportStepView.swift in Sources */,
		);
		runOnlyForDeploymentPostprocessing = 0;
	};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
	B00000000000000000000090 /* Debug */ = {
		isa = XCBuildConfiguration;
		buildSettings = {
			ALWAYS_SEARCH_USER_PATHS = NO;
			CLANG_ENABLE_MODULES = YES;
			CLANG_ENABLE_OBJC_ARC = YES;
			COPY_PHASE_STRIP = NO;
			DEBUG_INFORMATION_FORMAT = dwarf;
			ENABLE_STRICT_OBJC_MSGSEND = YES;
			ENABLE_TESTABILITY = YES;
			GCC_C_LANGUAGE_STANDARD = gnu17;
			GCC_NO_COMMON_BLOCKS = YES;
			GCC_OPTIMIZATION_LEVEL = 0;
			MACOSX_DEPLOYMENT_TARGET = 14.0;
			SDKROOT = macosx;
			SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
			SWIFT_OPTIMIZATION_LEVEL = "-Onone";
		};
		name = Debug;
	};
	B00000000000000000000091 /* Release */ = {
		isa = XCBuildConfiguration;
		buildSettings = {
			ALWAYS_SEARCH_USER_PATHS = NO;
			CLANG_ENABLE_MODULES = YES;
			CLANG_ENABLE_OBJC_ARC = YES;
			COPY_PHASE_STRIP = NO;
			DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
			ENABLE_NS_ASSERTIONS = NO;
			ENABLE_STRICT_OBJC_MSGSEND = YES;
			GCC_C_LANGUAGE_STANDARD = gnu17;
			GCC_NO_COMMON_BLOCKS = YES;
			MACOSX_DEPLOYMENT_TARGET = 14.0;
			SDKROOT = macosx;
			SWIFT_COMPILATION_MODE = wholemodule;
			SWIFT_OPTIMIZATION_LEVEL = "-O";
		};
		name = Release;
	};
	B00000000000000000000092 /* Debug */ = {
		isa = XCBuildConfiguration;
		buildSettings = {
			ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
			CODE_SIGN_STYLE = Automatic;
			CURRENT_PROJECT_VERSION = 1;
			DEVELOPMENT_TEAM = "";
			ENABLE_HARDENED_RUNTIME = YES;
			GENERATE_INFOPLIST_FILE = YES;
			INFOPLIST_KEY_CFBundleDisplayName = ClaudeForgeDesigner;
			INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.developer-tools";
			INFOPLIST_KEY_NSHumanReadableCopyright = "";
			LD_RUNPATH_SEARCH_PATHS = "@executable_path/../Frameworks";
			MARKETING_VERSION = 0.1;
			PRODUCT_BUNDLE_IDENTIFIER = com.example.ClaudeForgeDesigner;
			PRODUCT_NAME = "$(TARGET_NAME)";
			REGISTER_APP_GROUPS = NO;
			SWIFT_EMIT_LOC_STRINGS = YES;
			SWIFT_VERSION = 5.0;
		};
		name = Debug;
	};
	B00000000000000000000093 /* Release */ = {
		isa = XCBuildConfiguration;
		buildSettings = {
			ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
			CODE_SIGN_STYLE = Automatic;
			CURRENT_PROJECT_VERSION = 1;
			DEVELOPMENT_TEAM = "";
			ENABLE_HARDENED_RUNTIME = YES;
			GENERATE_INFOPLIST_FILE = YES;
			INFOPLIST_KEY_CFBundleDisplayName = ClaudeForgeDesigner;
			INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.developer-tools";
			LD_RUNPATH_SEARCH_PATHS = "@executable_path/../Frameworks";
			MARKETING_VERSION = 0.1;
			PRODUCT_BUNDLE_IDENTIFIER = com.example.ClaudeForgeDesigner;
			PRODUCT_NAME = "$(TARGET_NAME)";
			REGISTER_APP_GROUPS = NO;
			SWIFT_EMIT_LOC_STRINGS = YES;
			SWIFT_VERSION = 5.0;
		};
		name = Release;
	};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
	B00000000000000000000080 /* Build configuration list for PBXProject "ClaudeForgeDesigner" */ = {
		isa = XCConfigurationList;
		buildConfigurations = (
			B00000000000000000000090 /* Debug */,
			B00000000000000000000091 /* Release */,
		);
		defaultConfigurationIsVisible = 0;
		defaultConfigurationName = Release;
	};
	B00000000000000000000081 /* Build configuration list for PBXNativeTarget "ClaudeForgeDesigner" */ = {
		isa = XCConfigurationList;
		buildConfigurations = (
			B00000000000000000000092 /* Debug */,
			B00000000000000000000093 /* Release */,
		);
		defaultConfigurationIsVisible = 0;
		defaultConfigurationName = Release;
	};
/* End XCConfigurationList section */
	};
	rootObject = B00000000000000000000000 /* Project object */;
}
'''
(proj/'project.pbxproj').write_text(pbx)
print('done')
