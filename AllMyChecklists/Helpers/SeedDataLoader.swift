import Foundation
import SwiftData

enum SeedDataLoader {
    static func seedIfNeeded(using modelContext: ModelContext) async {
        let hasSeeded = UserDefaults.standard.bool(forKey: "seededSamples")
        if !hasSeeded {
            await seedSamples(using: modelContext)
        }
    }

    @MainActor
    static func seedSamples(using modelContext: ModelContext? = nil, force: Bool = false) async {
        let modelContext = modelContext ?? (try? ModelContainer(for: ChecklistTemplate.self, ChecklistItemTemplate.self, ChecklistRun.self, ChecklistRunItem.self).mainContext)
        guard let modelContext else { return }

        if !force {
            let existing = try? modelContext.fetch(FetchDescriptor<ChecklistTemplate>())
            if let existing, !existing.isEmpty { return }
        }

        let morning = ChecklistTemplate(name: "Morning Routine", category: SampleCategories.routines, items: [
            ChecklistItemTemplate(title: "Wake up", sortOrder: 0),
            ChecklistItemTemplate(title: "Drink water", sortOrder: 1),
            ChecklistItemTemplate(title: "Brush teeth", sortOrder: 2),
            ChecklistItemTemplate(title: "Plan day", notes: "Top 3 tasks", sortOrder: 3)
        ])

        let work = ChecklistTemplate(name: "Work Startup", category: SampleCategories.work, items: [
            ChecklistItemTemplate(title: "Review calendar", sortOrder: 0),
            ChecklistItemTemplate(title: "Process inbox", sortOrder: 1),
            ChecklistItemTemplate(title: "Daily standup notes", sortOrder: 2)
        ])

        let domestic = ChecklistTemplate(name: "Domestic Flight", category: SampleCategories.travel, items: [
            ChecklistItemTemplate(title: "Check-in online", sortOrder: 0),
            ChecklistItemTemplate(title: "ID / Wallet", sortOrder: 1),
            ChecklistItemTemplate(title: "Boarding pass", sortOrder: 2),
            ChecklistItemTemplate(title: "Carry-on packed", sortOrder: 3)
        ])

        let international = ChecklistTemplate(name: "International Flight", category: SampleCategories.travel, items: [
            ChecklistItemTemplate(title: "Passport", isRequired: true, sortOrder: 0),
            ChecklistItemTemplate(title: "Visa/ESTA", sortOrder: 1),
            ChecklistItemTemplate(title: "Travel insurance", sortOrder: 2),
            ChecklistItemTemplate(title: "Currency / Cards", sortOrder: 3)
        ])

        let library = ChecklistTemplate(name: "Library Trip", category: SampleCategories.errands, items: [
            ChecklistItemTemplate(title: "Books to return", sortOrder: 0),
            ChecklistItemTemplate(title: "Hold pickups", sortOrder: 1),
            ChecklistItemTemplate(title: "Study list", sortOrder: 2)
        ])

        modelContext.insert(morning)
        modelContext.insert(work)
        modelContext.insert(domestic)
        modelContext.insert(international)
        modelContext.insert(library)

        try? modelContext.save()
        UserDefaults.standard.set(true, forKey: "seededSamples")
    }
}

