import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var context
    @State private var userStats: UserStats?
    @State private var templateCompletions: [String: Int] = [:]
    @State private var recentAchievements: [Achievement] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let stats = userStats {
                        // Main stats cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(
                                icon: "🔥",
                                title: "\(stats.currentStreak)",
                                subtitle: "Days Streak",
                                color: .orange
                            )
                            
                            StatCard(
                                icon: "✅",
                                title: "\(stats.totalCompletions)",
                                subtitle: "Completed",
                                color: .green
                            )
                        }
                        
                        // Template completions
                        if !templateCompletions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Checklist Progress")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(Array(templateCompletions.sorted(by: { $0.value > $1.value })), id: \.key) { template, count in
                                    HStack {
                                        Text(template)
                                            .font(.system(size: 15, weight: .medium))
                                        Spacer()
                                        Text("\(count)")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color(white: 0.98))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Recent achievements
                        if !recentAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Achievements")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(recentAchievements, id: \.id) { achievement in
                                    HStack {
                                        Text(achievement.type == "milestone" ? "🏆" : "🔥")
                                            .font(.title2)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(achievement.title)
                                                .font(.system(size: 15, weight: .semibold))
                                            Text(achievement.message)
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(white: 0.98))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    } else {
                        Text("Start completing checklists to see your stats!")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Stats")
            .onAppear {
                loadStats()
            }
        }
    }
    
    private func loadStats() {
        let statsManager = StatsManager(context: context)
        userStats = statsManager.getUserStats()
        templateCompletions = statsManager.getCompletionsByTemplate()
        recentAchievements = statsManager.getRecentAchievements()
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 40))
            
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.98))
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    StatsView()
}
