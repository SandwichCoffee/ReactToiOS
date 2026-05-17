//
//  SignUpViewModel.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/16/26.
//

import Foundation
import Combine

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var userName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirm = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    var showPasswordMismatchError: Bool {
        !confirm.isEmpty && password != confirm
    }

    var isRegisterEnabled: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty
            && !confirm.isEmpty
            && password == confirm
            && !isLoading
    }

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
    }

    func registerTapped() {
        guard isRegisterEnabled else { return }
        Task {
            await performRegister()
        }
    }

    private func performRegister() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }

        do {
            try await authService.register(
                email: email,
                password: password,
                userName: userName
            )
            successMessage = "회원가입이 완료되었습니다. 로그인해 주세요."
        } catch {
            successMessage = nil
            if let localizedError = error as? LocalizedError,
               let message = localizedError.errorDescription {
                errorMessage = message
            } else {
                errorMessage = "회원가입 중 오류가 발생했습니다."
            }
        }
    }
}
