//
//  ContentView.swift
//  Kikaria
//
//  Created by Vita on 2026/5/1.
//

import SwiftUI

private enum KikariaTheme {
    static let sky = Color(red: 0.39, green: 0.73, blue: 0.96)
    static let cyan = Color(red: 0.57, green: 0.88, blue: 0.91)
    static let mist = Color(red: 0.91, green: 0.97, blue: 0.99)
    static let blueGray = Color(red: 0.62, green: 0.72, blue: 0.80)
    static let deepText = Color(red: 0.13, green: 0.25, blue: 0.33)
    static let softText = Color(red: 0.42, green: 0.54, blue: 0.62)

    static let pageGradient = LinearGradient(
        colors: [
            Color(red: 0.93, green: 0.98, blue: 1.0),
            Color(red: 0.86, green: 0.96, blue: 0.98),
            Color(red: 0.96, green: 0.98, blue: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let actionGradient = LinearGradient(
        colors: [
            Color(red: 0.35, green: 0.72, blue: 0.97),
            Color(red: 0.50, green: 0.87, blue: 0.89)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

private enum AppRoute: Hashable {
    case scope
    case review
    case reinforcement
    case reinforcementReview
}

enum ReviewMode {
    case normal
    case reinforcement

    var isReinforcement: Bool {
        if case .reinforcement = self {
            return true
        }

        return false
    }
}

struct ContentView: View {
    @State private var knowledgePoints = KnowledgePoint.samples
    @State private var selectedTags = Set<String>()
    @State private var navigationPath: [AppRoute] = []

    private var allTags: [String] {
        Array(Set(knowledgePoints.flatMap(\.tags))).sorted()
    }

    private var selectedScopeCountText: String {
        selectedTags.isEmpty ? "\(allTags.count)" : "\(selectedTags.count)"
    }

    private var reinforcedCount: Int {
        knowledgePoints.filter(\.isReinforced).count
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                KikariaTheme.pageGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        Text("Kikaria")
                            .font(.system(size: 39, weight: .semibold, design: .serif))
                            .foregroundStyle(KikariaTheme.deepText)

                        Spacer()

                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(KikariaTheme.sky, .white.opacity(0.85))
                            .shadow(color: KikariaTheme.sky.opacity(0.22), radius: 12, y: 6)
                    }
                    .padding(.top, 14)

                    Spacer(minLength: 32)

                    NavigationLink(value: AppRoute.review) {
                        StartReviewButton()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("开始背诵")

                    Spacer(minLength: 42)

                    VStack(spacing: 16) {
                        NavigationLink(value: AppRoute.scope) {
                            HomeEntryCard(
                                title: "选择范围",
                                countText: selectedScopeCountText
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: AppRoute.reinforcement) {
                            HomeEntryCard(
                                title: "重点集锦",
                                countText: "\(reinforcedCount)"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 18)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .scope:
                    ScopeSelectionView(
                        selectedTags: $selectedTags,
                        allTags: allTags
                    )
                case .review:
                    ReviewView(
                        knowledgePoints: $knowledgePoints,
                        selectedTags: $selectedTags,
                        mode: .normal,
                        onOpenScope: {
                            navigationPath.append(.scope)
                        }
                    )
                case .reinforcement:
                    ReinforcementView(
                        knowledgePoints: $knowledgePoints,
                        onStartReview: {
                            navigationPath.append(.reinforcementReview)
                        }
                    )
                case .reinforcementReview:
                    ReviewView(
                        knowledgePoints: $knowledgePoints,
                        selectedTags: .constant([]),
                        mode: .reinforcement,
                        onReturnHome: {
                            navigationPath.removeAll()
                        }
                    )
                }
            }
        }
    }
}

private struct StartReviewButton: View {
    @State private var isBreathing = false

    var body: some View {
        ZStack {
            SoftBubble(
                size: 82,
                colors: [KikariaTheme.cyan, Color(red: 0.73, green: 0.95, blue: 0.90)],
                opacity: 0.48
            )
            .scaleEffect(isBreathing ? 1.04 : 0.98)
            .offset(x: -88, y: isBreathing ? -70 : -62)

            SoftBubble(
                size: 54,
                colors: [Color(red: 0.75, green: 0.78, blue: 1.0), KikariaTheme.mist],
                opacity: 0.44
            )
            .scaleEffect(isBreathing ? 0.98 : 1.05)
            .offset(x: 96, y: isBreathing ? -50 : -58)

            SoftBubble(
                size: 68,
                colors: [Color(red: 0.78, green: 0.95, blue: 0.74), KikariaTheme.cyan],
                opacity: 0.38
            )
            .scaleEffect(isBreathing ? 1.035 : 0.985)
            .offset(x: 86, y: isBreathing ? 82 : 72)

            SoftBubble(
                size: 42,
                colors: [KikariaTheme.sky, Color.white],
                opacity: 0.34
            )
            .scaleEffect(isBreathing ? 0.98 : 1.06)
            .offset(x: -106, y: isBreathing ? 62 : 72)

            Circle()
                .fill(KikariaTheme.actionGradient)
                .frame(width: 190, height: 190)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: KikariaTheme.sky.opacity(0.28), radius: 28, x: 0, y: 18)
                .overlay {
                    Circle()
                        .fill(.white.opacity(0.16))
                        .padding(1)
                }

            Image(systemName: "arrow.up")
                .font(.system(size: 70, weight: .regular))
                .foregroundStyle(.white.opacity(0.96))
                .shadow(color: KikariaTheme.deepText.opacity(0.10), radius: 8, y: 4)
        }
        .frame(width: 272, height: 260)
        .scaleEffect(isBreathing ? 1.018 : 0.995)
        .offset(y: isBreathing ? -4 : 2)
        .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: isBreathing)
        .onAppear {
            isBreathing = true
        }
    }
}

private struct SoftBubble: View {
    let size: CGFloat
    let colors: [Color]
    let opacity: Double

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: colors.map { $0.opacity(opacity) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .background(.ultraThinMaterial, in: Circle())
            .overlay {
                Circle()
                    .stroke(.white.opacity(0.36), lineWidth: 1)
            }
            .shadow(color: KikariaTheme.sky.opacity(0.10), radius: 14, y: 8)
    }
}

private struct HomeEntryCard: View {
    let title: String
    let countText: String

    var body: some View {
        HStack(spacing: 14) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(KikariaTheme.deepText)

            Spacer()

            Text(countText)
                .font(.title3.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(KikariaTheme.sky)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KikariaTheme.blueGray)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white.opacity(0.46))
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: KikariaTheme.sky.opacity(0.12), radius: 18, y: 10)
    }
}

struct ScopeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTags: Set<String>
    let allTags: [String]

    private let columns = [
        GridItem(.adaptive(minimum: 132), spacing: 12)
    ]

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("选择范围")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(KikariaTheme.deepText)

                            Text(selectedTags.isEmpty ? "未选择标签时，会默认使用全部知识点。" : "已选择 \(selectedTags.count) 个标签。")
                                .font(.subheadline)
                                .foregroundStyle(KikariaTheme.softText)
                        }
                        .padding(.top, 16)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(allTags, id: \.self) { tag in
                                Button {
                                    toggleTag(tag)
                                } label: {
                                    ScopeTagChip(
                                        title: tag,
                                        isSelected: selectedTags.contains(tag)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 96)
                }

                Button {
                    dismiss()
                } label: {
                    Text("完成")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .foregroundStyle(.white)
                        .background(KikariaTheme.actionGradient, in: Capsule())
                        .shadow(color: KikariaTheme.sky.opacity(0.22), radius: 18, y: 9)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
                .background(.ultraThinMaterial)
            }
        }
        .navigationTitle("Scope")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}

