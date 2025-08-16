import SwiftUI
import SwiftData

struct TemplateDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let template: ChecklistTemplate
    @State private var showingEdit = false
    @State private var checkedItems: Set<UUID> = []
    @State private var celebratingItems: Set<UUID> = []
    @State private var showingCompletionCelebration = false
    @State private var pendingAchievements: [Achievement] = []
    @State private var showingAchievementCelebration = false
    @State private var microCelebrationText = ""
    @State private var microCelebrationEmoji = ""
    @State private var showingMicroCelebration = false
    
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
        default:
            return Color(white: 0.5)
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
        ZStack {
            backgroundGradient
            contentView
            
            // MASSIVE completion celebration
            if showingCompletionCelebration {
                MassiveCompletionCelebrationView(onDismiss: dismissCelebration)
            }
            
            // Achievement celebration
            if showingAchievementCelebration {
                AchievementCelebrationView(
                    achievements: pendingAchievements,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showingAchievementCelebration = false
                        }
                        pendingAchievements = []
                    }
                )
            }
            
            // Micro-celebration overlay
            if showingMicroCelebration {
                MicroCelebrationView(
                    emoji: microCelebrationEmoji,
                    text: microCelebrationText
                )
                .allowsHitTesting(false)
            }
        }
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Reset") {
                    resetChecklist()
                }
                .foregroundColor(categoryColor)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
                .foregroundColor(categoryColor)
            }
        }
        .sheet(isPresented: $showingEdit) {
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
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                startButton
                itemsList
                Spacer(minLength: 40)
            }
        }
    }
    
    private var headerView: some View {
        // Just spacing for navigation title
        Spacer()
            .frame(height: 20)
    }
    
    private var startButton: some View {
        // Remove the start button - it's in the toolbar now
        EmptyView()
    }
    
    private var itemsList: some View {
        VStack(spacing: 12) {
            ForEach(template.items.sorted(by: { $0.sortOrder < $1.sortOrder })) { item in
                itemRow(for: item)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func itemRow(for item: ChecklistItemTemplate) -> some View {
        HStack(spacing: 12) {
            // Celebration overlay for individual items
            ZStack {
                // Always show checkbox
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        if checkedItems.contains(item.id) {
                            checkedItems.remove(item.id)
                        } else {
                            checkedItems.insert(item.id)
                            // Enhanced mini celebration
                            celebratingItems.insert(item.id)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                celebratingItems.remove(item.id)
                            }
                            
                            // Check if all items are complete (item was just added to checkedItems)
                            let currentCheckedCount = checkedItems.count
                            if currentCheckedCount == template.items.count {
                                // Last item - show full completion celebration
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showCompletionCelebration()
                                }
                            } else {
                                // Not last item - show micro-celebration
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showMicroCelebration()
                                }
                            }
                        }
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(checkedItems.contains(item.id) ? Color.green : Color.clear)
                            .frame(width: 24, height: 24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(checkedItems.contains(item.id) ? Color.clear : Color(white: 0.7), lineWidth: 1.5)
                            )
                            .scaleEffect(celebratingItems.contains(item.id) ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: celebratingItems.contains(item.id))
                        
                        if checkedItems.contains(item.id) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(celebratingItems.contains(item.id) ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: celebratingItems.contains(item.id))
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Enhanced mini celebration sparkles
                if celebratingItems.contains(item.id) {
                    ForEach(0..<8, id: \.self) { index in
                        Group {
                            if index % 2 == 0 {
                                Circle()
                                    .fill(Color.green.opacity(0.9))
                                    .frame(width: 6, height: 6)
                            } else {
                                Star()
                                    .fill(Color.yellow.opacity(0.9))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .offset(
                            x: CGFloat.random(in: -35...35),
                            y: CGFloat.random(in: -35...35)
                        )
                        .opacity(celebratingItems.contains(item.id) ? 0 : 1)
                        .scaleEffect(celebratingItems.contains(item.id) ? 3 : 0.3)
                        .rotationEffect(.degrees(celebratingItems.contains(item.id) ? Double.random(in: 0...360) : 0))
                        .animation(.easeOut(duration: 1.2).delay(Double(index) * 0.1), value: celebratingItems.contains(item.id))
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(checkedItems.contains(item.id) ? Color(white: 0.6) : Color(white: 0.1))
                    .strikethrough(checkedItems.contains(item.id))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let notes = item.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.98))
        )
    }
    
    private func resetChecklist() {
        checkedItems.removeAll()
    }
    
    // MARK: - Micro-celebration data and logic
    private let microCelebrations = [
        ("🌟", "Nice!"),
        ("⭐", "Great!"),
        ("✨", "Awesome!"),
        ("🎯", "Nailed it!"),
        ("💪", "You got this!"),
        ("🔥", "On fire!"),
        ("👏", "Well done!"),
        ("🚀", "Crushing it!"),
        ("💯", "Perfect!"),
        ("⚡", "Brilliant!"),
        ("🎉", "Fantastic!"),
        ("👍", "Good work!")
    ]
    
    private func showMicroCelebration() {
        let celebration = microCelebrations.randomElement()!
        microCelebrationEmoji = celebration.0
        microCelebrationText = celebration.1
        
        withAnimation(.easeOut(duration: 0.3)) {
            showingMicroCelebration = true
        }
        
        // Auto-hide after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.3)) {
                showingMicroCelebration = false
            }
        }
    }
    
    private func showCompletionCelebration() {
        withAnimation(.easeInOut(duration: 1.0)) {
            showingCompletionCelebration = true
        }
        // No auto-dismiss - user must tap to dismiss
    }
    
    private func dismissCelebration() {
        // Record completion and check for achievements
        Task {
            let statsManager = StatsManager(context: context)
            let achievements = await statsManager.recordCompletion(
                templateId: template.id,
                templateName: template.name
            )
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showingCompletionCelebration = false
                }
                
                // Show achievement celebration if any new achievements
                if !achievements.isEmpty {
                    pendingAchievements = achievements
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            showingAchievementCelebration = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - MASSIVE Completion Celebration View
struct MassiveCompletionCelebrationView: View {
    let onDismiss: () -> Void
    @State private var animationPhase = 0.0
    @State private var explosionPhase = 0.0
    @State private var fireworksPhase = 0.0
    @State private var showDismissHint = false
    
    var body: some View {
        ZStack {
            // Full screen golden explosive background
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.yellow,
                            Color.orange,
                            Color.red,
                            Color.purple,
                            Color.blue,
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 800
                    )
                )
                .opacity(0.8)
                .scaleEffect(explosionPhase)
                .animation(.easeOut(duration: 2.0), value: explosionPhase)
            
            // Celebration content (background layer)
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("CHECKLIST")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(1.0 + sin(animationPhase * 1.5) * 0.1)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Text("COMPLETE!")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(1.0 + sin(animationPhase * 1.7) * 0.1)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Text("🏆 YOU'RE A CHAMPION! 🏆")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                        .opacity(0.8 + sin(animationPhase * 3) * 0.2)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThickMaterial)
                        .shadow(color: .orange.opacity(0.8), radius: 30)
                        .scaleEffect(1.0 + sin(animationPhase) * 0.05)
                )
                
                // Dismiss instruction
                if showDismissHint {
                    VStack(spacing: 8) {
                        Text("👆 Tap anywhere to continue")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2)
                        
                        Text("or swipe up")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .opacity(showDismissHint ? 1 : 0)
                    .animation(.easeInOut(duration: 1.0), value: showDismissHint)
                }
            }
            
            // MASSIVE confetti storm - TOP LAYER (animates over everything)
            ForEach(0..<150, id: \.self) { index in
                MassiveConfettiPiece(index: index, animationPhase: animationPhase, explosionPhase: explosionPhase)
            }
            
            // Fireworks bursts - TOP LAYER
            ForEach(0..<8, id: \.self) { index in
                FireworkBurst(index: index, phase: fireworksPhase)
            }
        }
        .onAppear {
            // Start all animations
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 6
            }
            
            withAnimation(.easeOut(duration: 1.5)) {
                explosionPhase = 2.0
            }
            
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                fireworksPhase = .pi * 8
            }
            
            // Show dismiss hint after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showDismissHint = true
            }
        }
        .onTapGesture {
            onDismiss()
        }
        .gesture(
            DragGesture()
                .onEnded { drag in
                    if drag.translation.height < -50 {
                        onDismiss()
                    }
                }
        )
    }
}

