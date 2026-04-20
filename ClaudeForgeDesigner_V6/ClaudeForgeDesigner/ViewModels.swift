import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers

final class WizardViewModel: ObservableObject {
    @Published var currentStep: WizardStep = .overview

    @Published var projectName = "ClaudeForge Project"
    @Published var productSummary = "A Mac-based design and planning studio that generates Claude Code guidance, design examples, screenshots and image references, and repo setup files for Apple software projects."
    @Published var selectedPlatforms: Set<TargetPlatform> = [.macOS]
    @Published var themePreset: ThemePreset = .glassProductivity
    @Published var projectGoals = "Define a polished version 1, keep architecture maintainable, and produce an instruction system Claude can follow with confidence."
    @Published var keyFeatures = "Document generation, prompt packs, design examples, screenshots and images, repo setup help, and a review-and-edit workflow."
    @Published var targetAudience = "Solo founders, indie developers, designers, and technical product builders using Claude Code."
    @Published var complexityLevel: ComplexityLevel = .focusedV1
    @Published var polishLevel: PolishLevel = .refined
    @Published var developmentPace = "Fast, but with a clear plan before changes."

    @Published var repoName = "my-app-repo"
    @Published var repoOwner = "your-github-name"
    @Published var localProjectFolderName = "MyClaudeProject"
    @Published var repoKeyHint = "Fine-grained personal access token or SSH key"
    @Published var useSSH = true
    @Published var useHTTPS = true
    @Published var includeRepoCreationGuide = true
    @Published var includeFloatingSetupHelper = true
    @Published var createRepoViaAPI = false
    @Published var showingSSHHelper = false

    @Published var includeAccessibilityRules = true
    @Published var includePerformanceRules = true
    @Published var includeDocumentationRules = true
    @Published var includeGitWorkflowRules = true
    @Published var includeLocalizationReadiness = false
    @Published var includeAnalyticsReadiness = false
    @Published var includeSecurityReview = false
    @Published var includeCIReadiness = false
    @Published var includeAppStoreReadiness = false
    @Published var customStandards: [CustomStandard] = [
        CustomStandard(title: "Dependency discipline", rule: "Do not add third-party dependencies without stating why the native platform APIs are insufficient."),
        CustomStandard(title: "Architecture fit", rule: "Keep feature boundaries and file organization understandable to a future human maintainer.")
    ]

    @Published var navigationStyle: NavigationStyle = .sidebar
    @Published var controlStyle: ControlStyle = .softGlass
    @Published var typographyStyle: TypographyStyle = .systemBalanced
    @Published var colorPalette: ColorPalette = .blueSlate
    @Published var surfaceStyle: SurfaceStyle = .layeredGlass
    @Published var moodStyle: MoodStyle = .premium
    @Published var densityStyle: DensityStyle = .balanced
    @Published var menuChromeStyle: MenuChromeStyle = .floating
    @Published var animationStyle: AnimationStyle = .premium
    @Published var includeInspector = true
    @Published var includeSearch = true
    @Published var includeCommandPalettePrompt = true

    @Published var importedScreenshots: [ImportedScreenshot] = []
    @Published var screenshotUsageNotes = "Add screenshots or images of bugs, inspiration apps, layouts, components, or visual ideas. The exported prompts will reference these files so Claude can reason from them."

    @Published var generatedFiles: [GeneratedFile] = []
    @Published var selectedGeneratedFilePath: String?
    @Published var exportedTo: URL?
    @Published var exportStatusMessage = ""

    @Published var triggerRules: [TriggerRule] = [
        TriggerRule(phrase: "When I say plan mode", instruction: "Do not edit code yet. Summarize the task, inspect the existing structure, propose a step-by-step plan, and define acceptance criteria.", example: "Plan mode: add onboarding for first-time users."),
        TriggerRule(phrase: "When I say design pass", instruction: "Audit the interface for native Apple layout, typography, spacing, controls, accessibility, and state coverage before changing code.", example: "Design pass: review the current settings window."),
        TriggerRule(phrase: "When I say ship-ready", instruction: "Produce a release-readiness checklist covering tests, regressions, edge cases, accessibility, polishing, and distribution concerns.", example: "Ship-ready: evaluate the macOS utility app."),
        TriggerRule(phrase: "When I say low-risk refactor", instruction: "Prioritize maintainability improvements with minimal public API disruption and document the verification plan before editing.", example: "Low-risk refactor: simplify the view model layer."),
        TriggerRule(phrase: "When I say prompt pack", instruction: "Create a reusable prompt set for the requested task type, with steps, constraints, and expected output format.", example: "Prompt pack: bug triage for SwiftUI layout issues."),
        TriggerRule(phrase: "When I say screen blueprint", instruction: "Describe the screen structure, hierarchy, interactions, states, and component inventory before generating code.", example: "Screen blueprint: iPad project overview screen."),
        TriggerRule(phrase: "When I say test pass", instruction: "Identify what to test, where tests belong, and the minimum verification needed before merging.", example: "Test pass: recent async loading changes."),
        TriggerRule(phrase: "When I say repo ready", instruction: "Check that repo instructions, paths, setup commands, and generated guidance all match the actual folder structure.", example: "Repo ready: verify the exported pack before commit.")
    ]

