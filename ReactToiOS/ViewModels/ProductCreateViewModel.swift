//
//  ProductCreateViewModel.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/21/26.
//

import Foundation
import Combine

@MainActor
final class ProductCreateViewModel: ObservableObject {
    @Published var name = ""
    @Published var priceText = ""
    @Published var stockText = ""
    @Published var category = ProductCategory.electronics.rawValue
    @Published var desc = ""
    @Published var imageData: Data?

    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var didSave = false

    private let apiClient: APIClient

    init(apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? .shared
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Int(priceText) != nil &&
        Int(stockText) != nil &&
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

    private func performSave(
        name: String,
        price: Int,
        stock: Int,
        category: String,
        desc: String
    ) async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let form: [String: String] = [
            "prodName": name,
            "prodPrice": String(price),
            "prodStock": String(stock),
            "prodCategory": category,
            "prodDesc": desc,
            "prodStatus": "ON_SALE"
        ]

        let uploadFile = imageData.map {
            MultipartFile(
                fieldName: "file",
                fileName: "product-\(Int(Date().timeIntervalSince1970)).jpg",
                mimeType: "image/jpeg",
                data: $0
            )
        }

        do {
            try await apiClient.postMultipartNoResponse(
                path: "/products",
                form: form,
                file: uploadFile
            )
            NotificationCenter.default.post(name: .didUpdateProduct, object: nil)
            didSave = true
        } catch {
            if let localized = error as? LocalizedError, let msg = localized.errorDescription {
                errorMessage = msg
            } else {
                errorMessage = "상품 등록에 실패했습니다."
            }
        }
    }
}
