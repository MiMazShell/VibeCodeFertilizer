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

            StepFooter()
        }
        .padding(28)
        .frame(maxWidth: 1200, alignment: .topLeading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.16))
        )
        .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
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
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
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
            Button("Back") {
                viewModel.previous()
            }
            .disabled(viewModel.currentStep == .overview)

            Spacer()

            ProgressView(value: viewModel.completionFraction)
                .frame(width: 200)

            Spacer()

            Button(viewModel.currentStep == .review ? "Ready to Export" : "Continue") {
                if viewModel.currentStep == .review {
                    viewModel.regenerateFiles()
                } else {
                    viewModel.next()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 8)
    }
}

struct LabeledToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.switch)
    }
}

struct PreviewBadgeRow: View {
    let values: [String]

    var body: some View {
        FlowLayout(values: values)
    }
}

struct FlowLayout: View {
    let values: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(chunked(values, size: 3), id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { value in
                        PillTag(text: value)
                    }
                    Spacer()
                }
            }
        }
    }

    private func chunked(_ input: [String], size: Int) -> [[String]] {
        stride(from: 0, to: input.count, by: size).map { index in
            Array(input[index ..< min(index + size, input.count)])
        }
    }
}

struct NarrativeField: View {
    let title: String
    let prompt: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Menu {
                    Button("Make concise") {
                        text = WritingAssist.makeConcise(text)
                    }
                    Button("Make more specific") {
                        text = WritingAssist.makeMoreSpecific(text)
                    }
                    Button("Make more technical") {
                        text = WritingAssist.makeMoreTechnical(text)
                    }
                    Button("Rewrite for clarity") {
                        text = WritingAssist.rewriteForClarity(text)
                    }
                } label: {
                    Label("Refine", systemImage: "sparkles")
                        .font(.caption.weight(.semibold))
                }
                .menuStyle(.borderlessButton)
            }

            TextEditor(text: $text)
                .font(.body)
                .frame(minHeight: 92)
                .padding(8)
                .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(prompt)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 18)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}

enum WritingAssist {
    static func makeConcise(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }
        let parts = trimmed.components(separatedBy: ". ").prefix(2)
        return parts.joined(separator: ". ").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func makeMoreSpecific(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }
        return trimmed + " Include concrete user outcomes, constraints, and success criteria."
    }

    static func makeMoreTechnical(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }
        return trimmed + " Describe architecture expectations, state handling, data flow, testing approach, and platform-specific behavior."
    }

    static func rewriteForClarity(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }
        return trimmed
            .replacingOccurrences(of: "  ", with: " ")
            .replacingOccurrences(of: " and ", with: ", and ")
    }
}

extension Color {
    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6, let int = Int(cleaned, radix: 16) else { return nil }
        let red = Double((int >> 16) & 0xFF) / 255.0
        let green = Double((int >> 8) & 0xFF) / 255.0
        let blue = Double(int & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
