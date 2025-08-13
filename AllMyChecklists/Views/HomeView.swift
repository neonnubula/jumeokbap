import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\ChecklistTemplate.category, order: .forward), SortDescriptor(\ChecklistTemplate.name, order: .forward)]) private var templates: [ChecklistTemplate]
    @State private var searchText: String = ""
    @State private var showingCreate: Bool = false

    var filteredTemplates: [ChecklistTemplate] {
        guard !searchText.isEmpty else { return templates }
        return templates.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.category.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if templates.isEmpty {
                    VStack(spacing: 16) {
                        ContentUnavailableView("No Checklists", systemImage: "checklist.unchecked", description: Text("Create your first checklist to get started."))
                        Button(action: { showingCreate = true }) {
                            Label("New Checklist", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(groupedByCategory.keys.sorted(), id: \.self) { category in
                            Section(category) {
                                ForEach(groupedByCategory[category] ?? []) { template in
                                    NavigationLink(destination: TemplateDetailView(template: template)) {
                                        VStack(alignment: .leading) {
                                            Text(template.name)
                                                .font(.headline)
                                            Text("\(template.items.count) items")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            context.delete(template)
                                            try? context.save()
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText)
                }
            }
            .navigationTitle("All My Checklists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingCreate = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("New Checklist")
                }
            }
            .sheet(isPresented: $showingCreate) {
                NavigationStack {
                    TemplateEditorView(template: nil)
                }
                .presentationDetents([.large])
            }
        }
    }

    private var groupedByCategory: [String: [ChecklistTemplate]] {
        Dictionary(grouping: filteredTemplates, by: { $0.category })
    }
}

struct TemplateDetailView: View {
    @Environment(\.modelContext) private var context
    @State private var showingEdit: Bool = false
    @State private var activeRun: ChecklistRun?
    var template: ChecklistTemplate

    var body: some View {
        List {
            ForEach(template.items.sorted(by: { $0.sortOrder < $1.sortOrder })) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                    if let notes = item.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(template.name)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Run") {
                    let run = ChecklistRun(templateId: template.id, title: template.name, items: template.items.sorted(by: { $0.sortOrder < $1.sortOrder }).map {
                        ChecklistRunItem(templateItemId: $0.id, title: $0.title, notes: $0.notes, isChecked: false, sortOrder: $0.sortOrder)
                    })
                    context.insert(run)
                    try? context.save()
                    activeRun = run
                }
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack { TemplateEditorView(template: template) }
        }
        .sheet(item: $activeRun) { run in
            NavigationStack { RunChecklistView(existingRun: run) }
        }
    }
}

