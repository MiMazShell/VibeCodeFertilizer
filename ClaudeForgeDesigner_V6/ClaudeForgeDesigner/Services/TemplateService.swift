import Foundation

struct TemplateService {
    func buildFiles(from vm: WizardViewModel) -> [GeneratedFile] {
        let root = vm.exportRootFolderName

        return [
            GeneratedFile(relativePath: "\(root)/ProjectOverview 1.txt", content: projectOverview(vm: vm), purpose: "A high-level summary of the product direction, planned improvements, and what this project pack is intended to generate."),
            GeneratedFile(relativePath: "\(root)/CLAUDE.md", content: baseClaude(vm: vm), purpose: "The main repository instruction file Claude Code should read first before making plans or edits."),
            GeneratedFile(relativePath: "\(root)/planning/project-brief.txt", content: projectBrief(vm: vm), purpose: "The core product brief: goals, audience, version 1 scope, platform mix, and success criteria."),
            GeneratedFile(relativePath: "\(root)/planning/architecture-guidelines.txt", content: architectureGuidelines(vm: vm), purpose: "Architecture boundaries, code organization expectations, and how the project should scale safely."),
            GeneratedFile(relativePath: "\(root)/planning/acceptance-criteria.txt", content: acceptanceCriteria(vm: vm), purpose: "A practical checklist Claude can use before calling work complete."),
            GeneratedFile(relativePath: "\(root)/prompts/trigger-phrases.txt", content: triggerRules(vm: vm), purpose: "A library of reusable trigger phrases, what they mean, examples of how to use them with Claude, and companion terminal helpers."),
            GeneratedFile(relativePath: "\(root)/prompts/task-templates.txt", content: taskTemplates(vm: vm), purpose: "Reusable prompt templates for planning, implementation, design, debugging, and repo setup tasks."),
            GeneratedFile(relativePath: "\(root)/prompts/claude-repo-access.txt", content: claudeRepoPrompt(vm: vm), purpose: "Starter prompts for opening the repo with Claude Code and giving it the right context on day one."),
            GeneratedFile(relativePath: "\(root)/design-examples/theme-definition.txt", content: themeDefinition(vm: vm), purpose: "The selected design direction in plain language so Claude understands the desired visual feel."),
            GeneratedFile(relativePath: "\(root)/design-examples/ui-rules.txt", content: uiRules(vm: vm), purpose: "Specific UI rules covering navigation, controls, states, accessibility, and interaction behavior."),
            GeneratedFile(relativePath: "\(root)/design-examples/component-guidelines.txt", content: componentGuidelines(vm: vm), purpose: "Concrete guidance for common controls, menus, animation intent, and structural UI elements in the chosen theme."),
            GeneratedFile(relativePath: "\(root)/design-examples/layout-behavior.txt", content: layoutBehavior(vm: vm), purpose: "How the layout should adapt across the selected Apple platforms, including panes, density, and flow."),
            GeneratedFile(relativePath: "\(root)/design-examples/README.txt", content: designReadme(vm: vm), purpose: "Explains what is stored in design-examples/ and how Claude should use those files and images."),
            GeneratedFile(relativePath: "\(root)/design-examples/palette.svg", content: paletteSVG(vm: vm), purpose: "A simple visual color reference image for the selected palette."),
            GeneratedFile(relativePath: "\(root)/design-examples/window-wireframe.svg", content: windowWireframeSVG(vm: vm), purpose: "A lightweight structural mock showing the chosen layout approach."),
            GeneratedFile(relativePath: "\(root)/design-examples/component-sheet.svg", content: componentSheetSVG(vm: vm), purpose: "A simple component reference sheet for buttons, menus, inputs, and layout chrome."),
            GeneratedFile(relativePath: "\(root)/design-examples/design-tokens.json", content: designTokensJSON(vm: vm), purpose: "Machine-readable design tokens (colors, typography, spacing, materials, controls, navigation, animation) that Claude can use directly when writing SwiftUI code."),
            GeneratedFile(relativePath: "\(root)/screenshots/README.txt", content: screenshotsReadme(vm: vm), purpose: "Explains what kinds of screenshots or images belong in screenshots/ and how Claude should interpret them."),
            GeneratedFile(relativePath: "\(root)/repo/github-setup.txt", content: githubSetup(vm: vm), purpose: "GitHub clone/setup instructions, token/API repo-creation guidance, and the selected SSH or HTTPS flows."),
            GeneratedFile(relativePath: "\(root)/repo/terminal-cheatsheet.txt", content: terminalCheatSheet(vm: vm), purpose: "Common terminal navigation, git commands, and Claude Code helper commands for this project pack."),
            GeneratedFile(relativePath: "\(root)/repo/document-guide.txt", content: documentGuide(vm: vm), purpose: "A short explanation of each generated file so the user understands what to edit and when to use it."),
        ]
    }

