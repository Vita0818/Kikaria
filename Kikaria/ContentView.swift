//
//  ContentView.swift
//  Kikaria
//
//  Created by Vita on 2026/5/1.
//

import PhotosUI
import SwiftUI
import UIKit

private enum KikariaTheme {
    static let sky = Color(red: 0.39, green: 0.73, blue: 0.96)
    static let cyan = Color(red: 0.57, green: 0.88, blue: 0.91)
    static let mist = Color(red: 0.91, green: 0.97, blue: 0.99)
    static let blueGray = Color(red: 0.62, green: 0.72, blue: 0.80)
    static let masteredGreen = Color(red: 0.36, green: 0.76, blue: 0.54)
    static let masteredDeepGreen = Color(red: 0.12, green: 0.47, blue: 0.30)
    static let masteredCompletedGreen = Color(red: 0.79, green: 0.93, blue: 0.84)
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

    static let masteredGradient = LinearGradient(
        colors: [
            Color(red: 0.39, green: 0.78, blue: 0.55),
            Color(red: 0.68, green: 0.91, blue: 0.76)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let masteredActionGradient = LinearGradient(
        colors: [
            Color(red: 0.25, green: 0.66, blue: 0.42),
            Color(red: 0.54, green: 0.82, blue: 0.63)
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
    case mastered
    case masteredReview
    case settings
    case editProfile
    case markdownEditor
    case dailyGoal
}

enum ReviewMode {
    case normal
    case reinforcement
    case mastered

    var isNormal: Bool {
        if case .normal = self {
            return true
        }

        return false
    }

    var isReinforcement: Bool {
        if case .reinforcement = self {
            return true
        }

        return false
    }

    var isMastered: Bool {
        if case .mastered = self {
            return true
        }

        return false
    }
}

private struct UserProfile {
    var displayName = "Vita"
    var userHandle = "vita_0818"
    var avatarSystemName = "person.crop.circle.fill"
    var avatarImageData: Data?
}

struct ContentView: View {
    @State private var knowledgePoints = KnowledgePoint.samples
    @State private var markdownText = KnowledgePoint.defaultMarkdownText
    @State private var userProfile = UserProfile()
    @State private var selectedTags = Set<String>()
    @State private var navigationPath: [AppRoute] = []
    @AppStorage("dailyLearningGoal") private var dailyGoal = 20

    private var allTags: [String] {
        Array(Set(knowledgePoints.flatMap(\.tags))).sorted()
    }

    private var selectedScopeCountText: String {
        selectedTags.isEmpty ? "\(allTags.count)" : "\(selectedTags.count)"
    }

    private var reinforcedCount: Int {
        knowledgePoints.filter(\.isReinforced).count
    }

    private var masteredCount: Int {
        knowledgePoints.filter(\.isMastered).count
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

                        NavigationLink(value: AppRoute.settings) {
                            ProfileAvatarView(
                                systemName: userProfile.avatarSystemName,
                                imageData: userProfile.avatarImageData,
                                size: 44
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("打开设置")
                    }
                    .padding(.top, 14)

                    Spacer(minLength: 32)

                    NavigationLink(value: AppRoute.review) {
                        StartReviewButton(
                            dailyGoal: dailyGoal,
                            masteredCount: masteredCount
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("开始背诵")

                    Spacer(minLength: 42)

                    VStack(spacing: 12) {
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

                        NavigationLink(value: AppRoute.mastered) {
                            HomeEntryCard(
                                title: "已掌握",
                                countText: "\(masteredCount)"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 12)
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
                        mode: .normal
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
                case .mastered:
                    MasteredView(
                        knowledgePoints: $knowledgePoints,
                        onStartReview: {
                            navigationPath.append(.masteredReview)
                        }
                    )
                case .masteredReview:
                    ReviewView(
                        knowledgePoints: $knowledgePoints,
                        selectedTags: .constant([]),
                        mode: .mastered,
                        onReturnHome: {
                            navigationPath.removeAll()
                        }
                    )
                case .settings:
                    SettingsView(
                        profile: userProfile,
                        dailyGoal: dailyGoal,
                        onClose: {
                            navigationPath.removeAll()
                        },
                        onEditProfile: {
                            navigationPath.append(.editProfile)
                        },
                        onOpenDailyGoal: {
                            navigationPath.append(.dailyGoal)
                        },
                        onOpenMarkdownEditor: {
                            navigationPath.append(.markdownEditor)
                        }
                    )
                case .editProfile:
                    EditProfileView(profile: $userProfile)
                case .markdownEditor:
                    MarkdownEditorView(
                        markdownText: $markdownText,
                        knowledgePoints: $knowledgePoints,
                        selectedTags: $selectedTags
                    )
                case .dailyGoal:
                    DailyGoalSettingsView(dailyGoal: $dailyGoal)
                }
            }
        }
    }
}

private struct ProfileAvatarView: View {
    let systemName: String
    let imageData: Data?
    let size: CGFloat

    var body: some View {
        Group {
            if let imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.42), lineWidth: 1)
                    }
            } else {
                Image(systemName: systemName)
                    .font(.system(size: size))
                    .foregroundStyle(KikariaTheme.sky, .white.opacity(0.85))
            }
        }
        .shadow(color: KikariaTheme.sky.opacity(0.22), radius: 12, y: 6)
    }
}

private struct SettingsView: View {
    let profile: UserProfile
    let dailyGoal: Int
    let onClose: () -> Void
    let onEditProfile: () -> Void
    let onOpenDailyGoal: () -> Void
    let onOpenMarkdownEditor: () -> Void

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("设置")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(KikariaTheme.deepText)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.58), in: Circle())
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(color: KikariaTheme.sky.opacity(0.10), radius: 12, y: 6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 18)

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            ProfileAvatarView(
                                systemName: profile.avatarSystemName,
                                imageData: profile.avatarImageData,
                                size: 86
                            )
                            .padding(.top, 8)

