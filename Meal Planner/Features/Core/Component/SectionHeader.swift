//
//  SectionHeader.swift
//  Meal Planner
//
//  Created by eric ho on 13/8/2025.
//
import SwiftUI

struct SectionHeader: View {
    var title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.title3.bold())
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }
}

