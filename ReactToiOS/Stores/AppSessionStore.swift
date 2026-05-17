//
//  AppSessionStore.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/16/26.
//

import Foundation
import Combine

@MainActor
final class AppSessionStore: ObservableObject {
    @Published private(set) var isRestoringSession = true
    @Published private(set) var isAuthenticated = false

    private let authService: AuthServiceProtocol
    private var hasRestoredSession = false
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()

        NotificationCenter.default.publisher(for: .didReceiveUnauthorizedResponse)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.isAuthenticated = false
            }
            .store(in: &cancellables)
    }

    func restoreSessionIfNeeded() {
        guard !hasRestoredSession else { return }
        hasRestoredSession = true

        isAuthenticated = authService.readSavedToken() != nil
        isRestoringSession = false
    }

    func markAuthenticated() {
        isAuthenticated = true
    }

    func logout() {
        try? authService.logout()
        isAuthenticated = false
    }
}
