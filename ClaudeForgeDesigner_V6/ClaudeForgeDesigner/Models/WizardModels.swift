import Foundation

struct WizardStepItem: Identifiable, Hashable {
    let id: WizardStep
    let title: String
    let subtitle: String
    let symbol: String
}

enum WizardStep: String, CaseIterable, Identifiable {
    case overview
    case project
    case standards
    case rules
    case designStudio
    case screenshots
    case repo
    case review

    var id: String { rawValue }
}

enum TargetPlatform: String, CaseIterable, Identifiable, Hashable {
    case macOS = "macOS"
    case iPhone = "iPhone"
    case iPad = "iPad"

    var id: String { rawValue }

    var designSummary: String {
        switch self {
        case .macOS:
            return "Desktop-first layout, sidebars, inspectors, menus, keyboard shortcuts, and spacious productivity workflows."
        case .iPhone:
            return "Focused touch-first navigation, strong hierarchy, compact layouts, and short, clear task flows."
        case .iPad:
            return "Large-canvas navigation with split views, side panels, adaptable layouts, and flexible productivity zones."
        }
    }
}

enum ComplexityLevel: String, CaseIterable, Identifiable {
    case prototype = "Prototype"
    case focusedV1 = "Focused V1"
    case advancedV1 = "Advanced V1"
    case ambitious = "Ambitious"

    var id: String { rawValue }

    var summary: String {
        switch self {
        case .prototype:
            return "Small feature set, fast learning loop, and minimal polish for exploring the idea."
        case .focusedV1:
            return "A realistic first release with a tight feature set and intentional polish on the essentials."
        case .advancedV1:
            return "A stronger first release with more states, edge cases, and production-aware structure."
        case .ambitious:
            return "A broader, more demanding project that may need phased delivery and stricter scope control."
        }
    }
}

enum PolishLevel: String, CaseIterable, Identifiable {
    case practical = "Practical"
    case refined = "Refined"
    case premium = "Premium"

    var id: String { rawValue }
}

enum ThemePreset: String, CaseIterable, Identifiable {
    case appleProfessional = "Apple Professional"
    case glassProductivity = "Glass Productivity"
    case calmUtility = "Calm Utility"
    case boldCreator = "Bold Creator"

    var id: String { rawValue }

    var summary: String {
        switch self {
        case .appleProfessional:
            return "Clean native structure, restrained color, familiar Apple controls, and strong hierarchy."
        case .glassProductivity:
            return "Layered materials, soft chrome, floating emphasis, and a contemporary productivity feel."
        case .calmUtility:
            return "Quiet utility styling with subtle borders, neutral tones, and clarity-first surfaces."
        case .boldCreator:
            return "Creative but still Apple-friendly, with stronger accents and more expressive presentation."
        }
    }
}

enum NavigationStyle: String, CaseIterable, Identifiable {
    case sidebar = "Sidebar + Detail"
    case splitInspector = "Split View + Inspector"
    case tabSidebar = "Sidebar + Section Tabs"
    case utility = "Single Utility Window"

    var id: String { rawValue }

    var summary: String {
        switch self {
        case .sidebar:
            return "A familiar Apple productivity layout with navigation on the left and content on the right."
        case .splitInspector:
            return "A multi-pane productivity flow with a focused detail area and a contextual inspector."
        case .tabSidebar:
            return "A hybrid navigation structure for apps with several major work modes."
        case .utility:
            return "A compact tool-focused window for quick tasks, conversion, capture, or utility actions."
        }
    }
}

enum ControlStyle: String, CaseIterable, Identifiable {
    case nativeFilled = "Native Filled"
    case tintedToolbar = "Tinted Toolbar"
    case softGlass = "Soft Glass"
    case outlineMinimal = "Outline Minimal"

    var id: String { rawValue }
}

enum TypographyStyle: String, CaseIterable, Identifiable {
    case systemBalanced = "SF Pro Balanced"
    case largeProductivity = "Large Productivity"
    case compactUtility = "Compact Utility"
    case editorial = "Editorial Contrast"

    var id: String { rawValue }
}

enum ColorPalette: String, CaseIterable, Identifiable {
    case blueSlate = "Blue Slate"
    case graphite = "Graphite Neutral"
    case sunrise = "Sunrise Accent"
    case mintViolet = "Mint + Violet"

    var id: String { rawValue }

    var swatches: [String] {
        switch self {
        case .blueSlate:
            return ["#EEF4FF", "#D5E5FF", "#7BA7FF", "#315C96", "#18283D"]
        case .graphite:
            return ["#F5F5F7", "#DCDCE1", "#8D8E98", "#4E505D", "#22242B"]
        case .sunrise:
            return ["#FFF6ED", "#FFD5B2", "#FF9A57", "#B45309", "#552400"]
        case .mintViolet:
            return ["#EDFDF7", "#C8FAEA", "#7FE1BE", "#7B61FF", "#281E65"]
        }
    }
}

enum SurfaceStyle: String, CaseIterable, Identifiable {
    case standardMaterial = "Standard Material"
    case layeredGlass = "Layered Glass"
    case cardStacks = "Card Stacks"
    case flatPanels = "Flat Panels"

    var id: String { rawValue }
}

enum MoodStyle: String, CaseIterable, Identifiable {
    case calm = "Calm"
    case premium = "Premium"
    case playful = "Playful"
    case enterprise = "Enterprise"
    case futuristic = "Futuristic"

    var id: String { rawValue }
}

enum DensityStyle: String, CaseIterable, Identifiable {
    case airy = "Airy"
    case balanced = "Balanced"
    case compact = "Compact"

    var id: String { rawValue }
}

enum MenuChromeStyle: String, CaseIterable, Identifiable {
    case rounded = "Rounded Menus"
    case subtle = "Subtle Menus"
    case floating = "Floating Menus"
    case utility = "Utility Menus"

    var id: String { rawValue }
}

enum AnimationStyle: String, CaseIterable, Identifiable {
    case calm = "Calm"
    case springy = "Springy"
    case crisp = "Crisp"
    case premium = "Premium"
    case minimal = "Minimal"

    var id: String { rawValue }

    var summary: String {
        switch self {
        case .calm:
            return "Soft, subtle transitions with low distraction."
        case .springy:
            return "Expressive motion with a more playful rebound."
        case .crisp:
            return "Fast, tidy changes suited to utility and productivity apps."
        case .premium:
            return "Smooth eased motion for a more polished, high-end feel."
        case .minimal:
            return "Almost static, with motion used only to explain state changes."
        }
    }
}

struct TriggerRule: Identifiable, Hashable {
    let id = UUID()
    var phrase: String
    var instruction: String
    var example: String
}

struct GeneratedFile: Identifiable, Hashable {
    let id = UUID()
    let relativePath: String
    var content: String
    var purpose: String
}

struct ImportedScreenshot: Identifiable, Hashable {
    let id = UUID()
    let sourceURL: URL
    var note: String

    var fileName: String {
        sourceURL.lastPathComponent
    }
}

struct CustomStandard: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var rule: String
}

struct Hazard: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var whyItBites: String
    var howToHandle: String
    var addedDate: Date = Date()
}

enum BugStatus: String, CaseIterable, Identifiable, Hashable {
    case open = "Open"
    case closed = "Closed"

    var id: String { rawValue }
}

struct Bug: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var symptom: String
    var suspectedArea: String
    var addedDate: Date = Date()
    var status: BugStatus = .open
}
