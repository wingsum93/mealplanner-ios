//
//  LoginSheet.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI
import Foundation

struct LoginBottomSheet:View {
    var onGuestLogin: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Login to unlock features")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Favorite recipes, history, more")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Divider()
                .padding(.horizontal)
            
            // Buttons
            VStack(spacing: 12) {
                
                LoginOptionButton(
                    label: "Continue as Guest",
                    icon: "person.fill",
                    backgroundColor: Color(.systemGray6),
                    textColor: .primary,
                    action: onGuestLogin
                )
            }
            
            Spacer(minLength: 8)
        }
        .padding()
        .presentationDetents([.height(300)])
    }
}