private struct ScopeTagChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? .white : KikariaTheme.deepText)
            .lineLimit(2)
            .minimumScaleFactor(0.82)
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.horizontal, 14)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? KikariaTheme.sky : .white.opacity(0.76))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? KikariaTheme.cyan.opacity(0.95) : KikariaTheme.cyan.opacity(0.28), lineWidth: 1.5)
            }
            .shadow(color: KikariaTheme.sky.opacity(isSelected ? 0.18 : 0.08), radius: 12, y: 7)
    }
}

struct ReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var knowledgePoints: [KnowledgePoint]
    @Binding var selectedTags: Set<String>
    let mode: ReviewMode
    var onOpenScope: (() -> Void)?
    var onReturnHome: (() -> Void)?

    @State private var currentPointID: KnowledgePoint.ID?
    @State private var isShowingHint = false
    @State private var isShowingContent = false
    @State private var pointHistory: [KnowledgePoint.ID] = []
    @State private var gestureFeedback = false

    private var matchingPoints: [KnowledgePoint] {
        switch mode {
        case .normal:
            if selectedTags.isEmpty {
                return knowledgePoints
            }

            return knowledgePoints.filter { point in
                point.tags.contains { selectedTags.contains($0) }
            }
        case .reinforcement:
            return knowledgePoints.filter(\.isReinforced)
        }
    }

    private var currentPoint: KnowledgePoint? {
        guard let currentPointID else {
            return nil
        }

        return knowledgePoints.first { $0.id == currentPointID }
    }

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            if matchingPoints.isEmpty {
                if mode.isReinforcement {
                    ReinforcementCompletionView {
                        if let onReturnHome {
                            onReturnHome()
                        } else {
                            dismiss()
                        }
                    }
                    .padding(24)
                } else {
                    SoftEmptyState(
                        title: "暂无知识点",
                        subtitle: "请返回后调整选择范围。",
                        systemImage: "tag.slash"
                    )
                    .padding(24)
                }
            } else if let currentPoint {
                VStack(spacing: 0) {
                    Spacer(minLength: 58)

                    VStack(spacing: 18) {
                        Text(currentPoint.title)
                            .font(.system(size: 40, weight: .semibold, design: .serif))
                            .foregroundStyle(KikariaTheme.deepText)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.72)
                            .padding(.horizontal, 22)

                        LightTagRow(tags: currentPoint.tags)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 14)

                    VStack(spacing: 14) {
                        if isShowingHint {
                            FloatingInfoCard(title: "提示", text: currentPoint.hint)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        if isShowingContent {
                            FloatingInfoCard(title: "答案", text: currentPoint.content)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)

                    Spacer(minLength: 24)

                    VStack(spacing: 14) {
                        if !isShowingContent {
                            if !isShowingHint {
                                ReviewActionButton(
                                    title: "查看提示",
                                    systemImage: "lightbulb",
                                    isPrimary: false
                                ) {
                                    withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) {
                                        isShowingHint = true
                                    }
                                }
                                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                            }

                            ReviewActionButton(
                                title: "查看答案",
                                systemImage: "doc.text",
                                isPrimary: true
                            ) {
                                withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) {
                                    isShowingContent = true
                                }
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        } else {
                            if mode.isReinforcement {
                                ReviewActionButton(
                                    title: "移出重点集锦",
                                    systemImage: "minus.circle.fill",
                                    isPrimary: true
                                ) {
                                    removeCurrentPointFromReinforcement()
                                    withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                        chooseRandomPoint()
                                    }
                                }
                            } else {
                                ReviewActionButton(
                                    title: "加入重点集锦",
                                    systemImage: "plus.circle.fill",
                                    isPrimary: true
                                ) {
                                    addCurrentPointToReinforcement()
                                    withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                        chooseRandomPoint()
                                    }
                                }
                            }

                            ReviewActionButton(
                                title: "下一个",
                                systemImage: "shuffle",
                                isPrimary: false
                            ) {
                                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                    chooseRandomPoint()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
                .scaleEffect(gestureFeedback ? 0.985 : 1.0)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .simultaneousGesture(reviewDragGesture)
        .onAppear {
            if currentPointID == nil {
                chooseRandomPoint(rememberCurrent: false)
            }
        }
        .onChange(of: selectedTags) {
            if !mode.isReinforcement {
                pointHistory.removeAll()
                chooseRandomPoint(rememberCurrent: false)
            }
        }
    }

    private var reviewDragGesture: some Gesture {
        DragGesture(minimumDistance: 28, coordinateSpace: .local)
            .onEnded { value in
                handleDragGesture(translation: value.translation, startLocation: value.startLocation)
            }
    }

    private func handleDragGesture(translation: CGSize, startLocation: CGPoint) {
        let horizontal = abs(translation.width)
        let vertical = abs(translation.height)
        let threshold: CGFloat = 68
        let dominance: CGFloat = 1.35

        if horizontal > threshold && horizontal > vertical * dominance {
            if translation.width > 0 {
                guard !mode.isReinforcement, startLocation.x > 34 else {
                    return
                }

                triggerGestureFeedback()
                onOpenScope?()
            } else if !mode.isReinforcement {
                triggerGestureFeedback()
                addCurrentPointToReinforcement()
                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                    chooseRandomPoint()
                }
            }
        } else if vertical > threshold && vertical > horizontal * dominance {
            if translation.height < 0 {
                guard !isShowingContent else {
                    return
                }

                triggerGestureFeedback()
                withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) {
                    isShowingContent = true
                }
            } else {
                triggerGestureFeedback()
                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                    goBackOrChooseRandom()
                }
            }
        }
    }

    private func triggerGestureFeedback() {
        withAnimation(.easeInOut(duration: 0.12)) {
            gestureFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(.easeInOut(duration: 0.16)) {
                gestureFeedback = false
            }
        }
    }

    private func chooseRandomPoint(rememberCurrent: Bool = true) {
        guard !matchingPoints.isEmpty else {
            currentPointID = nil
            resetRevealState()
            return
        }

        let previousID = currentPointID
        if rememberCurrent, let previousID {
            pointHistory.append(previousID)
        }

        let candidates: [KnowledgePoint]
        if matchingPoints.count > 1 {
            candidates = matchingPoints.filter { $0.id != previousID }
        } else {
            candidates = matchingPoints
        }

        currentPointID = candidates.randomElement()?.id
        resetRevealState()
    }

    private func goBackOrChooseRandom() {
        while let previousID = pointHistory.popLast() {
            if matchingPoints.contains(where: { $0.id == previousID }) {
                currentPointID = previousID
                resetRevealState()
                return
            }
        }

        chooseRandomPoint(rememberCurrent: false)
    }

    private func resetRevealState() {
        isShowingHint = false
        isShowingContent = false
    }

    private func addCurrentPointToReinforcement() {
        guard let currentPointID,
              let index = knowledgePoints.firstIndex(where: { $0.id == currentPointID })
        else {
            return
        }

        knowledgePoints[index].isReinforced = true
        knowledgePoints[index].updatedAt = Date()
    }

    private func removeCurrentPointFromReinforcement() {
        guard let currentPointID,
              let index = knowledgePoints.firstIndex(where: { $0.id == currentPointID })
        else {
            return
        }

        knowledgePoints[index].isReinforced = false
        knowledgePoints[index].updatedAt = Date()
    }
}

