import Foundation
import SwiftUI

struct CategoryOption {
    let name: String
    let emoji: String
    let color: Color
    
    static let predefined: [CategoryOption] = [
        CategoryOption(name: "Routines", emoji: "🌅", color: Color(red: 1.0, green: 0.5, blue: 0.0)),
        CategoryOption(name: "Travel", emoji: "✈️", color: Color(red: 0.0, green: 0.5, blue: 1.0)),
        CategoryOption(name: "Work", emoji: "💼", color: Color(red: 0.0, green: 0.8, blue: 0.4)),
        CategoryOption(name: "Health", emoji: "❤️", color: Color(red: 1.0, green: 0.3, blue: 0.3)),
        CategoryOption(name: "Weekly", emoji: "📅", color: Color(red: 0.6, green: 0.2, blue: 0.8)),
        CategoryOption(name: "Errands", emoji: "🛍️", color: Color(red: 0.9, green: 0.6, blue: 0.1)),
        CategoryOption(name: "Learning", emoji: "📚", color: Color(red: 0.2, green: 0.6, blue: 0.8)),
        CategoryOption(name: "Fitness", emoji: "💪", color: Color(red: 0.8, green: 0.2, blue: 0.6))
    ]
    
    static func colorFor(category: String) -> Color {
        if let found = predefined.first(where: { $0.name.lowercased() == category.lowercased() }) {
            return found.color
        }
        return Color(red: 0.5, green: 0.3, blue: 0.9)
    }
    
    static func emojiFor(category: String) -> String {
        if let found = predefined.first(where: { $0.name.lowercased() == category.lowercased() }) {
            return found.emoji
        }
        return "📝"
    }
}
