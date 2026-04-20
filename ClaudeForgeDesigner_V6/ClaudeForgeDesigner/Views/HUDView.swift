import SwiftUI
import UniformTypeIdentifiers

// MARK: - HUD root

struct HUDView: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var selectedTab: HUDTab = .capture
    @State private var showingSettings = false
    @State private var showingRestoreSheet = false

    enum HUDTab: String, CaseIterable, Identifiable {
        case capture = "Capture"
        case plan = "Plan"
        case archive = "Archive"

        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            HUDHeader(showingSettings: $showingSettings)

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
                    case .archive:
                        HUDArchiveView()
                    }
                }
                .padding(12)
            }
        }
        .sheet(isPresented: $showingSettings) {
            HUDSettingsSheet()
                .environmentObject(viewModel)
        }
        .onAppear {
            // Absorb any blocks the repo's capture files hold that aren't in the
            // in-memory list yet (e.g., added manually, by an AI agent, or captured
            // in a previous session before we had any startup sync).
            viewModel.refreshFromRepoIfTargetSet()
        }
    }
}

// MARK: - Header (pending indicator + sync + settings)

private struct HUDHeader: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @Binding var showingSettings: Bool
    @State private var syncIconRotation: Double = 0
    @State private var justSyncedFlash = false
    // Timer-driven rotation is used instead of a repeatForever SwiftUI animation
    // because repeatForever does not cleanly stop when the driving state flips off.
    @State private var rotationTimer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                    .rotationEffect(.degrees(syncIconRotation))
                    .scaleEffect(justSyncedFlash ? 1.25 : 1.0)
                    .animation(.easeInOut(duration: 0.35), value: justSyncedFlash)
                    .onChange(of: viewModel.isSyncing) { _, syncing in
                        if syncing {
                            startSpin()
                        } else {
                            stopSpin()
                            justSyncedFlash = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation(.easeOut(duration: 0.35)) {
                                    justSyncedFlash = false
                                }
                            }
                        }
                    }
                    .onDisappear { stopSpin() }

                Text("ClaudeForge")
                    .font(.headline)

                if viewModel.pendingTotalCount > 0 {
                    PendingBadge(count: viewModel.pendingTotalCount)
                }

                Spacer()

                Button {
                    viewModel.syncToRepo()
                } label: {
                    Label(viewModel.isSyncing ? "Syncing…" : "Sync", systemImage: "arrow.triangle.2.circlepath")
                        .labelStyle(.titleAndIcon)
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(viewModel.isSyncing || viewModel.targetRepoURL == nil)

                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
                .help("HUD settings")
            }

            if viewModel.targetRepoURL == nil {
                Text("No target repo set — captures live in app only. Open settings to point at a repo.")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            } else if !viewModel.lastSyncMessage.isEmpty {
                Text(viewModel.lastSyncMessage)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else if let failure = viewModel.syncFailure {
                Text(failure)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .lineLimit(3)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }

    private var iconName: String {
        if viewModel.isSyncing { return "gearshape.2.fill" }
        if justSyncedFlash     { return "checkmark.seal.fill" }
        return "hammer.fill"
    }

    private var iconColor: Color {
        if viewModel.isSyncing { return .accentColor }
        if justSyncedFlash     { return .green }
        return .orange
    }

    private func startSpin() {
        rotationTimer?.invalidate()
        let step = 6.0 // degrees per tick (360° / 60 ticks = 1s per revolution)
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            syncIconRotation = (syncIconRotation + step).truncatingRemainder(dividingBy: 360)
        }
    }

    private func stopSpin() {
        rotationTimer?.invalidate()
        rotationTimer = nil
        syncIconRotation = 0
    }
}

private struct PendingBadge: View {
    let count: Int
    var body: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(Color.orange)
                .frame(width: 6, height: 6)
            Text("\(count) unsynced")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.orange)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.orange.opacity(0.12), in: Capsule())
    }
}

// MARK: - Capture tab

private struct HUDCaptureView: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var captureType: CaptureType = .hazard

    enum CaptureType: String, CaseIterable, Identifiable {
        case hazard = "Hazard"
        case bug = "Bug"
        case idea = "Idea"
        case screenshot = "Shot"

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
            case .idea:
                IdeaCaptureForm()
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
                ForEach(Array(viewModel.hazards.reversed())) { hazard in
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
        .background(CaptureRowStyle.background(for: hazard.syncState), in: RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(CaptureRowStyle.strokeColor(for: hazard.syncState), lineWidth: 1)
                .allowsHitTesting(false)
        )
    }
}

enum CaptureRowStyle {
    static func background(for state: SyncState) -> Color {
        switch state {
        case .pending: return Color.orange.opacity(0.12)
        case .synced:  return Color.blue.opacity(0.08)
        }
    }

