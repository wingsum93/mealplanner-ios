//
//  AuthState.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
struct AuthState: Equatable {
    var isLoggedIn: Bool = false
    var email: String = ""
    var password: String = ""
    var showPassword: Bool = false
    var loginErrorMessage: String?
    var isLoggingIn: Bool = false
}
