//
//  ProfileContentView.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI
struct ProfileContentView:View {
    let onLoginout: () -> Void
    @State private var isShowingOpenSourceLicenseSheet = false
    
    private let openSourceLicenses: [OpenSourceLicenseItem] = [
        OpenSourceLicenseItem(
            iconName: "shippingbox.fill",
            title: "Alamofire (MIT License)",
            link: URL(string: "https://github.com/Alamofire/Alamofire/blob/master/LICENSE")!
        ),
        OpenSourceLicenseItem(
            iconName: "photo.stack.fill",
            title: "Kingfisher (MIT License)",
            link: URL(string: "https://github.com/onevcat/Kingfisher/blob/master/LICENSE")!
        )
    ]
    
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

            Button {
                isShowingOpenSourceLicenseSheet = true
            } label: {
                Text("Open Source License")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.accentColor, lineWidth: 1)
                    )
                    .padding(.horizontal, 40)
            }

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
        .sheet(isPresented: $isShowingOpenSourceLicenseSheet) {
            OpenSourceLicensesBottomSheet(licenses: openSourceLicenses)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct OpenSourceLicensesBottomSheet: View {
    let licenses: [OpenSourceLicenseItem]
    
    var body: some View {
        NavigationStack {
            List(licenses) { item in
                Link(destination: item.link) {
                    HStack(spacing: 12) {
                        Image(systemName: item.iconName)
                            .foregroundStyle(.accent)
                            .frame(width: 24)
                        Text(item.title)
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Open Source License")
        }
    }
}

private struct OpenSourceLicenseItem: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let link: URL
}

#Preview {
    ProfileContentView()
}
