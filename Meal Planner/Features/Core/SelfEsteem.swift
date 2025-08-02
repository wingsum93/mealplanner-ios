//
//  SelfEsteem.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct SelfEsteem:View {
    
    var click: () -> Void = {}
    
    var body: some View {
        Button(action: click){
            Text("Eric is the best")
                .bold()
                .font(.largeTitle)
        }
    }
}
