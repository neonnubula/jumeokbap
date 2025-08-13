import SwiftUI
import SwiftData

final class AppSettings: ObservableObject {
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
}

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var haptics: HapticsManager
    @StateObject private var settings = AppSettings()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Feedback") {
                    Toggle("Haptics", isOn: $settings.hapticsEnabled)
                        .onChange(of: settings.hapticsEnabled) { _, newValue in
                            haptics.isEnabled = newValue
                        }
                }

                Section("Data") {
                    Button("Load Sample Checklists") {
                        Task { await SeedDataLoader.seedSamples(force: true) }
                    }
                    Button("Wipe All Data", role: .destructive) { wipeData() }
                }

                Section("Onboarding") {
                    Button("Show Onboarding on Next Launch") { hasCompletedOnboarding = false }
                }

                Section(footer: Text("All data is stored locally on your device.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            haptics.isEnabled = settings.hapticsEnabled
        }
    }

    private func wipeData() {
        do {
            let descriptor1 = FetchDescriptor<ChecklistTemplate>()
            for obj in try context.fetch(descriptor1) { context.delete(obj) }
            let descriptor2 = FetchDescriptor<ChecklistRun>()
            for obj in try context.fetch(descriptor2) { context.delete(obj) }
            try context.save()
        } catch {
            // no-op for now
        }
    }
}

