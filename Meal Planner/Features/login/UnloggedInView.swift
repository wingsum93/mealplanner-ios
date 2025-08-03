//
//  UnloggedInView.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct UnloggedInView: View {
    let onLogin: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.gray.opacity(0.6))

            Text("Login to unlock features")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onLogin) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
    }
}

#Preview(){
    UnloggedInView(){}
}
