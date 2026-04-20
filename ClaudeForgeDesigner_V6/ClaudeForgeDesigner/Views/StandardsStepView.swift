import SwiftUI

struct StandardsStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(
            title: "Standards and engineering defaults",
            subtitle: "Core quality rules are assumed. Add advanced standards and any custom rules you want Claude to enforce more explicitly."
        ) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    InfoCard(title: "Always-on core defaults", symbol: "checkmark.seal") {
                        PreviewBadgeRow(values: [
                            "plan before multi-file edits",
                            "maintainable code",
                            "clear naming",
                            "verification steps",
                            "sync docs to repo",
                            "safe refactors"
                        ])
                    }

                    InfoCard(title: "Advanced standards", symbol: "gearshape.2") {
                        VStack(alignment: .leading, spacing: 12) {
                            LabeledToggle(title: "Accessibility-first", subtitle: "Labels, keyboard awareness, contrast, reduced motion, and state clarity.", isOn: $viewModel.includeAccessibilityRules)
                            LabeledToggle(title: "Performance awareness", subtitle: "Flag rendering, async, or memory hotspots before broad changes.", isOn: $viewModel.includePerformanceRules)
                            LabeledToggle(title: "Documentation sync", subtitle: "Keep guidance files aligned with repo reality.", isOn: $viewModel.includeDocumentationRules)
                            LabeledToggle(title: "Git workflow discipline", subtitle: "Prefer small reviewable changes and clear commit logic.", isOn: $viewModel.includeGitWorkflowRules)
                            LabeledToggle(title: "Localization readiness", subtitle: "Avoid assumptions that make future localization painful.", isOn: $viewModel.includeLocalizationReadiness)
                            LabeledToggle(title: "Analytics readiness", subtitle: "Leave room for event instrumentation and flow analysis.", isOn: $viewModel.includeAnalyticsReadiness)
                            LabeledToggle(title: "Security review", subtitle: "Flag secrets, auth, permissions, and sensitive data handling.", isOn: $viewModel.includeSecurityReview)
                            LabeledToggle(title: "CI readiness", subtitle: "Keep structure friendly for future automation and tests.", isOn: $viewModel.includeCIReadiness)
                            LabeledToggle(title: "App Store readiness", subtitle: "Think about polish, privacy descriptions, onboarding, and release packaging.", isOn: $viewModel.includeAppStoreReadiness)
                        }
                    }
                }

                InfoCard(title: "Custom standards", symbol: "plus.square.on.square") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(viewModel.customStandards.indices), id: \.self) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    TextField("Standard title", text: Binding(
                                        get: { viewModel.customStandards[index].title },
                                        set: { viewModel.customStandards[index].title = $0 }
                                    ))
                                    Button(role: .destructive) {
                                        viewModel.customStandards.remove(at: index)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderless)
                                }
                                TextField("Rule", text: Binding(
                                    get: { viewModel.customStandards[index].rule },
                                    set: { viewModel.customStandards[index].rule = $0 }
                                ), axis: .vertical)
                                .lineLimit(2...4)
                            }
                            .padding(12)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }

                        Button("Add Custom Standard") {
                            viewModel.addCustomStandard()
                        }
                    }
                }
            }
        }
    }
}