    private func selectedPlatformSection(vm: WizardViewModel) -> String {
        TargetPlatform.allCases
            .filter { vm.selectedPlatforms.contains($0) }
            .map { "- \($0.rawValue): \($0.designSummary)" }
            .joined(separator: "\n")
    }

    private func advancedStandards(vm: WizardViewModel) -> [String] {
        var rules: [String] = []
        if vm.includeAccessibilityRules {
            rules.append("- Accessibility-first: keep labels, keyboard navigation, clear states, readable contrast, and reduced-motion awareness in scope.")
        }
        if vm.includePerformanceRules {
            rules.append("- Performance-aware: call out rendering, async, or memory hotspots before large changes and prefer native APIs where possible.")
        }
        if vm.includeDocumentationRules {
            rules.append("- Documentation sync: when architecture, folder structure, or workflows change, update the repo guidance files so they stay truthful.")
        }
        if vm.includeGitWorkflowRules {
            rules.append("- Git workflow discipline: prefer small reviewable commits and summarize the impact of each change clearly.")
        }
        if vm.includeLocalizationReadiness {
            rules.append("- Localization readiness: avoid hard-coded UI assumptions that make future localization difficult.")
        }
        if vm.includeAnalyticsReadiness {
            rules.append("- Analytics readiness: when relevant, keep event naming, user flows, and instrumentation points easy to add later.")
        }
        if vm.includeSecurityReview {
            rules.append("- Security awareness: flag secrets, auth, key storage, permissions, and sensitive data handling before implementation.")
        }
        if vm.includeCIReadiness {
            rules.append("- CI readiness: keep the project organized so tests, linting, and build automation can be added cleanly.")
        }
        if vm.includeAppStoreReadiness {
            rules.append("- App Store readiness: think about privacy descriptions, polish, onboarding, accessibility, and release packaging earlier.")
        }
        return rules
    }

    private func customStandardsText(vm: WizardViewModel) -> String {
        vm.customStandards
            .filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !$0.rule.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { "- \($0.title): \($0.rule)" }
            .joined(separator: "\n")
    }

    private func baseClaude(vm: WizardViewModel) -> String {
        let advancedRules = advancedStandards(vm: vm).joined(separator: "\n")
        let customRules = customStandardsText(vm: vm)

        return """
# CLAUDE.md

## Project identity
- Project name: \(vm.projectName)
- Supported platforms: \(vm.selectedPlatformsDescription)
- Product summary: \(vm.productSummary)
- Version 1 complexity: \(vm.complexityLevel.rawValue)
- Polish level: \(vm.polishLevel.rawValue)
- Theme preset: \(vm.themePreset.rawValue)
- Menu chrome: \(vm.menuChromeStyle.rawValue)
- Density: \(vm.densityStyle.rawValue)
- Animation style: \(vm.animationStyle.rawValue)

## Role
You are Claude Code operating inside this repository to help plan, design, and implement Apple software with a native feel, a disciplined engineering workflow, and clear communication.

## Project framing
- Target audience: \(vm.targetAudience)
- Project goals: \(vm.projectGoals)
- Key features: \(vm.keyFeatures)
- Expected development pace: \(vm.developmentPace)

## Supported platform notes
\(selectedPlatformSection(vm: vm))

## Core standards
- Start meaningful work by summarizing the goal, current structure, assumptions, constraints, and acceptance criteria.
- For multi-file work, propose a short implementation plan before editing.
- Prefer maintainable code over clever code.
- Keep business logic out of presentation-heavy SwiftUI views where practical.
- Favor small focused files, clear naming, and predictable folder organization.
- Preserve public behavior unless a change is explicitly requested.
- Distinguish compile confidence from tested confidence.
- When tests are not added, provide specific manual verification steps.
- Keep the generated guidance files aligned with repo reality.

## Advanced standards selected
\(advancedRules.isEmpty ? "- No extra advanced standards were selected beyond the core defaults." : advancedRules)
\(customRules.isEmpty ? "" : "\n## Custom standards\n\(customRules)")

## Planning workflow
- Inspect the existing structure before proposing major edits.
- Break implementation into small verifiable steps.
- Separate must-have work from nice-to-have polish.
- Surface tradeoffs when more than one reasonable path exists.
- For refactors, explain risk and affected files before editing.

## UI workflow
- Use native Apple patterns for the selected platform mix.
- Reference design-examples/ and screenshots/ by file name when making visual recommendations.
- Treat animation intent, menu chrome, and spacing density as real design requirements.
- Describe empty, loading, success, error, and edge-case states.
- Prefer clarity of hierarchy, spacing, and action placement over novelty.
- When inspired by a screenshot, translate it into native Apple components rather than copying it literally.

## Output expectations
- Planning tasks: summarize context, plan, risks, and acceptance criteria.
- Implementation tasks: list files changed, what changed, and how to verify it.
- Design tasks: describe hierarchy, components, interactions, states, accessibility, motion, and rationale.
- Repo tasks: keep clone instructions, paths, and startup prompts aligned with the real folder structure.

## Repository guidance map
- planning/: project framing, architecture, and acceptance criteria
- prompts/: trigger phrases, prompt packs, and Claude startup text
- design-examples/: theme, UI rules, component preferences, and reference SVGs
- screenshots/: human-provided screenshots, inspiration, or bug references
- repo/: clone instructions, terminal helpers, and document guide
"""
    }

