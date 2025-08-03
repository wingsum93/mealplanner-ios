//
//  AuthManager.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {

    @Published private(set) var state = AuthState()

    private let loginKey = "is_logged_in"
    private let localDataSource:LoginLocalDataSource

    init(localDataSource:LoginLocalDataSource) {
        self.localDataSource = localDataSource
        onIntent(.load)
    }

    func onIntent(_ intent: AuthIntent) {
        switch intent {
        case .load:
            state.isLoggedIn = localDataSource.isLoggedIn()
        case .loginSuccess:
            state.isLoggedIn = true
            localDataSource.setLoggedIn(true)
        case .logout:
            state.isLoggedIn = false
            localDataSource.logout()
        }
    }
}
