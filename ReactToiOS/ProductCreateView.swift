//
//  ProductCreateView.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/21/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct ProductCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProductCreateViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        Form {
            Section("이미지") {
                if let data = viewModel.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("사진 선택", systemImage: "photo")
                }

                if viewModel.imageData != nil {
                    Button("이미지 제거", role: .destructive) {
                        viewModel.imageData = nil
                    }
                }
            }

            Section("기본 정보") {
                TextField("상품명", text: $viewModel.name)
                Picker("카테고라", selection: $viewModel.category) {
                    ForEach(ProductCategory.allCases) { category in
                        Text(category.title).tag(category.rawValue)
                    }
                }
                .pickerStyle(.menu)
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
        .navigationTitle("상품 추가")
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
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }

            Task {
                if let rawData = try? await newItem.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: rawData),
                       let jpeg = uiImage.jpegData(compressionQuality: 0.85) {
                        viewModel.imageData = jpeg
                    } else {
                        viewModel.imageData = rawData
                    }
                }
            }
        }
        .onChange(of: viewModel.didSave) { _, saved in
            if saved { dismiss() }
        }
    }
}