    private func projectBrief(vm: WizardViewModel) -> String {
        return """
PROJECT BRIEF

Name: \(vm.projectName)
Supported platforms: \(vm.selectedPlatformsDescription)
Theme preset: \(vm.themePreset.rawValue)
Navigation style: \(vm.navigationStyle.rawValue)
Control style: \(vm.controlStyle.rawValue)
Menu chrome: \(vm.menuChromeStyle.rawValue)
Typography: \(vm.typographyStyle.rawValue)
Color palette: \(vm.colorPalette.rawValue)
Surface style: \(vm.surfaceStyle.rawValue)
Mood: \(vm.moodStyle.rawValue)
Density: \(vm.densityStyle.rawValue)
Animation: \(vm.animationStyle.rawValue)
Complexity level: \(vm.complexityLevel.rawValue)
Polish level: \(vm.polishLevel.rawValue)

Summary:
\(vm.productSummary)

Target audience:
\(vm.targetAudience)

Project goals:
\(vm.projectGoals)

Key features:
\(vm.keyFeatures)

Expected development pace:
\(vm.developmentPace)

Success criteria:
- Repo root includes CLAUDE.md and ProjectOverview 1.txt.
- planning/, prompts/, design-examples/, screenshots/, and repo/ exist.
- design-examples/ includes both text guidance and visual SVG reference artifacts.
- screenshots/ is ready for bugs, inspiration, and other image references.
- The repo folder includes both setup guidance and terminal helper text.
- The final generated files are editable before export.
"""
    }

    private func architectureGuidelines(vm: WizardViewModel) -> String {
        return """
ARCHITECTURE GUIDELINES

- Keep repo guidance files separate from app source code.
- Use the root CLAUDE.md for global rules and supporting files for scoped detail.
- Keep files concise but specific enough that Claude can follow them consistently.
- Treat animation intent, screenshots, and design examples as first-class requirements, not optional polish.
- Organize future product code by feature or clear domain boundary.
- Keep UI layout logic focused on presentation while moving heavier decision logic into view models or services.
- Prefer Apple-native components and patterns before inventing custom UI chrome.
- For multi-platform projects, share concepts and rules where possible, then add platform-specific behavior only where needed.
- Protect future maintainability: explicit names, predictable folders, and minimal surprise.
- Treat screenshots/ and design-examples/ as first-class context inputs for Claude, not optional decoration.
"""
    }

    private func acceptanceCriteria(vm: WizardViewModel) -> String {
        return """
ACCEPTANCE CRITERIA

Before closing a task, Claude should confirm:
- The goal is met for the requested platform or platform mix: \(vm.selectedPlatformsDescription).
- The change respects the selected complexity level: \(vm.complexityLevel.rawValue).
- The UI direction matches the selected design pack.
- Any relevant screenshots or image references were reviewed and cited by file name.
- Any repo instructions or generated docs touched by the change stay current.
- Tests were added, updated, or an explicit manual verification plan was written.
- Edge states were considered where relevant.
- Risks or unresolved questions were surfaced instead of hidden.
"""
    }

    private func triggerRules(vm: WizardViewModel) -> String {
        let items = vm.triggerRules.enumerated().map { index, rule in
            """
\(index + 1). Phrase: \(rule.phrase)
   What it does: \(rule.instruction)
   Example: \(rule.example)
"""
        }.joined(separator: "\n")

        return """
TRIGGER PHRASES REFERENCE

Use these as reusable task-mode activators when prompting Claude.

\(items)

TERMINAL HELPERS TO ASK FOR
- "Terminal help": ask Claude for one-line shell commands with a short explanation of each line.
- "Repo ready": ask Claude to verify clone instructions, local paths, and startup prompts.
- "Command helper": ask Claude for exact commands in the right order, including where to run them.
- "Issue from screenshot": ask Claude to inspect screenshots/ and explain likely UI issues before proposing fixes.
"""
    }

