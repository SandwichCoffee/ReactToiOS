//
//  HomeView.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/16/26.
//

import SwiftUI
import Charts

private enum HomeMenuItem: String, CaseIterable, Identifiable {
    case dashboard
    case resume
    case products
    case recruits
    case devlogs
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .resume: return "Resume"
        case .products: return "Products"
        case .recruits: return "Recruits"
        case .devlogs: return "Devlogs"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .dashboard: return "chart.bar.xaxis"
        case .resume: return "doc.text"
        case .products: return "shippingbox"
        case .recruits: return "person.3"
        case .devlogs: return "terminal"
        case .settings: return "gearshape"
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var sessionStore: AppSessionStore
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @State private var selectedMenu: HomeMenuItem = .dashboard
    @State private var isMenuPresented = false

    var body: some View {
        ZStack(alignment: .leading) {
            NavigationStack {
                Group {
                    switch selectedMenu {
                    case .dashboard:
                        DashboardScreen(
                            viewModel: dashboardViewModel,
                            onQuickMenuTap: selectMenu
                        )
                    case .resume:
                        PlaceholderFeatureView(
                            title: "Resume 준비중",
                            description: "다음 단계에서 이력/자기소개 섹션을 연결합니다."
                        )
                    case .products:
                        PlaceholderFeatureView(
                            title: "Products 준비중",
                            description: "다음 단계에서 상품 목록/상세를 연결합니다."
                        )
                    case .recruits:
                        PlaceholderFeatureView(
                            title: "Recruits 준비중",
                            description: "다음 단계에서 채용공고 목록/상세를 연결합니다."
                        )
                    case .devlogs:
                        PlaceholderFeatureView(
                            title: "Devlogs 준비중",
                            description: "다음 단계에서 개발로그 목록/상세를 연결합니다."
                        )
                    case .settings:
                        PlaceholderFeatureView(
                            title: "Settings 준비중",
                            description: "다음 단계에서 설정 화면을 연결합니다."
                        )
                    }
                }
                .navigationTitle(selectedMenu.title)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isMenuPresented.toggle()
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                    }
                }
            }
            .disabled(isMenuPresented)

            if isMenuPresented {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isMenuPresented = false
                        }
                    }
            }

            sideMenu
                .offset(x: isMenuPresented ? 0 : -300)
                .animation(.easeInOut(duration: 0.2), value: isMenuPresented)
        }
    }

    private var sideMenu: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("메뉴")
                .font(.headline)
                .padding(.top, 20)
                .padding(.horizontal, 16)

            ForEach(HomeMenuItem.allCases) { menu in
                Button {
                    selectMenu(menu)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: menu.iconName)
                        Text(menu.title)
                            .fontWeight(menu == selectedMenu ? .semibold : .regular)
                    }
                    .foregroundStyle(menu == selectedMenu ? Color.accentColor : Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(menu == selectedMenu ? Color.accentColor.opacity(0.12) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            Spacer(minLength: 0)

            Button(role: .destructive) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isMenuPresented = false
                }
                sessionStore.logout()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("로그아웃")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 24)
        }
        .frame(width: 280)
        .frame(maxHeight: .infinity)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 2, y: 0)
    }

    private func selectMenu(_ menu: HomeMenuItem) {
        selectedMenu = menu
        withAnimation(.easeInOut(duration: 0.2)) {
            isMenuPresented = false
        }
    }
}

private struct DashboardScreen: View {
    @ObservedObject var viewModel: DashboardViewModel
    let onQuickMenuTap: (HomeMenuItem) -> Void

    private static let quickMenus: [HomeMenuItem] = [.resume, .products, .recruits, .devlogs, .settings]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCardsSection
                periodPicker
                chartSection
                quickMenuSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .onAppear {
            viewModel.loadIfNeeded()
        }
    }

    private var summaryCardsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            SummaryMetricCard(
                title: "총 등록 상품",
                value: "\(viewModel.totalProductCount)개",
                iconName: "shippingbox",
                tint: .blue
            )
            SummaryMetricCard(
                title: "진행 중 공고",
                value: "\(viewModel.activeRecruitCount)건",
                iconName: "person.3",
                tint: .green
            )
            SummaryMetricCard(
                title: "누적 총 매출",
                value: formattedCurrency(viewModel.totalRevenue),
                subtitle: "실시간 집계 중",
                iconName: "chart.line.uptrend.xyaxis",
                tint: .blue
            )
            SummaryMetricCard(
                title: "시스템 상태",
                value: viewModel.systemStatus,
                subtitle: viewModel.systemStatusDescription,
                iconName: "checkmark.shield",
                tint: .green
            )
        }
    }

    private var periodPicker: some View {
        Picker(
            "기간",
            selection: Binding(
                get: { viewModel.selectedPeriod },
                set: { viewModel.changePeriod($0) }
            )
        ) {
            ForEach(DashboardPeriod.allCases) { period in
                Text(period.title).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("매출 추이")
                .font(.headline)

            if viewModel.isLoading {
                ProgressView("불러오는 중...")
                    .frame(maxWidth: .infinity, minHeight: 220, alignment: .center)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 10) {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("다시 시도") {
                        viewModel.retryTapped()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
            } else if viewModel.chartData.isEmpty {
                Text("표시할 데이터가 없습니다.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 220, alignment: .center)
            } else {
                Chart(viewModel.chartData) { item in
                    BarMark(
                        x: .value("기간", item.date),
                        y: .value("매출", item.revenue)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                }
                .frame(height: 220)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var quickMenuSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("빠른 메뉴")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(Self.quickMenus) { menu in
                    Button {
                        onQuickMenuTap(menu)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: menu.iconName)
                            Text(menu.title)
                                .font(.subheadline.weight(.semibold))
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func formattedCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let value = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(value)원"
    }
}

private struct SummaryMetricCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let iconName: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Image(systemName: iconName)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint)
            }

            Text(value)
                .font(.headline.bold())
                .foregroundStyle(tint)

            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct PlaceholderFeatureView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title3.bold())
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(24)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppSessionStore())
}
