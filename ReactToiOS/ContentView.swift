//
//  ContentView.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/15/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var sessionStore: AppSessionStore
    @StateObject private var viewModel = LoginViewModel()
    @State private var toastMessage: String?
    @State private var isToastVisible = false
    @State private var toastHideTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("로그인")
                        .font(.largeTitle.bold())
                }

                VStack(spacing: 12) {
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
                        .textContentType(.password)
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: viewModel.loginTapped) {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("로그인")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isLoginEnabled)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let loginMessage = viewModel.loginMessage {
                    Text(loginMessage)
                        .font(.footnote)
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: 6) {
                    Text("아직 계정이 없으신가요?")
                        .foregroundStyle(.secondary)
                    NavigationLink("회원가입") {
                        SignUpView { message in
                            showToast(message)
                        }
                    }
                }
                .font(.footnote)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
        }
        .overlay(alignment: .top) {
            if isToastVisible, let toastMessage {
                ToastBannerView(message: toastMessage)
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onDisappear {
            toastHideTask?.cancel()
        }
        .onChange(of: viewModel.loginMessage) { _, newValue in
            guard newValue != nil else { return }
            sessionStore.markAuthenticated()
        }
    }

    private func showToast(_ message: String) {
        toastHideTask?.cancel()
        toastMessage = message

        withAnimation(.easeInOut(duration: 0.2)) {
            isToastVisible = true
        }

        toastHideTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.2)) {
                isToastVisible = false
            }

            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            toastMessage = nil
        }
    }
}

private struct ToastBannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.green.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSessionStore())
}
