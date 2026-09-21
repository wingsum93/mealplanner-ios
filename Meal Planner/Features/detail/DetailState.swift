//
//  DetailState.swift
//  Meal Planner
//
//  Created by eric ho on 17/8/2025.
//

struct DetailState: Equatable {
    var item: UIRecipeItem?                // seeded summary, then full record
    var isSavingFavorite: Bool = false     // show spinner/disable while saving
    var isLoadingDetail: Bool = false      // full record fetch in flight
    var errorMessage: String? = nil        // surface an error if save fails
    var isPresented: Bool {
            item != nil
    }
    
}