    let steps: [WizardStepItem] = [
        .init(id: .overview, title: "Overview", subtitle: "What this project pack creates", symbol: "sparkles.rectangle.stack"),
        .init(id: .project, title: "Project Brief", subtitle: "Goals, audience, platforms, and version 1 scope", symbol: "square.and.pencil"),
        .init(id: .standards, title: "Standards", subtitle: "Core defaults, advanced rules, and custom standards", symbol: "checkmark.shield"),
        .init(id: .rules, title: "Trigger Phrases", subtitle: "Reusable Claude task modes and command helpers", symbol: "text.badge.star"),
        .init(id: .designStudio, title: "Design Studio", subtitle: "Visual language, previews, and theme direction", symbol: "paintpalette"),
        .init(id: .screenshots, title: "Screenshots & Images", subtitle: "Visual references for bugs, ideas, and inspiration", symbol: "photo.on.rectangle"),
        .init(id: .repo, title: "Repository", subtitle: "Clone flows, repo setup, and helper guidance", symbol: "point.3.connected.trianglepath.dotted"),
        .init(id: .review, title: "Review & Edit", subtitle: "Inspect and edit every generated file before export", symbol: "doc.text.magnifyingglass")
    ]

    var completionFraction: Double {
        let index = steps.firstIndex(where: { $0.id == currentStep }) ?? 0
        return Double(index + 1) / Double(steps.count)
    }

    var exportRootFolderName: String {
        let sanitized = projectName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        return sanitized.isEmpty ? "ClaudeForge-Pack" : sanitized
    }

    var selectedPlatformNames: [String] {
        TargetPlatform.allCases.filter { selectedPlatforms.contains($0) }.map(\.rawValue)
    }

    var selectedPlatformsDescription: String {
        let names = selectedPlatformNames
        if names.isEmpty { return "No platform selected" }
        return names.joined(separator: ", ")
    }

    var enabledCloneFlowsDescription: String {
        switch (useHTTPS, useSSH) {
        case (true, true): return "HTTPS and SSH"
        case (true, false): return "HTTPS only"
        case (false, true): return "SSH only"
        case (false, false): return "SSH and HTTPS are both disabled. Enable at least one before export."
        }
    }

    var generatedFileLookup: [String: GeneratedFile] {
        Dictionary(uniqueKeysWithValues: generatedFiles.map { ($0.relativePath, $0) })
    }

    var selectedGeneratedFileIndex: Int? {
        guard let selectedGeneratedFilePath else { return nil }
        return generatedFiles.firstIndex(where: { $0.relativePath == selectedGeneratedFilePath })
    }

    var selectedGeneratedFile: GeneratedFile? {
        guard let selectedGeneratedFilePath else { return nil }
        return generatedFiles.first(where: { $0.relativePath == selectedGeneratedFilePath })
    }

    func next() {
        guard let index = steps.firstIndex(where: { $0.id == currentStep }), index + 1 < steps.count else { return }
        currentStep = steps[index + 1].id
    }

    func previous() {
        guard let index = steps.firstIndex(where: { $0.id == currentStep }), index > 0 else { return }
        currentStep = steps[index - 1].id
    }

    func togglePlatform(_ platform: TargetPlatform) {
        if selectedPlatforms.contains(platform) {
            if selectedPlatforms.count > 1 {
                selectedPlatforms.remove(platform)
            }
        } else {
            selectedPlatforms.insert(platform)
        }
        regenerateFiles()
    }

    func regenerateFiles() {
        let built = TemplateService().buildFiles(from: self)
        if generatedFiles.isEmpty {
            generatedFiles = built
        } else {
            let previous = generatedFileLookup
            generatedFiles = built.map { file in
                if let existing = previous[file.relativePath] {
                    return GeneratedFile(relativePath: file.relativePath, content: existing.content, purpose: file.purpose)
                }
                return file
            }
        }

        if selectedGeneratedFilePath == nil {
            selectedGeneratedFilePath = generatedFiles.first?.relativePath
        } else if let selectedGeneratedFilePath, !generatedFiles.contains(where: { $0.relativePath == selectedGeneratedFilePath }) {
            self.selectedGeneratedFilePath = generatedFiles.first?.relativePath
        }
    }

