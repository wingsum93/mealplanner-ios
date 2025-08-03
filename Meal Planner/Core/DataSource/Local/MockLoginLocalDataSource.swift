//
//  MockLoginLocalDataSource.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

struct MockLoginLocalDataSource: LoginLocalDataSource {
    func login(username: String, password: String) async -> Bool { true }
    func isLoggedIn() -> Bool { false }
    func setLoggedIn(_ value: Bool) {}
    func logout() {}
}
