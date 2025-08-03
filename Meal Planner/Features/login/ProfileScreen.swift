//
//  ProfileScreen.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct ProfileScreen:View{
    @Environment(\.loginLocalDataSource) private var localDataSource
    @StateObject private var authViewModel:AuthViewModel

    init() {
        _authViewModel = StateObject(wrappedValue: AuthViewModel(localDataSource: LoginLocalDataSourceImpl()))
    }
    var body: some View{
        VStack {
                    if authViewModel.state.isLoggedIn {
                        ProfileContentView()
                    } else {
                        UnloggedInView {
                            authViewModel.onIntent(.loginSuccess)
                        }
                    }
                }
                .onAppear {
                    authViewModel.onIntent(.load)
                }
                .navigationTitle("Profile")
    }
}

#Preview {
    ProfileScreen().environment(\.loginLocalDataSource, LoginLocalDataSourceImpl())
}
