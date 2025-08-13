import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "checklist")
                }

            RunsHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct RunsHistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ChecklistRun.startedAt, order: .reverse) private var runs: [ChecklistRun]

    var body: some View {
        NavigationStack {
            Group {
                if runs.isEmpty {
                    ContentUnavailableView("No Runs Yet", systemImage: "clock", description: Text("Start a checklist from Home to see it here."))
                } else {
                    List(runs) { run in
                        NavigationLink(value: run.id) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(run.title)
                                    .font(.headline)
                                Text(run.startedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .navigationDestination(for: UUID.self) { runId in
                        if let run = runs.first(where: { $0.id == runId }) {
                            RunChecklistView(existingRun: run)
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