// MARK: - Massive Confetti and Effects
struct MassiveConfettiPiece: View {
    let index: Int
    let animationPhase: Double
    let explosionPhase: Double
    
    @State private var startPosition = CGPoint.zero
    @State private var endPosition = CGPoint.zero
    @State private var rotation = 0.0
    @State private var scale = 1.0
    @State private var animatedPosition = CGPoint.zero
    @State private var animatedRotation = 0.0
    @State private var animatedScale = 1.0
    @State private var animatedOpacity = 1.0
    
    var colors: [Color] = [.yellow, .orange, .red, .pink, .purple, .blue, .green, .cyan, .mint, .indigo]
    
    var body: some View {
        let color = colors[index % colors.count]
        let shape = index % 5
        
        Group {
            if shape == 0 {
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: CGFloat.random(in: 8...16), height: CGFloat.random(in: 8...16))
            } else if shape == 1 {
                Circle()
                    .fill(color)
                    .frame(width: CGFloat.random(in: 6...14), height: CGFloat.random(in: 6...14))
            } else if shape == 2 {
                Diamond()
                    .fill(color)
                    .frame(width: CGFloat.random(in: 10...18), height: CGFloat.random(in: 10...18))
            } else if shape == 3 {
                Star()
                    .fill(color)
                    .frame(width: CGFloat.random(in: 12...20), height: CGFloat.random(in: 12...20))
            } else {
                Heart()
                    .fill(color)
                    .frame(width: CGFloat.random(in: 10...16), height: CGFloat.random(in: 10...16))
            }
        }
        .rotationEffect(.degrees(animatedRotation))
        .scaleEffect(animatedScale)
        .position(animatedPosition)
        .opacity(animatedOpacity)
        .onAppear {
            setupAnimation()
            startAnimations()
        }
    }
    
    private func setupAnimation() {
        startPosition = CGPoint(
            x: CGFloat.random(in: 50...350),
            y: CGFloat.random(in: 100...600)
        )
        endPosition = CGPoint(
            x: startPosition.x + CGFloat.random(in: -200...200),
            y: startPosition.y + CGFloat.random(in: 200...600)
        )
        
        // Initialize animated properties
        animatedPosition = startPosition
        animatedRotation = 0
        animatedScale = 0.3
        animatedOpacity = 1.0
    }
    
    private func startAnimations() {
        let duration = Double.random(in: 3.0...5.0)
        let delay = Double(index) * 0.05 // Stagger animations
        
        withAnimation(.easeOut(duration: duration).delay(delay)) {
            animatedPosition = endPosition
            animatedOpacity = 0.0
        }
        
        withAnimation(.linear(duration: duration).delay(delay)) {
            animatedRotation = Double.random(in: 720...1440)
        }
        
        withAnimation(.easeOut(duration: duration * 0.7).delay(delay)) {
            animatedScale = Double.random(in: 1.0...2.5)
        }
    }
}

