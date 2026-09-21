//
//  LegacyAuthMigrationTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 10/9/2026.
//

import Foundation
import Testing
@testable import Meal_Planner

struct LegacyAuthMigrationTests {

    @Test func migrationRemovesLegacyLoginDefaults() throws {
        let suiteName = "LegacyAuthMigrationTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set("eric", forKey: "stored_username")
        defaults.set("test", forKey: "stored_password")
        defaults.set(true, forKey: "login")
        defaults.set("keep", forKey: "category_cache")

        LegacyAuthMigration.removeLegacyAuthData(from: defaults)

        #expect(defaults.object(forKey: "stored_username") == nil)
        #expect(defaults.object(forKey: "stored_password") == nil)
        #expect(defaults.object(forKey: "login") == nil)
        #expect(defaults.string(forKey: "category_cache") == "keep")
    }
}