private struct ReviewActionButton: View {
    let title: String
    let systemImage: String
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(isPrimary ? .white : KikariaTheme.deepText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 19)
                .background {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(isPrimary ? AnyShapeStyle(KikariaTheme.actionGradient) : AnyShapeStyle(.white.opacity(0.82)))
                }
                .shadow(color: KikariaTheme.sky.opacity(isPrimary ? 0.22 : 0.10), radius: 16, y: 9)
        }
        .buttonStyle(.plain)
    }
}

private struct ReinforcementCompletionView: View {
    let returnHome: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 86, weight: .semibold))
                .foregroundStyle(Color(red: 0.36, green: 0.76, blue: 0.46), .white.opacity(0.96))
                .shadow(color: Color.green.opacity(0.16), radius: 16, y: 8)

            Button(action: returnHome) {
                Text("返回首页")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 42)
                    .padding(.vertical, 16)
                    .background(KikariaTheme.actionGradient, in: Capsule())
                    .shadow(color: KikariaTheme.sky.opacity(0.20), radius: 16, y: 8)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ReinforcementView: View {
    @Binding var knowledgePoints: [KnowledgePoint]
    let onStartReview: () -> Void

    private var reinforcedPoints: [KnowledgePoint] {
        knowledgePoints.filter(\.isReinforced)
    }

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            if reinforcedPoints.isEmpty {
                SoftEmptyState(
                    title: "还没有重点",
                    subtitle: "在背诵时查看答案后，可以把知识点加入这里。",
                    systemImage: "sparkles"
                )
                .padding(24)
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("重点集锦")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(KikariaTheme.deepText)
                                .padding(.top, 18)

                            ForEach(reinforcedPoints) { point in
                                ReinforcementCard(point: point) {
                                    removeFromReinforcement(point)
                                }
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 150)
                    }

                    VStack(spacing: 0) {
                        Button(action: onStartReview) {
                            ReinforcementStartButton(count: reinforcedPoints.count)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 18)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 20)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .navigationTitle("重点集锦")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func removeFromReinforcement(_ point: KnowledgePoint) {
        guard let index = knowledgePoints.firstIndex(where: { $0.id == point.id }) else {
            return
        }

        withAnimation(.spring(response: 0.36, dampingFraction: 0.9)) {
            knowledgePoints[index].isReinforced = false
            knowledgePoints[index].updatedAt = Date()
        }
    }
}

