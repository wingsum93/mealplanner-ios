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
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showPassword: Bool = false
    @Published var loginErrorMessage: String?
    private let loginKey = "is_logged_in"
    private let localDataSource:LoginLocalDataSource

    init(localDataSource:LoginLocalDataSource) {
        self.localDataSource = localDataSource
        onIntent(.load)
    }

    func performLogin(onSuccess: @escaping () -> Void) {
        guard !email.isEmpty else {
            loginErrorMessage = "Email is required"
            return
        }
        guard !password.isEmpty else {
            loginErrorMessage = "Password is required"
            return
        }
        
        Task {
            let success = await localDataSource.login(username: email, password: password)
            if success {
                loginErrorMessage = nil
                onIntent(.loginSuccess)
                onSuccess()
            } else {
                loginErrorMessage = "Invalid email or password"
            }
        }
    }
    
    func resetInputFields(){
        email.removeAll()
        password.removeAll()
        showPassword = false
        loginErrorMessage = nil
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