                            VStack(spacing: 4) {
                                Text(profile.displayName)
                                    .font(.system(size: 28, weight: .semibold, design: .serif))
                                    .foregroundStyle(KikariaTheme.deepText)

                                Text("@\(profile.userHandle)")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(KikariaTheme.softText)
                            }

                            Button(action: onEditProfile) {
                                Text("编辑个人资料")
                                    .font(.headline)
                                    .foregroundStyle(KikariaTheme.deepText)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 13)
                                    .background(.white.opacity(0.62), in: Capsule())
                                    .background(.ultraThinMaterial, in: Capsule())
                                    .shadow(color: KikariaTheme.sky.opacity(0.12), radius: 14, y: 8)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)

                        VStack(spacing: 12) {
                            SettingsOptionRow(
                                title: "每日学习目标",
                                subtitle: "设置每天计划掌握的数量",
                                systemImage: "target",
                                valueText: "\(dailyGoal)"
                            ) {
                                onOpenDailyGoal()
                            }

                            SettingsOptionRow(
                                title: "知识点上传",
                                subtitle: "粘贴或编辑 Markdown 文本",
                                systemImage: "doc.text"
                            ) {
                                onOpenMarkdownEditor()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SettingsOptionRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var valueText: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(KikariaTheme.sky)
                    .frame(width: 38, height: 38)
                    .background(.white.opacity(0.50), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(KikariaTheme.deepText)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(KikariaTheme.softText)
                }

                Spacer()

                if let valueText {
                    Text(valueText)
                        .font(.headline.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(KikariaTheme.sky)
                }

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KikariaTheme.blueGray)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.white.opacity(0.54))
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: KikariaTheme.sky.opacity(0.12), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
    }
}

