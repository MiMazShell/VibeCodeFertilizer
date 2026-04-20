import SwiftUI

struct ScreenshotsStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(
            title: "Screenshots & Images",
            subtitle: "Import screenshots, mockups, inspiration images, bug captures, or visual ideas. The export writes them into screenshots/ so Claude can reference them directly."
        ) {
            VStack(alignment: .leading, spacing: 18) {
                InfoCard(title: "How these visuals help", symbol: "photo") {
                    TextEditor(text: $viewModel.screenshotUsageNotes)
                        .frame(minHeight: 120)
                }

                InfoCard(title: "Imported visual references", symbol: "folder.badge.plus") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button("Import Screenshots or Images") {
                                viewModel.importScreenshots()
                            }
                            .buttonStyle(.borderedProminent)

                            Text("\(viewModel.importedScreenshots.count) selected")
                                .foregroundStyle(.secondary)
                        }

                        if viewModel.importedScreenshots.isEmpty {
                            Text("No visual references added yet. You can still export; the app will create screenshots/ and its README for later use.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.importedScreenshots) { screenshot in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(screenshot.fileName)
                                        Text(screenshot.note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Button("Remove") {
                                        viewModel.removeScreenshot(screenshot)
                                    }
                                }
                                .padding(12)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                }
            }
        }
    }
}
