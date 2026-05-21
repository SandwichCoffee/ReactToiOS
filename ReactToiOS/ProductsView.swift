//
//  ProductsView.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/19/26.
//

import SwiftUI

struct ProductsView: View {
    @StateObject private var viewModel = ProductsViewModel()
    @EnvironmentObject private var sessionStore: AppSessionStore
    @State private var showCreateSheet = false
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView("불러오는 중...")
            } else if let message = viewModel.errorMessage, viewModel.products.isEmpty {
                VStack {
                    Text(message)
                    Button("다시 시도") { viewModel.refresh() }
                }
            } else if viewModel.products.isEmpty {
                Text("등록된 상품이 없습니다.")
            } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.products) { product in
                            NavigationLink {
                                ProductDetailView(productId: product.prodId, seed: product)
                            } label: {
                                ProductCard(item: product)
                            }
                        }
                    }
                    .padding()
            }
        }
        .navigationTitle("Products")
        .toolbar {
            if sessionStore.isAdmin {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            NavigationStack {
                ProductCreateView()
            }
        }
        .task { viewModel.refresh() }
    }
}

private struct ProductCard: View {
    let item: ProductItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.tertiarySystemBackground))
                
                if let url = productImageURL(item.prodImg) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case let .success(image):
                            image.resizable().scaledToFill()
                        default:
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(item.prodName)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            
            Text(priceText(item.prodPrice))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
            
            Text(stockText(item.prodStock))
                .font(.caption)
                .foregroundStyle((item.prodStock ?? 0) <= 10 ? .red : .secondary)
        }
    }
    
    private func priceText(_ value: Int?) -> String {
        guard let value else { return "가격 정보 없음" }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        
        return "\(f.string(from:NSNumber(value: value)) ?? "\(value)")원"
    }
    
    private func stockText(_ value: Int?) -> String {
        guard let value else { return "재고 정보 없음" }
        
        return "재고 \(value)"
    }
    
    private func productImageURL(_ name: String?) -> URL? {
        guard let name, !name.isEmpty else { return nil }
        let escaped = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        
        return URL(string: "https://reactproject-q472.onrender.com/images/\(escaped)")
    }
}
