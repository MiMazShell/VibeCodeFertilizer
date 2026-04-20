import SwiftUI

struct ThemeStepView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        StepContainer(
            title: "Design Studio",
            subtitle: "Choose the visual language, then see a live style preview so the user understands what the settings mean before export."
        ) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    InfoCard(title: "Theme preset", symbol: "paintpalette") {
                        Picker("Theme preset", selection: $viewModel.themePreset) {
                            ForEach(ThemePreset.allCases) { preset in
                                Text(preset.rawValue).tag(preset)
                            }
                        }
                        Text(viewModel.themePreset.summary)
                            .foregroundStyle(.secondary)
                    }

                    InfoCard(title: "Mood, surfaces, and motion", symbol: "sparkles") {
                        Picker("Mood", selection: $viewModel.moodStyle) {
                            ForEach(MoodStyle.allCases) { mood in
                                Text(mood.rawValue).tag(mood)
                            }
                        }
                        Picker("Surface style", selection: $viewModel.surfaceStyle) {
                            ForEach(SurfaceStyle.allCases) { surface in
                                Text(surface.rawValue).tag(surface)
                            }
                        }
                        Picker("Animation style", selection: $viewModel.animationStyle) {
                            ForEach(AnimationStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        Text(viewModel.animationStyle.summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(alignment: .top, spacing: 16) {
                    InfoCard(title: "Layout and navigation", symbol: "sidebar.leading") {
                        Picker("Navigation", selection: $viewModel.navigationStyle) {
                            ForEach(NavigationStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        Text(viewModel.navigationStyle.summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Picker("Density", selection: $viewModel.densityStyle) {
                            ForEach(DensityStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        LabeledToggle(title: "Include inspector", subtitle: "Generate guidance that includes a contextual inspector or details pane.", isOn: $viewModel.includeInspector)
                        LabeledToggle(title: "Include search", subtitle: "Generate visible search affordances for content-heavy workflows.", isOn: $viewModel.includeSearch)
                        LabeledToggle(title: "Include command palette prompts", subtitle: "Add power-user guidance for quick actions or command-driven behavior.", isOn: $viewModel.includeCommandPalettePrompt)
                    }

                    InfoCard(title: "Controls, menus, type, and color", symbol: "slider.horizontal.3") {
                        Picker("Control style", selection: $viewModel.controlStyle) {
                            ForEach(ControlStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        Picker("Menu chrome", selection: $viewModel.menuChromeStyle) {
                            ForEach(MenuChromeStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        Picker("Typography", selection: $viewModel.typographyStyle) {
                            ForEach(TypographyStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        Picker("Color palette", selection: $viewModel.colorPalette) {
                            ForEach(ColorPalette.allCases) { palette in
                                Text(palette.rawValue).tag(palette)
                            }
                        }
                        PreviewBadgeRow(values: viewModel.colorPalette.swatches)
                    }
                }

                InfoCard(title: "Live style preview", symbol: "eye") {
                    DesignPreviewCard()
                }

                HStack(alignment: .top, spacing: 16) {
                    InfoCard(title: "Component preview", symbol: "square.grid.2x2") {
                        ComponentPreviewStrip()
                    }

                    InfoCard(title: "Animation preview", symbol: "waveform.path") {
                        AnimationPreviewCard()
                    }
                }

                InfoCard(title: "Design pack output", symbol: "rectangle.3.group") {
                    Text("This step exports both text files and SVG reference images inside design-examples/ so Claude can reason from written rules and visual examples.")
                        .foregroundStyle(.secondary)
                    PreviewBadgeRow(values: ["theme-definition.txt", "ui-rules.txt", "component-guidelines.txt", "palette.svg", "window-wireframe.svg", "component-sheet.svg"])
                }
            }
        }
    }
}

private struct DesignPreviewCard: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    private var spacingValue: CGFloat {
        switch viewModel.densityStyle {
        case .airy: return 16
        case .balanced: return 11
        case .compact: return 7
        }
    }

    private var sidebarWidth: CGFloat {
        switch viewModel.navigationStyle {
        case .utility: return 116
        case .sidebar: return 180
        case .splitInspector: return 170
        case .tabSidebar: return 190
        }
    }

    private var headerHeight: CGFloat {
        switch viewModel.densityStyle {
        case .airy: return 42
        case .balanced: return 34
        case .compact: return 28
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle().fill(Color(hex: viewModel.colorPalette.swatches[2]) ?? .accentColor).frame(width: 12, height: 12)
                Circle().fill(Color.orange).frame(width: 12, height: 12)
                Circle().fill(Color.green).frame(width: 12, height: 12)
                Spacer()
                if viewModel.includeSearch {
                    searchBar
                }
            }

            HStack(spacing: 12) {
                sidebarView
                contentView
                if viewModel.includeInspector {
                    inspectorView
                }
            }
            .frame(height: 270)

            HStack(spacing: 10) {
                PillTag(text: viewModel.moodStyle.rawValue)
                PillTag(text: viewModel.surfaceStyle.rawValue)
                PillTag(text: viewModel.menuChromeStyle.rawValue)
                PillTag(text: viewModel.animationStyle.rawValue)
            }
        }
        .padding(18)
        .background(backgroundFill, in: RoundedRectangle(cornerRadius: outerCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: outerCornerRadius)
                .stroke(Color.white.opacity(borderOpacity), lineWidth: 1)
        )
        .animation(animationValue, value: viewModel.navigationStyle)
        .animation(animationValue, value: viewModel.controlStyle)
        .animation(animationValue, value: viewModel.typographyStyle)
        .animation(animationValue, value: viewModel.colorPalette)
        .animation(animationValue, value: viewModel.surfaceStyle)
        .animation(animationValue, value: viewModel.densityStyle)
        .animation(animationValue, value: viewModel.includeInspector)
        .animation(animationValue, value: viewModel.includeSearch)
        .animation(animationValue, value: viewModel.moodStyle)
        .animation(animationValue, value: viewModel.menuChromeStyle)
    }

    private var sidebarView: some View {
        RoundedRectangle(cornerRadius: menuCornerRadius)
            .fill(sidebarFill)
            .frame(width: sidebarWidth)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: spacingValue) {
                    Text(sidebarHeading)
                        .font(.headline)
                    if viewModel.navigationStyle == .tabSidebar {
                        HStack(spacing: 6) {
                            miniTab("Build", selected: true)
                            miniTab("Plan", selected: false)
                        }
                    }
                    ForEach(sidebarItems, id: \.self) { item in
                        Text(item)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, viewModel.densityStyle == .airy ? 8 : 6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(item == sidebarItems[1] ? accentSoft : Color.clear, in: Capsule())
                    }
                }
                .padding(16)
            }
    }

    private var contentView: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(contentFill)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: spacingValue) {
                    HStack {
                        Text("\(viewModel.themePreset.rawValue) preview")
                            .font(titleFont)
                        Spacer()
                        headerChip(text: viewModel.animationStyle.rawValue)
                    }
                    Text("\(viewModel.navigationStyle.rawValue) • \(viewModel.controlStyle.rawValue) • \(viewModel.typographyStyle.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        primaryButton
                        secondaryButton
                        menuPreview
                    }

                    RoundedRectangle(cornerRadius: 18)
                        .fill(panelFill)
                        .frame(height: 104)
                        .overlay(alignment: .leading) {
                            VStack(alignment: .leading, spacing: spacingValue - 2) {
                                Text(contentHeading)
                                    .font(.headline)
                                Text(contentDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                        }

                    HStack(spacing: 12) {
                        metricCard(title: "Spacing", value: viewModel.densityStyle.rawValue)
                        metricCard(title: "Menus", value: viewModel.menuChromeStyle.rawValue)
                        metricCard(title: "Motion", value: viewModel.animationStyle.rawValue)
                    }
                }
                .padding(18)
            }
    }

    private var inspectorView: some View {
        RoundedRectangle(cornerRadius: menuCornerRadius)
            .fill(panelFill)
            .frame(width: viewModel.navigationStyle == .utility ? 124 : 150)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: spacingValue) {
                    Text(viewModel.navigationStyle == .splitInspector ? "Inspector" : "Details")
                        .font(.headline)
                    Text("Color")
                        .font(.caption)
                    Text("Spacing")
                        .font(.caption)
                    Text("States")
                        .font(.caption)
                    if viewModel.includeCommandPalettePrompt {
                        headerChip(text: "⌘K")
                    }
                }
                .padding(16)
            }
    }

    private var searchBar: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.white.opacity(0.82))
            .frame(width: 180, height: 26)
            .overlay(alignment: .leading) {
                Text(viewModel.navigationStyle == .utility ? "Quick search" : "Search")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 10)
            }
    }

    private var primaryButton: some View {
        RoundedRectangle(cornerRadius: buttonCornerRadius)
            .fill(primaryButtonFill)
            .frame(width: 122, height: headerHeight)
            .overlay {
                Text(primaryButtonTitle)
                    .foregroundStyle(viewModel.controlStyle == .outlineMinimal ? Color.primary : Color.white)
                    .font(buttonFont)
            }
    }

    private var secondaryButton: some View {
        RoundedRectangle(cornerRadius: buttonCornerRadius)
            .stroke(borderColor, lineWidth: 1)
            .background(Color.clear)
            .frame(width: 118, height: headerHeight)
            .overlay {
                Text("Secondary")
                    .font(buttonFont)
            }
    }

    private var menuPreview: some View {
        RoundedRectangle(cornerRadius: menuCornerRadius)
            .fill(menuFill)
            .frame(width: 120, height: headerHeight)
            .overlay(alignment: .leading) {
                HStack(spacing: 8) {
                    Text(menuTitle)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal, 12)
            }
    }

    private func metricCard(title: String, value: String) -> some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(panelFill)
            .frame(height: 64)
            .overlay(alignment: .leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 14)
            }
    }

    private func miniTab(_ title: String, selected: Bool) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(selected ? accentSoft : Color.clear, in: Capsule())
    }

    private func headerChip(text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(panelFill, in: Capsule())
    }

    private var sidebarHeading: String {
        switch viewModel.navigationStyle {
        case .sidebar: return "Navigation"
        case .splitInspector: return "Sections"
        case .tabSidebar: return "Workspaces"
        case .utility: return "Quick Tool"
        }
    }

    private var sidebarItems: [String] {
        switch viewModel.navigationStyle {
        case .utility: return ["Convert", "Capture", "Export"]
        case .tabSidebar: return ["Overview", "Design", "Prompts", "Export"]
        case .splitInspector: return ["Overview", "Selection", "Inspector"]
        case .sidebar: return ["Overview", "Projects", "Design", "Export"]
        }
    }

    private var contentHeading: String {
        switch viewModel.themePreset {
        case .appleProfessional: return "Native structure"
        case .glassProductivity: return "Layered productivity"
        case .calmUtility: return "Quiet utility panels"
        case .boldCreator: return "Expressive workspace"
        }
    }

    private var contentDescription: String {
        switch viewModel.animationStyle {
        case .minimal: return "Motion is restrained and used only to support state changes."
        case .crisp: return "Fast transitions keep the interface feeling efficient and precise."
        case .calm: return "Subtle movement supports focus without stealing attention."
        case .premium: return "Soft easing makes state changes feel polished and premium."
        case .springy: return "Playful motion adds energy while still staying platform-native."
        }
    }

    private var buttonFont: Font {
        switch viewModel.typographyStyle {
        case .systemBalanced: return .headline
        case .largeProductivity: return .title3.weight(.semibold)
        case .compactUtility: return .subheadline.weight(.semibold)
        case .editorial: return .title3.weight(.bold)
        }
    }

    private var titleFont: Font {
        switch viewModel.typographyStyle {
        case .systemBalanced: return .title3.weight(.semibold)
        case .largeProductivity: return .title2.weight(.bold)
        case .compactUtility: return .headline.weight(.semibold)
        case .editorial: return .title3.weight(.bold)
        }
    }

    private var menuTitle: String {
        switch viewModel.menuChromeStyle {
        case .rounded: return "Rounded"
        case .subtle: return "Subtle"
        case .floating: return "Floating"
        case .utility: return "Utility"
        }
    }

    private var primaryButtonTitle: String {
        viewModel.navigationStyle == .utility ? "Run" : "Primary"
    }

    private var buttonCornerRadius: CGFloat {
        switch viewModel.controlStyle {
        case .nativeFilled: return 12
        case .tintedToolbar: return 10
        case .softGlass: return 16
        case .outlineMinimal: return 12
        }
    }

    private var menuCornerRadius: CGFloat {
        switch viewModel.menuChromeStyle {
        case .rounded: return 18
        case .subtle: return 12
        case .floating: return 20
        case .utility: return 10
        }
    }

    private var outerCornerRadius: CGFloat {
        switch viewModel.surfaceStyle {
        case .layeredGlass: return 26
        case .cardStacks: return 22
        case .flatPanels: return 18
        case .standardMaterial: return 24
        }
    }

    private var panelFill: Color {
        switch viewModel.surfaceStyle {
        case .standardMaterial: return .white.opacity(0.58)
        case .layeredGlass: return .white.opacity(0.46)
        case .cardStacks: return .white.opacity(0.84)
        case .flatPanels: return .gray.opacity(0.12)
        }
    }

    private var contentFill: Color {
        switch viewModel.moodStyle {
        case .calm: return .white.opacity(0.80)
        case .premium: return .white.opacity(0.84)
        case .playful: return .white.opacity(0.76)
        case .enterprise: return .white.opacity(0.90)
        case .futuristic: return .white.opacity(0.72)
        }
    }

    private var menuFill: Color {
        switch viewModel.menuChromeStyle {
        case .rounded: return panelFill.opacity(0.94)
        case .subtle: return Color.white.opacity(0.66)
        case .floating: return accentSoft.opacity(0.60)
        case .utility: return Color.black.opacity(0.06)
        }
    }

    private var sidebarFill: Color {
        switch viewModel.moodStyle {
        case .calm: return panelFill
        case .premium: return panelFill.opacity(0.96)
        case .playful: return accentSoft.opacity(0.42)
        case .enterprise: return Color.white.opacity(0.62)
        case .futuristic: return Color.black.opacity(0.08)
        }
    }

    private var backgroundFill: LinearGradient {
        let start = Color(hex: viewModel.colorPalette.swatches[0]) ?? .white
        let mid = Color(hex: viewModel.colorPalette.swatches[1]) ?? .white
        let accent = Color(hex: viewModel.colorPalette.swatches[2]) ?? Color.accentColor
        let deep = Color(hex: viewModel.colorPalette.swatches[3]) ?? Color.accentColor

        switch viewModel.moodStyle {
        case .calm:
            return LinearGradient(colors: [start, mid, accent.opacity(0.28)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .premium:
            return LinearGradient(colors: [start, mid, deep.opacity(0.28)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .playful:
            return LinearGradient(colors: [start, accent.opacity(0.28), deep.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .enterprise:
            return LinearGradient(colors: [start, mid, Color.gray.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .futuristic:
            return LinearGradient(colors: [start.opacity(0.92), deep.opacity(0.22), Color.black.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var accentSoft: Color {
        let base = Color(hex: viewModel.colorPalette.swatches[1]) ?? .accentColor
        switch viewModel.moodStyle {
        case .calm: return base.opacity(0.82)
        case .premium: return base.opacity(0.92)
        case .playful: return (Color(hex: viewModel.colorPalette.swatches[2]) ?? .accentColor).opacity(0.78)
        case .enterprise: return base.opacity(0.70)
        case .futuristic: return (Color(hex: viewModel.colorPalette.swatches[3]) ?? .accentColor).opacity(0.52)
        }
    }

    private var primaryButtonFill: Color {
        switch viewModel.controlStyle {
        case .nativeFilled:
            return Color(hex: viewModel.colorPalette.swatches[2]) ?? .accentColor
        case .tintedToolbar:
            return Color(hex: viewModel.colorPalette.swatches[3]) ?? .accentColor
        case .softGlass:
            return (Color(hex: viewModel.colorPalette.swatches[2]) ?? .accentColor).opacity(0.82)
        case .outlineMinimal:
            return .white.opacity(0.35)
        }
    }

    private var borderColor: Color {
        switch viewModel.controlStyle {
        case .outlineMinimal:
            return Color.primary.opacity(0.22)
        default:
            return Color.secondary.opacity(0.25)
        }
    }

    private var borderOpacity: Double {
        switch viewModel.surfaceStyle {
        case .layeredGlass: return 0.22
        case .cardStacks: return 0.16
        case .flatPanels: return 0.08
        case .standardMaterial: return 0.18
        }
    }

    private var animationValue: Animation {
        switch viewModel.animationStyle {
        case .calm:
            return .easeInOut(duration: 0.42)
        case .springy:
            return .spring(response: 0.46, dampingFraction: 0.68)
        case .crisp:
            return .easeOut(duration: 0.2)
        case .premium:
            return .easeInOut(duration: 0.55)
        case .minimal:
            return .linear(duration: 0.14)
        }
    }
}

private struct ComponentPreviewStrip: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                sampleButton("Primary", filled: true)
                sampleButton("Ghost", filled: false)
                sampleDropDown
            }
            HStack(spacing: 12) {
                sampleCard(title: "Sidebar Pane", subtitle: viewModel.navigationStyle.rawValue)
                sampleCard(title: "Typography", subtitle: viewModel.typographyStyle.rawValue)
                sampleCard(title: "Menu Chrome", subtitle: viewModel.menuChromeStyle.rawValue)
            }
        }
    }

    private func sampleButton(_ title: String, filled: Bool) -> some View {
        RoundedRectangle(cornerRadius: viewModel.controlStyle == .softGlass ? 16 : 12)
            .fill(filled ? (Color(hex: viewModel.colorPalette.swatches[2]) ?? .accentColor) : Color.white.opacity(0.4))
            .frame(width: 100, height: 36)
            .overlay {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(filled ? Color.white : Color.primary)
            }
    }

    private var sampleDropDown: some View {
        RoundedRectangle(cornerRadius: viewModel.menuChromeStyle == .floating ? 18 : 12)
            .fill(Color.white.opacity(viewModel.menuChromeStyle == .utility ? 0.50 : 0.70))
            .frame(width: 116, height: 36)
            .overlay {
                HStack(spacing: 8) {
                    Text(viewModel.menuChromeStyle == .utility ? "Utility" : "Menu")
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
            }
    }

    private func sampleCard(title: String, subtitle: String) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.62))
            .frame(height: 86)
            .overlay(alignment: .leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(subtitle)
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 14)
            }
    }
}

private struct AnimationPreviewCard: View {
    @EnvironmentObject private var viewModel: WizardViewModel
    @State private var active = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Animation intent")
                .font(.headline)
            Text(viewModel.animationStyle.summary)
                .font(.caption)
                .foregroundStyle(.secondary)

            ZStack(alignment: active ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.45))
                    .frame(height: 70)
                Circle()
                    .fill(Color(hex: viewModel.colorPalette.swatches[2]) ?? .accentColor)
                    .frame(width: active ? 28 : 20, height: active ? 28 : 20)
                    .padding(.horizontal, 16)
            }
            .animation(previewAnimation, value: active)

            Button(active ? "Replay" : "Preview motion") {
                active.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    active = false
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var previewAnimation: Animation {
        switch viewModel.animationStyle {
        case .calm:
            return .easeInOut(duration: 0.55)
        case .springy:
            return .spring(response: 0.42, dampingFraction: 0.62)
        case .crisp:
            return .easeOut(duration: 0.18)
        case .premium:
            return .easeInOut(duration: 0.70)
        case .minimal:
            return .linear(duration: 0.18)
        }
    }
}
