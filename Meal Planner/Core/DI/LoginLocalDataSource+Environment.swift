//
//  AppKey.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

private struct LoginLocalDataSourceKey: EnvironmentKey {
    static let defaultValue: LoginLocalDataSource = LoginLocalDataSourceImpl()
}

extension EnvironmentValues {
    var loginLocalDataSource: LoginLocalDataSource {
        get { self[LoginLocalDataSourceKey.self] }
        set { self[LoginLocalDataSourceKey.self] = newValue }
    }
}
