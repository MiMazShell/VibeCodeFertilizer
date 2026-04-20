import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("ClaudeForge")
                    .font(.system(size: 28, weight: .bold))
                Text("Design and export a richer Claude Code project pack")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            List {
                ForEach(viewModel.steps) { step in
                    Button {
                        viewModel.currentStep = step.id
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: step.symbol)
                                .frame(width: 18)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(step.title)
                                Text(step.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(viewModel.currentStep == step.id ? Color.accentColor.opacity(0.16) : Color.clear)
                }
            }
            .listStyle(.sidebar)

            VStack(alignment: .leading, spacing: 10) {
                Text("Pack contents")
                    .font(.headline)
                Text("CLAUDE.md, ProjectOverview 1.txt, planning files, prompt packs, design examples, screenshots and images guidance, repo setup, and terminal helper text.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                PreviewBadgeRow(values: ["CLAUDE.md", "ProjectOverview 1", "design-examples", "screenshots", "repo helpers"])
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}