    private func taskTemplates(vm: WizardViewModel) -> String {
        return """
TASK TEMPLATES

Plan-first template:
Review CLAUDE.md, planning/project-brief.txt, planning/architecture-guidelines.txt, and any relevant screenshots or design examples. Summarize the current structure, list assumptions, propose a step-by-step plan, and define acceptance criteria before editing.

Screen blueprint template:
Use design-examples/theme-definition.txt, design-examples/ui-rules.txt, and screenshots/ if present. Describe the screen hierarchy, navigation, components, major interactions, and all important states before generating SwiftUI.

Bug triage template:
Inspect the referenced screenshots and the relevant files. Identify likely causes, rank them by confidence, propose the safest fix, and list how to verify it.

Repo setup template:
Use repo/github-setup.txt and repo/terminal-cheatsheet.txt. Give exact terminal commands, explain each command briefly, and keep all paths aligned with the actual exported folder structure.
"""
    }

    private func claudeRepoPrompt(vm: WizardViewModel) -> String {
        return """
CLAUDE REPO ACCESS PROMPTS

Prompt 1:
Read CLAUDE.md, planning/project-brief.txt, planning/architecture-guidelines.txt, repo/document-guide.txt, and the design-examples folder before suggesting changes.

Prompt 2:
Use the selected design system from design-examples/ plus any screenshots or images in screenshots/ when proposing UI work for \(vm.selectedPlatformsDescription).

Prompt 3:
Before coding, summarize the goal, affected files, risks, and verification plan.
"""
    }

    private func themeDefinition(vm: WizardViewModel) -> String {
        return """
THEME DEFINITION

Preset: \(vm.themePreset.rawValue)
Mood: \(vm.moodStyle.rawValue)
Navigation: \(vm.navigationStyle.rawValue)
Controls: \(vm.controlStyle.rawValue)
Menu chrome: \(vm.menuChromeStyle.rawValue)
Typography: \(vm.typographyStyle.rawValue)
Palette: \(vm.colorPalette.rawValue)
Surface style: \(vm.surfaceStyle.rawValue)
Density: \(vm.densityStyle.rawValue)
Animation: \(vm.animationStyle.rawValue)
Inspector enabled: \(vm.includeInspector ? "Yes" : "No")
Search enabled: \(vm.includeSearch ? "Yes" : "No")
Command palette prompt enabled: \(vm.includeCommandPalettePrompt ? "Yes" : "No")

Theme summary:
\(vm.themePreset.summary)

Motion intent:
\(vm.animationStyle.summary)

Design intent:
Make the app feel native, polished, and fun to work on. Use visuals that support clarity and confidence while preserving Apple-platform familiarity.
"""
    }

    private func uiRules(vm: WizardViewModel) -> String {
        return """
UI RULES

- Preferred navigation: \(vm.navigationStyle.rawValue)
- Preferred controls: \(vm.controlStyle.rawValue)
- Preferred typography: \(vm.typographyStyle.rawValue)
- Preferred palette: \(vm.colorPalette.rawValue)
- Preferred surface style: \(vm.surfaceStyle.rawValue)
- Preferred mood: \(vm.moodStyle.rawValue)
- Preferred menu chrome: \(vm.menuChromeStyle.rawValue)
- Preferred density: \(vm.densityStyle.rawValue)
- Preferred animation: \(vm.animationStyle.rawValue)

Rules:
- Use a clear primary action and avoid cluttering the first screen.
- Favor Apple-native layout behavior and component hierarchy.
- Keep spacing and visual rhythm consistent.
- Use color to support hierarchy, not to replace it.
- Keep toolbars purposeful and avoid decorative overload.
- Use motion to clarify hierarchy and state changes, not as decoration.
- If search is enabled, give it a clear place in the navigation or toolbar.
- If the inspector is enabled, reserve it for secondary detail, configuration, or metadata.
- If the command palette prompt is enabled, include a power-user path for quick actions in prompt guidance.
"""
    }

