//
//  SignUpView.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/16/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SignUpViewModel()
    var onRegisterCompleted: (String) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TextField("이름", text: $viewModel.userName)
                    .textContentType(.name)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                TextField("이메일", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                SecureField("비밀번호", text: $viewModel.password)
                    .textContentType(.newPassword)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                SecureField("비밀번호 확인", text: $viewModel.confirm)
                    .textContentType(.newPassword)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.showPasswordMismatchError ? Color.red : Color.clear, lineWidth: 1.5)
                    )
                
                if viewModel.showPasswordMismatchError {
                    Text("비밀번호가 일치하지 않습니다.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading, 4)
                }

                Button(action: viewModel.registerTapped) {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("회원가입")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isRegisterEnabled)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.successMessage) { _, newValue in
            guard let message = newValue else { return }
            onRegisterCompleted(message)
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
    .environmentObject(AppSessionStore())
}
