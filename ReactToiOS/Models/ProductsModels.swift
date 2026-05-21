//
//  ProductsModels.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/19/26.
//

import Foundation

struct ProductResponse: Decodable {
    let list: [ProductItem]
    let total: Int
}

struct ProductItem: Decodable, Identifiable {
    let prodId: Int
    let prodName: String
    let prodPrice: Int?
    let prodStock: Int?
    let prodImg: String?
    let regDate: String?
    
    let prodCategory: String?
    let prodDesc: String?
    let prodStatus: String?
    
    var id: Int { prodId }
}
