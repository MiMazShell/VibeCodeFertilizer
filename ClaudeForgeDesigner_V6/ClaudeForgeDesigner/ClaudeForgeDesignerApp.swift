import SwiftUI

@main
struct ClaudeForgeDesignerApp: App {
    @StateObject private var viewModel = WizardViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 1100, minHeight: 760)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        MenuBarExtra("ClaudeForge", systemImage: "hammer.fill") {
            HUDView()
                .environmentObject(viewModel)
                .frame(width: 380, height: 520)
        }
        .menuBarExtraStyle(.window)
    }
}