    private func componentGuidelines(vm: WizardViewModel) -> String {
        return """
COMPONENT GUIDELINES

Use the selected controls, menu chrome, density, and animation style as binding requirements when describing or generating UI.

Navigation pane:
- Use \(vm.navigationStyle.rawValue) with concise section names and stable hierarchy.

Buttons and controls:
- Default visual direction: \(vm.controlStyle.rawValue)
- Primary action should be obvious.
- Secondary actions should remain available but quieter.

Typography:
- Use \(vm.typographyStyle.rawValue) as the baseline tone.
- Preserve readable hierarchy for titles, section headers, labels, and supporting copy.

Panels and surfaces:
- Use \(vm.surfaceStyle.rawValue) to determine whether the UI reads as layered, flat, or card-based.

Motion and polish:
- Use \(vm.animationStyle.rawValue) to guide transitions, emphasis, and changes between states.
- Respect \(vm.densityStyle.rawValue) spacing and pacing across the interface.
- Use \(vm.menuChromeStyle.rawValue) as the menu and picker styling cue.

Common components to support:
- Menus and pickers
- Search field
- Toggle or segmented filter
- List or collection area
- Detail or inspector region if enabled
- Empty, loading, and error states
"""
    }

    private func layoutBehavior(vm: WizardViewModel) -> String {
        return """
LAYOUT BEHAVIOR

Supported platforms: \(vm.selectedPlatformsDescription)

Recommended platform notes:
\(selectedPlatformSection(vm: vm))

Behavior guidance:
- On macOS, preserve keyboard-friendly flows, toolbars, sidebars, and resizable content.
- On iPhone, simplify layout density and focus on the shortest useful path through the task.
- On iPad, use roomier split layouts and keep information grouping visible.
- For universal products, share content language and design tone while allowing platform-specific navigation behavior.
"""
    }

    private func designReadme(vm: WizardViewModel) -> String {
        return """
DESIGN EXAMPLES README

This folder stores both text guidance and simple SVG reference images.

Use these files when asking Claude to:
- create a new UI direction
- redesign a screen
- match a selected Apple-feeling theme
- interpret screenshots or inspiration images in a native way

Selected design direction:
- \(vm.themePreset.rawValue)
- \(vm.navigationStyle.rawValue)
- \(vm.controlStyle.rawValue)
- \(vm.menuChromeStyle.rawValue)
- \(vm.typographyStyle.rawValue)
- \(vm.colorPalette.rawValue)
- \(vm.surfaceStyle.rawValue)
- \(vm.densityStyle.rawValue)
- \(vm.animationStyle.rawValue)
- \(vm.moodStyle.rawValue)
"""
    }

    private func screenshotsReadme(vm: WizardViewModel) -> String {
        return """
SCREENSHOTS & IMAGES README

Put screenshots, mockups, UI inspiration images, bug captures, and other visual references in this folder.

How Claude should use them:
- Refer to image files by name.
- Treat them as context for issues, inspiration, hierarchy, spacing, or component behavior.
- Translate what is useful into native Apple UI patterns rather than copying literally.
- Use these notes for context:
\(vm.screenshotUsageNotes)
"""
    }

    private func githubSetup(vm: WizardViewModel) -> String {
        var lines: [String] = [
            "GITHUB SETUP",
            "",
            "Owner: \(vm.repoOwner)",
            "Repository: \(vm.repoName)",
            "Local project folder: \(vm.localProjectFolderName)",
            "Credential hint: \(vm.repoKeyHint)",
            "Enabled clone flows: \(vm.enabledCloneFlowsDescription)",
            "Repo creation via API desired: \(vm.createRepoViaAPI ? "Yes" : "No")",
            ""
        ]

        if vm.useSSH {
            lines += [
                "SSH clone:",
                "git clone git@github.com:\(vm.repoOwner)/\(vm.repoName).git",
                ""
            ]
        }

        if vm.useHTTPS {
            lines += [
                "HTTPS clone:",
                "git clone https://github.com/\(vm.repoOwner)/\(vm.repoName).git",
                ""
            ]
        }

        if vm.includeRepoCreationGuide {
            lines += [
                "Optional GitHub CLI repo creation flow:",
                "gh repo create \(vm.repoOwner)/\(vm.repoName) --private --source=. --remote=origin",
                "",
                "Optional GitHub REST API repo creation flow:",
                #"curl -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer <YOUR_TOKEN>" https://api.github.com/user/repos -d '{"name":"\#(vm.repoName)","private":true}'"#,
                "",
                "The token/API flow creates the repo. SSH or HTTPS is then used for clone, pull, and push.",
                ""
            ]
        }

        lines += [
            "Suggested local setup:",
            "mkdir -p ~/Projects/\(vm.localProjectFolderName)",
            "cd ~/Projects/\(vm.localProjectFolderName)",
            "",
            "After cloning or creating the repo:",
            "1. Copy the generated files into the repository root.",
            "2. Verify CLAUDE.md is at repo root.",
            "3. Commit the initial pack.",
            "4. Open the repo with Claude Code and start with the repo access prompts.",
            ""
        ]

        if vm.includeFloatingSetupHelper {
            lines += [
                "Helper overlay recommendation:",
                "Keep the floating helper panel visible while you work through GitHub account setup in the browser or Terminal.",
                ""
            ]
        }

        return lines.joined(separator: "\n")
    }

