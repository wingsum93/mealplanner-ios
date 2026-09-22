//
//  IngredientAggregator.swift
//  Meal Planner
//
//  Aggregates & de-duplicates ingredients across planned meal instances
//  (FR-5.1, FR-5.4, E4, E5) and groups them into the 5 categories (Q2).
//

import Foundation

/// Best-effort parser for measure strings like "1 cup", "200g", "1 1/2 tbsp".
struct QuantityParser {
    struct Parsed {
        let value: Double?
        let unit: String
    }

    private static let pattern = try? NSRegularExpression(
        pattern: #"^\s*([0-9]+(?:\s+[0-9]+/[0-9]+)?|[0-9]+/[0-9]+|[0-9]*\.?[0-9]+)\s*(.*)$"#
    )

    static func parse(_ raw: String) -> Parsed {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let pattern else {
            return Parsed(value: nil, unit: normalizedUnit(trimmed))
        }

        let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
        guard let match = pattern.firstMatch(in: trimmed, options: [], range: range),
              match.numberOfRanges >= 3,
              let numberRange = Range(match.range(at: 1), in: trimmed),
              let unitRange = Range(match.range(at: 2), in: trimmed)
        else {
            return Parsed(value: nil, unit: normalizedUnit(trimmed))
        }

        let numberText = String(trimmed[numberRange])
        let unitText = String(trimmed[unitRange])
        return Parsed(value: parseNumber(numberText), unit: normalizedUnit(unitText))
    }

    private static func parseNumber(_ text: String) -> Double? {
        let parts = text.split(separator: " ", omittingEmptySubsequences: true)
        if parts.count == 2 {
            guard let whole = Double(parts[0]), let fraction = parseFraction(String(parts[1])) else {
                return nil
            }
            return whole + fraction
        }
        if parts.count == 1 {
            if let fraction = parseFraction(String(parts[0])) { return fraction }
            return Double(parts[0])
        }
        return nil
    }

    private static func parseFraction(_ text: String) -> Double? {
        let pieces = text.split(separator: "/")
        guard pieces.count == 2,
              let numerator = Double(pieces[0]),
              let denominator = Double(pieces[1]),
              denominator != 0
        else { return nil }
        return numerator / denominator
    }

    private static func normalizedUnit(_ text: String) -> String {
        let cleaned = text
            .trimmingCharacters(in: CharacterSet(charactersIn: ". "))
            .lowercased()
        let aliases: [String: String] = [
            "grams": "g", "gram": "g", "g": "g",
            "kilograms": "kg", "kilogram": "kg", "kg": "kg",
            "millilitres": "ml", "milliliters": "ml", "millilitre": "ml", "milliliter": "ml", "ml": "ml",
            "litres": "l", "liters": "l", "litre": "l", "liter": "l", "l": "l",
            "cups": "cup", "cup": "cup",
            "tablespoons": "tbsp", "tablespoon": "tbsp", "tbsp": "tbsp",
            "teaspoons": "tsp", "teaspoon": "tsp", "tsp": "tsp",
            "ounces": "oz", "ounce": "oz", "oz": "oz",
            "pounds": "lb", "pound": "lb", "lb": "lb"
        ]
        return aliases[cleaned] ?? cleaned
    }
}

struct IngredientAggregator {
    private let categorizer = IngredientCategorizer()

    /// - Parameter meals: each selected meal with how many times it appears in
    ///   the final schedule.
    func aggregate(meals: [(item: RecipeItem, occurrences: Int)]) -> [PlanIngredient] {
        var buckets: [String: Bucket] = [:]
        var order: [String] = []

        for (recipe, occurrences) in meals where occurrences > 0 {
            let alignedMeasures = recipe.measures.count == recipe.ingredients.count
                ? recipe.measures
                : []

            for (index, rawName) in recipe.ingredients.enumerated() {
                let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { continue }

                let rawMeasure = alignedMeasures.indices.contains(index) ? alignedMeasures[index] : ""
                let parsed = QuantityParser.parse(rawMeasure)
                let normalizedName = name.lowercased()
                let key = normalizedName + "|" + parsed.unit

                if buckets[key] == nil {
                    buckets[key] = Bucket(
                        name: name,
                        unit: parsed.unit,
                        quantity: nil,
                        rawMeasure: rawMeasure,
                        count: 0,
                        category: categorizer.category(for: name)
                    )
                    order.append(key)
                }

                var bucket = buckets[key]!
                if let value = parsed.value {
                    bucket.quantity = (bucket.quantity ?? 0) + value * Double(occurrences)
                }
                bucket.count += occurrences
                buckets[key] = bucket
            }
        }

        return order.compactMap { key in
            guard let bucket = buckets[key] else { return nil }
            return PlanIngredient(
                name: bucket.name,
                quantityText: bucket.quantityText,
                unit: bucket.unit,
                category: bucket.category,
                isChecked: false,
                occurrenceCount: bucket.count
            )
        }
        .sorted {
            if $0.category != $1.category { return $0.category.rawValue < $1.category.rawValue }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    private struct Bucket {
        let name: String
        let unit: String
        var quantity: Double?
        let rawMeasure: String
        var count: Int
        let category: IngredientCategory

        var quantityText: String {
            if let quantity {
                let number = Self.format(quantity)
                return unit.isEmpty ? number : "\(number) \(unit)"
            }
            return rawMeasure
        }

        static func format(_ value: Double) -> String {
            if value.rounded() == value {
                return String(Int(value))
            }
            let rounded = (value * 100).rounded() / 100
            return String(format: "%.2f", rounded)
                .replacingOccurrences(of: "0$", with: "", options: .regularExpression)
                .replacingOccurrences(of: "\\.$", with: "", options: .regularExpression)
        }
    }
}