import SwiftUI
import SwiftData

@main
struct AllMyChecklistsApp: App {
    var body: some Scene {
        WindowGroup {
            RootEntryView()
            .modelContainer(for: [ChecklistTemplate.self, ChecklistItemTemplate.self, ChecklistRun.self, ChecklistRunItem.self, UserStats.self, CompletionRecord.self, Achievement.self])
            .environmentObject(HapticsManager())
        }
    }
}

