//
//  LoginOptionButton.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct LoginOptionButton: View {
    let label: String
    let icon: String
    let backgroundColor: Color
    let textColor: Color
    var borderColor: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                Text(label)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor ?? .clear, lineWidth: borderColor != nil ? 1 : 0)
            )
            .cornerRadius(10)
        }
    }
}
