import SwiftUI
import SwiftData

struct RunChecklistView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var haptics: HapticsManager

    @State private var run: ChecklistRun

    init(existingRun: ChecklistRun) {
        _run = State(initialValue: existingRun)
    }

    private var progress: Double {
        guard !run.items.isEmpty else { return 0 }
        let done = run.items.filter { $0.isChecked }.count
        return Double(done) / Double(run.items.count)
    }

    var body: some View {
        List {
            Section {
                ProgressView(value: progress)
                Text("\(Int(progress * 100))% complete")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .listRowSeparator(.hidden)

            ForEach(run.items.sorted(by: { $0.sortOrder < $1.sortOrder })) { item in
                HStack(alignment: .firstTextBaseline) {
                    Button(action: { toggle(item) }) {
                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.isChecked ? .green : .secondary)
                            .font(.title3)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .strikethrough(item.isChecked)
                        if let notes = item.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
            }
        }
        .navigationTitle(run.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish") { finish() }
                    .disabled(!canFinish)
            }
        }
    }

    private var canFinish: Bool {
        // If there are required items, ensure they are checked
        let required = run.items.filter { _ in true } // future: carry required flag per item if needed
        if required.isEmpty { return true }
        return required.allSatisfy { $0.isChecked }
    }

    private func toggle(_ item: ChecklistRunItem) {
        if let idx = run.items.firstIndex(where: { $0.id == item.id }) {
            run.items[idx].isChecked.toggle()
            try? context.save()
            haptics.light()
        }
    }

    private func finish() {
        run.completedAt = .now
        try? context.save()
        haptics.success()
    }
}

