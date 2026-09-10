//
//  LegacyAuthStorageCleanup.swift
//  Meal Planner
//
//  Created by Codex on 10/9/2026.
//

import Foundation

enum LegacyAuthStorageCleanup {
    static let keys = [
        "stored_username",
        "stored_password",
        "login"
    ]

    static func removeLegacyAuthData(from defaults: UserDefaults = .standard) {
        keys.forEach { defaults.removeObject(forKey: $0) }
    }
}
