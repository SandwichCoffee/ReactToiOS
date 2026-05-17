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
    @Published var loginMessage: String?

    var isLoginEnabled: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty
            && !isLoading
    }

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
    }

    func loginTapped() {
        guard isLoginEnabled else { return }

        Task {
            await performLogin()
        }
    }

    private func performLogin() async {
        isLoading = true
        errorMessage = nil
        loginMessage = nil
        defer { isLoading = false }

        do {
            try await authService.login(email: email, password: password)
            loginMessage = "로그인에 성공했습니다."
        } catch {
            loginMessage = nil
            if let localizedError = error as? LocalizedError,
               let message = localizedError.errorDescription {
                errorMessage = message
            } else {
                errorMessage = "로그인 중 오류가 발생했습니다."
            }
        }
    }
}
