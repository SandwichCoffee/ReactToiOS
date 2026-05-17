//
//  ReactToiOSApp.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/15/26.
//

import SwiftUI

@main
struct ReactToiOSApp: App {
    @StateObject private var sessionStore = AppSessionStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if sessionStore.isRestoringSession {
                    ProgressView("세션 확인 중...")
                } else if sessionStore.isAuthenticated {
                    HomeView()
                } else {
                    ContentView()
                }
            }
            .environmentObject(sessionStore)
            .onAppear {
                sessionStore.restoreSessionIfNeeded()
            }
        }
    }
}