private struct ReinforcementStartButton: View {
    let count: Int

    var body: some View {
        HStack(spacing: 14) {
            Text("开始重点背诵")
                .font(.title3.weight(.semibold))
                .foregroundStyle(KikariaTheme.deepText)

            Spacer()

            Text("\(count)")
                .font(.title3.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(KikariaTheme.sky)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KikariaTheme.blueGray)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white.opacity(0.54))
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: KikariaTheme.sky.opacity(0.16), radius: 20, y: 10)
    }
}

private struct ReinforcementCard: View {
    let point: KnowledgePoint
    let removeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(point.title)
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundStyle(KikariaTheme.deepText)

            LightTagRow(tags: point.tags)

            FloatingInfoCard(title: "提示", text: point.hint)
                .shadow(color: .clear, radius: 0)

            FloatingInfoCard(title: "答案", text: point.content)
                .shadow(color: .clear, radius: 0)

            Button(role: .destructive, action: removeAction) {
                Label("移出重点集锦", systemImage: "minus.circle")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderless)
            .tint(.red.opacity(0.82))
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.white.opacity(0.48))
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: KikariaTheme.sky.opacity(0.12), radius: 20, y: 12)
    }
}

private struct FloatingInfoCard: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KikariaTheme.sky)

            Text(text)
                .font(.system(.body, design: .serif))
                .foregroundStyle(KikariaTheme.deepText)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: KikariaTheme.sky.opacity(0.14), radius: 18, y: 10)
    }
}

