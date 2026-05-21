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

nonisolated struct DashboardStatsResponse: Decodable {
    let chartData: [SalesPoint]
    let totalRevenue: Int
}

nonisolated struct ProductListSummaryResponse: Decodable {
    let total: Int
    let products: [ProductSummary]

    private enum CodingKeys: String, CodingKey {
        case total
        case totalElements
        case list
        case content
        case products
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        total = container.decodeFlexibleInt(forKeys: [.total, .totalElements]) ?? 0
        products =
            (try? container.decode([ProductSummary].self, forKey: .list)) ??
            (try? container.decode([ProductSummary].self, forKey: .content)) ??
            (try? container.decode([ProductSummary].self, forKey: .products)) ??
            (try? container.decode([ProductSummary].self, forKey: .items)) ??
            []
    }
}

struct ProductSummary: Decodable, Identifiable {
    let productId: Int
    let id: String
    let name: String
    let price: Int?
    let stock: Int?
    let imageName: String?
    let createdAt: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case productId
        case prodId
        case name
        case productName
        case prodName
        case title
        case price
        case prodPrice
        case stock
        case prodStock
        case imageName
        case prodImg
        case image
        case createdAt
        case regDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawProductId = container.decodeFlexibleInt(forKeys: [.prodId, .productId]) ?? 0
        let rawId = container.decodeFlexibleString(forKeys: [.id, .productId, .prodId])
        let rawName = container.decodeFlexibleString(forKeys: [.prodName, .name, .productName, .title]) ?? "이름 없는 상품"
        let rawPrice = container.decodeFlexibleInt(forKeys: [.prodPrice, .price])
        let rawStock = container.decodeFlexibleInt(forKeys: [.prodStock, .stock])
        let rawImageName = container.decodeFlexibleString(forKeys: [.prodImg, .imageName, .image])
        let rawCreatedAt = container.decodeFlexibleString(forKeys: [.regDate, .createdAt])

        productId = rawProductId
        id = rawId ?? "\(rawName)-\(rawCreatedAt ?? UUID().uuidString)"
        name = rawName
        price = rawPrice
        stock = rawStock
        imageName = rawImageName
        createdAt = rawCreatedAt
    }
}

struct RecruitSummary: Decodable, Identifiable {
    let recruitId: Int
    let id: String
    let status: String
    let title: String
    let startDate: String?
    let endDate: String?
    let createdAt: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case recruitId
        case status
        case title
        case position
        case recruitTitle
        case startDate
        case endDate
        case regDate
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawRecruitId = container.decodeFlexibleInt(forKeys: [.recruitId]) ?? 0
        let rawId = container.decodeFlexibleString(forKeys: [.id, .recruitId])

        recruitId = rawRecruitId
        status = container.decodeFlexibleString(forKeys: [.status]) ?? ""
        title = container.decodeFlexibleString(forKeys: [.title, .position, .recruitTitle]) ?? "제목 없는 공고"
        startDate = container.decodeFlexibleString(forKeys: [.startDate])
        endDate = container.decodeFlexibleString(forKeys: [.endDate])
        createdAt = container.decodeFlexibleString(forKeys: [.regDate, .createdAt])
        id = rawId ?? "\(title)-\(createdAt ?? UUID().uuidString)"
    }
}

struct SalesPoint: Decodable, Identifiable {
    let date: String
    let revenue: Int

    var id: String { date }
}

private extension KeyedDecodingContainer {
    nonisolated func decodeFlexibleString(forKeys keys: [Key]) -> String? {
        for key in keys {
            if let value = try? decode(String.self, forKey: key), !value.isEmpty {
                return value
            }
            if let value = try? decode(Int.self, forKey: key) {
                return String(value)
            }
        }
        return nil
    }

    nonisolated func decodeFlexibleInt(forKeys keys: [Key]) -> Int? {
        for key in keys {
            if let value = try? decode(Int.self, forKey: key) {
                return value
            }
            if let value = try? decode(Double.self, forKey: key) {
                return Int(value)
            }
            if let value = try? decode(String.self, forKey: key),
               let parsed = Int(value) {
                return parsed
            }
            if let value = try? decode(String.self, forKey: key),
               let parsed = Double(value) {
                return Int(parsed)
            }
        }
        return nil
    }
}
