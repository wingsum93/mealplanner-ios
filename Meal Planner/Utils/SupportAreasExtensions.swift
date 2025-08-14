//
//  SupportAreasExtensions.swift
//  Meal Planner
//
//  Created by eric ho on 14/8/2025.
//
import Foundation

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
internal extension String {
    func getAreaImageURL() -> String {
        let map: [String: String] = [
            "American": "https://flagcdn.com/w320/us.png",
            "British":  "https://flagcdn.com/w320/gb.png",
            "Canadian": "https://flagcdn.com/w320/ca.png",
            "Chinese":  "https://flagcdn.com/w320/cn.png",
            "Croatian": "https://flagcdn.com/w320/hr.png",
            "Dutch": "https://flagcdn.com/w320/nl.png",
            "Egyptian": "https://flagcdn.com/w320/eg.png",
            "Filipino": "https://flagcdn.com/w320/ph.png",
            "French":   "https://flagcdn.com/w320/fr.png",
            "Greek":    "https://flagcdn.com/w320/gr.png",
            "Indian":   "https://flagcdn.com/w320/in.png",
            "Irish":    "https://flagcdn.com/w320/ie.png",
            "Italian":  "https://flagcdn.com/w320/it.png",
            "Jamaican": "https://flagcdn.com/w320/jm.png",
            "Japanese": "https://flagcdn.com/w320/jp.png",
            "Kenyan":   "https://flagcdn.com/w320/ke.png",
            "Malaysian": "https://flagcdn.com/w320/my.png",
            "Mexican":  "https://flagcdn.com/w320/mx.png",
            "Moroccan": "https://flagcdn.com/w320/ma.png",
            "Polish":   "https://flagcdn.com/w320/pl.png",
            "Portuguese": "https://flagcdn.com/w320/pt.png",
            "Russian":  "https://flagcdn.com/w320/ru.png",
            "Spanish":  "https://flagcdn.com/w320/es.png",
            "Thai":     "https://flagcdn.com/w320/th.png",
            "Turkish":  "https://flagcdn.com/w320/tr.png",
            "Ukrainian": "https://flagcdn.com/w320/ua.png",
            "Vietnamese": "https://flagcdn.com/w320/vn.png",
        ]
        return map[self] ?? ""
    }
}

extension String {
    /// Build TheMealDB category image URL safely
    var mealCategoryImageLink: String {
        // encode for a path segment (比單純 replace " " 更安全)
        let encoded = self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self
        return  "https://www.themealdb.com/images/category/\(encoded).png"
    }
}