    func updateGeneratedFileContent(_ newContent: String) {
        guard let index = selectedGeneratedFileIndex else { return }
        generatedFiles[index].content = newContent
    }

    func selectGeneratedFile(path: String) {
        selectedGeneratedFilePath = path
    }

    func displayTitle(for file: GeneratedFile) -> String {
        let name = URL(fileURLWithPath: file.relativePath).deletingPathExtension().lastPathComponent
        return name
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    func addTriggerRule() {
        triggerRules.append(TriggerRule(phrase: "When I say ...", instruction: "Describe the specialized behavior Claude should apply.", example: "Example: ask Claude to ..."))
    }

    func addSuggestedTriggers() {
        let suggestions: [TriggerRule] = [
            TriggerRule(phrase: "When I say architecture audit", instruction: "Review the current architecture, risks, abstractions, and module boundaries before proposing changes.", example: "Architecture audit: assess the services layer."),
            TriggerRule(phrase: "When I say UI clone", instruction: "Use screenshots and design examples to recreate the requested feel with native Apple components, not a literal pixel copy.", example: "UI clone: recreate the sidebar from screenshots/reference.png."),
            TriggerRule(phrase: "When I say acceptance criteria", instruction: "Write explicit acceptance criteria before implementation and separate must-haves from nice-to-haves.", example: "Acceptance criteria: new export flow."),
            TriggerRule(phrase: "When I say command helper", instruction: "Generate exact terminal commands and explain what each one does in order.", example: "Command helper: create a repo and commit the initial pack."),
            TriggerRule(phrase: "When I say animation pass", instruction: "Describe motion intent, timing, and how transitions support understanding rather than decoration.", example: "Animation pass: refine the onboarding flow."),
            TriggerRule(phrase: "When I say issue from screenshot", instruction: "Study the referenced screenshot, identify likely layout or state issues, and explain the safest native fix.", example: "Issue from screenshot: review screenshots/sidebar-bug.png."),
            TriggerRule(phrase: "When I say terminal help", instruction: "Explain the next shell commands one line at a time, including where the user should run them.", example: "Terminal help: clone the repo and open the project."),
            TriggerRule(phrase: "When I say platform fit", instruction: "Explain how the feature should differ across Mac, iPhone, and iPad while keeping the product coherent.", example: "Platform fit: settings and onboarding flow.")
        ]
        for suggestion in suggestions where !triggerRules.contains(where: { $0.phrase == suggestion.phrase }) {
            triggerRules.append(suggestion)
        }
    }

    func removeTriggerRules(at offsets: IndexSet) {
        triggerRules.remove(atOffsets: offsets)
    }

    func addCustomStandard() {
        customStandards.append(CustomStandard(title: "New standard", rule: "Describe the additional engineering expectation Claude should follow."))
    }

    func removeCustomStandard(at offsets: IndexSet) {
        customStandards.remove(atOffsets: offsets)
    }

    func importScreenshots() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.png, .jpeg, .gif, .tiff, .pdf]
        panel.message = "Choose screenshots or other visual references to copy into the exported screenshots folder."

        guard panel.runModal() == .OK else { return }

        let newItems = panel.urls.map { ImportedScreenshot(sourceURL: $0, note: "Reference image for issue analysis, redesign, or inspiration.") }
        importedScreenshots.append(contentsOf: newItems)
    }

    func removeScreenshot(_ screenshot: ImportedScreenshot) {
        importedScreenshots.removeAll { $0.id == screenshot.id }
    }

    func exportPack() {
        if generatedFiles.isEmpty {
            regenerateFiles()
        }
        do {
            let destination = try ExportService().export(
                rootFolderName: exportRootFolderName,
                files: generatedFiles,
                requiredFolders: [
                    "\(exportRootFolderName)/screenshots",
                    "\(exportRootFolderName)/design-examples",
                    "\(exportRootFolderName)/planning",
                    "\(exportRootFolderName)/prompts",
                    "\(exportRootFolderName)/repo"
                ],
                screenshots: importedScreenshots
            )
            exportedTo = destination
            if let destination {
                exportStatusMessage = "Exported pack to \(destination.path)"
            } else {
                exportStatusMessage = "Export cancelled."
            }
        } catch {
            exportStatusMessage = "Export failed: \(error.localizedDescription)"
        }
    }
}