private struct LightTagRow: View {
    let tags: [String]

    var body: some View {
        CenteredTagFlow(spacing: 8, rowSpacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KikariaTheme.softText)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.58), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(KikariaTheme.cyan.opacity(0.30), lineWidth: 1)
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CenteredTagFlow: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        let rows = makeRows(maxWidth: maxWidth, subviews: subviews)
        let width = proposal.width ?? rows.map(\.width).max() ?? 0
        let height = rows.reduce(0) { $0 + $1.height } + rowSpacing * CGFloat(max(rows.count - 1, 0))

        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = makeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX + max((bounds.width - row.width) / 2, 0)

            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y + (row.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: item.size.width, height: item.size.height)
                )
                x += item.size.width + spacing
            }

            y += row.height + rowSpacing
        }
    }

    private func makeRows(maxWidth: CGFloat, subviews: Subviews) -> [TagFlowRow] {
        let availableWidth = maxWidth.isFinite ? maxWidth : .greatestFiniteMagnitude
        var rows: [TagFlowRow] = []
        var current = TagFlowRow()

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let nextWidth = current.items.isEmpty ? size.width : current.width + spacing + size.width

            if nextWidth > availableWidth && !current.items.isEmpty {
                rows.append(current)
                current = TagFlowRow()
            }

            if !current.items.isEmpty {
                current.width += spacing
            }

            current.items.append(TagFlowItem(index: index, size: size))
            current.width += size.width
            current.height = max(current.height, size.height)
        }

        if !current.items.isEmpty {
            rows.append(current)
        }

        return rows
    }
}

private struct TagFlowRow {
    var items: [TagFlowItem] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
}

private struct TagFlowItem {
    let index: Int
    let size: CGSize
}

private struct SoftEmptyState: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 42))
                .foregroundStyle(KikariaTheme.sky)

            Text(title)
                .font(.title3.bold())
                .foregroundStyle(KikariaTheme.deepText)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(KikariaTheme.softText)
                .multilineTextAlignment(.center)
        }
        .padding(26)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.80), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: KikariaTheme.sky.opacity(0.12), radius: 18, y: 10)
    }
}

#Preview {
    ContentView()
}
