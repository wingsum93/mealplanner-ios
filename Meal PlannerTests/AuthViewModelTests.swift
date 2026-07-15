//
//  AuthViewModelTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Testing
@testable import Meal_Planner

struct AuthViewModelTests {

    @MainActor
    @Test func authValidatesRequiredFieldsAndResetsForm() async throws {
        let viewModel = AuthViewModel(localDataSource: AuthLocalDataSourceSpy())

        viewModel.onIntent(.submitLogin)
        #expect(viewModel.state.loginErrorMessage == "Email is required")

        viewModel.onIntent(.updateEmail("eric"))
        viewModel.onIntent(.submitLogin)
        #expect(viewModel.state.loginErrorMessage == "Password is required")

        viewModel.onIntent(.updatePassword("test"))
        viewModel.onIntent(.togglePasswordVisibility)
        viewModel.onIntent(.resetLoginForm)

        #expect(viewModel.state.email == "")
        #expect(viewModel.state.password == "")
        #expect(viewModel.state.showPassword == false)
        #expect(viewModel.state.loginErrorMessage == nil)
    }

    @MainActor
    @Test func authHandlesFailedAndSuccessfulLogin() async throws {
        let localDataSource = AuthLocalDataSourceSpy(loginResult: false)
        let viewModel = AuthViewModel(localDataSource: localDataSource)

        viewModel.onIntent(.updateEmail("eric"))
        viewModel.onIntent(.updatePassword("wrong"))
        viewModel.onIntent(.submitLogin)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.isLoggedIn == false)
        #expect(viewModel.state.loginErrorMessage == "Invalid email or password")

        localDataSource.loginResult = true
        viewModel.onIntent(.updatePassword("test"))
        viewModel.onIntent(.submitLogin)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.isLoggedIn)
        #expect(localDataSource.loggedIn)

        viewModel.onIntent(.logout)
        #expect(viewModel.state.isLoggedIn == false)
        #expect(localDataSource.loggedIn == false)
    }
}
