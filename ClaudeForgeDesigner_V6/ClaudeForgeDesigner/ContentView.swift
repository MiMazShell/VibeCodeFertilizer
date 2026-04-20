import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: WizardViewModel

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 250, ideal: 280)
        } detail: {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(nsColor: .windowBackgroundColor),
                        Color.accentColor.opacity(0.08),
                        Color.white.opacity(0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    Group {
                        switch viewModel.currentStep {
                        case .overview:
                            OverviewStepView()
                        case .project:
                            ProjectSetupStepView()
                        case .standards:
                            StandardsStepView()
                        case .rules:
                            RulesStepView()
                        case .designStudio:
                            ThemeStepView()
                        case .screenshots:
                            ScreenshotsStepView()
                        case .repo:
                            RepoStepView()
                        case .review:
                            ReviewExportStepView()
                        }
                    }
                    .padding(28)
                }
            }
        }
        .onAppear {
            viewModel.regenerateFiles()
        }
    }
}
