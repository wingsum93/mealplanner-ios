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
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("RecipeApp-IOS").font(.title2).bold()
            Image("AppIcon").resizable().frame(width: 72, height: 72).clipShape(Circle())
            
            TextField("Email", text: $authViewModel.email)
                .textInputAutocapitalization(.none)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
            
            ZStack(alignment: .trailing) {
                Group {
                    if authViewModel.showPassword {
                        TextField("Password", text: $authViewModel.password)
                    } else {
                        SecureField("Password", text: $authViewModel.password)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                
                Button {
                    authViewModel.showPassword.toggle()
                } label: {
                    Image(systemName: authViewModel.showPassword ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            
            if let error = authViewModel.loginErrorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button("Login") {
                authViewModel.performLogin {
                    authViewModel.resetInputFields()
                    dismiss()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(24)
        }
        .padding()
        .presentationDetents([.height(420)])
    }
    
}
