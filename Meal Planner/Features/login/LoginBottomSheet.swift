//
//  LoginSheet.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI
import Foundation

struct LoginBottomSheet:View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("RecipeApp-IOS").font(.title2).bold()
            Image("AppIcon").resizable().frame(width: 72, height: 72).clipShape(Circle())
            
            TextField("Email", text: Binding(
                get: { authViewModel.state.email },
                set: { authViewModel.onIntent(.updateEmail($0)) }
            ))
                .textInputAutocapitalization(.none)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
            
            ZStack(alignment: .trailing) {
                Group {
                    if authViewModel.state.showPassword {
                        TextField("Password", text: Binding(
                            get: { authViewModel.state.password },
                            set: { authViewModel.onIntent(.updatePassword($0)) }
                        ))
                    } else {
                        SecureField("Password", text: Binding(
                            get: { authViewModel.state.password },
                            set: { authViewModel.onIntent(.updatePassword($0)) }
                        ))
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                
                Button {
                    authViewModel.onIntent(.togglePasswordVisibility)
                } label: {
                    Image(systemName: authViewModel.state.showPassword ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            
            if let error = authViewModel.state.loginErrorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button("Login") {
                authViewModel.onIntent(.submitLogin)
            }
            .disabled(authViewModel.state.isLoggingIn)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(24)
        }
        .padding()
        .presentationDetents([.height(420)])
        .onChange(of: authViewModel.state.isLoggedIn) { _, isLoggedIn in
            guard isLoggedIn else { return }
            authViewModel.onIntent(.resetLoginForm)
            dismiss()
        }
    }
    
}
