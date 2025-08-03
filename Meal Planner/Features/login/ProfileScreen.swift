//
//  ProfileScreen.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct ProfileScreen:View{
    @Environment(\.loginLocalDataSource) private var localDataSource
    @ObservedObject var authViewModel: AuthViewModel
    let onLoginBtnClicked:() -> Void
    
    init(authViewModel: AuthViewModel,_ onLoginBtnClicked:@escaping ()->Void = {}) {
        self.authViewModel = authViewModel
        self.onLoginBtnClicked = onLoginBtnClicked
    }
    
    // MARK: - Convenience initializer for preview
    init(isLoggedIn: Bool = false) {
        let mockVM = AuthViewModel(localDataSource: MockLoginLocalDataSource())
        self.init(authViewModel: mockVM)
        if isLoggedIn {
            mockVM.onIntent(.loginSuccess)
        }
    }
    
    var body: some View{
        VStack {
            if authViewModel.state.isLoggedIn {
                ProfileContentView{
                    _authViewModel.wrappedValue.onIntent(.logout)
                }
            } else {
                UnloggedInView {
                    onLoginBtnClicked()
                }
            }
        }
        .onAppear {
            authViewModel.onIntent(.load)
        }
    }
}

#Preview("Logged Out") {
    ProfileScreen(isLoggedIn: false)
}

#Preview("Logged In") {
    ProfileScreen(isLoggedIn: true)
}
