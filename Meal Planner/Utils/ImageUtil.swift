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
                    return "fork.knife.circle.fill"           // 🍗 general cooked meal
                case "beef":
                    return "flame.fill"                       // 🔥 grilled / strong dish
                case "pork":
                    return "takeoutbag.and.cup.and.straw.fill"// 🥡 general takeaway-style meal
                case "breakfast":
                    return "sun.max.fill"                     // ☀️ morning meal
                case "dessert":
                    return "cupcake"                          // 🧁 (SF Symbols 5+)
                case "goat", "lamb":
                    return "leaf.circle.fill"                 // 🐑 natural protein / mild dish
                case "miscellaneous":
                    return "questionmark.circle.fill"         // ❓ unknown
                case "pasta":
                    return "fork.knife"                       // 🍝 dining symbol
                case "side":
                    return "tray.fill"                        // 🍽️ side dish / serving tray
                case "starter":
                    return "takeoutbag.and.cup.and.straw"     // appetizer-like
                case "vegan", "vegetarian":
                    return "leaf.fill"                        // 🌿 plant-based
                default:
                    return "square.grid.2x2.fill"             // fallback icon
                }
    }
    
}
