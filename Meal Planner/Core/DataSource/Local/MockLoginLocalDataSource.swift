//
//  MockLoginLocalDataSource.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

struct MockLoginLocalDataSource: LoginLocalDataSource {
    var loggedIn: Bool = false

    func login(username: String, password: String) async -> Bool { true }
    func isLoggedIn() -> Bool { loggedIn }
    func setLoggedIn(_ value: Bool) {}
    func logout() {}
}
