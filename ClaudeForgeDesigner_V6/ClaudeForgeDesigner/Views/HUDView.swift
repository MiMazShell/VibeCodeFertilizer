import SwiftUI
import UniformTypeIdentifiers

// MARK: - HUD root

struct HUDView: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var selectedTab: HUDTab = .capture

    enum HUDTab: String, CaseIterable, Identifiable {
        case capture = "Capture"
        case plan = "Plan"

        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            HUDHeader()

            Picker("", selection: $selectedTab) {
                ForEach(HUDTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 12)
            .padding(.top, 4)

            Divider()
                .padding(.top, 8)

            ScrollView {
                Group {
                    switch selectedTab {
                    case .capture:
                        HUDCaptureView()
                    case .plan:
                        HUDPlanView()
                    }
                }
                .padding(12)
            }
        }
    }
}

private struct HUDHeader: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "hammer.fill")
                .foregroundStyle(.orange)
            Text("ClaudeForge")
                .font(.headline)
            Spacer()
            Text("HUD")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.15), in: Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }
}

// MARK: - Capture tab

private struct HUDCaptureView: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var captureType: CaptureType = .hazard

    enum CaptureType: String, CaseIterable, Identifiable {
        case hazard = "Hazard"
        case bug = "Bug"
        case screenshot = "Screenshot"

        var id: String { rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Type", selection: $captureType) {
                ForEach(CaptureType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            switch captureType {
            case .hazard:
                HazardCaptureForm()
            case .bug:
                BugCaptureForm()
            case .screenshot:
                ScreenshotCaptureForm()
            }
        }
    }
}

// MARK: - Hazard capture

private struct HazardCaptureForm: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var title = ""
    @State private var why = ""
    @State private var how = ""
    @State private var justAdded = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Log something that will bite a future you — or a future AI.")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Title (short description)", text: $title)
                .textFieldStyle(.roundedBorder)

            TextField("Why it bites (the consequence)", text: $why, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)

            TextField("How to handle (the safe path)", text: $how, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button {
                    viewModel.addHazard(title: title, whyItBites: why, howToHandle: how)
                    justAdded = title
                    title = ""
                    why = ""
                    how = ""
                } label: {
                    Label("Log Hazard", systemImage: "exclamationmark.triangle.fill")
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                .keyboardShortcut(.return, modifiers: [.command])
                .buttonStyle(.borderedProminent)

                Spacer()

                if !justAdded.isEmpty {
                    Label("Saved", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            if !viewModel.hazards.isEmpty {
                Divider().padding(.vertical, 4)
                Text("Current hazards (\(viewModel.hazards.count))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                ForEach(viewModel.hazards) { hazard in
                    HazardRow(hazard: hazard) {
                        viewModel.removeHazard(hazard)
                    }
                }
            }
        }
    }
}

private struct HazardRow: View {
    let hazard: Hazard
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.caption)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(hazard.title)
                    .font(.callout.weight(.medium))
                    .lineLimit(2)
                if !hazard.whyItBites.isEmpty {
                    Text(hazard.whyItBites)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
            Spacer(minLength: 4)
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
        }
        .padding(8)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Bug capture

private struct BugCaptureForm: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var title = ""
    @State private var symptom = ""
    @State private var area = ""
    @State private var justAdded = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Log a defect — a specific thing to fix.")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Title (short description)", text: $title)
                .textFieldStyle(.roundedBorder)

            TextField("Symptom (what's observably wrong)", text: $symptom, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)

            TextField("Suspected area (optional)", text: $area)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button {
                    viewModel.addBug(title: title, symptom: symptom, suspectedArea: area)
                    justAdded = title
                    title = ""
                    symptom = ""
                    area = ""
                } label: {
                    Label("Log Bug", systemImage: "ant.fill")
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                .keyboardShortcut(.return, modifiers: [.command])
                .buttonStyle(.borderedProminent)

                Spacer()

                if !justAdded.isEmpty {
                    Label("Saved", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            if !viewModel.bugs.isEmpty {
                Divider().padding(.vertical, 4)
                Text("Open bugs (\(viewModel.bugs.filter { $0.status == .open }.count))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                ForEach(viewModel.bugs) { bug in
                    BugRow(bug: bug) {
                        viewModel.removeBug(bug)
                    }
                }
            }
        }
    }
}

private struct BugRow: View {
    let bug: Bug
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "ant.fill")
                .foregroundStyle(.red)
                .font(.caption)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(bug.title)
                    .font(.callout.weight(.medium))
                    .lineLimit(2)
                if !bug.symptom.isEmpty {
                    Text(bug.symptom)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
            Spacer(minLength: 4)
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
        }
        .padding(8)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Screenshot capture

private struct ScreenshotCaptureForm: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var caption = ""
    @State private var isTargeted = false
    @State private var lastAdded = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Drag a screenshot below. Caption is optional.")
                .font(.caption)
                .foregroundStyle(.secondary)

            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.primary.opacity(0.25),
                    style: StrokeStyle(lineWidth: 2, dash: [6])
                )
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.primary.opacity(isTargeted ? 0.08 : 0.02))
                )
                .frame(height: 110)
                .overlay(
                    VStack(spacing: 6) {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text(isTargeted ? "Release to add" : "Drop image here")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                )
                .onDrop(of: [.fileURL, .image], isTargeted: $isTargeted, perform: handleDrop)

            TextField("Caption (optional)", text: $caption)
                .textFieldStyle(.roundedBorder)

            if !lastAdded.isEmpty {
                Label("Added: \(lastAdded)", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            if !viewModel.importedScreenshots.isEmpty {
                Divider().padding(.vertical, 4)
                Text("Screenshots (\(viewModel.importedScreenshots.count))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                ForEach(viewModel.importedScreenshots) { shot in
                    HStack(spacing: 8) {
                        Image(systemName: "photo")
                            .foregroundStyle(.blue)
                            .font(.caption)
                        Text(shot.fileName)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(6)
                    .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        _ = provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            var resolvedURL: URL?
            if let url = item as? URL {
                resolvedURL = url
            } else if let data = item as? Data {
                resolvedURL = URL(dataRepresentation: data, relativeTo: nil)
            }

            guard let url = resolvedURL else { return }

            DispatchQueue.main.async {
                viewModel.addScreenshotFromURL(url, caption: caption)
                lastAdded = url.lastPathComponent
                caption = ""
            }
        }
        return true
    }
}

// MARK: - Plan tab

private struct HUDPlanView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Wizard progress")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ForEach(viewModel.steps) { step in
                PlanStepRow(step: step, isCurrent: step.id == viewModel.currentStep) {
                    viewModel.currentStep = step.id
                }
            }
        }
    }
}

private struct PlanStepRow: View {
    let step: WizardStepItem
    let isCurrent: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                Image(systemName: step.symbol)
                    .foregroundStyle(isCurrent ? Color.accentColor : .secondary)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 1) {
                    Text(step.title)
                        .font(.callout.weight(isCurrent ? .semibold : .regular))
                        .foregroundStyle(.primary)
                    Text(step.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 4)
                if isCurrent {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isCurrent ? Color.accentColor.opacity(0.12) : Color.primary.opacity(0.03))
            )
        }
        .buttonStyle(.plain)
    }
}
