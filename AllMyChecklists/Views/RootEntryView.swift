import SwiftUI
import SwiftData

struct RootEntryView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                RootTabView()
            } else {
                OnboardingView(onFinished: {
                    hasCompletedOnboarding = true
                })
            }
        }
        .task { await handleLaunchArguments() }
    }

    @MainActor
    private func handleLaunchArguments() async {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-resetOnboarding") {
            hasCompletedOnboarding = false
        }
        if args.contains("-wipeData") {
            try? wipeAllData()
        }
        if args.contains("-seedSamples") {
            await SeedDataLoader.seedSamples(using: context, force: true)
        }
    }

    private func wipeAllData() throws {
        let descriptor1 = FetchDescriptor<ChecklistTemplate>()
        let templates = try context.fetch(descriptor1)
        templates.forEach { context.delete($0) }
        let descriptor2 = FetchDescriptor<ChecklistRun>()
        let runs = try context.fetch(descriptor2)
        runs.forEach { context.delete($0) }
        try context.save()
        UserDefaults.standard.removeObject(forKey: "seededSamples")
    }
}


