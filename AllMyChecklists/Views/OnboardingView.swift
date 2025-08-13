import SwiftUI
import SwiftData

struct OnboardingView: View {
    var onFinished: () -> Void
    @Environment(\.modelContext) private var context
    @State private var page: Int = 0
    @State private var seedRequested: Bool = true

    var body: some View {
        VStack {
            TabView(selection: $page) {
                OnboardingPage(title: "All My Checklists",
                               subtitle: "Reusable checklists for life's repeatable processes.",
                               symbol: "checklist.unchecked")
                .tag(0)

                OnboardingPage(title: "Build Templates",
                               subtitle: "Create templates like Morning Routine, Domestic Flight, or Library Trip.",
                               symbol: "square.and.pencil")
                .tag(1)

                OnboardingPage(title: "Run and Track",
                               subtitle: "Check off items, see progress, and review history.",
                               symbol: "timer")
                .tag(2)

                VStack(spacing: 20) {
                    Image(systemName: seedRequested ? "shippingbox.and.arrow.backward" : "shippingbox")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 56))
                        .foregroundStyle(.tint)
                    Text("Sample Checklists")
                        .font(.title.bold())
                    Text("Load sample templates to explore: Morning, Work Startup, Domestic/International Flight, and Library Trip.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Toggle(isOn: $seedRequested) { Text("Load sample templates") }
                        .toggleStyle(.switch)
                        .padding(.top, 8)
                }
                .padding()
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(action: finish) {
                Text(page == 3 ? "Get Started" : "Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }

    private func finish() {
        if page < 3 {
            withAnimation { page += 1 }
            return
        }
        Task {
            if seedRequested {
                await SeedDataLoader.seedSamples(using: context)
            }
            onFinished()
        }
    }
}

private struct OnboardingPage: View {
    let title: String
    let subtitle: String
    let symbol: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: symbol)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text(title)
                .font(.title.bold())
            Text(subtitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }
}

