//
//  ProductDetailViewModel.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/20/26.
//

import Foundation
import Combine

@MainActor
final class ProductDetailViewModel: ObservableObject {
    @Published var product: ProductItem?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isDeleting = false
    @Published var didDelete = false
    
    private let apiClient: APIClient
    private let productId: Int
    private var hasLoaded = false
    
    init(productId: Int, seed: ProductItem? = nil, apiClient: APIClient? = nil) {
        self.productId = productId
        self.product = seed
        self.apiClient = apiClient ?? .shared
    }
    
    func loadIfNeeded() {
        guard !hasLoaded else { return }
        hasLoaded = true
        
        refresh()
    }
    
    func refresh() {
        guard !isLoading else { return }
        Task { await fetchDetail() }
    }
    
    private func fetchDetail() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let detail: ProductItem = try await apiClient.get(path: "/products/\(productId)")
            product = detail
        } catch {
            errorMessage = "상품 정보를 불러오지 못했습니다."
        }
    }
    
    func deleteProduct() {
        guard !isDeleting else { return }
        
        Task { await performDelete() }
    }
    
    private func performDelete() async {
        isDeleting = true
        defer { isDeleting = false }
        
        do {
            try await apiClient.delete(path: "/products/\(productId)")
            NotificationCenter.default.post(name: .didUpdateProduct, object: productId)
            didDelete = true
        } catch {
            errorMessage = "상품 삭제에 실패했습니다."
        }
    }
}
