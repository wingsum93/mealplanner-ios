//
//  RecipeItemDisplay.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import Foundation

struct UIRecipeItem: Identifiable, Equatable,Hashable {
    let id: String
    let name: String
    let description: String
    let area: String?
    let category: String?
    let thumbURL: URL?
    let ingredients: [String]
    let measures: [String]
    let instructions: [String]
    let tags: [String] // can be empty
    let youtubeLink: String
    var stepCount:Int  {
        self.instructions.count
    }
    var isFavorite: Bool = false
}

extension UIRecipeItem {
    static let sample = UIRecipeItem(
        id: "sample-1",
        name: "Blini Pancakes",
        description: "This is the description of this meal",
        area: "hk",
        category: "burger",
        thumbURL: URL(string: "https://www.themealdb.com/images/media/meals/rwuyqx1511383174.jpg"),
        ingredients: ["beef","burger","apple"],
        measures: ["1 cup","2 cup","3 cup"],
        instructions: ["Roll the pastry to a 3mm-thick round on a lightly floured surface and cut a 24cm circle, using a plate as a guide",
                      "Lightly prick all over with a fork, wrap in cling film on a baking sheet and freeze while preparing the apples.\r\nHeat oven to 180C/160C fan/gas 4",
                      "Peel, quarter and core the apples. Put the sugar in a flameproof 20cm ceramic Tatin dish or a 20cm ovenproof heavy-based frying pan and place over a medium-high heat",
                      "Cook the sugar for 5-7 mins to a dark amber caramel syrup that’s starting to smoke, then turn off the heat and stir in the 60g diced chilled butter"],
        tags: ["Dinner","Desseart"],
        youtubeLink: "www",
        isFavorite: false
    )
    
    static func new(
        id: String,
        name: String,
        area: String = "HK",
        category: String = "Cat 1",
        thumbURL: URL? = URL(string: "https://www.themealdb.com/images/media/meals/rwuyqx1511383174.jpg")
    ) -> UIRecipeItem {
        return .init(
            id: id,
            name: name,
            description: "des",
            area: area,
            category: category,
            thumbURL: thumbURL,
            ingredients: [],
            measures: [],
            instructions: [],
            tags: [],
            youtubeLink: "www.youtube.com"
        )
    }
}