    private func terminalCheatSheet(vm: WizardViewModel) -> String {
        let cloneSection = [
            vm.useSSH ? "git clone git@github.com:\(vm.repoOwner)/\(vm.repoName).git" : nil,
            vm.useHTTPS ? "git clone https://github.com/\(vm.repoOwner)/\(vm.repoName).git" : nil
        ].compactMap { $0 }.joined(separator: "\n")

        return """
TERMINAL CHEAT SHEET

Create local project folder:
mkdir -p ~/Projects/\(vm.localProjectFolderName)
cd ~/Projects/\(vm.localProjectFolderName)

Clone repo:
\(cloneSection)

Enter the repo:
cd \(vm.repoName)

Show current location:
pwd

List files:
ls
ls -la

Open current folder in Finder:
open .

Git basics:
git status
git add .
git commit -m "Initial ClaudeForge project pack"
git push origin main

Common navigation:
cd ..
cd ~/Desktop
mkdir screenshots
mkdir design-examples

Helpful Claude Code starter idea:
"Read CLAUDE.md, planning/project-brief.txt, planning/architecture-guidelines.txt, repo/document-guide.txt, and the design-examples folder before suggesting changes."
"""
    }

    private func documentGuide(vm: WizardViewModel) -> String {
        return """
DOCUMENT GUIDE

ProjectOverview 1.txt
- High-level summary of why this project pack exists and the product direction behind it.

CLAUDE.md
- The root operating manual for Claude Code.

planning/project-brief.txt
- Product context, goals, audience, and version 1 priorities.

planning/architecture-guidelines.txt
- Structural engineering expectations.

planning/acceptance-criteria.txt
- How Claude should check that work is complete.

prompts/trigger-phrases.txt
- Reusable phrases that activate different working modes.

prompts/task-templates.txt
- Example prompt formats for planning, UI, debugging, and repo work.

prompts/claude-repo-access.txt
- Startup prompts for opening the repo with the right context.

design-examples/*
- Visual system rules and SVG references that help Claude understand the intended UI feel.

screenshots/README.txt
- Guidance for how to use screenshots and images in prompts.

repo/github-setup.txt
- Repo setup, clone, and creation guidance.

repo/terminal-cheatsheet.txt
- Common shell, git, and repo navigation commands.
"""
    }

    private func projectOverview(vm: WizardViewModel) -> String {
        return """
ProjectOverview 1

This exported project pack is designed to help Claude Code plan and build Apple software more effectively by combining written instructions, planning documents, design direction, screenshots or images, and repository setup guidance.

Selected direction
- Project: \(vm.projectName)
- Platforms: \(vm.selectedPlatformsDescription)
- Theme preset: \(vm.themePreset.rawValue)
- Complexity: \(vm.complexityLevel.rawValue)
- Polish: \(vm.polishLevel.rawValue)
- Density: \(vm.densityStyle.rawValue)
- Animation: \(vm.animationStyle.rawValue)

Why the pack exists
- A single generic CLAUDE.md file is often not enough.
- Claude performs better with a clear instruction system.
- Visual references improve UI reasoning and debugging.
- Trigger phrases help the user get consistent outputs from Claude.
- A terminal cheat sheet helps users move from planning into repo work.

What this pack creates
- CLAUDE.md
- planning/
- prompts/
- design-examples/
- screenshots/
- repo/

How to use it
1. Place the exported files in your repo.
2. Add screenshots or images into screenshots/ when relevant.
3. Use the trigger-phrase reference when prompting Claude.
4. Point Claude to CLAUDE.md, the planning files, and design-examples before asking for code.
"""
    }

    private func paletteSVG(vm: WizardViewModel) -> String {
        let colors = vm.colorPalette.swatches
        let rects = colors.enumerated().map { index, color in
            "<rect x='\(20 + index * 120)' y='40' width='100' height='100' rx='24' fill='\(color)'/>"
        }.joined(separator: "\n")
        let labels = colors.enumerated().map { index, color in
            "<text x='\(70 + index * 120)' y='165' font-size='14' text-anchor='middle' fill='#111111'>\(color)</text>"
        }.joined(separator: "\n")

        return """
<svg xmlns='http://www.w3.org/2000/svg' width='660' height='220' viewBox='0 0 660 220'>
  <rect width='660' height='220' rx='28' fill='#FFFFFF'/>
  <text x='24' y='24' font-size='18' font-family='Helvetica Neue, Arial, sans-serif' fill='#111111'>\(vm.colorPalette.rawValue) palette</text>
  \(rects)
  \(labels)
</svg>
"""
    }

