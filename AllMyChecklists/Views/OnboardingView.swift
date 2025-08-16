import SwiftUI
import SwiftData

// MARK: - Stunning Gradient Background
struct OnboardingGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base mesh-style gradient
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.90, blue: 1.0),
                    Color(red: 0.90, green: 0.95, blue: 1.0),
                    Color(red: 0.98, green: 0.92, blue: 0.95)
                ],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            
            // Floating radial gradients
            RadialGradient(
                colors: [
                    Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.3),
                    Color.clear
                ],
                center: animateGradient ? .topTrailing : .topLeading,
                startRadius: 50,
                endRadius: 400
            )
            
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.6).opacity(0.2),
                    Color.clear
                ],
                center: animateGradient ? .bottomLeading : .bottomTrailing,
                startRadius: 50,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct OnboardingView: View {
    var onFinished: () -> Void
    @Environment(\.modelContext) private var context
    @State private var page: Int = 0
    @State private var seedRequested: Bool = true

    var body: some View {
        ZStack {
            // Absolutely gorgeous animated background
            OnboardingGradientBackground()
            
            VStack(spacing: 0) {
                // Stunning content
            TabView(selection: $page) {
                                        StunningOnboardingPage(
                        title: "All My Checklists",
                        subtitle: "Transform Chaos Into Clarity",
                        description: "Build your library of repeatable life processes",
                        symbol: "checklist",
                        color: Color(red: 0.5, green: 0.3, blue: 0.9)
                    )
                    .tag(0)

                    StunningOnboardingPage(
                        title: "Stay On Top",
                        subtitle: "Never Miss What Matters",
                        description: "Gain the confidence that comes from systematic preparation",
                        symbol: "crown.fill",
                        color: Color(red: 0.9, green: 0.6, blue: 0.1)
                    )
                    .tag(1)

                    StunningOnboardingPage(
                        title: "Surgery Success",
                        subtitle: "Checklists Reduced Deaths by 47%",
                        description: "WHO study: surgical safety checklists prevent complications and save thousands of lives globally",
                        symbol: "heart.fill",
                        color: Color(red: 0.9, green: 0.3, blue: 0.5)
                    )
                    .tag(2)

                    StunningOnboardingPage(
                        title: "Aviation Safety",
                        subtitle: "Checklists Drive 99.9999% Success",
                        description: "Pre-flight checklists transformed aviation into the world's safest form of transportation",
                        symbol: "airplane.departure",
                        color: Color(red: 0.3, green: 0.7, blue: 0.5)
                    )
                    .tag(3)

                                        // Clean sample templates page
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Simple icon
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 80, height: 80)
                                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                            
                            Image(systemName: "gift.fill")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(Color.orange)
                        }
                        
                        VStack(spacing: 16) {
                            Text("10 Ready Templates")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(white: 0.1))
                                .multilineTextAlignment(.center)
                            
                            Text("Each list has 5-9 items.\nEdit any list or create your own!")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(white: 0.4))
                        .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 40)
                        }
                        
                        // Simple toggle
                        HStack {
                            Image(systemName: seedRequested ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(seedRequested ? Color.green : Color.gray)
                            
                            Text("Load sample templates")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(white: 0.3))
                            
                            Spacer()
                            
                            Toggle("", isOn: $seedRequested)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal, 40)
                        
                        Spacer()
                        Spacer()
                    }
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // Perfect button and skip link
                VStack(spacing: 16) {
                    Button(action: finish) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.3, blue: 0.9),
                                            Color(red: 0.6, green: 0.3, blue: 0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 44)
                                .shadow(color: Color(red: 0.4, green: 0.3, blue: 0.9).opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            HStack(spacing: 6) {
                                Text(page == 4 ? "Start My Journey" : "Continue")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                
                                if page < 4 {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Skip link - only show on pages 0-3, not on final page (4)
                    if page < 4 {
                        Button(action: skipToApp) {
                            Text("Skip to Checklists")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .underline()
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }

    private func finish() {
        if page < 4 {
            withAnimation(.easeInOut(duration: 0.5)) { 
                page += 1 
            }
            return
        }
        Task {
            if seedRequested {
                await SeedDataLoader.seedSamples(using: context)
            }
            await MainActor.run {
            onFinished()
            }
        }
    }
    
    private func skipToApp() {
        // Skip directly to app with sample data loaded
        Task {
            await SeedDataLoader.seedSamples(using: context)
            await MainActor.run {
                onFinished()
            }
        }
    }
}

private struct StunningOnboardingPage: View {
    let title: String
    let subtitle: String
    let description: String
    let symbol: String
    let color: Color
    @State private var iconScale = 0.8
    @State private var iconRotation = -5.0

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Absolutely stunning icon with animation
                ZStack {
                    // Animated background elements
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 20 + CGFloat(index * 5))
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.3 - Double(index) * 0.1),
                                        color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: 100 + CGFloat(index * 20), height: 100 + CGFloat(index * 20))
                            .rotationEffect(.degrees(iconRotation + Double(index * 15)))
                    }
                    
                    // Glassmorphic icon container
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.8), .white.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: color.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    // Beautiful gradient icon
            Image(systemName: symbol)
                        .font(.system(size: 48, weight: .regular, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(iconScale)
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        iconScale = 1.0
                    }
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        iconRotation = 5.0
                    }
                }
                
                // Perfect content spacing
                VStack(spacing: 12) {
            Text(title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(white: 0.1), color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                    
            Text(subtitle)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(white: 0.4))
                .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .lineLimit(4)
                        .frame(minHeight: 56)
                }
                
                Spacer()
            }
        }
    }
}



