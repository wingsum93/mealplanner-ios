//
//  LoginLocalDataSource.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

protocol LoginLocalDataSource{
    func login(username: String, password: String) async -> Bool
    func isLoggedIn() -> Bool
    func setLoggedIn(_ status:Bool)
    func logout()
}
