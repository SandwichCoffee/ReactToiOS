//
//  ProductsViewModel.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/19/26.
//

import Foundation
import Combine

@MainActor
final class ProductsViewModel: ObservableObject {
    @Published var products: [ProductItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: APIClient
    private var cancellables = Set<AnyCancellable>()
    
    init(apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? .shared
        
        NotificationCenter.default.publisher(for: .didUpdateProduct)
            .sink { [weak self] _ in
                Task { @MainActor in
                    guard let self else { return }
                    guard !self.isLoading else { return } // 중복 호출 방지
                    self.refresh()
                }
            }
            .store(in: &cancellables)
    }
    
    func refresh() {
        guard !isLoading else { return }
        
        Task {
            await loadProduct()
        }
    }
    
    private func loadProduct() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response: ProductResponse = try await apiClient.get(
                path: "/products",
                queryItems: [
                    URLQueryItem(name: "page", value: "1"),
                    URLQueryItem(name: "size", value: "10")
                ]
            )
            
            products = response.list
        } catch {
            errorMessage = "상품 정보를 불러오지 못했습니다."
        }
    }
}
