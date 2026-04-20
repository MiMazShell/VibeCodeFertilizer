import SwiftUI

struct ProjectSetupStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(
            title: "Project brief",
            subtitle: "Give Claude clearer product context: goals, audience, features, platforms, scope, and the quality bar for version 1."
        ) {
            VStack(alignment: .leading, spacing: 18) {
                InfoCard(title: "Project basics", symbol: "square.and.pencil") {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Project name", text: $viewModel.projectName)
                        NarrativeField(title: "Product summary", prompt: "Describe what the product is, why it matters, and the kind of experience it should deliver.", text: $viewModel.productSummary)
                    }
                }

                InfoCard(title: "Supported platforms", symbol: "macwindow") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose any platform mix you want the project pack to support.")
                            .foregroundStyle(.secondary)
                        HStack(spacing: 12) {
                            ForEach(TargetPlatform.allCases) { platform in
                                Button {
                                    viewModel.togglePlatform(platform)
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Image(systemName: viewModel.selectedPlatforms.contains(platform) ? "checkmark.circle.fill" : "circle")
                                            Text(platform.rawValue)
                                                .fontWeight(.semibold)
                                        }
                                        Text(platform.designSummary)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                                .background(viewModel.selectedPlatforms.contains(platform) ? Color.accentColor.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(viewModel.selectedPlatforms.contains(platform) ? Color.accentColor.opacity(0.45) : Color.secondary.opacity(0.18), lineWidth: 1)
                                )
                            }
                        }
                    }
                }

                HStack(alignment: .top, spacing: 16) {
                    InfoCard(title: "Goals and audience", symbol: "target") {
                        VStack(alignment: .leading, spacing: 12) {
                            NarrativeField(title: "Project goals", prompt: "State the goals for version 1, the outcome you want, and what success looks like.", text: $viewModel.projectGoals)
                            NarrativeField(title: "Target audience", prompt: "Who is the app for, what do they need, and what tone should the product have?", text: $viewModel.targetAudience)
                            NarrativeField(title: "Key features for version 1", prompt: "List the most important features, the order they matter in, and any notable platform differences.", text: $viewModel.keyFeatures)
                        }
                    }

                    InfoCard(title: "Scope and quality bar", symbol: "dial.medium") {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Version 1 complexity", selection: $viewModel.complexityLevel) {
                                ForEach(ComplexityLevel.allCases) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            Text(viewModel.complexityLevel.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Picker("Polish level", selection: $viewModel.polishLevel) {
                                ForEach(PolishLevel.allCases) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            NarrativeField(title: "Development pace", prompt: "Describe the desired pace, level of iteration, and whether speed or polish should dominate early decisions.", text: $viewModel.developmentPace)
                        }
                    }
                }
            }
        }
    }
}
