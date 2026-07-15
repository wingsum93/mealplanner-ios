//
//  DetailState.swift
//  Meal Planner
//
//  Created by eric ho on 17/8/2025.
//

struct DetailState: Equatable {
    var item: UIRecipeItem?                // already loaded
    var isSavingFavorite: Bool = false     // show spinner/disable while saving
    var errorMessage: String? = nil        // surface an error if save fails
    var isPresented: Bool {
            item != nil
    }
    
}
