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
