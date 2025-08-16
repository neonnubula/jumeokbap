import Foundation
import SwiftData

@Model
class UserStats {
    @Attribute(.unique) var id: UUID = UUID()
    var totalCompletions: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCompletionDate: Date?
    var createdAt: Date = Date()
    
    // Relationship to completion records
    @Relationship(deleteRule: .cascade) var completions: [CompletionRecord] = []
    
    init() {}
}

@Model
class CompletionRecord {
    @Attribute(.unique) var id: UUID = UUID()
    var templateId: UUID
    var templateName: String
    var completedAt: Date
    var dayOfYear: Int // Used for streak calculation
    
    // Relationship back to user stats
    var userStats: UserStats?
    
    init(templateId: UUID, templateName: String, completedAt: Date = Date()) {
        self.templateId = templateId
        self.templateName = templateName
        self.completedAt = completedAt
        
        let calendar = Calendar.current
        self.dayOfYear = calendar.ordinality(of: .day, in: .year, for: completedAt) ?? 0
    }
}

@Model
class Achievement {
    @Attribute(.unique) var id: UUID = UUID()
    var type: String // "milestone" or "streak"
    var value: Int // The milestone number or streak days
    var title: String
    var message: String
    var unlockedAt: Date?
    var isUnlocked: Bool = false
    
    init(type: String, value: Int, title: String, message: String) {
        self.type = type
        self.value = value
        self.title = title
        self.message = message
    }
}

// MARK: - Achievement Data
struct AchievementData {
    static let milestoneAchievements: [(value: Int, title: String, message: String)] = [
        (10, "Getting Started!", "🌟 10 checklists completed! You're building great habits!"),
        (25, "Quarter Century!", "🎯 25 completions down! You're becoming unstoppable!"),
        (50, "Half Century Hero!", "🏆 50 checklists conquered! Your consistency is impressive!"),
        (100, "Century Club!", "💯 100 completions! You've joined the elite club of champions!"),
        (150, "Persistence Pro!", "🚀 150 checklists crushed! Your dedication is inspiring!"),
        (200, "Double Century!", "⭐ 200 completions! You're a true checklist master!"),
        (300, "Triple Threat!", "🔥 300 checklists completed! Your momentum is unstoppable!"),
        (400, "Fantastic Four!", "💪 400 completions! You're redefining what's possible!"),
        (500, "Half Grand!", "🎉 500 checklists! You're in a league of your own!"),
        (1000, "The Thousand!", "👑 1000 completions! You are the ultimate checklist champion!"),
        (2500, "Legendary!", "🏛️ 2500 completions! You've achieved legendary status!"),
        (5000, "Mythical Master!", "⚡ 5000 checklists! You're operating on a mythical level!"),
        (10000, "The Perfect Ten!", "🌟 10,000 completions! You've reached perfection itself!")
    ]
    
    static let streakAchievements: [(value: Int, title: String, message: String)] = [
        (1, "First Step!", "🎯 Day 1! Every journey begins with a single step!"),
        (2, "Building Momentum!", "🔥 2 days in a row! The habit is forming!"),
        (3, "Triple Threat!", "⭐ 3 consecutive days! You're on fire!"),
        (4, "Fantastic Four!", "💪 4 days straight! Your dedication is showing!"),
        (5, "High Five!", "🙌 5 days in a row! You're proving your commitment!"),
        (7, "Lucky Seven!", "🍀 A full week! You're building serious momentum!"),
        (10, "Perfect Ten!", "💯 10 days straight! You're in the zone!"),
        (14, "Two Week Wonder!", "🚀 14 consecutive days! You're on an amazing streak!"),
        (28, "Monthly Master!", "🏆 28 days! You've made this a true habit!"),
        (50, "Fifty Fantastic!", "⭐ 50 days in a row! You're absolutely unstoppable!"),
        (100, "Centurion!", "👑 100 consecutive days! You're a true champion!"),
        (180, "Half Year Hero!", "🌟 6 months straight! Your consistency is legendary!"),
        (365, "Year One Champion!", "🎉 365 consecutive days! You've completed a full year!"),
        (730, "Two Year Titan!", "🏛️ 2 years straight! You're operating on another level!"),
        (1095, "Three Year Master!", "⚡ 3 consecutive years! You've achieved mastery!"),
        (1460, "Four Year Force!", "🔥 4 years in a row! You're an unstoppable force!"),
        (1825, "Five Year Legend!", "👑 5 consecutive years! You are truly legendary!"),
        (2190, "Six Year Sage!", "🌟 6 years straight! Your wisdom and discipline inspire!"),
        (2555, "Seven Year Champion!", "🏆 7 consecutive years! You've reached new heights!"),
        (2920, "Eight Year Elite!", "⭐ 8 years in a row! You're in the elite class!"),
        (3285, "Nine Year Noble!", "💎 9 consecutive years! You've achieved noble status!"),
        (3650, "Decade Deity!", "🌟 10 FULL YEARS! You are a living legend, a true deity of discipline! Your unwavering commitment to daily checklist completion has transformed you into something beyond ordinary human achievement. You are the embodiment of consistency, the master of habits, and the ultimate example of what persistent daily action can accomplish!")
    ]
}
