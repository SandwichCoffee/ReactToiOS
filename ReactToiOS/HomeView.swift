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
//                        PlaceholderFeatureView(
//                            title: "Products 준비중",
//                            description: "다음 단계에서 상품 목록/상세를 연결합니다."
//                        )
                        ProductsView()
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
                .simultaneousGesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            guard shouldTriggerBackGesture(value) else { return }
                            goBackToDashboard()
                        }
                )
                .navigationTitle(selectedMenu.title)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if canGoBackToDashboard {
                            Button {
                                goBackToDashboard()
                            } label: {
                                Label("뒤로", systemImage: "chevron.left")
                            }
                        } else {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isMenuPresented.toggle()
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if canGoBackToDashboard {
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

    private var canGoBackToDashboard: Bool {
        selectedMenu != .dashboard
    }

    private func goBackToDashboard() {
        guard canGoBackToDashboard else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedMenu = .dashboard
            isMenuPresented = false
        }
    }

    private func shouldTriggerBackGesture(_ value: DragGesture.Value) -> Bool {
        guard canGoBackToDashboard, !isMenuPresented else { return false }
        let horizontal = value.translation.width
        let vertical = abs(value.translation.height)
        return horizontal > 90 && vertical < 60
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
                latestRecruitsSection
                recentProductsSection
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
                .chartXAxis {
                    AxisMarks(values: viewModel.chartData.map(\.date)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let raw = value.as(String.self) {
                                Text(formatXAxisLabel(raw))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text(formatYAxisRevenue(Double(intValue)))
                            } else if let doubleValue = value.as(Double.self) {
                                Text(formatYAxisRevenue(doubleValue))
                            }
                        }
                    }
                }
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

    private var latestRecruitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("최신 채용공고")
                    .font(.headline)
                Spacer(minLength: 0)
                Button {
                    onQuickMenuTap(.recruits)
                } label: {
                    HStack(spacing: 4) {
                        Text("전체 보기")
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                    }
                }
                .font(.subheadline.weight(.semibold))
            }

            if viewModel.latestRecruits.isEmpty {
                Text("표시할 채용공고가 없습니다.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(viewModel.latestRecruits) { recruit in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top, spacing: 10) {
                                    VStack(spacing: 2) {
                                        Image(systemName: "calendar")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(Color.accentColor)
                                        if let (month, day) = monthDayText(from: recruit.startDate) {
                                            Text("\(month)월")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                            Text("\(day)일")
                                                .font(.caption.weight(.semibold))
                                        }
                                    }
                                    .frame(width: 48, height: 56)
                                    .background(Color(.systemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(recruit.title)
                                            .font(.subheadline.weight(.semibold))
                                            .lineLimit(2)
                                        if let start = formattedDateText(recruit.startDate),
                                           let end = formattedDateText(recruit.endDate) {
                                            Text("\(start) ~ \(end)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        } else if let dateText = formattedDateText(recruit.createdAt) {
                                            Text("등록일 \(dateText)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer(minLength: 0)
                                }

                                HStack {
                                    Spacer(minLength: 0)
                                    Text(recruitStatusText(recruit))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(recruitStatusColor(recruit))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(recruitStatusColor(recruit).opacity(0.12))
                                        )
                                }
                            }
                            .frame(width: 250, alignment: .leading)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var recentProductsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("최근 등록 상품")
                    .font(.headline)
                Spacer(minLength: 0)
                Button {
                    onQuickMenuTap(.products)
                } label: {
                    HStack(spacing: 4) {
                        Text("전체 보기")
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                    }
                }
                .font(.subheadline.weight(.semibold))
            }

            if viewModel.recentProducts.isEmpty {
                Text("표시할 상품이 없습니다.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(viewModel.recentProducts) { product in
                            VStack(alignment: .leading, spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.tertiarySystemBackground))

                                    if let imageURL = productImageURL(product.imageName) {
                                        AsyncImage(url: imageURL) { phase in
                                            switch phase {
                                            case let .success(image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .font(.title3)
                                                    .foregroundStyle(.secondary)
                                            default:
                                                ProgressView()
                                            }
                                        }
                                    } else {
                                        Image(systemName: "photo")
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(height: 110)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                Text(product.name)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(2)

                                if let price = product.price {
                                    Text(formattedCurrency(price))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.accentColor)
                                } else {
                                    Text("가격 정보 없음")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if let stock = product.stock {
                                    Text("재고 \(stock)")
                                        .font(.caption)
                                        .foregroundStyle(stock <= 10 ? Color.red : Color.secondary)
                                } else {
                                    Text("재고 정보 없음")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if let dateText = formattedDateText(product.createdAt) {
                                    Text("등록일 \(dateText)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(width: 180, alignment: .leading)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
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

    private func formatXAxisLabel(_ raw: String) -> String {
        switch viewModel.selectedPeriod {
        case .daily:
            // "05-17" -> "5/17"
            let parts = raw.split(separator: "-")
            if parts.count == 2,
               let month = Int(parts[0]),
               let day = Int(parts[1]) {
                return "\(month)/\(day)"
            }
            return raw
        case .weekly:
            // "2026-w06" -> "2월 1째주"
            return weeklyLabelToMonth(raw) ?? raw
        case .monthly:
            // "2026-02" -> "2026-2월"
            let parts = raw.split(separator: "-")
            if parts.count == 2,
               let year = Int(parts[0]),
               let month = Int(parts[1]) {
                return "\(year)-\(month)월"
            }
            return raw
        case .yearly:
            // "2026" -> "2026년"
            return "\(raw)년"
        }
    }

    private func weeklyLabelToMonth(_ raw: String) -> String? {
        let parts = raw.components(separatedBy: "-w")
        guard parts.count == 2,
              let year = Int(parts[0]),
              let week = Int(parts[1]) else {
            return nil
        }

        var components = DateComponents()
        components.yearForWeekOfYear = year
        components.weekOfYear = week
        components.weekday = 2 // Monday in ISO week

        let calendar = Calendar(identifier: .iso8601)
        guard let date = calendar.date(from: components) else {
            return nil
        }

        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let weekOfMonth = ((day - 1) / 7) + 1
        return "\(month)월 \(weekOfMonth)째주"
    }

    private func formatYAxisRevenue(_ value: Double) -> String {
        let positive = max(value, 0)

        if positive >= 100_000_000 {
            let eok = Int(positive / 100_000_000)
            return "\(eok)억"
        }

        if positive >= 10_000 {
            let man = Int(positive / 10_000)
            return "\(man)만"
        }

        return "\(Int(positive))"
    }

    private func formattedDateText(_ raw: String?) -> String? {
        guard let date = parseDate(raw) else { return raw }

        let output = DateFormatter()
        output.locale = Locale(identifier: "ko_KR")
        output.dateFormat = "yyyy.MM.dd"
        return output.string(from: date)
    }

    private func recruitStatusText(_ recruit: RecruitSummary) -> String {
        switch effectiveRecruitStatus(recruit) {
        case "OPEN":
            return "진행중"
        case "CLOSED":
            return "마감"
        case "EXPIRED":
            return "기간만료"
        case "DRAFT":
            return "임시저장"
        default:
            return recruit.status.isEmpty ? "상태없음" : recruit.status
        }
    }

    private func recruitStatusColor(_ recruit: RecruitSummary) -> Color {
        switch effectiveRecruitStatus(recruit) {
        case "OPEN":
            return .green
        case "CLOSED":
            return .secondary
        case "EXPIRED":
            return .gray
        case "DRAFT":
            return .orange
        default:
            return .secondary
        }
    }

    private func effectiveRecruitStatus(_ recruit: RecruitSummary) -> String {
        let status = recruit.status.uppercased()
        if status == "CLOSED" || status == "DRAFT" {
            return status
        }

        if let endDate = parseDate(recruit.endDate),
           Date() > endDate.endOfDay {
            return "EXPIRED"
        }

        return status
    }

    private func parseDate(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let formatterWithMilliseconds = ISO8601DateFormatter()
        formatterWithMilliseconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let value = formatterWithMilliseconds.date(from: trimmed) {
            return value
        }

        let formatter = ISO8601DateFormatter()
        if let value = formatter.date(from: trimmed) {
            return value
        }

        let knownFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
            "yyyy-MM-dd'T'HH:mmXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mmZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd HH:mm",
            "yyyy-MM-dd"
        ]

        let formatterByPattern = DateFormatter()
        formatterByPattern.locale = Locale(identifier: "en_US_POSIX")
        formatterByPattern.timeZone = TimeZone.current

        for format in knownFormats {
            formatterByPattern.dateFormat = format
            if let value = formatterByPattern.date(from: trimmed) {
                return value
            }
        }

        return nil
    }

    private func monthDayText(from raw: String?) -> (Int, Int)? {
        guard let date = parseDate(raw) else { return nil }
        let calendar = Calendar.current
        return (calendar.component(.month, from: date), calendar.component(.day, from: date))
    }

    private func productImageURL(_ imageName: String?) -> URL? {
        guard let imageName, !imageName.isEmpty else { return nil }
        let escaped = imageName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? imageName
        return URL(string: "https://reactproject-q472.onrender.com/images/\(escaped)")
    }
}

private extension Date {
    var endOfDay: Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: self)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay) ?? self
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
