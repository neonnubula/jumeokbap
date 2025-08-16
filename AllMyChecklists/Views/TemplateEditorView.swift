import SwiftUI
import SwiftData

struct TemplateEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var category: String
    @State private var customCategory: String = ""
    @State private var customEmoji: String = ""
    @State private var items: [ChecklistItemTemplate]
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var showingCustomCategory = false

    private var existingTemplate: ChecklistTemplate?
    
    private var itemCount: Int { items.count }
    private var isValid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    private var validationWarning: String? {
        if itemCount < 5 {
            return "Consider adding more items. Research shows 5-9 items work best for checklists."
        } else if itemCount > 9 {
            return "You have many items. Consider if this could be broken into multiple checklists."
        }
        return nil
    }

    init(template: ChecklistTemplate?) {
        self._name = State(initialValue: template?.name ?? "")
        self._category = State(initialValue: template?.category ?? SampleCategories.routines)
        let initialItems = template?.items.sorted(by: { $0.sortOrder < $1.sortOrder }) ?? []
        self._items = State(initialValue: initialItems)
        self.existingTemplate = template
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.97, green: 0.95, blue: 1.0),
                        Color(red: 0.95, green: 0.97, blue: 1.0),
                        Color(red: 0.98, green: 0.95, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section("Checklist Details") {
                        TextField("Checklist Name", text: $name, prompt: Text("e.g., Morning Routine"))
                            .font(.system(size: 16, weight: .medium))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            if showingCustomCategory {
                                HStack(spacing: 8) {
                                    TextField("Emoji", text: $customEmoji, prompt: Text("📝"))
                                        .font(.system(size: 16))
                                        .frame(width: 40)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    TextField("Category Name", text: $customCategory, prompt: Text("Custom Category"))
                                        .font(.system(size: 16, weight: .medium))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button("Done") {
                                        if !customCategory.isEmpty {
                                            category = customCategory
                                        }
                                        showingCustomCategory = false
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                                }
                            } else {
                                Menu {
                                    ForEach(CategoryOption.predefined, id: \.name) { option in
                                        Button(action: {
                                            category = option.name
                                        }) {
                                            HStack {
                                                Text(option.emoji)
                                                Text(option.name)
                                                Spacer()
                                                if category == option.name {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(option.color)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    Button(action: {
                                        showingCustomCategory = true
                                        customCategory = ""
                                        customEmoji = ""
                                    }) {
                                        HStack {
                                            Text("➕")
                                            Text("Create New Category")
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(CategoryOption.emojiFor(category: category))
                                            .font(.system(size: 16))
                                        Text(category.isEmpty ? "Select Category" : category)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(category.isEmpty ? .secondary : .primary)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray6))
                                    )
                                }
                            }
                        }
                    }
                    
                    Section {
                        // Item count and guidance
                        HStack {
                            Text("Items (\(itemCount))")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Text("5-9 items ideal")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                        }
                        
                        // Validation warning
                        if let warning = validationWarning {
                            HStack {
                                Image(systemName: itemCount < 5 ? "exclamationmark.triangle.fill" : "info.circle.fill")
                                    .foregroundColor(itemCount < 5 ? .orange : .blue)
                                Text(warning)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill((itemCount < 5 ? Color.orange : Color.blue).opacity(0.1))
                            )
                        }
                        
                        // Items list
                        if items.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                                Text("No items yet")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                Text("Add your first checklist item below")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                        } else {
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("\(index + 1).")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                                            .frame(width: 24, alignment: .leading)
                                        
                                        TextField("Step title", text: Binding(
                                            get: { item.title },
                                            set: { newValue in
                                                if let idx = items.firstIndex(where: { $0.id == item.id }) { 
                                                    items[idx].title = newValue 
                                                }
                                            }
                                        ))
                                        .font(.system(size: 15, weight: .medium))
                                    }
                                    
                                    HStack {
                                        Spacer()
                                            .frame(width: 24)
                                        TextField("Optional notes or details", text: Binding(
                                            get: { item.notes ?? "" },
                                            set: { newValue in
                                                if let idx = items.firstIndex(where: { $0.id == item.id }) { 
                                                    items[idx].notes = newValue.isEmpty ? nil : newValue 
                                                }
                                            }
                                        ))
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onMove { from, to in
                                items.move(fromOffsets: from, toOffset: to)
                                for (index, var item) in items.enumerated() { 
                                    if let idx = items.firstIndex(where: { $0.id == item.id }) {
                                        items[idx].sortOrder = index 
                                    }
                                }
                            }
                            .onDelete { offsets in
                                items.remove(atOffsets: offsets)
                            }
                        }
                        
                        // Add item button
                        Button(action: addItem) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                                Text("Add Item")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                            }
                        }
                    } header: {
                        Text("Checklist Items")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingTemplate == nil ? "New Checklist" : "Edit Checklist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { 
                    Button("Cancel", role: .cancel) { dismiss() } 
                }
                ToolbarItem(placement: .topBarTrailing) { 
                    Button("Save") { 
                        if itemCount < 5 {
                            validationMessage = "Your checklist has \(itemCount) items. Research shows 5-9 items work best, but you can save anyway."
                            showingValidationAlert = true
                        } else {
                            save()
                        }
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .bottomBar) { 
                    EditButton()
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                }
            }
            .alert("Save Checklist?", isPresented: $showingValidationAlert) {
                Button("Save Anyway") { save() }
                Button("Keep Editing", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
    }

    private func addItem() {
        let nextOrder = items.count
        items.append(ChecklistItemTemplate(
            title: "", 
            notes: nil, 
            isRequired: true, 
            sortOrder: nextOrder
        ))
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Filter out empty items
        let validItems = items.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        let now = Date()
        if let template = existingTemplate {
            template.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            template.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
            template.updatedAt = now
            template.items = validItems.enumerated().map { idx, item in
                item.sortOrder = idx
                return item
            }
        } else {
            let normalizedItems = validItems.enumerated().map { idx, item in
                item.sortOrder = idx
                return item
            }
            let newTemplate = ChecklistTemplate(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines), 
                category: category.trimmingCharacters(in: .whitespacesAndNewlines), 
                createdAt: now, 
                updatedAt: now, 
                items: normalizedItems
            )
            context.insert(newTemplate)
        }
        try? context.save()
        dismiss()
    }
}

