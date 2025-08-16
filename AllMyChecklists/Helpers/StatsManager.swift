import Foundation
import SwiftData

@MainActor
class StatsManager: ObservableObject {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Get or Create User Stats
    func getUserStats() -> UserStats {
        let descriptor = FetchDescriptor<UserStats>()
        let stats = try? context.fetch(descriptor)
        
        if let existingStats = stats?.first {
            return existingStats
        } else {
            let newStats = UserStats()
            context.insert(newStats)
            try? context.save()
            return newStats
        }
    }
    
    // MARK: - Record Completion
    func recordCompletion(templateId: UUID, templateName: String) async -> [Achievement] {
        let userStats = getUserStats()
        let completionDate = Date()
        
        // Create completion record
        let completion = CompletionRecord(templateId: templateId, templateName: templateName, completedAt: completionDate)
        completion.userStats = userStats
        context.insert(completion)
        
        // Update total completions
        userStats.totalCompletions += 1
        
        // Update streak
        updateStreak(userStats: userStats, completionDate: completionDate)
        
        // Check for new achievements
        let newAchievements = await checkForNewAchievements(userStats: userStats)
        
        try? context.save()
        return newAchievements
    }
    
    // MARK: - Update Streak Logic
    private func updateStreak(userStats: UserStats, completionDate: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: completionDate)
        
        if let lastDate = userStats.lastCompletionDate {
            let lastCompletionDay = calendar.startOfDay(for: lastDate)
            let daysBetween = calendar.dateComponents([.day], from: lastCompletionDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day - extend streak
                userStats.currentStreak += 1
            } else if daysBetween == 0 {
                // Same day - don't change streak
                return
            } else {
                // Streak broken - reset to 1
                userStats.currentStreak = 1
            }
        } else {
            // First ever completion
            userStats.currentStreak = 1
        }
        
        // Update longest streak if needed
        if userStats.currentStreak > userStats.longestStreak {
            userStats.longestStreak = userStats.currentStreak
        }
        
        userStats.lastCompletionDate = completionDate
    }
    
    // MARK: - Check for New Achievements
    private func checkForNewAchievements(userStats: UserStats) async -> [Achievement] {
        var newAchievements: [Achievement] = []
        
        // Check milestone achievements
        for milestone in AchievementData.milestoneAchievements {
            if userStats.totalCompletions == milestone.value {
                if !achievementExists(type: "milestone", value: milestone.value) {
                    let achievement = Achievement(
                        type: "milestone",
                        value: milestone.value,
                        title: milestone.title,
                        message: milestone.message
                    )
                    achievement.isUnlocked = true
                    achievement.unlockedAt = Date()
                    context.insert(achievement)
                    newAchievements.append(achievement)
                }
            }
        }
        
        // Check streak achievements
        for streak in AchievementData.streakAchievements {
            if userStats.currentStreak == streak.value {
                if !achievementExists(type: "streak", value: streak.value) {
                    let achievement = Achievement(
                        type: "streak",
                        value: streak.value,
                        title: streak.title,
                        message: streak.message
                    )
                    achievement.isUnlocked = true
                    achievement.unlockedAt = Date()
                    context.insert(achievement)
                    newAchievements.append(achievement)
                }
            }
        }
        
        return newAchievements
    }
    
    // MARK: - Helper Methods
    private func achievementExists(type: String, value: Int) -> Bool {
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { achievement in
                achievement.type == type && achievement.value == value
            }
        )
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }
    
    // MARK: - Get Stats for Display
    func getCompletionsByTemplate() -> [String: Int] {
        let descriptor = FetchDescriptor<CompletionRecord>()
        let completions = (try? context.fetch(descriptor)) ?? []
        
        var templateCounts: [String: Int] = [:]
        for completion in completions {
            templateCounts[completion.templateName, default: 0] += 1
        }
        return templateCounts
    }
    
    func getRecentAchievements(limit: Int = 5) -> [Achievement] {
        var descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { achievement in
                achievement.isUnlocked == true
            },
            sortBy: [SortDescriptor(\.unlockedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getAllAchievements() -> [Achievement] {
        let descriptor = FetchDescriptor<Achievement>(
            sortBy: [SortDescriptor(\.unlockedAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
