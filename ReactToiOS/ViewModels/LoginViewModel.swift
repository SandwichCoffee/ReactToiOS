//
//  LoginViewModel.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/15/26.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var loggedInRole: String?

    var isLoginEnabled: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty
            && !isLoading
    }
    
    private let authService: AuthServiceProtocol
    private let adminEmail = "admin@aa.com"
    private let adminPassword = "123123"

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
    }

    func loginTapped() async -> Bool {
        guard isLoginEnabled else { return false }
        
        return await performLogin(email: email, password: password)
    }

    func loginAsAdminTapped() async -> Bool {
        guard !isLoading else { return false }
        email = adminEmail
        password = adminPassword
        
        return await performLogin(email: adminEmail, password: adminPassword)
    }

    private func performLogin(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await authService.login(email: email, password: password)
            loggedInRole = response.role
            
            return true
        } catch {
            if let localizedError = error as? LocalizedError,
               let message = localizedError.errorDescription {
                errorMessage = message
            } else {
                errorMessage = "로그인 중 오류가 발생했습니다."
            }
            
            return false
        }
    }
}