private struct DailyGoalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var dailyGoal: Int
    @State private var draftGoal: Int

    init(dailyGoal: Binding<Int>) {
        _dailyGoal = dailyGoal
        _draftGoal = State(initialValue: dailyGoal.wrappedValue)
    }

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(KikariaTheme.deepText)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.58), in: Circle())
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("每日学习目标")
                        .font(.headline)
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Button("完成") {
                        dailyGoal = draftGoal
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(KikariaTheme.sky)
                    .frame(width: 42, alignment: .trailing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 18)

                Spacer(minLength: 36)

                VStack(spacing: 22) {
                    Text("\(draftGoal)")
                        .font(.system(size: 52, weight: .semibold, design: .serif))
                        .monospacedDigit()
                        .foregroundStyle(KikariaTheme.deepText)

                    Picker("每日学习目标", selection: $draftGoal) {
                        ForEach(1...100, id: \.self) { goal in
                            Text("\(goal) 个")
                                .tag(goal)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 188)
                    .clipped()

                    Text("每日计划掌握的知识点数量")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(KikariaTheme.softText)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.52), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: KikariaTheme.sky.opacity(0.13), radius: 24, y: 14)
                .padding(.horizontal, 24)

                Spacer(minLength: 56)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var profile: UserProfile
    @State private var displayName: String
    @State private var userHandle: String
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(profile: Binding<UserProfile>) {
        _profile = profile
        _displayName = State(initialValue: profile.wrappedValue.displayName)
        _userHandle = State(initialValue: profile.wrappedValue.userHandle)
    }

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(KikariaTheme.deepText)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.58), in: Circle())
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("编辑个人资料")
                        .font(.headline)
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Button("保存") {
                        saveProfile()
                    }
                    .font(.headline)
                    .foregroundStyle(KikariaTheme.sky)
                    .frame(width: 42, alignment: .trailing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 18)

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            ProfileAvatarView(
                                systemName: profile.avatarSystemName,
                                imageData: profile.avatarImageData,
                                size: 92
                            )

                            PhotosPicker(
                                selection: $selectedPhotoItem,
                                matching: .images
                            ) {
                                Label("更换头像", systemImage: "photo")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(KikariaTheme.deepText)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 11)
                                    .background(.white.opacity(0.48), in: Capsule())
                                    .background(.ultraThinMaterial, in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 12)

                        VStack(spacing: 14) {
                            ProfileTextField(
                                title: "显示名称",
                                text: $displayName
                            )

                            ProfileTextField(
                                title: "用户 ID",
                                text: $userHandle
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: selectedPhotoItem) {
            loadSelectedAvatar()
        }
    }

    private func saveProfile() {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHandle = userHandle
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "@"))

        profile.displayName = trimmedName.isEmpty ? "Vita" : trimmedName
        profile.userHandle = trimmedHandle.isEmpty ? "vita_0818" : trimmedHandle
        dismiss()
    }

    private func loadSelectedAvatar() {
        guard let selectedPhotoItem else {
            return
        }

        Task {
            guard let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) else {
                return
            }

            await MainActor.run {
                guard UIImage(data: data) != nil else {
                    return
                }

                profile.avatarImageData = data
            }
        }
    }
}

private struct ProfileTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KikariaTheme.softText)

            TextField(title, text: $text)
                .font(.body)
                .foregroundStyle(KikariaTheme.deepText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: KikariaTheme.sky.opacity(0.08), radius: 12, y: 7)
        }
    }
}

private struct MarkdownEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var markdownText: String
    @Binding var knowledgePoints: [KnowledgePoint]
    @Binding var selectedTags: Set<String>
    @State private var draftText: String
    @State private var errorMessage: String?
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    init(
        markdownText: Binding<String>,
        knowledgePoints: Binding<[KnowledgePoint]>,
        selectedTags: Binding<Set<String>>
    ) {
        _markdownText = markdownText
        _knowledgePoints = knowledgePoints
        _selectedTags = selectedTags
        _draftText = State(initialValue: markdownText.wrappedValue)
    }

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(KikariaTheme.deepText)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.58), in: Circle())
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("知识点上传")
                        .font(.headline)
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Button("应用") {
                        applyMarkdown()
                    }
                    .font(.headline)
                    .foregroundStyle(KikariaTheme.sky)
                    .frame(width: 42, alignment: .trailing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 12) {
                    TextEditor(text: $draftText)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(KikariaTheme.deepText)
                        .scrollContentBackground(.hidden)
                        .padding(16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .shadow(color: KikariaTheme.sky.opacity(0.12), radius: 18, y: 10)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(red: 0.72, green: 0.24, blue: 0.24))
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }

            if let toastMessage {
                KikariaToast(message: toastMessage)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func applyMarkdown() {
        do {
            let parsedPoints = try KnowledgePoint.parseMarkdown(draftText)

            withAnimation(.spring(response: 0.36, dampingFraction: 0.9)) {
                markdownText = draftText
                knowledgePoints = parsedPoints
                selectedTags.removeAll()
                errorMessage = nil
            }

            showToast("已更新 \(parsedPoints.count) 个知识点")
        } catch {
            withAnimation(.easeInOut(duration: 0.2)) {
                errorMessage = "没有解析到有效知识点。请检查 # 标题、hint: 和 content:。"
            }
        }
    }

    private func showToast(_ message: String) {
        let token = UUID()
        toastToken = token

        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            toastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard toastToken == token else {
                return
            }

            withAnimation(.easeOut(duration: 0.22)) {
                toastMessage = nil
            }
        }
    }
}

