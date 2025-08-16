import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\ChecklistTemplate.category, order: .forward), SortDescriptor(\ChecklistTemplate.name, order: .forward)]) private var templates: [ChecklistTemplate]
    @State private var searchText: String = ""
    @State private var showingCreate: Bool = false
    @State private var editingTemplate: ChecklistTemplate? = nil
    @State private var runningTemplate: ChecklistTemplate? = nil

    var filteredTemplates: [ChecklistTemplate] {
        guard !searchText.isEmpty else { return templates }
        return templates.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.category.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var groupedByCategory: [String: [ChecklistTemplate]] {
        Dictionary(grouping: filteredTemplates, by: { $0.category })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                mainContent
            }
        }
        .searchable(text: $searchText, prompt: "Search checklists...")
        .navigationTitle("Checklists")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !templates.isEmpty {
                    EditButton()
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                }
            }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingCreate = true }) {
                        Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                }
                }
            }
            .sheet(isPresented: $showingCreate) {
                    TemplateEditorView(template: nil)
                }
        .sheet(item: $editingTemplate) { template in
            TemplateEditorView(template: template)
        }
    }
    
    private var backgroundGradient: some View {
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
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            if templates.isEmpty {
                emptyStateView
            } else {
                filledStateView
            }
        }
    }
    
        private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Subtle icon
            Image(systemName: "checklist")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Checklists Yet")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(white: 0.2))
                
                Text("Create your first checklist to get started")
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.5))
                    .multilineTextAlignment(.center)
            }
            
            // Subtle create button
            Button(action: { showingCreate = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .medium))
                    Text("Create Checklist")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(red: 0.5, green: 0.3, blue: 0.9))
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var filledStateView: some View {
        VStack(spacing: 0) {
            // Subtle tip - much smaller
            HStack {
                Image(systemName: "lightbulb")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                Text("Create checklists for repeatable processes")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                Spacer()
                // Elegant small create button
                Button(action: { showingCreate = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                        Text("New")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.5, green: 0.3, blue: 0.9))
                            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.05))
            )
            .padding(.horizontal, 16)
            .padding(.top, 4)
            
            // Elegant list with subtle lifts
            List {
                ForEach(filteredTemplates, id: \.id) { template in
                    NavigationLink(destination: TemplateDetailView(template: template)) {
                        ElegantChecklistRow(template: template)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                    .buttonStyle(PlainButtonStyle())
                }
                .onMove(perform: moveTemplates)
                .onDelete(perform: deleteTemplatesAtIndices)
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .padding(.top, 8)
        }
    }
    
    private func sectionHeader(for category: String, count: Int) -> some View {
        HStack {
            Image(systemName: categoryHeaderIcon(for: category))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(categoryColor(for: category))
            Text(category.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(white: 0.5))
                .tracking(0.5)
            Spacer()
            Text("\(count)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(categoryColor(for: category))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(categoryColor(for: category).opacity(0.1))
                )
        }
    }

    private func deleteTemplate(_ template: ChecklistTemplate) {
        context.delete(template)
        try? context.save()
    }
    
    private func deleteTemplatesAtIndices(_ indexSet: IndexSet) {
        for index in indexSet {
            let template = filteredTemplates[index]
            context.delete(template)
        }
                    try? context.save()
                }
    
    private func moveTemplates(from source: IndexSet, to destination: Int) {
        // For now, we'll just trigger a save - proper reordering would require
        // adding a sortOrder field to ChecklistTemplate
        try? context.save()
    }

    private func categoryHeaderIcon(for category: String) -> String {
        switch category.lowercased() {
        case "routines":
            return "sunrise"
        case "travel":
            return "airplane.departure"
        case "work":
            return "building.2"
        case "health":
            return "heart"
        case "weekly":
            return "calendar"
        default:
            return "checklist"
        }
    }

    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "routines":
            return Color(red: 1.0, green: 0.5, blue: 0.0)
        case "travel":
            return Color(red: 0.0, green: 0.5, blue: 1.0)
        case "work":
            return Color(red: 0.0, green: 0.8, blue: 0.4)
        case "health":
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        case "weekly":
            return Color(red: 0.6, green: 0.2, blue: 0.8)
        default:
            return Color(white: 0.5)
        }
    }
}

// MARK: - Elegant Checklist Row Component
struct ElegantChecklistRow: View {
    let template: ChecklistTemplate
    @State private var isHovered = false
    
    private var categoryColor: Color {
        switch template.category.lowercased() {
        case "routines":
            return Color(red: 1.0, green: 0.5, blue: 0.0)
        case "travel":
            return Color(red: 0.0, green: 0.5, blue: 1.0)
        case "work":
            return Color(red: 0.0, green: 0.8, blue: 0.4)
        case "health":
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        case "weekly":
            return Color(red: 0.6, green: 0.2, blue: 0.8)
        case "errands":
            return Color(red: 0.9, green: 0.6, blue: 0.1)
        default:
            return Color(red: 0.5, green: 0.3, blue: 0.9)
        }
    }
    
    private var categoryIcon: String {
        switch template.category.lowercased() {
        case "routines":
            return "sunrise.fill"
        case "travel":
            return "airplane.departure"
        case "work":
            return "building.2.fill"
        case "health":
            return "heart.fill"
        case "weekly":
            return "calendar.badge.clock"
        default:
            return "checklist"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            // Subtle category indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(categoryColor)
                .frame(width: 3, height: 24)
            
            // Compact icon
            Image(systemName: categoryIcon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(categoryColor)
                .frame(width: 20)
            
            // Title with subtle secondary info
            VStack(alignment: .leading, spacing: 1) {
                Text(template.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(white: 0.1))
                    .lineLimit(1)
                
                Text(template.category)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(categoryColor.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(isHovered ? 0.08 : 0.04), radius: isHovered ? 4 : 2, x: 0, y: isHovered ? 2 : 1)
        )
        .scaleEffect(isHovered ? 1.005 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}