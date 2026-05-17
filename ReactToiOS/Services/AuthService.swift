//
//  AuthService.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/16/26.
//

import Foundation

final class AuthService: AuthServiceProtocol {
    private let apiClient: APIClient
    private let tokenStore: TokenStoreProtocol

    init(
        apiClient: APIClient = .shared,
        tokenStore: TokenStoreProtocol = KeychainTokenStore()
    ) {
        self.apiClient = apiClient
        self.tokenStore = tokenStore
    }

    func login(email: String, password: String) async throws {
        let request = LoginRequest(email: email, password: password)
        let response: LoginResponse = try await apiClient.post(path: "/users/login", body: request)
        try tokenStore.saveToken(response.token)
    }

    func register(email: String, password: String, userName: String) async throws {
        let request = RegisterRequest(
            email: email,
            password: password,
            userName: userName
        )
        try await apiClient.postNoResponse(path: "/users/join", body: request)
    }

    func readSavedToken() -> String? {
        tokenStore.readToken()
    }

    func logout() throws {
        try tokenStore.deleteToken()
    }
}
