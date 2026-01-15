//
//  ProfileContentView.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI
struct ProfileContentView:View {
    let onLoginout: () -> Void
    private let feedbackURL = URL(string: "mailto:support@mealplanner.app")
    private let privacyPolicyURL = URL(string: "https://www.themealdb.com/privacy.php")
    private let mealDbURL = URL(string: "https://www.themealdb.com/")
    
    init(onLoginout: @escaping () -> Void = {}) {
           self.onLoginout = onLoginout
       }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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

                aboutSection
                    .padding(.horizontal, 24)
            }
            .padding(.vertical, 32)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)

            Text(appVersionText)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Data provided by TheMealDB.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let mealDbURL {
                Link("TheMealDB", destination: mealDbURL)
            }

            if let feedbackURL {
                Link("Feedback & Support", destination: feedbackURL)
            }

            if let privacyPolicyURL {
                Link("Privacy Policy", destination: privacyPolicyURL)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var appVersionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = info?["CFBundleVersion"] as? String ?? "Unknown"
        return "Version \(version) (\(build))"
    }
}

#Preview {
    ProfileContentView()
}
