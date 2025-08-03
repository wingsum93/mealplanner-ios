//
//  ProfileContentView.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI
struct ProfileContentView:View {
    let onLoginout: () -> Void
    
    init(onLoginout: @escaping () -> Void = {}) {
           self.onLoginout = onLoginout
       }
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image("person")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .foregroundColor(.gray.opacity(0.6))

            Text("Profile Content")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onLoginout) {
                Text("Logout").fontWeight(.bold).font(.title)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
    }
}

#Preview {
    ProfileContentView()
}
