//
//  ProductEditViewModel.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/21/26.
//

import Foundation
import Combine

@MainActor
final class ProductEditViewModel: ObservableObject {
    @Published var name: String
    @Published var priceText: String
    @Published var stockText: String
    @Published var category: String
    @Published var desc: String
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var didSave = false
    
    private let apiClient: APIClient
    private let productId: Int
    private let prodStatus: String
    
    init(seed: ProductItem, apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? .shared
        self.productId = seed.prodId
        self.prodStatus = seed.prodStatus ?? "ON_SALE"
        
        self.name = seed.prodName
        self.priceText = seed.prodPrice.map(String.init) ?? ""
        self.stockText = seed.prodStock.map(String.init) ?? ""
        self.category = seed.prodCategory ?? ""
        self.desc = seed.prodDesc ?? ""
    }
    
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSaving
    }
    
    func save() {
        guard !isSaving else { return }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDesc = desc.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "상품명을 입력해 주세요."
            return
        }
        
        guard !trimmedCategory.isEmpty else {
            errorMessage = "카테고리를 입력해 주세요."
            return
        }
        guard let price = Int(priceText), price >= 0 else {
            errorMessage = "가격은 0 이상 숫자로 입력해 주세요."
            return
        }
        guard let stock = Int(stockText), stock >= 0 else {
            errorMessage = "재고는 0 이상 숫자로 입력해 주세요."
            return
        }
        
        Task {
            await performSave(
                name: trimmedName,
                price: price,
                stock: stock,
                category: trimmedCategory,
                desc: trimmedDesc
            )
        }
    }
    
    private func performSave(name: String, price: Int, stock: Int, category: String, desc: String) async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        
        do {
            try await apiClient.postFormNoResponse(
                path: "/products/\(productId)",
                form: [
                    "prodName": name,
                    "prodPrice": String(price),
                    "prodStock": String(stock),
                    "prodCategory": category,
                    "prodDesc": desc,
                    "prodStatus": prodStatus
                ]
            )
            NotificationCenter.default.post(name: .didUpdateProduct, object: productId)
            didSave = true
        } catch {
            if let localized = error as? LocalizedError, let msg = localized.errorDescription {
                errorMessage = msg
            } else {
                errorMessage = "상품 수정에 실패했습니다."
            }
        }
    }
}
