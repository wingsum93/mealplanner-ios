//
//  LoginLocalDataSourceImpl.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import Foundation

final class LoginLocalDataSourceImpl: LoginLocalDataSource {
    func login(username: String, password: String) async -> Bool {
        let isValid = username.lowercased() == "eric" && password == "test"
        
        if isValid {
            UserDefaults.standard.set(username, forKey: "stored_username")
            UserDefaults.standard.set(password, forKey: "stored_password")
            UserDefaults.standard.setValue(true, forKey: "login")
        }
        
        return isValid
    }
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "login")
    }
    
    func setLoggedIn(_ status: Bool) {
        UserDefaults.standard.setValue(true, forKey: "login")
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "stored_username")
        UserDefaults.standard.removeObject(forKey: "stored_password")
        UserDefaults.standard.setValue(false, forKey: "login")
    }
    
}
