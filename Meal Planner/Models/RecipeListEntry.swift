//
//  RecipeListEntry.swift
//  Meal Planner
//
//  Created by eric ho on 22/9/2026.
//

import Foundation
import SwiftData

enum RecipeListType: String, CaseIterable, Identifiable, Codable {
    case favourite
    case mastered
    case viewed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .favourite:
            return "Favourite"
        case .mastered:
            return "Mastered"
        case .viewed:
            return "Recently Viewed"
        }
    }

    var systemImage: String {
        switch self {
        case .favourite:
            return "heart.fill"
        case .mastered:
            return "checkmark.seal.fill"
        case .viewed:
            return "clock.arrow.circlepath"
        }
    }

    /// Only the curated lists expose area/category filters. The view history is
    /// always ordered by date and cannot be filtered.
    var supportsFiltering: Bool {
        self != .viewed
    }
}

/// A single membership row for the My List feature. Only the meal id and the
/// list type are persisted; the recipe payload lives in `RecipeEntity`.
/// The pair (`mealId`, `type`) is unique, enforced in code by upserting.
@Model
final class RecipeListEntry {
    var mealId: Int64
    var typeRaw: String
    var updatedAt: Date

    var type: RecipeListType {
        RecipeListType(rawValue: typeRaw) ?? .favourite
    }

    init(mealId: Int64, type: RecipeListType, updatedAt: Date = Date()) {
        self.mealId = mealId
        self.typeRaw = type.rawValue
        self.updatedAt = updatedAt
    }
}
