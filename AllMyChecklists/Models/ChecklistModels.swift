import Foundation
import SwiftData

@Model
final class ChecklistItemTemplate {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String?
    var isRequired: Bool
    var sortOrder: Int

    init(id: UUID = UUID(), title: String, notes: String? = nil, isRequired: Bool = true, sortOrder: Int = 0) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isRequired = isRequired
        self.sortOrder = sortOrder
    }
}

@Model
final class ChecklistTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade) var items: [ChecklistItemTemplate]

    init(id: UUID = UUID(), name: String, category: String, createdAt: Date = .now, updatedAt: Date = .now, items: [ChecklistItemTemplate] = []) {
        self.id = id
        self.name = name
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.items = items
    }
}

@Model
final class ChecklistRunItem {
    @Attribute(.unique) var id: UUID
    var templateItemId: UUID
    var title: String
    var notes: String?
    var isChecked: Bool
    var sortOrder: Int

    init(id: UUID = UUID(), templateItemId: UUID, title: String, notes: String? = nil, isChecked: Bool = false, sortOrder: Int = 0) {
        self.id = id
        self.templateItemId = templateItemId
        self.title = title
        self.notes = notes
        self.isChecked = isChecked
        self.sortOrder = sortOrder
    }
}

@Model
final class ChecklistRun {
    @Attribute(.unique) var id: UUID
    var templateId: UUID
    var startedAt: Date
    var completedAt: Date?
    var title: String
    @Relationship(deleteRule: .cascade) var items: [ChecklistRunItem]

    init(id: UUID = UUID(), templateId: UUID, startedAt: Date = .now, completedAt: Date? = nil, title: String, items: [ChecklistRunItem] = []) {
        self.id = id
        self.templateId = templateId
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.title = title
        self.items = items
    }
}

enum SampleCategories {
    static let routines = "Routines"
    static let travel = "Travel"
    static let work = "Work"
    static let errands = "Errands"
}

