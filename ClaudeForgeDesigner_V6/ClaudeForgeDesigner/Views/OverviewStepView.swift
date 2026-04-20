import SwiftUI

struct OverviewStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(
            title: "Build a better Claude Code project pack",
            subtitle: "Create a stronger root CLAUDE.md, companion planning files, prompt packs, design examples, screenshots and images, repo setup text, and an editable review phase."
        ) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    InfoCard(title: "What gets exported", symbol: "shippingbox") {
                        Text("A repo-ready folder with CLAUDE.md, ProjectOverview 1.txt, planning guidance, prompt packs, design examples, screenshots and images guidance, GitHub setup help, and a terminal cheat sheet.")
                            .foregroundStyle(.secondary)
                        PreviewBadgeRow(values: ["CLAUDE.md", "planning", "prompts", "design-examples", "screenshots", "repo"])
                    }

                    InfoCard(title: "Why it helps Claude", symbol: "brain.head.profile") {
                        Text("Claude works better with explicit instructions, concrete visual references, reusable trigger phrases, and a small system of files instead of one vague note.")
                            .foregroundStyle(.secondary)
                        PreviewBadgeRow(values: ["clear rules", "visual references", "task prompts", "acceptance criteria"])
                    }
                }

                InfoCard(title: "Project summary", symbol: "wand.and.stars") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(viewModel.productSummary)
                        HStack(spacing: 8) {
                            PillTag(text: viewModel.selectedPlatformsDescription)
                            PillTag(text: viewModel.themePreset.rawValue)
                            PillTag(text: viewModel.complexityLevel.rawValue)
                        }
                    }
                }
            }
        }
    }
}
