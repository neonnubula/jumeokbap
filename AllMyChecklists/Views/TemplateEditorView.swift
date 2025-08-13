import SwiftUI
import SwiftData

struct TemplateEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var category: String
    @State private var items: [ChecklistItemTemplate]

    private var existingTemplate: ChecklistTemplate?

    init(template: ChecklistTemplate?) {
        self._name = State(initialValue: template?.name ?? "")
        self._category = State(initialValue: template?.category ?? SampleCategories.routines)
        let initialItems = template?.items.sorted(by: { $0.sortOrder < $1.sortOrder }) ?? []
        self._items = State(initialValue: initialItems)
        self.existingTemplate = template
    }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                TextField("Category", text: $category)
            }

            Section("Items") {
                if items.isEmpty {
                    ContentUnavailableView("No Items", systemImage: "list.bullet", description: Text("Add items below."))
                } else {
                    ForEach(items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                TextField("Title", text: Binding(
                                    get: { item.title },
                                    set: { newValue in
                                        if let idx = items.firstIndex(where: { $0.id == item.id }) { items[idx].title = newValue }
                                    }
                                ))
                                TextField("Notes (optional)", text: Binding(
                                    get: { item.notes ?? "" },
                                    set: { newValue in
                                        if let idx = items.firstIndex(where: { $0.id == item.id }) { items[idx].notes = newValue.isEmpty ? nil : newValue }
                                    }
                                ))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Toggle(isOn: Binding(
                                get: { item.isRequired },
                                set: { newValue in if let idx = items.firstIndex(where: { $0.id == item.id }) { items[idx].isRequired = newValue } }
                            )) {
                                Text("Required")
                            }
                            .labelsHidden()
                        }
                    }
                    .onMove { from, to in
                        items.move(fromOffsets: from, toOffset: to)
                        for (index, var item) in items.enumerated() { item.sortOrder = index }
                    }
                    .onDelete { offsets in
                        items.remove(atOffsets: offsets)
                    }
                }

                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle(existingTemplate == nil ? "New Checklist" : "Edit Checklist")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("Cancel", role: .cancel) { dismiss() } }
            ToolbarItem(placement: .topBarTrailing) { Button("Save", action: save) }
            ToolbarItem(placement: .bottomBar) { EditButton() }
        }
    }

    private func addItem() {
        let nextOrder = (items.map { $0.sortOrder }.max() ?? -1) + 1
        items.append(ChecklistItemTemplate(title: "", notes: nil, isRequired: true, sortOrder: nextOrder))
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let now = Date()
        if let template = existingTemplate {
            template.name = name
            template.category = category
            template.updatedAt = now
            // Replace items: keep stable IDs where possible
            template.items = items.enumerated().map { idx, it in
                it.sortOrder = idx
                return it
            }
        } else {
            let normalizedItems = items.enumerated().map { idx, it in
                it.sortOrder = idx
                return it
            }
            let newTemplate = ChecklistTemplate(name: name, category: category, createdAt: now, updatedAt: now, items: normalizedItems)
            context.insert(newTemplate)
        }
        try? context.save()
        dismiss()
    }
}

