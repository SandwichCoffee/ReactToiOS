//
//  ProductDetailView.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/20/26.
//

import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @EnvironmentObject private var sessionStore: AppSessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false
    @State private var showEditSheet = false
    
    init(productId: Int, seed: ProductItem? = nil) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productId: productId, seed: seed))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.product == nil {
                ProgressView("불러오는 중...")
            } else if let message = viewModel.errorMessage, viewModel.product == nil {
                VStack(spacing: 12) {
                    Text(message)
                    Button("다시 시도") { viewModel.refresh() }
                }
            } else if let product = viewModel.product {
                ScrollView {
                    VStack(spacing: 16) {
                        if let message = viewModel.errorMessage {
                            errorBanner(message)
                        }
                        imageSection(product)
                        infoSection(product)
                        stockStatusSection(product)
                        descriptionSection(product)
                    }
                    .padding()
                }
            } else {
                Text("상품 정보를 찾을 수 없습니다.")
            }
        }
        .navigationTitle("상품 상세")
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.loadIfNeeded() }
        .toolbar {
            if sessionStore.isAdmin {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("수정") {
                            showEditSheet = true
                        }
                        
                        Button("삭제", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .confirmationDialog("상품을 삭제할까요?", isPresented: $showDeleteConfirm) {
            Button("삭제", role: .destructive) {
                viewModel.deleteProduct()
            }
            
            Button("취소", role: .cancel) { }
        }
        .onChange(of: viewModel.didDelete) { _, deleted in
            if deleted { dismiss() }
        }
        .sheet(isPresented: $showEditSheet) {
            if let product = viewModel.product {
                NavigationStack {
                    ProductEditView(seed: product) {
                        viewModel.refresh()
                    }
                }
            }
        }
    }
    
    private func imageSection(_ product: ProductItem) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
            
            if let url = productImageURL(product.prodImg) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    default:
                        ProgressView()
                    }
                }
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
        }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func infoSection(_ product: ProductItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let category = product.prodCategory, !category.isEmpty {
                Text(category)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.12))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
            
            Text(product.prodName)
                .font(.title2.bold())
            
            Text("등록일: \(product.regDate ?? "-")")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(priceText(product.prodPrice))
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.blue)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func stockStatusSection(_ product: ProductItem) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("현재 재고")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(stockText(product.prodStock))
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("판매 상태")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(saleStatusText(product.prodStatus))
                    .fontWeight(.semibold)
                    .foregroundStyle(saleStatusColor(product.prodStatus))
            }
        }
        .font(.subheadline)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func descriptionSection(_ product: ProductItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("상품 설명")
            
            Text(product.prodDesc ?? "설명 정보가 없습니다.")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func priceText(_ value: Int?) -> String {
        guard let value else { return "가격 정보 없음" }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        
        return "\(f.string(from: NSNumber(value: value)) ?? "\(value)")원"
    }

    private func stockText(_ value: Int?) -> String {
        guard let value else { return "재고 정보 없음" }
        
        return("\(value)")
    }
    
    private func saleStatusText(_ raw: String?) -> String {
        switch raw?.uppercased() {
        case "ON_SALE": return "판매 중"
        case "SOLD_OUT": return "품절"
        case "STOP", "OFF_SALE": return "판매 중지"
        default: return raw ?? "정보 없음"
        }
    }
    
    private func saleStatusColor(_ raw: String?) -> Color {
        switch raw?.uppercased() {
        case "ON_SALE": return .green
        case "SOLD_OUT": return .red
        case "STOP", "OFF_SALE": return .orange
        default: return .secondary
        }
    }
    
    private func productImageURL(_ name: String?) -> URL? {
        guard let name, !name.isEmpty else { return nil }
        let escaped = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        return URL(string: "https://reactproject-q472.onrender.com/images/\(escaped)")
    }
    
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()

            Button("재시도") { viewModel.refresh() }
                .font(.footnote.weight(.semibold))
        }
        .padding(12)
        .background(Color.orange.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