    static func strokeColor(for state: SyncState) -> Color {
        switch state {
        case .pending: return Color.orange.opacity(0.30)
        case .synced:  return Color.blue.opacity(0.25)
        }
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
                ForEach(Array(viewModel.bugs.reversed())) { bug in
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
        .background(CaptureRowStyle.background(for: bug.syncState), in: RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(CaptureRowStyle.strokeColor(for: bug.syncState), lineWidth: 1)
                .allowsHitTesting(false)
        )
    }
}

// MARK: - Idea capture

private struct IdeaCaptureForm: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var title = ""
    @State private var why = ""
    @State private var sketch = ""
    @State private var justAdded = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Log a bright idea — speculative, not yet committed scope.")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Title (short description)", text: $title)
                .textFieldStyle(.roundedBorder)

            TextField("Why it matters (the user problem or value)", text: $why, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)

            TextField("Sketch (one-line shape of what it might look like)", text: $sketch, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button {
                    viewModel.addIdea(title: title, whyItMatters: why, sketch: sketch)
                    justAdded = title
                    title = ""
                    why = ""
                    sketch = ""
                } label: {
                    Label("Log Idea", systemImage: "lightbulb.fill")
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

            if !viewModel.ideas.isEmpty {
                Divider().padding(.vertical, 4)
                Text("Current ideas (\(viewModel.ideas.count))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                ForEach(Array(viewModel.ideas.reversed())) { idea in
                    IdeaRow(idea: idea) {
                        viewModel.removeIdea(idea)
                    }
                }
            }
        }
    }
}

private struct IdeaRow: View {
    let idea: Idea
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.caption)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(idea.title)
                    .font(.callout.weight(.medium))
                    .lineLimit(2)
                if !idea.whyItMatters.isEmpty {
                    Text(idea.whyItMatters)
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
        .background(CaptureRowStyle.background(for: idea.syncState), in: RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(CaptureRowStyle.strokeColor(for: idea.syncState), lineWidth: 1)
                .allowsHitTesting(false)
        )
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

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
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

// MARK: - Archive tab (git history → removed captures)

private struct HUDArchiveView: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var removed: [RemovedCaptureBlock] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Removed captures")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    loadHistory()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.caption2)
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
                .disabled(viewModel.targetRepoURL == nil || isLoading)
            }

            if viewModel.targetRepoURL == nil {
                Text("Set a target repo in settings to see history.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if isLoading {
                ProgressView("Reading git history…")
                    .controlSize(.small)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if removed.isEmpty {
                Text("No removed captures found in git history yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(removed) { block in
                    RemovedBlockRow(block: block) {
                        viewModel.restoreRemovedBlock(block)
                        // Refresh so the restored block drops out of the list.
                        loadHistory()
                    }
                }
            }
        }
        .onAppear {
            if viewModel.targetRepoURL != nil && removed.isEmpty && errorMessage == nil {
                loadHistory()
            }
        }
    }

    private func loadHistory() {
        guard let root = viewModel.targetRepoURL else { return }
        isLoading = true
        errorMessage = nil
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let blocks = try RepoSyncService.fetchRemovedBlocks(targetRoot: root)
                DispatchQueue.main.async {
                    removed = blocks
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

private struct RemovedBlockRow: View {
    let block: RemovedCaptureBlock
    let onRestore: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: iconName)
                .foregroundStyle(.secondary)
                .font(.caption)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(block.title)
                    .font(.callout.weight(.medium))
                    .lineLimit(2)
                Text("\(block.file) · commit \(block.commit)\(dateSuffix)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            Button {
                onRestore()
            } label: {
                Label("Restore", systemImage: "arrow.uturn.backward")
                    .font(.caption2)
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
        }
        .padding(8)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
    }

    private var iconName: String {
        switch block.file {
        case "HAZARDS.md": return "exclamationmark.triangle"
        case "BUGS.md":    return "ant"
        case "IDEAS.md":   return "lightbulb"
        default:           return "doc.text"
        }
    }

    private var dateSuffix: String {
        guard let d = block.removedAt else { return "" }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return " · \(df.string(from: d))"
    }
}

// MARK: - Settings sheet

private struct HUDSettingsSheet: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("HUD Settings")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Target Repo Folder")
                    .font(.callout.weight(.semibold))

                Text("Captures from the HUD are written to HAZARDS.md / BUGS.md / IDEAS.md in this folder. The Sync button runs git add / commit / push here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(viewModel.targetRepoURL == nil ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.accentColor))
                    Text(viewModel.targetRepoURL?.path ?? "No target repo set")
                        .font(.caption)
                        .lineLimit(2)
                        .truncationMode(.middle)
                    Spacer()
                }
                .padding(8)
                .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))

                HStack {
                    Button {
                        viewModel.chooseTargetRepo()
                    } label: {
                        Label(viewModel.targetRepoURL == nil ? "Choose Folder…" : "Change Folder…", systemImage: "folder.badge.plus")
                    }
                    if viewModel.targetRepoURL != nil {
                        Button(role: .destructive) {
                            viewModel.clearTargetRepo()
                        } label: {
                            Text("Clear")
                        }
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Last Sync")
                    .font(.callout.weight(.semibold))
                if viewModel.lastSyncMessage.isEmpty && viewModel.syncFailure == nil {
                    Text("No sync yet this session.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !viewModel.lastSyncMessage.isEmpty {
                    Text(viewModel.lastSyncMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let failure = viewModel.syncFailure {
                    Text(failure)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(width: 420, height: 340)
    }
}
