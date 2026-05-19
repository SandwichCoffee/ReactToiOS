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
    @Published var totalProductCount: Int = 0
    @Published var activeRecruitCount: Int = 0
    @Published var totalRevenue: Int = 0
    @Published var chartData: [SalesPoint] = []
    @Published var recentProducts: [ProductSummary] = []
    @Published var latestRecruits: [RecruitSummary] = []
    @Published var systemStatus: String = "정상"
    @Published var systemStatusDescription: String = "Server Uptime: 99.9%"
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
            async let statsTask: DashboardStatsResponse = apiClient.get(
                path: "/orders/stats",
                queryItems: [URLQueryItem(name: "period", value: selectedPeriod.rawValue)]
            )
            async let productsTask: ProductListSummaryResponse = apiClient.get(
                path: "/products",
                queryItems: [
                    URLQueryItem(name: "page", value: "1"),
                    URLQueryItem(name: "size", value: "10")
                ]
            )
            async let recruitsTask: [RecruitSummary] = apiClient.get(path: "/recruits")

            let stats = try await statsTask
            let products = try await productsTask
            let recruits = try await recruitsTask

            totalRevenue = stats.totalRevenue
            chartData = stats.chartData
            totalProductCount = products.total
            recentProducts = Array(
                products.products
                    .sorted(by: { $0.productId > $1.productId })
                    .prefix(4)
            )
            activeRecruitCount = recruits.filter { $0.status.uppercased() == "OPEN" }.count
            latestRecruits = Array(
                recruits.prefix(5)
            )
        } catch {
            chartData = []
            totalProductCount = 0
            activeRecruitCount = 0
            recentProducts = []
            latestRecruits = []
            if let localizedError = error as? LocalizedError,
               let message = localizedError.errorDescription {
                errorMessage = message
            } else {
                errorMessage = "대시보드 정보를 불러오지 못했습니다."
            }
        }
    }
}
