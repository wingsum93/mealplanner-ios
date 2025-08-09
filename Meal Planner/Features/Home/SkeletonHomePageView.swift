//
//  SkeletonHomePageView.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftUI

struct SkeletonHomePageView:View {
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