    private func windowWireframeSVG(vm: WizardViewModel) -> String {
        let inspectorWidth = vm.includeInspector ? 120 : 0
        let detailWidth = 520 - inspectorWidth
        let searchBar = vm.includeSearch ? "<rect x='180' y='50' width='180' height='28' rx='12' fill='#FFFFFF' stroke='#D5D7DD'/>" : ""
        let inspector = vm.includeInspector ? "<rect x='\(180 + detailWidth)' y='92' width='120' height='220' rx='18' fill='#F5F6FA' stroke='#D9DCE5'/>" : ""

        return """
<svg xmlns='http://www.w3.org/2000/svg' width='820' height='360' viewBox='0 0 820 360'>
  <rect width='820' height='360' rx='28' fill='#F7F8FB'/>
  <rect x='20' y='20' width='780' height='320' rx='24' fill='#FFFFFF' stroke='#D5D7DD'/>
  <rect x='20' y='20' width='780' height='54' rx='24' fill='#F3F4F7'/>
  <circle cx='48' cy='47' r='7' fill='#FF5F57'/><circle cx='70' cy='47' r='7' fill='#FEBC2E'/><circle cx='92' cy='47' r='7' fill='#28C840'/>
  \(searchBar)
  <rect x='32' y='92' width='132' height='220' rx='18' fill='#F5F6FA' stroke='#D9DCE5'/>
  <rect x='180' y='92' width='\(detailWidth)' height='220' rx='18' fill='#FFFFFF' stroke='#D9DCE5'/>
  \(inspector)
  <text x='36' y='108' font-size='16' fill='#111111'>\(vm.navigationStyle.rawValue)</text>
</svg>
"""
    }

    private func componentSheetSVG(vm: WizardViewModel) -> String {
        return """
<svg xmlns='http://www.w3.org/2000/svg' width='820' height='420' viewBox='0 0 820 420'>
  <rect width='820' height='420' rx='28' fill='#FFFFFF'/>
  <text x='28' y='34' font-size='20' font-family='Helvetica Neue, Arial, sans-serif' fill='#111111'>Component sheet</text>
  <rect x='30' y='60' width='180' height='54' rx='18' fill='\(vm.colorPalette.swatches[2])'/>
  <text x='120' y='92' text-anchor='middle' font-size='16' fill='#FFFFFF'>Primary button</text>
  <rect x='230' y='60' width='180' height='54' rx='18' fill='#F5F6FA' stroke='#D9DCE5'/>
  <text x='320' y='92' text-anchor='middle' font-size='16' fill='#111111'>Secondary button</text>
  <rect x='430' y='60' width='220' height='54' rx='18' fill='#FFFFFF' stroke='#D9DCE5'/>
  <text x='454' y='92' font-size='15' fill='#666666'>Search</text>
  <rect x='30' y='140' width='250' height='180' rx='20' fill='#F8F9FC' stroke='#D9DCE5'/>
  <text x='48' y='168' font-size='16' fill='#111111'>Panel / card</text>
  <rect x='310' y='140' width='160' height='42' rx='14' fill='#F3F4F7' stroke='#D9DCE5'/>
  <text x='390' y='166' text-anchor='middle' font-size='15' fill='#111111'>Segmented control</text>
  <rect x='500' y='140' width='220' height='150' rx='20' fill='#F8F9FC' stroke='#D9DCE5'/>
  <text x='520' y='168' font-size='16' fill='#111111'>Inspector block</text>
  <text x='30' y='356' font-size='14' fill='#444444'>Control style: \(vm.controlStyle.rawValue)</text>
  <text x='280' y='356' font-size='14' fill='#444444'>Typography: \(vm.typographyStyle.rawValue)</text>
  <text x='530' y='356' font-size='14' fill='#444444'>Surface: \(vm.surfaceStyle.rawValue)</text>
</svg>
"""
    }

    // MARK: - Design tokens (machine-readable)

