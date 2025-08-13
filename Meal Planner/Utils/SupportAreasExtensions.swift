//
//  SupportAreasExtensions.swift
//  Meal Planner
//
//  Created by eric ho on 14/8/2025.
//

extension Array where Element == String {
    func getAppSupportArea() -> [String] {
        let supportedArea = [
            "American",
            "British",
            "Canadian",
            "Chinese",
            "Dutch",
            "Egyptian",
            "Filipino",
            "French",
            "Indian",
            "Italian",
            "Japanese",
            "Malaysian",
            "Mexican",
            "Portuguese",
            "Russian",
            "Spanish",
            "Thai",
            "Turkish",
            "Ukrainian",
            "Vietnamese"
        ]
        return filter { supportedArea.contains($0)}
    }
}
