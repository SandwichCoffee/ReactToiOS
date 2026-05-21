//
//  ProductEditView.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/21/26.
//

import SwiftUI

struct ProductEditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ProductEditViewModel
    let onSaved: (() -> Void)?
    
    init(seed: ProductItem, onSaved: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: ProductEditViewModel(seed: seed))
        self.onSaved = onSaved
    }
    
    var body: some View {
        Form {
            Section("기본 정보") {
                TextField("상품명", text: $viewModel.name)
                TextField("카테고리", text: $viewModel.category)
            }
            
            Section("가격/재고") {
                TextField("가격", text: $viewModel.priceText)
                    .keyboardType(.numberPad)
                TextField("재고", text: $viewModel.stockText)
                    .keyboardType(.numberPad)
            }
            
            Section("설명") {
                TextField("상품 설명", text: $viewModel.desc, axis: .vertical)
                    .lineLimit(4...8)
            }
            
            if let message = viewModel.errorMessage {
                Section {
                    Text(message)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("상품 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(viewModel.isSaving ? "저장 중..." : "저장") {
                    viewModel.save()
                }
                .disabled(!viewModel.canSave || viewModel.isSaving)
            }
        }
        .onChange(of: viewModel.didSave) { _, saved in
            if saved {
                onSaved?()
                dismiss()
            }
        }
    }
}
