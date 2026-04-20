import SwiftUI

struct RulesStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(
            title: "Trigger phrases and command helpers",
            subtitle: "Define reusable task modes for Claude, and export a trigger reference plus terminal cheat sheet for everyday use."
        ) {
            VStack(alignment: .leading, spacing: 18) {
                InfoCard(title: "Trigger phrases", symbol: "text.badge.star") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(viewModel.triggerRules.indices), id: \.self) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    TextField(
                                        "Phrase",
                                        text: Binding(
                                            get: { viewModel.triggerRules[index].phrase },
                                            set: { viewModel.triggerRules[index].phrase = $0 }
                                        )
                                    )
                                    Spacer()
                                    Button(role: .destructive) {
                                        viewModel.triggerRules.remove(at: index)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderless)
                                }
                                TextField(
                                    "What it does",
                                    text: Binding(
                                        get: { viewModel.triggerRules[index].instruction },
                                        set: { viewModel.triggerRules[index].instruction = $0 }
                                    ),
                                    axis: .vertical
                                )
                                .lineLimit(2...4)
                                TextField(
                                    "Example prompt",
                                    text: Binding(
                                        get: { viewModel.triggerRules[index].example },
                                        set: { viewModel.triggerRules[index].example = $0 }
                                    ),
                                    axis: .vertical
                                )
                                .lineLimit(1...3)
                            }
                            .padding(12)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }

                        HStack {
                            Button("Add Trigger Phrase") {
                                viewModel.addTriggerRule()
                            }
                            Button("Add Suggested Triggers") {
                                viewModel.addSuggestedTriggers()
                            }
                        }
                    }
                }

                InfoCard(title: "What gets exported", symbol: "terminal") {
                    Text("The final pack includes a trigger-phrase reference, reusable task templates, repo startup prompts, and a terminal cheat sheet with common git, folder, and command-line helpers.")
                        .foregroundStyle(.secondary)
                    PreviewBadgeRow(values: ["trigger-phrases.txt", "task-templates.txt", "claude-repo-access.txt", "terminal-cheatsheet.txt"])
                }
            }
        }
    }
}
