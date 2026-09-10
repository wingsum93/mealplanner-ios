//
//  ImageUtil.swift
//  Meal Planner
//
//  Created by eric ho on 30/10/2025.
//
struct ImageUtil{
    static func getCategorySystemImage(category: String) -> String {
        switch category.lowercased() {
        case "seafood":
            return "fish.fill"                        // 🐟 seafood
        case "chicken":
            return "bird.fill"                        // 🐔 poultry
        case "beef":
            return "fork.knife.circle.fill"           // 🥩 hearty meal
        case "pork":
            return "fork.knife.circle"                // 🍖 cooked meat
        case "breakfast":
            return "sunrise.fill"                     // 🌅 morning meal
        case "dessert":
            return "birthday.cake.fill"               // 🎂 dessert
        case "goat", "lamb":
            return "pawprint.fill"                    // 🐑 livestock
        case "miscellaneous":
            return "questionmark.circle.fill"         // ❓ unknown
        case "pasta":
            return "fork.knife"                       // 🍝 dining symbol
        case "side":
            return "tray.full.fill"                   // 🍽️ side dish / serving tray
        case "starter":
            return "takeoutbag.and.cup.and.straw"      // appetizer-like
        case "vegan", "vegetarian":
            return "leaf.fill"                        // 🌿 plant-based
        default:
            return "square.grid.2x2.fill"             // fallback icon
        }
    }
    
}
