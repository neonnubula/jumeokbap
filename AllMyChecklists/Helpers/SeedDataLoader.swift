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
            // Even if templates exist, upsert the v2 defaults to replace similar lists
            applyDefaultTemplatesV2(using: modelContext)
            return
        }

        // Force reapply
        applyDefaultTemplatesV2(using: modelContext)
    }

    @MainActor
    static func applyDefaultTemplatesV2(using modelContext: ModelContext) {
        // Prevent re-applying on every launch; upsert once
        let versionKey = "seededSamplesVersion"
        let currentVersion = UserDefaults.standard.integer(forKey: versionKey)
        if currentVersion >= 2 { return }

        func upsert(name: String, category: String, items: [String]) {
            let fetch = FetchDescriptor<ChecklistTemplate>(predicate: #Predicate { $0.name == name })
            let existing = (try? modelContext.fetch(fetch))?.first

            let checklistItems = items.enumerated().map { idx, title in
                ChecklistItemTemplate(title: title, isRequired: true, sortOrder: idx)
            }

            if let template = existing {
                template.category = category
                template.updatedAt = .now
                template.items = checklistItems
            } else {
                let template = ChecklistTemplate(name: name, category: category, createdAt: .now, updatedAt: .now, items: checklistItems)
                modelContext.insert(template)
            }
        }

        // Morning routine
        upsert(
            name: "Morning Routine",
            category: SampleCategories.routines,
            items: [
                "Drink a glass of water",
                "Brush teeth",
                "Shower",
                "Make the bed",
                "Prepare breakfast",
                "Eat breakfast",
                "Do a workout",
                "Review top three priorities",
                "Check weather"
            ]
        )

        // Evening shutdown
        upsert(
            name: "Evening Shutdown",
            category: SampleCategories.routines,
            items: [
                "Tidy kitchen",
                "Pack bag for tomorrow",
                "Review tomorrow’s calendar",
                "Set alarms",
                "Read a book",
                "Stretch for five minutes",
                "Lock doors",
                "Adjust thermostat"
            ]
        )

        // Office day prep
        upsert(
            name: "Office Day Prep",
            category: SampleCategories.work,
            items: [
                "Pack laptop and charger",
                "Pack ID card",
                "Pack notebook",
                "Pack pen",
                "Prepare lunch",
                "Fill water bottle",
                "Pack headphones",
                "Confirm meeting times",
                "Check commute"
            ]
        )

        // Domestic flight
        upsert(
            name: "Domestic Flight",
            category: SampleCategories.travel,
            items: [
                "Check in online",
                "Save boarding pass",
                "Pack government ID",
                "Pack carry-on within limits",
                "Pack liquids in a clear bag",
                "Charge phone",
                "Charge power bank",
                "Download offline entertainment",
                "Arrive 90 minutes early"
            ]
        )

        // International trip
        upsert(
            name: "International Trip",
            category: SampleCategories.travel,
            items: [
                "Verify passport validity",
                "Confirm entry requirements",
                "Purchase travel insurance",
                "Enable travel alerts",
                "Obtain local currency",
                "Pack prescribed medications",
                "Download offline maps",
                "Pack adapters",
                "Pack chargers"
            ]
        )

        // Road trip
        upsert(
            name: "Road Trip",
            category: SampleCategories.travel,
            items: [
                "Plan route",
                "Check fuel level",
                "Check oil level",
                "Check tire pressure",
                "Pack emergency kit",
                "Pack snacks",
                "Pack water",
                "Download playlists",
                "Open toll app"
            ]
        )

        // Sunday reset
        upsert(
            name: "Sunday Reset",
            category: SampleCategories.routines,
            items: [
                "Review the upcoming week",
                "Call family members",
                "Plan meals for the week",
                "Build a grocery list",
                "Do laundry",
                "Tidy common areas",
                "Set weekly goals"
            ]
        )

        // Grocery and food shopping
        upsert(
            name: "Grocery Shopping",
            category: SampleCategories.errands,
            items: [
                "Check pantry for staple items",
                "Check fridge",
                "Check freezer",
                "Review meal plan",
                "Build a store list",
                "Take reusable bags",
                "Check loyalty app",
                "Take coin for trolley",
                "Bring payment method"
            ]
        )

        // Library visit
        upsert(
            name: "Library Visit",
            category: SampleCategories.errands,
            items: [
                "Gather items to return",
                "Check holds",
                "Bring library card",
                "Bring reading list",
                "Pack laptop",
                "Pack tote bag"
            ]
        )

        // Gym and workout prep
        upsert(
            name: "Gym Prep",
            category: SampleCategories.routines,
            items: [
                "Pack gym clothes",
                "Pack gym shoes",
                "Pack towel",
                "Pack water bottle",
                "Pack headphones",
                "Load workout plan"
            ]
        )

        try? modelContext.save()
        UserDefaults.standard.set(2, forKey: versionKey)
        UserDefaults.standard.set(true, forKey: "seededSamples")
    }
}

