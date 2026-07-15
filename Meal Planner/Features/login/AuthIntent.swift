//
//  AuthIntent.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

enum AuthIntent {
    case load
    case updateEmail(String)
    case updatePassword(String)
    case togglePasswordVisibility
    case submitLogin
    case resetLoginForm
    case logout
}

enum AuthEvent: Equatable {
    case setLoggedIn(Bool)
    case setEmail(String)
    case setPassword(String)
    case setShowPassword(Bool)
    case setLoginError(String?)
    case setLoggingIn(Bool)
    case resetLoginForm
}