private struct StartReviewButton: View {
    let dailyGoal: Int
    let masteredCount: Int
    @State private var isBreathing = false

    var body: some View {
        ZStack {
            MetricBubble(
                value: dailyGoal,
                label: "目标",
                size: 92,
                colors: [KikariaTheme.cyan, Color(red: 0.73, green: 0.95, blue: 0.90)],
                opacity: 0.48
            )
            .scaleEffect(isBreathing ? 1.04 : 0.98)
            .offset(x: -92, y: isBreathing ? -72 : -64)

            SoftBubble(
                size: 54,
                colors: [Color(red: 0.75, green: 0.78, blue: 1.0), KikariaTheme.mist],
                opacity: 0.44
            )
            .scaleEffect(isBreathing ? 0.98 : 1.05)
            .offset(x: 96, y: isBreathing ? -50 : -58)

            MetricBubble(
                value: masteredCount,
                label: "已掌握",
                size: 78,
                colors: [Color(red: 0.78, green: 0.95, blue: 0.74), KikariaTheme.cyan],
                opacity: 0.38
            )
            .scaleEffect(isBreathing ? 1.035 : 0.985)
            .offset(x: 90, y: isBreathing ? 84 : 74)

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

            Image(systemName: "arrow.right")
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

private struct MetricBubble: View {
    let value: Int
    let label: String
    let size: CGFloat
    let colors: [Color]
    let opacity: Double

    var body: some View {
        ZStack {
            SoftBubble(size: size, colors: colors, opacity: opacity)

            VStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: size > 84 ? 24 : 21, weight: .semibold, design: .serif))
                    .monospacedDigit()
                    .foregroundStyle(KikariaTheme.deepText.opacity(0.86))

                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(KikariaTheme.softText)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(value)")
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
    var onDone: (() -> Void)? = nil

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
                    if let onDone {
                        onDone()
                    } else {
                        dismiss()
                    }
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
    var onReturnHome: (() -> Void)?

    @State private var currentPointID: KnowledgePoint.ID?
    @State private var isShowingHint = false
    @State private var isShowingContent = false
    @State private var pointHistory: [KnowledgePoint.ID] = []
    @State private var gestureFeedback = false
    @State private var isShowingScopePanel = false
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    private var allTags: [String] {
        Array(Set(knowledgePoints.flatMap(\.tags))).sorted()
    }

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
        case .mastered:
            return knowledgePoints.filter(\.isMastered)
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
                if mode.isReinforcement || mode.isMastered {
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
                                    removeCurrentPointFromReinforcement(shouldShowToast: true)
                                    withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                        chooseRandomPoint()
                                    }
                                }
                            } else if mode.isMastered {
                                ReviewActionButton(
                                    title: "移出已掌握",
                                    systemImage: "minus.circle.fill",
                                    isPrimary: true,
                                    tone: .green
                                ) {
                                    removeCurrentPointFromMastered(shouldShowToast: true)
                                    withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                        chooseRandomPoint()
                                    }
                                }
                            } else {
                                ReviewActionButton(
                                    title: currentPoint.isReinforced ? "已添加至集锦" : "加入重点集锦",
                                    systemImage: currentPoint.isReinforced ? "checkmark.circle.fill" : "plus.circle.fill",
                                    isPrimary: !currentPoint.isReinforced,
                                    isEnabled: !currentPoint.isReinforced
                                ) {
                                    addCurrentPointToReinforcementAndAdvance()
                                }

                                MasteredReviewButton(isMastered: currentPoint.isMastered) {
                                    markCurrentPointAsMastered()
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

            if isShowingScopePanel {
                ScopeSelectionView(
                    selectedTags: $selectedTags,
                    allTags: allTags,
                    onDone: {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
                            isShowingScopePanel = false
                        }
                    }
                )
                .transition(.move(edge: .leading).combined(with: .opacity))
                .zIndex(4)
            }

            if let toastMessage {
                KikariaToast(message: toastMessage)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .allowsHitTesting(false)
                    .zIndex(5)
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
            if mode.isNormal {
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
        guard !isShowingScopePanel else {
            return
        }

        let horizontal = abs(translation.width)
        let vertical = abs(translation.height)
        let threshold: CGFloat = 68
        let dominance: CGFloat = 1.35

        if horizontal > threshold && horizontal > vertical * dominance {
            if translation.width > 0 {
                guard mode.isNormal, startLocation.x > 34 else {
                    return
                }

                triggerGestureFeedback()
                withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
                    isShowingScopePanel = true
                }
            } else {
                triggerGestureFeedback()
                handleSwipeLeft()
            }
        } else if vertical > threshold && vertical > horizontal * dominance {
            if translation.height < 0 {
                triggerGestureFeedback()
                if isShowingContent {
                    withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                        chooseRandomPoint()
                    }
                } else {
                    withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) {
                        isShowingContent = true
                    }
                }
            } else {
                triggerGestureFeedback()
                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                    goBackOrChooseRandom()
                }
            }
        }
    }

    private func handleSwipeLeft() {
        switch mode {
        case .normal:
            handleNormalSwipeLeft()
        case .reinforcement:
            handleReinforcementSwipeLeft()
        case .mastered:
            handleMasteredSwipeLeft()
        }
    }

    private func handleNormalSwipeLeft() {
        // Normal-mode left swipe only adds to reinforcement; it must never mark a point as mastered.
        let wasMastered = currentPoint?.isMastered
        if currentPoint?.isReinforced == true {
            withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                chooseRandomPoint()
            }
        } else {
            withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                isShowingContent = true
            }
            addCurrentPointToReinforcement()
            assert(currentPoint?.isMastered == wasMastered)
        }
    }

    private func handleReinforcementSwipeLeft() {
        // Reinforcement-mode left swipe only removes from reinforcement; mastered status is untouched.
        removeCurrentPointFromReinforcement(shouldShowToast: true)
        withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
            chooseRandomPoint()
        }
    }

    private func handleMasteredSwipeLeft() {
        // Mastered-mode left swipe only removes from mastered; reinforcement status is untouched.
        removeCurrentPointFromMastered(shouldShowToast: true)
        withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
            chooseRandomPoint()
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

        guard !knowledgePoints[index].isReinforced else {
            return
        }

        let wasMastered = knowledgePoints[index].isMastered
        knowledgePoints[index].isReinforced = true
        knowledgePoints[index].updatedAt = Date()
        assert(knowledgePoints[index].isMastered == wasMastered)
    }

    private func addCurrentPointToReinforcementAndAdvance() {
        addCurrentPointToReinforcement()
        withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
            chooseRandomPoint()
        }
    }

    private func markCurrentPointAsMastered() {
        // Mastered status is only set from the explicit "已掌握" action, not from normal-mode swipes.
        guard let currentPointID,
              let index = knowledgePoints.firstIndex(where: { $0.id == currentPointID })
        else {
            return
        }

        let title = knowledgePoints[index].title
        knowledgePoints[index].isMastered = true
        knowledgePoints[index].isReinforced = false
        knowledgePoints[index].updatedAt = Date()
        showToast("\(title) 已掌握")
    }

    @discardableResult
    private func removeCurrentPointFromReinforcement(shouldShowToast: Bool = false) -> Bool {
        guard let currentPointID,
              let index = knowledgePoints.firstIndex(where: { $0.id == currentPointID })
        else {
            return false
        }

        guard knowledgePoints[index].isReinforced else {
            return false
        }

        let title = knowledgePoints[index].title
        let wasMastered = knowledgePoints[index].isMastered
        knowledgePoints[index].isReinforced = false
        knowledgePoints[index].updatedAt = Date()
        assert(knowledgePoints[index].isMastered == wasMastered)

        if shouldShowToast {
            showToast("\(title) 已移除")
        }

        return true
    }

    @discardableResult
    private func removeCurrentPointFromMastered(shouldShowToast: Bool = false) -> Bool {
        guard let currentPointID,
              let index = knowledgePoints.firstIndex(where: { $0.id == currentPointID })
        else {
            return false
        }

        guard knowledgePoints[index].isMastered else {
            return false
        }

        let title = knowledgePoints[index].title
        let wasReinforced = knowledgePoints[index].isReinforced
        knowledgePoints[index].isMastered = false
        knowledgePoints[index].updatedAt = Date()
        assert(knowledgePoints[index].isReinforced == wasReinforced)

        if shouldShowToast {
            showToast("\(title) 已移出已掌握")
        }

        return true
    }

    private func showToast(_ message: String) {
        let token = UUID()
        toastToken = token

        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            toastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard toastToken == token else {
                return
            }

            withAnimation(.easeOut(duration: 0.22)) {
                toastMessage = nil
            }
        }
    }
}

