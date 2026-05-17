//
//  DashboardModels.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/17/26.
//

import Foundation

enum DashboardPeriod: String, CaseIterable, Identifiable {
    case daily
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: return "일"
        case .weekly: return "주"
        case .monthly: return "월"
        case .yearly: return "년"
        }
    }
}

struct DashboardStatsResponse: Decodable {
    let chartData: [SalesPoint]
    let totalRevenue: Int
}

struct ProductListSummaryResponse: Decodable {
    let total: Int
}

struct RecruitSummary: Decodable {
    let status: String
}

struct SalesPoint: Decodable, Identifiable {
    let date: String
    let revenue: Int

    var id: String { date }
}
