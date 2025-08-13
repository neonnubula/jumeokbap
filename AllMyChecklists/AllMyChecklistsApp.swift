import SwiftUI
import SwiftData

@main
struct AllMyChecklistsApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    RootTabView()
                } else {
                    OnboardingView(onFinished: {
                        hasCompletedOnboarding = true
                    })
                }
            }
            .modelContainer(for: [ChecklistTemplate.self, ChecklistItemTemplate.self, ChecklistRun.self, ChecklistRunItem.self])
            .environmentObject(HapticsManager())
        }
    }
}