struct FireworkBurst: View {
    let index: Int
    let phase: Double
    
    var body: some View {
        let colors: [Color] = [.yellow, .orange, .red, .purple, .blue, .green, .pink, .cyan]
        let color = colors[index % colors.count]
        
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .offset(y: -100)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .scaleEffect(sin(phase + Double(index)) > 0.5 ? 1.0 : 0.0)
                    .opacity(sin(phase + Double(index)) > 0.5 ? 1.0 : 0.0)
            }
        }
        .position(
            x: CGFloat(100 + index * 40),
            y: CGFloat(200 + index * 60)
        )
    }
}



struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        
        for i in 0..<10 {
            let angle = Double(i) * .pi / 5 - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

struct Heart: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.9))
        path.addCurve(to: CGPoint(x: width * 0.1, y: height * 0.3),
                      control1: CGPoint(x: width * 0.5, y: height * 0.7),
                      control2: CGPoint(x: width * 0.1, y: height * 0.5))
        path.addCurve(to: CGPoint(x: width * 0.5, y: height * 0.1),
                      control1: CGPoint(x: width * 0.1, y: height * 0.1),
                      control2: CGPoint(x: width * 0.3, y: height * 0.1))
        path.addCurve(to: CGPoint(x: width * 0.9, y: height * 0.3),
                      control1: CGPoint(x: width * 0.7, y: height * 0.1),
                      control2: CGPoint(x: width * 0.9, y: height * 0.1))
        path.addCurve(to: CGPoint(x: width * 0.5, y: height * 0.9),
                      control1: CGPoint(x: width * 0.9, y: height * 0.5),
                      control2: CGPoint(x: width * 0.5, y: height * 0.7))
        return path
    }
}

// MARK: - Achievement Celebration View
struct AchievementCelebrationView: View {
    let achievements: [Achievement]
    let onDismiss: () -> Void
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Rectangle()
                .fill(Color.black.opacity(0.8))
                .ignoresSafeArea()
            
            if currentIndex < achievements.count {
                let achievement = achievements[currentIndex]
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Achievement icon based on type
                        Text(achievement.type == "milestone" ? "🏆" : "🔥")
                            .font(.system(size: 60))
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatCount(3), value: currentIndex)
                        
                        VStack(spacing: 12) {
                            Text("ACHIEVEMENT UNLOCKED!")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                                .tracking(2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            
                            Text(achievement.title)
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.6)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(achievement.message)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 8)
                        }
                        
                        // Continue button
                        Button(action: nextAchievement) {
                            Text(currentIndex < achievements.count - 1 ? "Next Achievement" : "Awesome!")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                )
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .yellow.opacity(0.3), radius: 20)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 40)
            }
        }
        .onTapGesture {
            nextAchievement()
        }
    }
    
    private func nextAchievement() {
        if currentIndex < achievements.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
            }
        } else {
            onDismiss()
        }
    }
}

// MARK: - Micro-celebration View
struct MicroCelebrationView: View {
    let emoji: String
    let text: String
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 40))
                .scaleEffect(scale)
            
            Text(text)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .shadow(color: .orange.opacity(0.4), radius: 8)
                )
        }
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            // Quick bounce in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.2
                opacity = 1.0
            }
            
            // Settle to normal size
            withAnimation(.easeOut(duration: 0.2).delay(0.2)) {
                scale = 1.0
            }
            
            // Float up and fade out
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                offset = -30
                opacity = 0.0
                scale = 0.8
            }
        }
    }
}
