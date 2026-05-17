//
//  DashboardViewModel.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/17/26.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var selectedPeriod: DashboardPeriod = .daily
    @Published var totalRevenue: Int = 0
    @Published var chartData: [SalesPoint] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: APIClient
    private var hasLoaded = false

    init(apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? .shared
    }

    func loadIfNeeded() {
        guard !hasLoaded else { return }
        hasLoaded = true
        Task {
            await loadDashboard()
        }
    }

    func changePeriod(_ period: DashboardPeriod) {
        guard selectedPeriod != period else { return }
        selectedPeriod = period
        Task {
            await loadDashboard()
        }
    }

    func retryTapped() {
        Task {
            await loadDashboard()
        }
    }

    private func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response: DashboardStatsResponse = try await apiClient.get(
                path: "/orders/stats",
                queryItems: [URLQueryItem(name: "period", value: selectedPeriod.rawValue)]
            )
            totalRevenue = response.totalRevenue
            chartData = response.chartData
        } catch {
            chartData = []
            if let localizedError = error as? LocalizedError,
               let message = localizedError.errorDescription {
                errorMessage = message
            } else {
                errorMessage = "대시보드 정보를 불러오지 못했습니다."
            }
        }
    }
}
