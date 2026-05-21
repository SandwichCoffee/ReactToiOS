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
    @Published private(set) var userRole: String?

    private let authService: AuthServiceProtocol
    private let userRoleKey = "session.userRole"
    private var hasRestoredSession = false
    private var cancellables = Set<AnyCancellable>()
    
    var isAdmin: Bool {
        let normalized = (userRole ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        
        return normalized == "ADMIN" || normalized == "ROLE_ADMIN"
    }

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()

        NotificationCenter.default.publisher(for: .didReceiveUnauthorizedResponse)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.isAuthenticated = false
                self?.userRole = nil
                UserDefaults.standard.removeObject(forKey: self?.userRoleKey ?? "session.userRole")
            }
            .store(in: &cancellables)
    }

    func restoreSessionIfNeeded() {
        guard !hasRestoredSession else { return }
        hasRestoredSession = true

        isAuthenticated = authService.readSavedToken() != nil
        userRole = UserDefaults.standard.string(forKey: userRoleKey)
        isRestoringSession = false
    }

    func markAuthenticated(role: String?) {
        isAuthenticated = true
        userRole = role
        UserDefaults.standard.set(role, forKey: userRoleKey)
    }

    func logout() {
        try? authService.logout()
        isAuthenticated = false
        userRole = nil
        UserDefaults.standard.removeObject(forKey: userRoleKey)
    }
}
