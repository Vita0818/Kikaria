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

struct ContentView: View {
    @State private var knowledgePoints = KnowledgePoint.samples
    @State private var selectedTags = Set<String>()

    private var allTags: [String] {
        Array(Set(knowledgePoints.flatMap(\.tags))).sorted()
    }

    private var selectedScopeText: String {
        selectedTags.isEmpty ? "全部范围" : "\(selectedTags.count) 个标签"
    }

    private var reinforcedCount: Int {
        knowledgePoints.filter(\.isReinforced).count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KikariaTheme.pageGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Kikaria")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(KikariaTheme.deepText)

                            Text("轻量背诵空间")
                                .font(.subheadline)
                                .foregroundStyle(KikariaTheme.softText)
                        }

                        Spacer()

                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(KikariaTheme.sky, .white.opacity(0.85))
                            .shadow(color: KikariaTheme.sky.opacity(0.22), radius: 12, y: 6)
                    }
                    .padding(.top, 14)

                    Spacer(minLength: 32)

                    NavigationLink {
                        ReviewView(
                            knowledgePoints: $knowledgePoints,
                            selectedTags: selectedTags
                        )
                    } label: {
                        StartReviewButton(scopeText: selectedScopeText)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("开始背诵")

                    Spacer(minLength: 42)

                    VStack(spacing: 16) {
                        NavigationLink {
                            ScopeSelectionView(
                                selectedTags: $selectedTags,
                                allTags: allTags
                            )
                        } label: {
                            HomeEntryCard(
                                title: "选择范围",
                                subtitle: selectedScopeText,
                                systemImage: "slider.horizontal.3"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            ReinforcementView(knowledgePoints: $knowledgePoints)
                        } label: {
                            HomeEntryCard(
                                title: "重点集锦",
                                subtitle: "\(reinforcedCount) 个知识点",
                                systemImage: "sparkles"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 18)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarHidden(true)
        }
    }
}

private struct StartReviewButton: View {
    let scopeText: String

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(KikariaTheme.actionGradient)
                    .frame(width: 196, height: 196)
                    .shadow(color: KikariaTheme.sky.opacity(0.28), radius: 26, x: 0, y: 18)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.55), lineWidth: 1.5)
                            .padding(3)
                    }

                VStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("开始背诵")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(scopeText)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white.opacity(0.86))
                }
            }

            Text("Start")
                .font(.caption.weight(.semibold))
                .foregroundStyle(KikariaTheme.softText)
                .textCase(.uppercase)
        }
    }
}

private struct HomeEntryCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(KikariaTheme.sky)
                .frame(width: 52, height: 52)
                .background(KikariaTheme.mist, in: Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(KikariaTheme.deepText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(KikariaTheme.softText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KikariaTheme.blueGray)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
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
    @Binding var knowledgePoints: [KnowledgePoint]
    let selectedTags: Set<String>

    @State private var currentPointID: KnowledgePoint.ID?
    @State private var isShowingHint = false
    @State private var isShowingContent = false

    private var matchingPoints: [KnowledgePoint] {
        if selectedTags.isEmpty {
            return knowledgePoints
        }

        return knowledgePoints.filter { point in
            point.tags.contains { selectedTags.contains($0) }
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
                SoftEmptyState(
                    title: "暂无知识点",
                    subtitle: "请返回后调整选择范围。",
                    systemImage: "tag.slash"
                )
                .padding(24)
            } else if let currentPoint {
                VStack(spacing: 0) {
                    Spacer(minLength: 58)

                    VStack(spacing: 18) {
                        Text(currentPoint.title)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(KikariaTheme.deepText)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.72)
                            .padding(.horizontal, 22)

                        LightTagRow(tags: currentPoint.tags)
                    }
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
            } else {
                ProgressView()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if currentPointID == nil {
                chooseRandomPoint()
            }
        }
    }

    private func chooseRandomPoint() {
        guard !matchingPoints.isEmpty else {
            currentPointID = nil
            return
        }

        let candidates: [KnowledgePoint]
        if matchingPoints.count > 1 {
            candidates = matchingPoints.filter { $0.id != currentPointID }
        } else {
            candidates = matchingPoints
        }

        currentPointID = candidates.randomElement()?.id
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

struct ReinforcementView: View {
    @Binding var knowledgePoints: [KnowledgePoint]

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
                    .padding(.bottom, 32)
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

private struct ReinforcementCard: View {
    let point: KnowledgePoint
    let removeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(point.title)
                .font(.title3.bold())
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
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
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
                .font(.body)
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
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
            .padding(.horizontal, 2)
        }
    }
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
