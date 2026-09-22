//
//  IngredientCategorizer.swift
//  Meal Planner
//
//  Best-effort name-based categorization into the 5 canonical categories
//  (Q2). TheMealDB gives no ingredient tags, so this is heuristic by design.
//

import Foundation

struct IngredientCategorizer {
    func category(for name: String) -> IngredientCategory {
        let value = name.lowercased()

        if Self.seafood.contains(where: { value.contains($0) }) { return .seafood }
        if Self.meat.contains(where: { value.contains($0) }) { return .meat }
        if Self.herbs.contains(where: { value.contains($0) }) { return .herbs }
        if Self.vegetable.contains(where: { value.contains($0) }) { return .vegetable }
        return .others
    }

    private static let seafood = [
        "fish", "salmon", "tuna", "prawn", "shrimp", "cod", "crab", "lobster",
        "mussel", "squid", "anchovy", "oyster", "clam", "sardine", "herring",
        "scallop", "haddock", "trout", "mackerel", "calamari", "hake", "bass",
        "snapper", "seafood", "prawn"
    ]

    private static let meat = [
        "chicken", "beef", "pork", "lamb", "bacon", "ham", "sausage", "turkey",
        "duck", "veal", "mince", "steak", "ribs", "chorizo", "prosciutto",
        "pancetta", "liver", "oxtail", "venison", "goat", "mutton", "pepperoni",
        "salami", "meatball", "meat"
    ]

    private static let herbs = [
        "basil", "parsley", "thyme", "rosemary", "oregano", "mint", "coriander",
        "cilantro", "dill", "sage", "bay leaf", "bay", "chive", "garlic",
        "ginger", "turmeric", "cumin", "paprika", "cinnamon", "nutmeg", "clove",
        "cardamom", "curry", "spice", "seasoning", "vanilla", "black pepper",
        "white pepper", "peppercorn", "herb"
    ]

    private static let vegetable = [
        "onion", "tomato", "potato", "carrot", "pepper", "celery", "cucumber",
        "lettuce", "spinach", "broccoli", "mushroom", "cabbage", "pea", "bean",
        "corn", "zucchini", "courgette", "eggplant", "aubergine", "leek",
        "parsnip", "turnip", "beetroot", "radish", "asparagus", "cauliflower",
        "pumpkin", "squash", "shallot", "scallion", "spring onion", "kale",
        "rocket", "arugula", "avocado", "olive", "vegetable"
    ]
}