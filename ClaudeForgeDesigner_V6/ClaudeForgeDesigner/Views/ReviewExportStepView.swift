import SwiftUI

struct ReviewExportStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(
            title: "Review and edit",
            subtitle: "Inspect every generated document, understand its purpose, edit it if needed, and then export the full pack."
        ) {
            VStack(alignment: .leading, spacing: 18) {
                InfoCard(title: "Summary", symbol: "checkmark.circle") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Project: \(viewModel.projectName)")
                        Text("Platforms: \(viewModel.selectedPlatformsDescription)")
                        Text("Theme: \(viewModel.themePreset.rawValue)")
                        Text("Complexity / polish: \(viewModel.complexityLevel.rawValue) / \(viewModel.polishLevel.rawValue)")
                        Text("Visual references selected: \(viewModel.importedScreenshots.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(alignment: .top, spacing: 16) {
                    InfoCard(title: "Documents", symbol: "doc.on.doc") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Choose a document to review. Human-friendly title and purpose are emphasized; the technical file path stays smaller beneath them.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 10) {
                                    ForEach(viewModel.generatedFiles) { file in
                                        DocumentListRow(
                                            title: viewModel.displayTitle(for: file),
                                            purpose: file.purpose,
                                            path: file.relativePath,
                                            isSelected: viewModel.selectedGeneratedFilePath == file.relativePath
                                        ) {
                                            viewModel.selectGeneratedFile(path: file.relativePath)
                                        }
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                            .frame(minHeight: 420)
                        }
                    }
                    .frame(minWidth: 320, maxWidth: 380)

                    InfoCard(title: "Selected document", symbol: "pencil.and.list.clipboard") {
                        if let selectedFile = viewModel.selectedGeneratedFile {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(viewModel.displayTitle(for: selectedFile))
                                    .font(.title2.weight(.bold))
                                Text(selectedFile.purpose)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(selectedFile.relativePath)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.tertiary)

                                TextEditor(text: Binding(
                                    get: { viewModel.selectedGeneratedFile?.content ?? "" },
                                    set: { viewModel.updateGeneratedFileContent($0) }
                                ))
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 420)
                                .padding(8)
                                .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16))
                            }
                        } else {
                            Text("Select a generated file to review or edit it.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack(spacing: 12) {
                    Button("Refresh Generated Files") {
                        viewModel.regenerateFiles()
                    }

                    Button("Export Project Pack") {
                        viewModel.exportPack()
                    }
                    .buttonStyle(.borderedProminent)
                }

                if !viewModel.exportStatusMessage.isEmpty {
                    InfoCard(title: "Export status", symbol: "folder") {
                        Text(viewModel.exportStatusMessage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.regenerateFiles()
        }
    }
}

private struct DocumentListRow: View {
    let title: String
    let purpose: String
    let path: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(purpose)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(path)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: isSelected ? 1.5 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        isSelected ? Color.accentColor.opacity(0.14) : Color.white.opacity(0.42)
    }

    private var borderColor: Color {
        isSelected ? Color.accentColor.opacity(0.42) : Color.white.opacity(0.10)
    }
}