private enum ReviewActionTone {
    case blue
    case green
}

private struct ReviewActionButton: View {
    let title: String
    let systemImage: String
    let isPrimary: Bool
    var tone: ReviewActionTone = .blue
    var isEnabled = true
    let action: () -> Void

    private var primaryFill: AnyShapeStyle {
        switch tone {
        case .blue:
            return AnyShapeStyle(KikariaTheme.actionGradient)
        case .green:
            return AnyShapeStyle(KikariaTheme.masteredGradient)
        }
    }

    private var shadowColor: Color {
        switch tone {
        case .blue:
            return KikariaTheme.sky
        case .green:
            return KikariaTheme.masteredGreen
        }
    }

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(isPrimary ? .white : KikariaTheme.deepText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 19)
                .background {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(isPrimary ? primaryFill : AnyShapeStyle(.white.opacity(0.82)))
                }
                .shadow(color: shadowColor.opacity(isPrimary ? 0.22 : 0.10), radius: 16, y: 9)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.82)
    }
}

private struct MasteredReviewButton: View {
    let isMastered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isMastered ? "checkmark.seal.fill" : "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isMastered ? KikariaTheme.masteredGreen.opacity(0.9) : .white)

                Text(isMastered ? "已设定为掌握" : "加入已掌握")
                    .font(.headline)
            }
            .foregroundStyle(isMastered ? KikariaTheme.softText : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 19)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        isMastered
                            ? AnyShapeStyle(.white.opacity(0.78))
                            : AnyShapeStyle(KikariaTheme.masteredActionGradient)
                    )
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(
                color: isMastered
                    ? KikariaTheme.blueGray.opacity(0.10)
                    : KikariaTheme.masteredGreen.opacity(0.20),
                radius: 16,
                y: 9
            )
        }
        .buttonStyle(.plain)
        .disabled(isMastered)
        .opacity(isMastered ? 0.88 : 1)
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
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

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

            if let toastMessage {
                KikariaToast(message: toastMessage)
                    .padding(.horizontal, 24)
                    .padding(.bottom, reinforcedPoints.isEmpty ? 34 : 118)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .allowsHitTesting(false)
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

        showToast("\(point.title) 已移除")
    }

    private func showToast(_ message: String) {
        let token = UUID()
        toastToken = token

        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            toastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard toastToken == token else {
                return
            }

            withAnimation(.easeOut(duration: 0.22)) {
                toastMessage = nil
            }
        }
    }
}

