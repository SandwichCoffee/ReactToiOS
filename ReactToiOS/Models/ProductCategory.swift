//
//  ProductCategory.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/21/26.
//

import Foundation

enum ProductCategory: String, CaseIterable, Identifiable {
    case electronics = "Electronics"
    case clothing = "Clothing"
    case home = "Home"
    case books = "Books"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .electronics: return "전자제품"
        case .clothing: return "의류"
        case .home: return "생활용품"
        case .books: return "도서"
        }
    }

    static func normalizedRaw(_ raw: String?) -> String {
        let value = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch value {
        case "electronics", "전자제품": return ProductCategory.electronics.rawValue
        case "clothing", "의류": return ProductCategory.clothing.rawValue
        case "home", "생활용품": return ProductCategory.home.rawValue
        case "books", "도서": return ProductCategory.books.rawValue
        default: return ProductCategory.electronics.rawValue
        }
    }
}
