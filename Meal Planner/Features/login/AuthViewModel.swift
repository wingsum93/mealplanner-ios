//
//  AuthManager.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import Foundation

private enum AuthEvent: Equatable {
    case setLoggedIn(Bool)
    case setEmail(String)
    case setPassword(String)
    case setShowPassword(Bool)
    case setLoginError(String?)
    case setLoggingIn(Bool)
    case resetLoginForm
}

@MainActor
final class AuthViewModel: ObservableObject {

    @Published private(set) var state = AuthState()
    private let localDataSource:LoginLocalDataSource
    private var loginTask: Task<Void, Never>?

    init(localDataSource:LoginLocalDataSource) {
        self.localDataSource = localDataSource
        onIntent(.load)
    }

    deinit { loginTask?.cancel() }
    
    func onIntent(_ intent: AuthIntent) {
        switch intent {
        case .load:
            reduce(.setLoggedIn(localDataSource.isLoggedIn()))
        case .updateEmail(let email):
            reduce(.setEmail(email))
        case .updatePassword(let password):
            reduce(.setPassword(password))
        case .togglePasswordVisibility:
            reduce(.setShowPassword(!state.showPassword))
        case .submitLogin:
            submitLogin()
        case .resetLoginForm:
            reduce(.resetLoginForm)
        case .logout:
            localDataSource.logout()
            reduce(.setLoggedIn(false))
            reduce(.resetLoginForm)
        }
    }

    private func submitLogin() {
        guard !state.email.isEmpty else {
            reduce(.setLoginError("Email is required"))
            return
        }
        guard !state.password.isEmpty else {
            reduce(.setLoginError("Password is required"))
            return
        }

        loginTask?.cancel()
        reduce(.setLoggingIn(true))
        reduce(.setLoginError(nil))

        let email = state.email
        let password = state.password
        loginTask = Task { [weak self] in
            guard let self else { return }
            let success = await localDataSource.login(username: email, password: password)
            guard !Task.isCancelled else { return }
            reduce(.setLoggingIn(false))

            if success {
                localDataSource.setLoggedIn(true)
                reduce(.setLoginError(nil))
                reduce(.setLoggedIn(true))
            } else {
                reduce(.setLoginError("Invalid email or password"))
            }
        }
    }

    private func reduce(_ event: AuthEvent) {
        switch event {
        case .setLoggedIn(let isLoggedIn):
            state.isLoggedIn = isLoggedIn
        case .setEmail(let email):
            state.email = email
            state.loginErrorMessage = nil
        case .setPassword(let password):
            state.password = password
            state.loginErrorMessage = nil
        case .setShowPassword(let showPassword):
            state.showPassword = showPassword
        case .setLoginError(let message):
            state.loginErrorMessage = message
        case .setLoggingIn(let isLoggingIn):
            state.isLoggingIn = isLoggingIn
        case .resetLoginForm:
            state.email = ""
            state.password = ""
            state.showPassword = false
            state.loginErrorMessage = nil
            state.isLoggingIn = false
        }
    }
}