struct MasteredView: View {
    @Binding var knowledgePoints: [KnowledgePoint]
    let onStartReview: () -> Void
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    private var masteredPoints: [KnowledgePoint] {
        knowledgePoints.filter(\.isMastered)
    }

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            if masteredPoints.isEmpty {
                SoftEmptyState(
                    title: "还没有已掌握",
                    subtitle: "在背诵时查看答案后，可以把真正熟悉的知识点标记到这里。",
                    systemImage: "checkmark.seal"
                )
                .padding(24)
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("已掌握")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(KikariaTheme.deepText)
                                .padding(.top, 18)

                            ForEach(masteredPoints) { point in
                                ReinforcementCard(
                                    point: point,
                                    removeTitle: "移出已掌握",
                                    removeSystemImage: "minus.circle",
                                    removeTint: KikariaTheme.masteredGreen.opacity(0.86)
                                ) {
                                    removeFromMastered(point)
                                }
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 150)
                    }

                    VStack(spacing: 0) {
                        Button(action: onStartReview) {
                            MasteredStartButton(count: masteredPoints.count)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 18)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 20)
                    .background(.ultraThinMaterial)
                }
            }

            if let toastMessage {
                KikariaToast(message: toastMessage)
                    .padding(.horizontal, 24)
                    .padding(.bottom, masteredPoints.isEmpty ? 34 : 118)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .navigationTitle("已掌握")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func removeFromMastered(_ point: KnowledgePoint) {
        guard let index = knowledgePoints.firstIndex(where: { $0.id == point.id }) else {
            return
        }

        withAnimation(.spring(response: 0.36, dampingFraction: 0.9)) {
            knowledgePoints[index].isMastered = false
            knowledgePoints[index].updatedAt = Date()
        }

        showToast("\(point.title) 已移出已掌握")
    }

    private func showToast(_ message: String) {
        let token = UUID()
        toastToken = token

        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            toastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard toastToken == token else {
                return
            }

            withAnimation(.easeOut(duration: 0.22)) {
                toastMessage = nil
            }
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

private struct MasteredStartButton: View {
    let count: Int

    var body: some View {
        HStack(spacing: 14) {
            Text("开始已掌握复习")
                .font(.title3.weight(.semibold))
                .foregroundStyle(KikariaTheme.deepText)

            Spacer()

            Text("\(count)")
                .font(.title3.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(KikariaTheme.masteredGreen)

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
        .shadow(color: KikariaTheme.masteredGreen.opacity(0.16), radius: 20, y: 10)
    }
}

private struct ReinforcementCard: View {
    let point: KnowledgePoint
    var removeTitle = "移出重点集锦"
    var removeSystemImage = "minus.circle"
    var removeTint = Color.red.opacity(0.82)
    let removeAction: () -> Void
    @GestureState private var dragTranslation: CGSize = .zero

    private var previewOffset: CGFloat {
        let horizontal = abs(dragTranslation.width)
        let vertical = abs(dragTranslation.height)

        guard horizontal > vertical * 1.35 else {
            return 0
        }

        return min(max(dragTranslation.width * 0.18, -24), 24)
    }

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
                Label(removeTitle, systemImage: removeSystemImage)
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderless)
            .tint(removeTint)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.white.opacity(0.48))
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: KikariaTheme.sky.opacity(0.12), radius: 20, y: 12)
        .offset(x: previewOffset)
        .simultaneousGesture(cardSwipeGesture)
    }

    private var cardSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .local)
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                handleCardSwipe(translation: value.translation)
            }
    }

    private func handleCardSwipe(translation: CGSize) {
        let horizontal = abs(translation.width)
        let vertical = abs(translation.height)
        let threshold: CGFloat = 86
        let dominance: CGFloat = 1.45

        guard horizontal > threshold, horizontal > vertical * dominance else {
            return
        }

        removeAction()
    }
}

private struct KikariaToast: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(KikariaTheme.deepText)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white.opacity(0.62))
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: KikariaTheme.sky.opacity(0.18), radius: 18, y: 10)
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