    private func designTokensJSON(vm: WizardViewModel) -> String {
        let swatches = vm.colorPalette.swatches
        // Guard against a palette with fewer than 5 swatches (current data always has 5).
        let safe: (Int) -> String = { idx in idx < swatches.count ? swatches[idx] : "#000000" }

        let typography = typographyScale(vm.typographyStyle)
        let spacing = spacingScale(vm.densityStyle)
        let materials = materialMapping(vm.surfaceStyle)
        let controls = controlMapping(vm.controlStyle)
        let animation = animationMapping(vm.animationStyle)
        let navPattern = navigationPattern(vm.navigationStyle)

        let tokens: [String: Any] = [
            "$schema": "claude-forge/design-tokens-v1",
            "project": [
                "name": vm.projectName,
                "platforms": vm.selectedPlatformNames
            ],
            "preset": [
                "name": vm.themePreset.rawValue,
                "mood": vm.moodStyle.rawValue
            ],
            "colors": [
                "palette": vm.colorPalette.rawValue,
                "swatches": [
                    "background": safe(0),
                    "surface":    safe(1),
                    "accent":     safe(2),
                    "onAccent":   safe(3),
                    "text":       safe(4)
                ]
            ],
            "typography": [
                "style": vm.typographyStyle.rawValue,
                "fontFamily": "-apple-system",
                "scale": [
                    "title":    typography.title,
                    "subtitle": typography.subtitle,
                    "body":     typography.body,
                    "caption":  typography.caption
                ]
            ],
            "spacing": [
                "density": vm.densityStyle.rawValue,
                "scale": [
                    "xs": spacing.xs, "sm": spacing.sm, "md": spacing.md,
                    "lg": spacing.lg, "xl": spacing.xl
                ]
            ],
            "materials": [
                "surface":   vm.surfaceStyle.rawValue,
                "primary":   materials.primary,
                "secondary": materials.secondary
            ],
            "controls": [
                "style":        vm.controlStyle.rawValue,
                "buttonShape":  controls.buttonShape,
                "toolbarStyle": controls.toolbarStyle
            ],
            "navigation": [
                "style":          vm.navigationStyle.rawValue,
                "swiftUIPattern": navPattern
            ],
            "animation": [
                "style":           vm.animationStyle.rawValue,
                "defaultDuration": animation.duration,
                "spring": [
                    "response":        animation.duration,
                    "dampingFraction": animation.damping
                ]
            ],
            "menu": [
                "style": vm.menuChromeStyle.rawValue
            ]
        ]

        guard let data = try? JSONSerialization.data(
            withJSONObject: tokens,
            options: [.prettyPrinted, .sortedKeys]
        ), let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }

    private func typographyScale(_ style: TypographyStyle) -> (title: Int, subtitle: Int, body: Int, caption: Int) {
        switch style {
        case .systemBalanced:    return (22, 15, 13, 11)
        case .largeProductivity: return (26, 17, 14, 12)
        case .compactUtility:    return (18, 13, 11, 10)
        case .editorial:         return (28, 18, 14, 11)
        }
    }

    private func spacingScale(_ density: DensityStyle) -> (xs: Int, sm: Int, md: Int, lg: Int, xl: Int) {
        switch density {
        case .airy:     return (6, 12, 20, 32, 48)
        case .balanced: return (4,  8, 14, 22, 32)
        case .compact:  return (2,  6, 10, 16, 24)
        }
    }

    private func materialMapping(_ style: SurfaceStyle) -> (primary: String, secondary: String) {
        switch style {
        case .standardMaterial: return ("regularMaterial",  "thinMaterial")
        case .layeredGlass:     return ("thickMaterial",    "regularMaterial")
        case .cardStacks:       return ("regularMaterial",  "thinMaterial")
        case .flatPanels:       return ("ultraThinMaterial","ultraThinMaterial")
        }
    }

    private func controlMapping(_ style: ControlStyle) -> (buttonShape: String, toolbarStyle: String) {
        switch style {
        case .nativeFilled:   return ("capsule",      "unified")
        case .tintedToolbar:  return ("roundedRect",  "unifiedCompact")
        case .softGlass:      return ("capsule",      "unified")
        case .outlineMinimal: return ("roundedRect",  "expanded")
        }
    }

    private func navigationPattern(_ style: NavigationStyle) -> String {
        switch style {
        case .sidebar:        return "NavigationSplitView(sidebar:detail:)"
        case .splitInspector: return "NavigationSplitView(sidebar:content:detail:)"
        case .tabSidebar:     return "NavigationSplitView + TabView"
        case .utility:        return "WindowGroup single-view utility"
        }
    }

    private func animationMapping(_ style: AnimationStyle) -> (duration: Double, damping: Double) {
        switch style {
        case .calm:    return (0.35, 0.90)
        case .springy: return (0.40, 0.70)
        case .crisp:   return (0.15, 1.00)
        case .premium: return (0.25, 0.82)
        case .minimal: return (0.10, 1.00)
        }
    }
}
