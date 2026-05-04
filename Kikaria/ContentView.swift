//
//  ContentView.swift
//  Kikaria
//
//  Created by Vita on 2026/5/1.
//

import PhotosUI
import SwiftUI
import UIKit
import UserNotifications
import UniformTypeIdentifiers

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
    case presetSelection
    case newPreset
    case markdownFormatGuide
    case editPreset(String)
    case editKnowledgePoint(String, UUID?)
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

struct DailyReviewRecord: Codable, Equatable {
    var date: Date
    var count: Int
}

private struct PresetStudyState: Codable {
    let presetId: String
    var knowledgePoints: [KnowledgePoint]
    var markdownText: String
    var selectedTags: Set<String>
    var dailyReviewRecords: [KnowledgePoint.ID: DailyReviewRecord]
    var dailyGoal: Int
    var countdownStartDate: Date?
    var countdownEndDate: Date?
    var notificationsEnabled: Bool
    var notificationTime: Date
    var dangerPercent: Int

    init(
        presetId: String,
        knowledgePoints: [KnowledgePoint],
        markdownText: String,
        selectedTags: Set<String>,
        dailyReviewRecords: [KnowledgePoint.ID: DailyReviewRecord],
        dailyGoal: Int,
        countdownStartDate: Date? = nil,
        countdownEndDate: Date? = nil,
        notificationsEnabled: Bool = false,
        notificationTime: Date = PresetStudyState.defaultNotificationTime(),
        dangerPercent: Int = 80
    ) {
        self.presetId = presetId
        self.knowledgePoints = knowledgePoints
        self.markdownText = markdownText
        self.selectedTags = selectedTags
        self.dailyReviewRecords = dailyReviewRecords
        self.dailyGoal = dailyGoal
        self.countdownStartDate = countdownStartDate
        self.countdownEndDate = countdownEndDate
        self.notificationsEnabled = notificationsEnabled
        self.notificationTime = notificationTime
        self.dangerPercent = min(max(dangerPercent, 1), 100)
    }

    private enum CodingKeys: String, CodingKey {
        case presetId
        case knowledgePoints
        case markdownText
        case selectedTags
        case dailyReviewRecords
        case dailyGoal
        case countdownDate
        case countdownStartDate
        case countdownEndDate
        case notificationsEnabled
        case notificationTime
        case dangerPercent
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        presetId = try container.decode(String.self, forKey: .presetId)
        knowledgePoints = try container.decode([KnowledgePoint].self, forKey: .knowledgePoints)
        markdownText = try container.decode(String.self, forKey: .markdownText)
        selectedTags = try container.decodeIfPresent(Set<String>.self, forKey: .selectedTags) ?? []
        dailyReviewRecords = try container.decodeIfPresent([KnowledgePoint.ID: DailyReviewRecord].self, forKey: .dailyReviewRecords) ?? [:]
        dailyGoal = try container.decodeIfPresent(Int.self, forKey: .dailyGoal) ?? 20

        let legacyCountdownDate = try container.decodeIfPresent(Date.self, forKey: .countdownDate)
        countdownStartDate = try container.decodeIfPresent(Date.self, forKey: .countdownStartDate)
        countdownEndDate = try container.decodeIfPresent(Date.self, forKey: .countdownEndDate) ?? legacyCountdownDate

        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? false
        notificationTime = try container.decodeIfPresent(Date.self, forKey: .notificationTime) ?? PresetStudyState.defaultNotificationTime()
        dangerPercent = min(max(try container.decodeIfPresent(Int.self, forKey: .dangerPercent) ?? 80, 1), 100)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(presetId, forKey: .presetId)
        try container.encode(knowledgePoints, forKey: .knowledgePoints)
        try container.encode(markdownText, forKey: .markdownText)
        try container.encode(selectedTags, forKey: .selectedTags)
        try container.encode(dailyReviewRecords, forKey: .dailyReviewRecords)
        try container.encode(dailyGoal, forKey: .dailyGoal)
        try container.encodeIfPresent(countdownStartDate, forKey: .countdownStartDate)
        try container.encodeIfPresent(countdownEndDate, forKey: .countdownEndDate)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(notificationTime, forKey: .notificationTime)
        try container.encode(dangerPercent, forKey: .dangerPercent)
    }

    static func defaultNotificationTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 21
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}

private struct PresetLibrarySnapshot: Codable {
    var presets: [KnowledgePreset]
    var presetStates: [String: PresetStudyState]
    var currentPresetID: String
}

private enum PresetCreationOutcome {
    case success(KnowledgePreset)
    case failure(String)
}

private func countdownDays(until targetDate: Date?) -> Int? {
    guard let targetDate else {
        return nil
    }

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let target = calendar.startOfDay(for: targetDate)
    let dayCount = calendar.dateComponents([.day], from: today, to: target).day ?? 0
    return max(0, dayCount)
}

private func countdownText(for targetDate: Date?) -> String {
    guard let days = countdownDays(until: targetDate) else {
        return "--"
    }

    return "\(days) 天"
}

private struct StudyProgressWarning {
    let masteredCount: Int
    let expectedMasteredCount: Int
    let dangerPercent: Int
    let remainingDays: Int?

    var body: String {
        if let remainingDays {
            return "距离目标日还剩 \(remainingDays) 天。你已掌握 \(masteredCount) / \(expectedMasteredCount) 个计划知识点，低于 \(dangerPercent)% 安全线。"
        }

        return "你已掌握 \(masteredCount) / \(expectedMasteredCount) 个计划知识点，低于 \(dangerPercent)% 安全线。"
    }
}

final class KikariaNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = KikariaNotificationDelegate()

    private override init() {
        super.init()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}

private enum KikariaNotificationManager {
    static func identifier(for presetID: String) -> String {
        "kikaria.studyProgressWarning.\(presetID)"
    }

    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    static func cancelStudyProgressWarning(for presetID: String) {
        let identifier = identifier(for: presetID)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    static func rescheduleStudyProgressWarning(for state: PresetStudyState) {
        let center = UNUserNotificationCenter.current()
        let identifier = identifier(for: state.presetId)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard state.notificationsEnabled else {
            return
        }

        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized ||
                    settings.authorizationStatus == .provisional ||
                    settings.authorizationStatus == .ephemeral
            else {
                return
            }

            guard let warning = evaluateStudyProgressWarning(for: state) else {
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Kikaria 学习提醒"
            content.body = warning.body
            content.sound = .default

            let triggerDate = nextTriggerDate(for: state.notificationTime)
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
        }
    }

    static func scheduleDebugTestNotification(completion: @escaping (String) -> Void) {
        #if DEBUG
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                scheduleAuthorizedDebugTestNotification(completion: completion)
            case .notDetermined:
                requestAuthorization { granted in
                    if granted {
                        scheduleAuthorizedDebugTestNotification(completion: completion)
                    } else {
                        completion("请在系统设置中允许通知")
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    completion("请在系统设置中允许通知")
                }
            @unknown default:
                DispatchQueue.main.async {
                    completion("通知权限不可用")
                }
            }
        }
        #endif
    }

    private static func scheduleAuthorizedDebugTestNotification(completion: @escaping (String) -> Void) {
        #if DEBUG
        let center = UNUserNotificationCenter.current()
        let identifier = "kikaria.test.notification"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Kikaria 测试通知"
        content.body = "这是一条学习提醒测试。"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        center.add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion("测试通知将在 5 秒后发送")
                } else {
                    completion("测试通知发送失败")
                }
            }
        }
        #endif
    }

    static func evaluateStudyProgressWarning(for state: PresetStudyState, now: Date = Date()) -> StudyProgressWarning? {
        let totalCount = state.knowledgePoints.count
        let masteredCount = state.knowledgePoints.filter(\.isMastered).count
        let dangerPercent = min(max(state.dangerPercent, 1), 100)

        guard totalCount > 0,
              let startDate = state.countdownStartDate,
              let endDate = state.countdownEndDate
        else {
            return nil
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        guard start <= end else {
            return nil
        }

        if today < start {
            return nil
        }

        let expectedProgress: Double
        if today >= end {
            expectedProgress = 1
        } else {
            let totalDays = max(1, (calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1)
            let elapsedDays = max(1, (calendar.dateComponents([.day], from: start, to: today).day ?? 0) + 1)
            expectedProgress = Double(elapsedDays) / Double(totalDays)
        }

        let expectedMasteredCount = Int(ceil(Double(totalCount) * expectedProgress))
        guard expectedMasteredCount > 0 else {
            return nil
        }

        let actualProgressRatio = Double(masteredCount) / Double(expectedMasteredCount)
        guard actualProgressRatio < Double(dangerPercent) / 100 else {
            return nil
        }

        return StudyProgressWarning(
            masteredCount: masteredCount,
            expectedMasteredCount: expectedMasteredCount,
            dangerPercent: dangerPercent,
            remainingDays: countdownDays(until: endDate)
        )
    }

    private static func nextTriggerDate(for notificationTime: Date, now: Date = Date()) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: notificationTime)
        let hour = timeComponents.hour ?? 21
        let minute = timeComponents.minute ?? 0
        let today = calendar.startOfDay(for: now)
        let todayTrigger = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? now

        if todayTrigger > now {
            return todayTrigger
        }

        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? now.addingTimeInterval(24 * 60 * 60)
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: tomorrow) ?? tomorrow
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var presets = KnowledgePreset.all
    @State private var knowledgePoints = KnowledgePoint.samples
    @State private var markdownText = KnowledgePreset.defaultPreset.markdownText
    @State private var userProfile = UserProfile()
    @State private var selectedTags = Set<String>()
    @State private var navigationPath: [AppRoute] = []
    @State private var dailyReviewRecords: [KnowledgePoint.ID: DailyReviewRecord] = [:]
    @State private var presetStates: [String: PresetStudyState] = [:]
    @State private var currentPresetID = KnowledgePreset.defaultPresetID
    @State private var dailyGoal = 20
    @State private var countdownStartDate: Date?
    @State private var countdownEndDate: Date?
    @State private var notificationsEnabled = false
    @State private var notificationTime = PresetStudyState.defaultNotificationTime()
    @State private var dangerPercent = 80
    @State private var hasLoadedInitialPresetState = false
    @State private var isApplyingPresetState = false
    @AppStorage("dailyLearningGoal") private var legacyDailyGoal = 20
    @AppStorage("presetLibraryJSON") private var encodedPresetLibrary = ""

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

    private var countdownDayCount: Int? {
        countdownDays(until: countdownEndDate)
    }

    private var currentPreset: KnowledgePreset {
        presets.first { $0.id == currentPresetID } ?? KnowledgePreset.defaultPreset
    }

    private var currentPresetShortName: String {
        currentPreset.shortName
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                KikariaTheme.pageGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        Text("Kikaria")
                            .font(KikariaTypography.appTitle())
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
                            masteredCount: masteredCount,
                            countdownDays: countdownDayCount,
                            presetShortName: currentPresetShortName
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
                        dailyReviewRecords: $dailyReviewRecords,
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
                        dailyReviewRecords: $dailyReviewRecords,
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
                        dailyReviewRecords: $dailyReviewRecords,
                        mode: .mastered,
                        onReturnHome: {
                            navigationPath.removeAll()
                        }
                    )
                case .settings:
                    SettingsView(
                        profile: userProfile,
                        dailyGoal: dailyGoalBinding,
                        countdownStartDate: countdownStartDateBinding,
                        countdownEndDate: countdownEndDateBinding,
                        notificationsEnabled: notificationsEnabled,
                        notificationTime: notificationTimeBinding,
                        dangerPercent: dangerPercentBinding,
                        currentPresetName: currentPreset.name,
                        onClose: {
                            navigationPath.removeAll()
                        },
                        onEditProfile: {
                            navigationPath.append(.editProfile)
                        },
                        onOpenPresetSelection: {
                            navigationPath.append(.presetSelection)
                        },
                        onSetNotificationsEnabled: updateNotificationsEnabled,
                        onSendTestNotification: sendDebugTestNotification
                    )
                case .editProfile:
                    EditProfileView(profile: $userProfile)
                case .markdownEditor:
                    MarkdownEditorView(
                        markdownText: $markdownText,
                        knowledgePoints: $knowledgePoints,
                        selectedTags: $selectedTags,
                        dailyReviewRecords: $dailyReviewRecords
                    )
                case .presetSelection:
                    PresetSelectionView(
                        presets: presets,
                        currentPresetID: $currentPresetID,
                        switchPreset: switchToPreset,
                        onUploadNewPreset: {
                            navigationPath.append(.newPreset)
                        },
                        onEditPreset: { preset in
                            navigationPath.append(.editPreset(preset.id))
                        }
                    )
                case .newPreset:
                    NewPresetView(createPreset: createPreset)
                case .markdownFormatGuide:
                    MarkdownFormatGuideView()
                case .editPreset(let presetID):
                    if let preset = presets.first(where: { $0.id == presetID }),
                       let state = studyState(for: preset) {
                        EditPresetView(
                            preset: preset,
                            knowledgePoints: state.knowledgePoints,
                            onSavePreset: updatePresetMetadata,
                            onAddPoint: {
                                navigationPath.append(.editKnowledgePoint(presetID, nil))
                            },
                            onEditPoint: { pointID in
                                navigationPath.append(.editKnowledgePoint(presetID, pointID))
                            },
                            onDeletePoint: deleteKnowledgePoint,
                            onDeletePreset: deletePreset
                        )
                    } else {
                        SoftEmptyState(
                            title: "预设不存在",
                            subtitle: "请返回后重新选择预设。",
                            systemImage: "questionmark.folder"
                        )
                        .padding(24)
                    }
                case .editKnowledgePoint(let presetID, let pointID):
                    if let editorContext = knowledgePointEditorContext(presetID: presetID, pointID: pointID) {
                        EditKnowledgePointView(
                            presetName: editorContext.presetName,
                            point: editorContext.point,
                            onSave: { point in
                                upsertKnowledgePoint(point, inPresetID: presetID)
                            }
                        )
                    } else {
                        SoftEmptyState(
                            title: "知识点不存在",
                            subtitle: "请返回后重新选择知识点。",
                            systemImage: "doc.text.magnifyingglass"
                        )
                        .padding(24)
                    }
                }
            }
            .onAppear {
                loadInitialPresetStateIfNeeded()
            }
            .onChange(of: knowledgePoints) { _ in
                persistCurrentStudyStateIfReady()
            }
            .onChange(of: selectedTags) { _ in
                persistCurrentStudyStateIfReady()
            }
            .onChange(of: dailyReviewRecords) { _ in
                persistCurrentStudyStateIfReady()
            }
            .onChange(of: markdownText) { _ in
                persistCurrentStudyStateIfReady()
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    rescheduleCurrentNotification()
                }
            }
        }
    }

    private var dailyGoalBinding: Binding<Int> {
        Binding(
            get: { dailyGoal },
            set: { newValue in
                updateDailyGoal(newValue)
            }
        )
    }

    private var countdownStartDateBinding: Binding<Date?> {
        Binding(
            get: { countdownStartDate },
            set: { newValue in
                updateCountdownRange(startDate: newValue, endDate: countdownEndDate)
            }
        )
    }

    private var countdownEndDateBinding: Binding<Date?> {
        Binding(
            get: { countdownEndDate },
            set: { newValue in
                updateCountdownRange(startDate: countdownStartDate, endDate: newValue)
            }
        )
    }

    private var notificationTimeBinding: Binding<Date> {
        Binding(
            get: { notificationTime },
            set: { newValue in
                updateNotificationTime(newValue)
            }
        )
    }

    private var dangerPercentBinding: Binding<Int> {
        Binding(
            get: { dangerPercent },
            set: { newValue in
                updateDangerPercent(newValue)
            }
        )
    }

    private func loadInitialPresetStateIfNeeded() {
        guard !hasLoadedInitialPresetState else {
            return
        }

        hasLoadedInitialPresetState = true
        loadPersistedPresetLibrary()

        guard let state = studyState(for: currentPreset) else {
            return
        }

        presetStates[currentPresetID] = state
        restorePresetState(state)
        rescheduleCurrentNotification()
    }

    private func switchToPreset(_ preset: KnowledgePreset) -> Bool {
        guard let targetState = studyState(for: preset) else {
            return false
        }

        let previousPresetID = currentPresetID
        saveCurrentPresetState()

        withAnimation(.spring(response: 0.36, dampingFraction: 0.9)) {
            if presetStates[preset.id] == nil {
                presetStates[preset.id] = targetState
            }

            restorePresetState(targetState)
        }

        if previousPresetID != preset.id {
            KikariaNotificationManager.cancelStudyProgressWarning(for: previousPresetID)
        }

        persistLibrary()
        rescheduleCurrentNotification()
        return true
    }

    private func saveCurrentPresetState() {
        let state = currentPresetStateSnapshot()
        presetStates[currentPresetID] = state
        persistLibrary()
    }

    private func studyState(for preset: KnowledgePreset) -> PresetStudyState? {
        if let state = presetStates[preset.id] {
            return state
        }

        return initialStudyState(for: preset)
    }

    private func initialStudyState(for preset: KnowledgePreset) -> PresetStudyState? {
        guard let parsedPoints = try? KnowledgePoint.parseMarkdown(preset.markdownText) else {
            return nil
        }

        return PresetStudyState(
            presetId: preset.id,
            knowledgePoints: parsedPoints,
            markdownText: preset.markdownText,
            selectedTags: [],
            dailyReviewRecords: [:],
            dailyGoal: dailyGoal(forPresetID: preset.id),
            countdownStartDate: nil,
            countdownEndDate: nil
        )
    }

    private func currentPresetStateSnapshot() -> PresetStudyState {
        PresetStudyState(
            presetId: currentPresetID,
            knowledgePoints: knowledgePoints,
            markdownText: markdownText,
            selectedTags: selectedTags,
            dailyReviewRecords: dailyReviewRecords,
            dailyGoal: clampedDailyGoal(dailyGoal),
            countdownStartDate: countdownStartDate,
            countdownEndDate: countdownEndDate,
            notificationsEnabled: notificationsEnabled,
            notificationTime: notificationTime,
            dangerPercent: clampedDangerPercent(dangerPercent)
        )
    }

    private func restorePresetState(_ state: PresetStudyState) {
        isApplyingPresetState = true
        currentPresetID = state.presetId
        knowledgePoints = state.knowledgePoints
        markdownText = state.markdownText
        selectedTags = validSelectedTags(from: state.selectedTags, in: state.knowledgePoints)
        dailyReviewRecords = state.dailyReviewRecords
        dailyGoal = clampedDailyGoal(state.dailyGoal)
        countdownStartDate = state.countdownStartDate
        countdownEndDate = state.countdownEndDate
        notificationsEnabled = state.notificationsEnabled
        notificationTime = normalizedNotificationTime(state.notificationTime)
        dangerPercent = clampedDangerPercent(state.dangerPercent)

        DispatchQueue.main.async {
            isApplyingPresetState = false
            presetStates[state.presetId] = currentPresetStateSnapshot()
            persistLibrary()
            rescheduleCurrentNotification()
        }
    }

    private func validSelectedTags(from tags: Set<String>, in points: [KnowledgePoint]) -> Set<String> {
        let availableTags = Set(points.flatMap(\.tags))
        return Set(tags.filter { availableTags.contains($0) })
    }

    private func updateDailyGoal(_ newValue: Int) {
        let goal = clampedDailyGoal(newValue)
        dailyGoal = goal
        presetStates[currentPresetID] = currentPresetStateSnapshot()
        persistLibrary()
    }

    private func updateCountdownRange(startDate: Date?, endDate: Date?) {
        countdownStartDate = startDate
        countdownEndDate = endDate
        presetStates[currentPresetID] = currentPresetStateSnapshot()
        persistLibrary()
        rescheduleCurrentNotification()
    }

    private func updateNotificationsEnabled(_ newValue: Bool, completion: @escaping (Bool, String?) -> Void) {
        if newValue {
            KikariaNotificationManager.requestAuthorization { granted in
                notificationsEnabled = granted
                presetStates[currentPresetID] = currentPresetStateSnapshot()
                persistLibrary()
                rescheduleCurrentNotification()
                completion(granted, granted ? nil : "请在系统设置中允许通知")
            }
        } else {
            notificationsEnabled = false
            presetStates[currentPresetID] = currentPresetStateSnapshot()
            persistLibrary()
            KikariaNotificationManager.cancelStudyProgressWarning(for: currentPresetID)
            completion(false, nil)
        }
    }

    private func updateNotificationTime(_ newValue: Date) {
        notificationTime = normalizedNotificationTime(newValue)
        presetStates[currentPresetID] = currentPresetStateSnapshot()
        persistLibrary()
        rescheduleCurrentNotification()
    }

    private func updateDangerPercent(_ newValue: Int) {
        dangerPercent = clampedDangerPercent(newValue)
        presetStates[currentPresetID] = currentPresetStateSnapshot()
        persistLibrary()
        rescheduleCurrentNotification()
    }

    private func sendDebugTestNotification(completion: @escaping (String) -> Void) {
        KikariaNotificationManager.scheduleDebugTestNotification(completion: completion)
    }

    private func dailyGoal(forPresetID presetID: String) -> Int {
        if let goal = presetStates[presetID]?.dailyGoal {
            return clampedDailyGoal(goal)
        }

        if presetID == KnowledgePreset.defaultPresetID {
            return clampedDailyGoal(legacyDailyGoal)
        }

        return 20
    }

    private func persistCurrentStudyStateIfReady() {
        guard hasLoadedInitialPresetState, !isApplyingPresetState else {
            return
        }

        presetStates[currentPresetID] = currentPresetStateSnapshot()
        persistLibrary()
        rescheduleCurrentNotification()
    }

    private func loadPersistedPresetLibrary() {
        guard let data = encodedPresetLibrary.data(using: .utf8),
              let snapshot = try? JSONDecoder().decode(PresetLibrarySnapshot.self, from: data),
              !snapshot.presets.isEmpty
        else {
            presets = KnowledgePreset.all
            currentPresetID = KnowledgePreset.defaultPresetID
            return
        }

        presets = mergedPresets(with: snapshot.presets)
        presetStates = snapshot.presetStates

        if presets.contains(where: { $0.id == snapshot.currentPresetID }) {
            currentPresetID = snapshot.currentPresetID
        } else {
            currentPresetID = presets.first?.id ?? KnowledgePreset.defaultPresetID
        }
    }

    private func mergedPresets(with storedPresets: [KnowledgePreset]) -> [KnowledgePreset] {
        var merged = storedPresets

        for builtInPreset in KnowledgePreset.all where !merged.contains(where: { $0.id == builtInPreset.id }) {
            merged.append(builtInPreset)
        }

        return merged
    }

    private func persistLibrary() {
        var states = presetStates

        if hasLoadedInitialPresetState {
            states[currentPresetID] = currentPresetStateSnapshot()
        }

        let snapshot = PresetLibrarySnapshot(
            presets: presets,
            presetStates: states,
            currentPresetID: currentPresetID
        )

        if let data = try? JSONEncoder().encode(snapshot),
           let encoded = String(data: data, encoding: .utf8) {
            encodedPresetLibrary = encoded
        }

        if currentPresetID == KnowledgePreset.defaultPresetID {
            legacyDailyGoal = clampedDailyGoal(dailyGoal)
        }
    }

    private func createPreset(name: String, shortName: String, category: String, description: String, markdownText: String) -> PresetCreationOutcome {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return .failure("请填写预设名称。")
        }

        let trimmedMarkdown = markdownText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let parsedPoints = try? KnowledgePoint.parseMarkdown(trimmedMarkdown) else {
            return .failure("没有解析到有效知识点。请检查 # 标题、tags、hint: 和 content:。")
        }

        saveCurrentPresetState()

        let preset = KnowledgePreset(
            id: "user-\(UUID().uuidString)",
            name: trimmedName,
            shortName: shortName,
            subtitle: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "自定义知识点" : description.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "自定义上传的知识点预设。" : description.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "自定义" : category.trimmingCharacters(in: .whitespacesAndNewlines),
            markdownText: trimmedMarkdown,
            isBuiltIn: false
        )

        let state = PresetStudyState(
            presetId: preset.id,
            knowledgePoints: parsedPoints,
            markdownText: trimmedMarkdown,
            selectedTags: [],
            dailyReviewRecords: [:],
            dailyGoal: 20,
            countdownStartDate: nil,
            countdownEndDate: nil,
            notificationsEnabled: false,
            notificationTime: PresetStudyState.defaultNotificationTime(),
            dangerPercent: 80
        )

        presets.append(preset)
        presetStates[preset.id] = state
        restorePresetState(state)
        persistLibrary()

        return .success(preset)
    }

    private func updatePresetMetadata(presetID: String, name: String, shortName: String, category: String, description: String) {
        guard let index = presets.firstIndex(where: { $0.id == presetID }) else {
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        presets[index].name = trimmedName.isEmpty ? presets[index].name : trimmedName
        presets[index].shortName = KnowledgePreset.normalizedShortName(shortName, fallbackName: presets[index].name)
        presets[index].category = trimmedCategory.isEmpty ? "自定义" : trimmedCategory
        presets[index].subtitle = trimmedDescription.isEmpty ? presets[index].subtitle : trimmedDescription
        presets[index].description = trimmedDescription.isEmpty ? presets[index].description : trimmedDescription
        persistLibrary()
    }

    private func deletePreset(_ presetID: String) {
        guard let preset = presets.first(where: { $0.id == presetID }),
              !preset.isBuiltIn,
              presets.count > 1
        else {
            return
        }

        let wasCurrentPreset = presetID == currentPresetID
        presets.removeAll { $0.id == presetID }
        presetStates[presetID] = nil
        KikariaNotificationManager.cancelStudyProgressWarning(for: presetID)

        if wasCurrentPreset, let nextPreset = presets.first {
            _ = switchToPreset(nextPreset)
        } else {
            persistLibrary()
        }
    }

    private func knowledgePointEditorContext(presetID: String, pointID: UUID?) -> (presetName: String, point: KnowledgePoint?)? {
        guard let preset = presets.first(where: { $0.id == presetID }),
              let state = studyState(for: preset)
        else {
            return nil
        }

        let point = pointID.flatMap { id in
            state.knowledgePoints.first { $0.id == id }
        }

        if pointID != nil, point == nil {
            return nil
        }

        return (preset.name, point)
    }

    private func upsertKnowledgePoint(_ point: KnowledgePoint, inPresetID presetID: String) {
        guard var state = stateForEditing(presetID: presetID) else {
            return
        }

        if let index = state.knowledgePoints.firstIndex(where: { $0.id == point.id }) {
            state.knowledgePoints[index] = point
        } else {
            state.knowledgePoints.append(point)
        }

        syncEditedState(state)
    }

    private func deleteKnowledgePoint(_ pointID: UUID, fromPresetID presetID: String) {
        guard var state = stateForEditing(presetID: presetID) else {
            return
        }

        state.knowledgePoints.removeAll { $0.id == pointID }
        state.dailyReviewRecords[pointID] = nil
        state.selectedTags = validSelectedTags(from: state.selectedTags, in: state.knowledgePoints)
        syncEditedState(state)
    }

    private func stateForEditing(presetID: String) -> PresetStudyState? {
        if presetID == currentPresetID {
            return currentPresetStateSnapshot()
        }

        guard let preset = presets.first(where: { $0.id == presetID }) else {
            return nil
        }

        return studyState(for: preset)
    }

    private func syncEditedState(_ state: PresetStudyState) {
        var editedState = state
        let generatedMarkdown = KnowledgePoint.markdownText(from: editedState.knowledgePoints)
        editedState.markdownText = generatedMarkdown
        presetStates[editedState.presetId] = editedState

        if let presetIndex = presets.firstIndex(where: { $0.id == editedState.presetId }) {
            presets[presetIndex].markdownText = generatedMarkdown
        }

        if editedState.presetId == currentPresetID {
            restorePresetState(editedState)
        } else {
            persistLibrary()
        }
    }

    private func clampedDailyGoal(_ goal: Int) -> Int {
        min(max(goal, 1), 100)
    }

    private func clampedDangerPercent(_ percent: Int) -> Int {
        min(max(percent, 1), 100)
    }

    private func normalizedNotificationTime(_ date: Date) -> Date {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        var normalized = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        normalized.hour = components.hour ?? 21
        normalized.minute = components.minute ?? 0
        normalized.second = 0
        return Calendar.current.date(from: normalized) ?? PresetStudyState.defaultNotificationTime()
    }

    private func rescheduleCurrentNotification() {
        guard hasLoadedInitialPresetState else {
            return
        }

        KikariaNotificationManager.rescheduleStudyProgressWarning(for: currentPresetStateSnapshot())
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
    @Binding var dailyGoal: Int
    @Binding var countdownStartDate: Date?
    @Binding var countdownEndDate: Date?
    let notificationsEnabled: Bool
    @Binding var notificationTime: Date
    @Binding var dangerPercent: Int
    let currentPresetName: String
    let onClose: () -> Void
    let onEditProfile: () -> Void
    let onOpenPresetSelection: () -> Void
    let onSetNotificationsEnabled: (Bool, @escaping (Bool, String?) -> Void) -> Void
    let onSendTestNotification: (@escaping (String) -> Void) -> Void
    @State private var isShowingDailyGoalPicker = false
    @State private var isShowingCountdownPicker = false
    @State private var isShowingDangerPicker = false
    @State private var countdownDraftStartDate = Date()
    @State private var countdownDraftEndDate = Date()
    @State private var countdownErrorMessage: String?
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("设置")
                        .font(KikariaTypography.chineseTitle(size: 30))
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
                                    .font(KikariaTypography.chineseTitle(size: 28, weight: .semibold))
                                    .foregroundStyle(KikariaTheme.deepText)

                                Text("@\(profile.userHandle)")
                                    .font(KikariaTypography.chineseBody(size: 15, weight: .medium))
                                    .foregroundStyle(KikariaTheme.softText)
                            }

                            Button(action: onEditProfile) {
                                Text("编辑个人资料")
                                    .font(KikariaTypography.chineseButton(size: 16))
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
                            SettingsListRow(
                                title: "每日学习目标",
                                valueText: "\(dailyGoal)"
                            ) {
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                    isShowingCountdownPicker = false
                                    isShowingDangerPicker = false
                                    isShowingDailyGoalPicker.toggle()
                                }
                            }

                            SettingsListRow(
                                title: "倒数日",
                                valueText: countdownEndDate.map { "\(countdownDays(until: $0) ?? 0)天" } ?? "未设置"
                            ) {
                                prepareCountdownDraft()
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                    isShowingDailyGoalPicker = false
                                    isShowingDangerPicker = false
                                    isShowingCountdownPicker.toggle()
                                }
                            }

                            SettingsToggleRow(
                                title: "学习进度通知",
                                isOn: notificationsEnabled
                            ) { newValue in
                                onSetNotificationsEnabled(newValue) { _, message in
                                    if let message {
                                        showToast(message)
                                    }
                                }
                            }

                            if notificationsEnabled {
                                SettingsTimePickerRow(
                                    title: "通知时间",
                                    selectedTime: $notificationTime
                                )

                                SettingsListRow(
                                    title: "进度安全线",
                                    valueText: "\(dangerPercent)%"
                                ) {
                                    withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                        isShowingDailyGoalPicker = false
                                        isShowingCountdownPicker = false
                                        isShowingDangerPicker.toggle()
                                    }
                                }

                                if countdownStartDate == nil || countdownEndDate == nil {
                                    Text("请先设置倒数日区间")
                                        .font(KikariaTypography.chineseCaption(size: 12, weight: .medium))
                                        .foregroundStyle(KikariaTheme.softText)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 8)
                                }

                                #if DEBUG
                                Button {
                                    onSendTestNotification { message in
                                        showToast(message)
                                    }
                                } label: {
                                    Text("测试通知")
                                        .font(KikariaTypography.chineseButton(size: 14))
                                        .foregroundStyle(KikariaTheme.deepText)
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .background(.white.opacity(0.52), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                                }
                                .buttonStyle(.plain)
                                #endif
                            }

                            SettingsListRow(
                                title: "切换预设",
                                valueText: currentPresetName
                            ) {
                                onOpenPresetSelection()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }

            if isShowingDailyGoalPicker {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.18)) {
                            isShowingDailyGoalPicker = false
                        }
                    }
                    .transition(.opacity)

                VStack {
                    Spacer()
                        .frame(height: 352)

                    DailyGoalPickerBubble(dailyGoal: $dailyGoal) {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                            isShowingDailyGoalPicker = false
                        }
                    }
                    .padding(.horizontal, 34)
                    .transition(.scale(scale: 0.94, anchor: .topTrailing).combined(with: .opacity))

                    Spacer()
                }
            }

            if isShowingCountdownPicker {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.18)) {
                            isShowingCountdownPicker = false
                        }
                    }
                    .transition(.opacity)

                VStack {
                    Spacer()
                        .frame(height: 332)

                    CountdownDateRangePickerBubble(
                        startDate: $countdownDraftStartDate,
                        endDate: $countdownDraftEndDate,
                        isConfigured: countdownEndDate != nil,
                        errorMessage: countdownErrorMessage
                    ) {
                        countdownStartDate = nil
                        countdownEndDate = nil
                        countdownErrorMessage = nil
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                            isShowingCountdownPicker = false
                        }
                    } onDone: {
                        guard Calendar.current.startOfDay(for: countdownDraftEndDate) >= Calendar.current.startOfDay(for: countdownDraftStartDate) else {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                countdownErrorMessage = "结束日期不能早于开始日期。"
                            }
                            showToast("结束日期不能早于开始日期")
                            return
                        }

                        countdownStartDate = countdownDraftStartDate
                        countdownEndDate = countdownDraftEndDate
                        countdownErrorMessage = nil

                        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                            isShowingCountdownPicker = false
                        }
                    }
                    .padding(.horizontal, 34)
                    .transition(.scale(scale: 0.94, anchor: .topTrailing).combined(with: .opacity))

                    Spacer()
                }
            }

            if isShowingDangerPicker {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.18)) {
                            isShowingDangerPicker = false
                        }
                    }
                    .transition(.opacity)

                VStack {
                    Spacer()
                        .frame(height: 492)

                    DangerPercentPickerBubble(dangerPercent: $dangerPercent) {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                            isShowingDangerPicker = false
                        }
                    }
                    .padding(.horizontal, 34)
                    .transition(.scale(scale: 0.94, anchor: .topTrailing).combined(with: .opacity))

                    Spacer()
                }
            }

            if let toastMessage {
                KikariaToastLayer(message: toastMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func prepareCountdownDraft() {
        let today = Date()
        countdownDraftStartDate = countdownStartDate ?? today
        countdownDraftEndDate = countdownEndDate ?? countdownStartDate ?? today
        countdownErrorMessage = nil
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

private struct SettingsListRow: View {
    let title: String
    let valueText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(title)
                    .font(KikariaTypography.chineseHeadline(size: 17))
                    .foregroundStyle(KikariaTheme.deepText)

                Spacer()

                Text(valueText)
                    .font(KikariaTypography.chineseHeadline(size: 17))
                    .foregroundStyle(KikariaTheme.sky)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KikariaTheme.blueGray)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(.white.opacity(0.54), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: KikariaTheme.sky.opacity(0.10), radius: 16, y: 9)
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsToggleRow: View {
    let title: String
    let isOn: Bool
    let onChange: (Bool) -> Void

    var body: some View {
        HStack(spacing: 14) {
            Text(title)
                .font(KikariaTypography.chineseHeadline(size: 17))
                .foregroundStyle(KikariaTheme.deepText)

            Spacer()

            Toggle(
                title,
                isOn: Binding(
                    get: { isOn },
                    set: { onChange($0) }
                )
            )
            .labelsHidden()
            .tint(KikariaTheme.sky)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(.white.opacity(0.54), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: KikariaTheme.sky.opacity(0.10), radius: 16, y: 9)
    }
}

private struct SettingsTimePickerRow: View {
    let title: String
    @Binding var selectedTime: Date

    var body: some View {
        HStack(spacing: 14) {
            Text(title)
                .font(KikariaTypography.chineseHeadline(size: 17))
                .foregroundStyle(KikariaTheme.deepText)

            Spacer()

            DatePicker(title, selection: $selectedTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(KikariaTheme.sky)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(.white.opacity(0.54), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: KikariaTheme.sky.opacity(0.10), radius: 16, y: 9)
    }
}

private struct SettingsOptionRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var valueText: String? = nil
    var showsChevron = true
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
                        .font(KikariaTypography.chineseHeadline())
                        .foregroundStyle(KikariaTheme.deepText)

                    Text(subtitle)
                        .font(KikariaTypography.chineseCaption(size: 13))
                        .foregroundStyle(KikariaTheme.softText)
                }

                Spacer()

                if let valueText {
                    Text(valueText)
                        .font(KikariaTypography.chineseHeadline())
                        .monospacedDigit()
                        .foregroundStyle(KikariaTheme.sky)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }

                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KikariaTheme.blueGray)
                }
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

private struct DailyGoalPickerBubble: View {
    @Binding var dailyGoal: Int
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("每日学习目标")
                    .font(KikariaTypography.chineseHeadline())
                    .foregroundStyle(KikariaTheme.deepText)

                Spacer()

                Text("\(dailyGoal)")
                    .font(KikariaTypography.number(size: 17))
                    .monospacedDigit()
                    .foregroundStyle(KikariaTheme.sky)
            }

            Picker("每日学习目标", selection: $dailyGoal) {
                ForEach(1...100, id: \.self) { goal in
                    Text("\(goal) 个")
                        .font(KikariaTypography.chineseBody(size: 18))
                        .tag(goal)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 126)
            .clipped()

            Button(action: onDone) {
                Text("完成")
                    .font(KikariaTypography.chineseButton())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(KikariaTheme.actionGradient, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(maxWidth: 318)
        .background(.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.38), lineWidth: 1)
        }
        .shadow(color: KikariaTheme.sky.opacity(0.18), radius: 24, y: 14)
    }
}

private struct CountdownDateRangePickerBubble: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let isConfigured: Bool
    let errorMessage: String?
    let onClear: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("倒数日")
                    .font(KikariaTypography.chineseHeadline())
                    .foregroundStyle(KikariaTheme.deepText)

                Spacer()

                Text(isConfigured ? countdownText(for: endDate) : "未设置")
                    .font(KikariaTypography.chineseHeadline())
                    .monospacedDigit()
                    .foregroundStyle(KikariaTheme.sky)
            }

            VStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("开始日期")
                        .font(KikariaTypography.chineseCaption(size: 13, weight: .semibold))
                        .foregroundStyle(KikariaTheme.deepText)

                    DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                        .font(KikariaTypography.chineseBody(size: 14, weight: .medium))
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 100)
                        .clipped()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text("结束日期")
                        .font(KikariaTypography.chineseCaption(size: 13, weight: .semibold))
                        .foregroundStyle(KikariaTheme.deepText)

                    DatePicker("结束日期", selection: $endDate, displayedComponents: .date)
                        .font(KikariaTypography.chineseBody(size: 14, weight: .medium))
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 100)
                        .clipped()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(KikariaTypography.chineseCaption(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 0.72, green: 0.24, blue: 0.24))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 10) {
                Button(action: onClear) {
                    Text("清除")
                        .font(KikariaTypography.chineseButton())
                        .foregroundStyle(KikariaTheme.deepText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.62), in: Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onDone) {
                    Text("完成")
                        .font(KikariaTypography.chineseButton())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(KikariaTheme.actionGradient, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(maxWidth: 326)
        .background(.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.38), lineWidth: 1)
        }
        .shadow(color: KikariaTheme.sky.opacity(0.18), radius: 24, y: 14)
    }
}

private struct DangerPercentPickerBubble: View {
    @Binding var dangerPercent: Int
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("进度安全线")
                    .font(KikariaTypography.chineseHeadline())
                    .foregroundStyle(KikariaTheme.deepText)

                Spacer()

                Text("\(dangerPercent)%")
                    .font(KikariaTypography.number(size: 17))
                    .monospacedDigit()
                    .foregroundStyle(KikariaTheme.sky)
            }

            Picker("进度安全线", selection: $dangerPercent) {
                ForEach(1...100, id: \.self) { percent in
                    Text("\(percent)%")
                        .font(KikariaTypography.chineseBody(size: 18))
                        .tag(percent)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 126)
            .clipped()

            Button(action: onDone) {
                Text("完成")
                    .font(KikariaTypography.chineseButton())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(KikariaTheme.actionGradient, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(maxWidth: 318)
        .background(.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.38), lineWidth: 1)
        }
        .shadow(color: KikariaTheme.sky.opacity(0.18), radius: 24, y: 14)
    }
}

private struct PresetSelectionView: View {
    let presets: [KnowledgePreset]
    @Binding var currentPresetID: String
    let switchPreset: (KnowledgePreset) -> Bool
    let onUploadNewPreset: () -> Void
    let onEditPreset: (KnowledgePreset) -> Void
    @State private var pendingPreset: KnowledgePreset?
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("切换预设")
                        .font(KikariaTypography.chineseTitle())
                        .foregroundStyle(KikariaTheme.deepText)
                        .padding(.top, 18)
                        .padding(.bottom, 2)

                    Button(action: onUploadNewPreset) {
                        HStack {
                            Text("上传新预设")
                                .font(KikariaTypography.chineseButton())
                            Spacer()
                            Image(systemName: "plus")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .background(KikariaTheme.actionGradient, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: KikariaTheme.sky.opacity(0.18), radius: 16, y: 8)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 2)

                    ForEach(presets) { preset in
                        PresetCard(
                            preset: preset,
                            isCurrent: preset.id == currentPresetID,
                            onSelect: {
                                if preset.id != currentPresetID {
                                    pendingPreset = preset
                                }
                            },
                            onEdit: {
                                onEditPreset(preset)
                            }
                        )
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }

            if let toastMessage {
                KikariaToastLayer(message: toastMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationTitle("切换预设")
        .navigationBarTitleDisplayMode(.inline)
        .alert("切换预设？", isPresented: isConfirmingPreset) {
            Button("取消", role: .cancel) {
                pendingPreset = nil
            }

            Button("确认切换", role: .destructive) {
                confirmPresetSwitch()
            }
        } message: {
            Text("将切换到另一套知识点。当前预设的学习进度会被保留。")
        }
    }

    private var isConfirmingPreset: Binding<Bool> {
        Binding(
            get: { pendingPreset != nil },
            set: { isPresented in
                if !isPresented {
                    pendingPreset = nil
                }
            }
        )
    }

    private func confirmPresetSwitch() {
        guard let preset = pendingPreset else {
            return
        }

        pendingPreset = nil

        if switchPreset(preset) {
            showToast("已切换至「\(preset.name)」")
        } else {
            showToast("预设解析失败，请稍后再试")
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

private struct PresetCard: View {
    let preset: KnowledgePreset
    let isCurrent: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(preset.name)
                            .font(KikariaTypography.chineseHeadline(size: 20))
                            .foregroundStyle(KikariaTheme.deepText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        if isCurrent {
                            Text("当前")
                                .font(KikariaTypography.tag(size: 11, weight: .bold))
                                .foregroundStyle(KikariaTheme.sky)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.62), in: Capsule())
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                    }

                    HStack(spacing: 9) {
                        Text(preset.shortName)
                            .font(KikariaTypography.tag(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(KikariaTheme.sky.opacity(0.86), in: Capsule())

                        Text("\(preset.knowledgePointCount) 个知识点")
                            .font(KikariaTypography.tag(size: 12, weight: .semibold))
                            .foregroundStyle(KikariaTheme.softText)
                    }
                }

                Spacer()

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KikariaTheme.deepText)
                        .frame(width: 34, height: 34)
                        .background(.white.opacity(0.56), in: Circle())
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
            }

            Text(preset.description)
                .font(KikariaTypography.chineseBody(size: 14))
                .foregroundStyle(KikariaTheme.softText)
                .lineLimit(2)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture(perform: onSelect)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(isCurrent ? 0.64 : 0.50))
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isCurrent ? KikariaTheme.sky.opacity(0.62) : .white.opacity(0.26), lineWidth: isCurrent ? 1.6 : 1)
        }
        .shadow(color: KikariaTheme.sky.opacity(isCurrent ? 0.15 : 0.09), radius: 18, y: 10)
    }
}

private struct NewPresetView: View {
    @Environment(\.dismiss) private var dismiss
    let createPreset: (String, String, String, String, String) -> PresetCreationOutcome
    @State private var name = ""
    @State private var shortName = ""
    @State private var category = ""
    @State private var description = ""
    @State private var markdownText = ""
    @State private var errorMessage: String?
    @State private var isImportingFile = false
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    private var allowedContentTypes: [UTType] {
        var types: [UTType] = [.plainText, .text]

        if let markdownType = UTType(filenameExtension: "md") {
            types.insert(markdownType, at: 0)
        }

        return types
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

                    Text("上传新预设")
                        .font(KikariaTypography.chineseHeadline())
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Button("保存") {
                        savePreset()
                    }
                    .font(KikariaTypography.chineseButton())
                    .foregroundStyle(KikariaTheme.sky)
                    .frame(width: 42, alignment: .trailing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 16) {
                        ProfileTextField(title: "预设名称", text: $name)
                        ProfileTextField(title: "短名称（最多 3 字）", text: $shortName)
                        ProfileTextField(title: "分类", text: $category)
                        ProfileTextField(title: "简短描述", text: $description)

                        Button {
                            isImportingFile = true
                        } label: {
                            Label("选择 .md / .txt 文件", systemImage: "doc.badge.plus")
                                .font(KikariaTypography.chineseButton())
                                .foregroundStyle(KikariaTheme.deepText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .center) {
                                Text("Markdown 文本")
                                    .font(KikariaTypography.chineseHeadline(size: 14))
                                    .foregroundStyle(KikariaTheme.softText)

                                Spacer()

                                NavigationLink(value: AppRoute.markdownFormatGuide) {
                                    Text("如何编写 Markdown 预设？")
                                        .font(KikariaTypography.chineseCaption(size: 12, weight: .semibold))
                                        .foregroundStyle(KikariaTheme.sky)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(.white.opacity(0.58), in: Capsule())
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                                .buttonStyle(.plain)
                            }

                            TextEditor(text: $markdownText)
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(KikariaTheme.deepText)
                                .scrollContentBackground(.hidden)
                                .padding(14)
                                .frame(minHeight: 260)
                                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: KikariaTheme.sky.opacity(0.10), radius: 14, y: 8)
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(KikariaTypography.chineseBody(size: 14, weight: .semibold))
                                .foregroundStyle(Color(red: 0.72, green: 0.24, blue: 0.24))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(.white.opacity(0.64), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }

            if let toastMessage {
                KikariaToastLayer(message: toastMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: shortName) { newValue in
            let limited = String(newValue.prefix(3))
            if limited != newValue {
                shortName = limited
            }
        }
        .fileImporter(isPresented: $isImportingFile, allowedContentTypes: allowedContentTypes, allowsMultipleSelection: false) { result in
            importMarkdownFile(result)
        }
    }

    private func importMarkdownFile(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                return
            }

            let canAccess = url.startAccessingSecurityScopedResource()
            defer {
                if canAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                markdownText = try String(contentsOf: url, encoding: .utf8)
                errorMessage = nil
            } catch {
                errorMessage = "文件读取失败，请确认它是 UTF-8 文本。"
            }
        case .failure:
            errorMessage = "文件选择失败，请重试。"
        }
    }

    private func savePreset() {
        switch createPreset(name, shortName, category, description, markdownText) {
        case .success(let preset):
            showToast("已创建「\(preset.name)」")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                dismiss()
            }
        case .failure(let message):
            withAnimation(.easeInOut(duration: 0.2)) {
                errorMessage = message
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

private struct MarkdownFormatGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    private static let formatTemplate = """
    # 知识点名称

    tags: 标签1, 标签2, 标签3

    hint:
    这里写提示，可以是一句话，也可以是几行文字。

    content:
    这里写完整答案或背诵内容，可以是一段或多段文字。

    ---
    """

    private static let completeExample = """
    # 极限的保号性

    tags: 高等数学, 极限, 基础

    hint:
    当函数极限大于 0 时，函数值在充分靠近该点时也大于 0。

    content:
    若 lim f(x) = A，且 A > 0，则存在某个去心邻域，使得在该邻域内 f(x) > 0。

    ---

    # 罗尔定理

    tags: 高等数学, 中值定理

    hint:
    闭区间连续，开区间可导，两端函数值相等。

    content:
    若函数 f(x) 在 [a,b] 上连续，在 (a,b) 内可导，且 f(a)=f(b)，则至少存在一点 ξ∈(a,b)，使得 f'(ξ)=0。
    """

    private static let aiPrompt = """
    请你把我提供的学习资料整理成 Kikaria 背诵 App 支持的结构化 Markdown 知识点。

    格式必须严格遵守：

    # 知识点名称

    tags: 标签1, 标签2, 标签3

    hint:
    用简洁语言给出背诵提示，不要直接泄露完整答案。

    content:
    写出完整、准确、适合背诵的知识点内容。

    ---

    要求：
    1. 每个知识点之间必须用单独一行 --- 分隔。
    2. 每个知识点都必须包含标题、tags、hint、content 四部分。
    3. tags 后的标签用逗号分隔。
    4. hint 要简短，适合作为回忆提示。
    5. content 要完整、准确、适合直接背诵。
    6. 不要生成多余解释。
    7. 不要使用表格。
    8. 不要把多个知识点混在一起。
    9. 如果原资料太长，请拆分成多个小知识点。
    10. 输出结果只保留 Markdown 内容，不要添加寒暄或说明。

    下面是需要整理的资料：

    【在这里粘贴课本、讲义、笔记或 OCR 文本】
    """

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

                    Text("Markdown 格式说明")
                        .font(KikariaTypography.chineseHeadline())
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Color.clear
                        .frame(width: 42, height: 42)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        MarkdownGuideCard {
                            Text("Kikaria 使用结构化 Markdown 来导入知识点。每个知识点由标题、标签、提示和答案组成。多个知识点之间使用 --- 分隔。")
                                .font(KikariaTypography.chineseBody(size: 15))
                                .foregroundStyle(KikariaTheme.deepText)
                                .lineSpacing(5)
                        }

                        MarkdownGuideCard(title: "格式规则") {
                            MarkdownCodeBlock(text: Self.formatTemplate)

                            Text("多个知识点之间用一行 --- 分隔。")
                                .font(KikariaTypography.chineseBody(size: 14, weight: .medium))
                                .foregroundStyle(KikariaTheme.softText)
                        }

                        MarkdownGuideCard(title: "规则说明") {
                            VStack(alignment: .leading, spacing: 9) {
                                MarkdownRuleText("标题必须以 # 开头。")
                                MarkdownRuleText("tags: 后面写标签，多个标签用英文逗号或中文逗号分隔。")
                                MarkdownRuleText("hint: 后面写提示。")
                                MarkdownRuleText("content: 后面写完整内容。")
                                MarkdownRuleText("每个知识点之间用单独一行 --- 分隔。")
                                MarkdownRuleText("建议每个知识点不要太长，适合一次背诵。")
                                MarkdownRuleText("标签可以用于后续选择背诵范围。")
                            }
                        }

                        MarkdownGuideCard(title: "完整示例") {
                            MarkdownCodeBlock(text: Self.completeExample)
                        }

                        MarkdownGuideCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .center) {
                                    Text("给 AI 助手的 Prompt")
                                        .font(KikariaTypography.chineseHeadline(size: 18))
                                        .foregroundStyle(KikariaTheme.deepText)

                                    Spacer()

                                    Button {
                                        copyPrompt()
                                    } label: {
                                        Label("复制 Prompt", systemImage: "doc.on.doc")
                                            .font(KikariaTypography.chineseCaption(size: 12, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(KikariaTheme.actionGradient, in: Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }

                                Text("你可以把下面这段 prompt 复制给 AI 助手，并附上你的课本、讲义、笔记或照片识别出的文本，让 AI 帮你整理成 Kikaria 支持的 Markdown 格式。")
                                    .font(KikariaTypography.chineseBody(size: 14))
                                    .foregroundStyle(KikariaTheme.softText)
                                    .lineSpacing(4)

                                MarkdownCodeBlock(text: Self.aiPrompt)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }

            if let toastMessage {
                KikariaToastLayer(message: toastMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func copyPrompt() {
        UIPasteboard.general.string = Self.aiPrompt
        showToast("Prompt 已复制")
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

private struct MarkdownGuideCard<Content: View>: View {
    var title: String?
    @ViewBuilder var content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(KikariaTypography.chineseHeadline(size: 18))
                    .foregroundStyle(KikariaTheme.deepText)
            }

            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 1)
        }
        .shadow(color: KikariaTheme.sky.opacity(0.10), radius: 16, y: 8)
    }
}

private struct MarkdownCodeBlock: View {
    let text: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(text)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundStyle(KikariaTheme.deepText)
                .lineSpacing(4)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
        }
        .background(.white.opacity(0.70), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(KikariaTheme.sky.opacity(0.12), lineWidth: 1)
        }
    }
}

private struct MarkdownRuleText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(KikariaTheme.sky.opacity(0.72))
                .frame(width: 5, height: 5)
                .padding(.top, 8)

            Text(text)
                .font(KikariaTypography.chineseBody(size: 14))
                .foregroundStyle(KikariaTheme.deepText)
                .lineSpacing(4)
        }
    }
}

private struct EditPresetView: View {
    @Environment(\.dismiss) private var dismiss
    let preset: KnowledgePreset
    let knowledgePoints: [KnowledgePoint]
    let onSavePreset: (String, String, String, String, String) -> Void
    let onAddPoint: () -> Void
    let onEditPoint: (UUID) -> Void
    let onDeletePoint: (UUID, String) -> Void
    let onDeletePreset: (String) -> Void
    @State private var name: String
    @State private var shortName: String
    @State private var category: String
    @State private var description: String
    @State private var pendingDeletePoint: KnowledgePoint?
    @State private var isConfirmingPresetDelete = false

    init(
        preset: KnowledgePreset,
        knowledgePoints: [KnowledgePoint],
        onSavePreset: @escaping (String, String, String, String, String) -> Void,
        onAddPoint: @escaping () -> Void,
        onEditPoint: @escaping (UUID) -> Void,
        onDeletePoint: @escaping (UUID, String) -> Void,
        onDeletePreset: @escaping (String) -> Void
    ) {
        self.preset = preset
        self.knowledgePoints = knowledgePoints
        self.onSavePreset = onSavePreset
        self.onAddPoint = onAddPoint
        self.onEditPoint = onEditPoint
        self.onDeletePoint = onDeletePoint
        self.onDeletePreset = onDeletePreset
        _name = State(initialValue: preset.name)
        _shortName = State(initialValue: preset.shortName)
        _category = State(initialValue: preset.category)
        _description = State(initialValue: preset.description)
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

                    Text("编辑预设")
                        .font(KikariaTypography.chineseHeadline())
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Button("保存") {
                        onSavePreset(preset.id, name, shortName, category, description)
                        dismiss()
                    }
                    .font(KikariaTypography.chineseButton())
                    .foregroundStyle(KikariaTheme.sky)
                    .frame(width: 42, alignment: .trailing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 16) {
                        ProfileTextField(title: "预设名称", text: $name)
                        ProfileTextField(title: "短名称（最多 3 字）", text: $shortName)
                        ProfileTextField(title: "分类", text: $category)
                        ProfileTextField(title: "简短描述", text: $description)

                        Button(action: onAddPoint) {
                            Label("添加知识点", systemImage: "plus.circle.fill")
                                .font(KikariaTypography.chineseButton())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(KikariaTheme.actionGradient, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        VStack(spacing: 12) {
                            ForEach(knowledgePoints) { point in
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(point.title)
                                            .font(KikariaTypography.chineseHeadline(size: 16))
                                            .foregroundStyle(KikariaTheme.deepText)

                                        Text(point.tags.joined(separator: ", "))
                                            .font(KikariaTypography.tag(size: 12))
                                            .foregroundStyle(KikariaTheme.softText)
                                            .lineLimit(2)
                                    }

                                    Spacer()

                                    Button {
                                        onEditPoint(point.id)
                                    } label: {
                                        Image(systemName: "pencil")
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(KikariaTheme.sky)
                                            .frame(width: 34, height: 34)
                                            .background(.white.opacity(0.58), in: Circle())
                                    }
                                    .buttonStyle(.plain)

                                    Button {
                                        pendingDeletePoint = point
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(Color(red: 0.72, green: 0.24, blue: 0.24))
                                            .frame(width: 34, height: 34)
                                            .background(.white.opacity(0.58), in: Circle())
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(16)
                                .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                        }

                        if !preset.isBuiltIn {
                            Button(role: .destructive) {
                                isConfirmingPresetDelete = true
                            } label: {
                                Text("删除此预设")
                                    .font(KikariaTypography.chineseButton())
                                    .foregroundStyle(Color(red: 0.72, green: 0.24, blue: 0.24))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 6)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: shortName) { newValue in
            let limited = String(newValue.prefix(3))
            if limited != newValue {
                shortName = limited
            }
        }
        .alert("删除知识点？", isPresented: isConfirmingPointDelete) {
            Button("取消", role: .cancel) {
                pendingDeletePoint = nil
            }

            Button("删除", role: .destructive) {
                if let pendingDeletePoint {
                    onDeletePoint(pendingDeletePoint.id, preset.id)
                }

                pendingDeletePoint = nil
            }
        } message: {
            Text("删除后，该知识点的重点集锦、已掌握和今日复习次数也会一并移除。")
        }
        .alert("删除预设？", isPresented: $isConfirmingPresetDelete) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                onDeletePreset(preset.id)
                dismiss()
            }
        } message: {
            Text("此操作会删除该自定义预设和它的学习状态。")
        }
    }

    private var isConfirmingPointDelete: Binding<Bool> {
        Binding(
            get: { pendingDeletePoint != nil },
            set: { isPresented in
                if !isPresented {
                    pendingDeletePoint = nil
                }
            }
        )
    }
}

private struct EditKnowledgePointView: View {
    @Environment(\.dismiss) private var dismiss
    let presetName: String
    let point: KnowledgePoint?
    let onSave: (KnowledgePoint) -> Void
    @State private var title: String
    @State private var tagsText: String
    @State private var hint: String
    @State private var content: String
    @State private var errorMessage: String?

    init(presetName: String, point: KnowledgePoint?, onSave: @escaping (KnowledgePoint) -> Void) {
        self.presetName = presetName
        self.point = point
        self.onSave = onSave
        _title = State(initialValue: point?.title ?? "")
        _tagsText = State(initialValue: point?.tags.joined(separator: ", ") ?? "")
        _hint = State(initialValue: point?.hint ?? "")
        _content = State(initialValue: point?.content ?? "")
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

                    Text(point == nil ? "添加知识点" : "编辑知识点")
                        .font(KikariaTypography.chineseHeadline())
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Button("保存") {
                        savePoint()
                    }
                    .font(KikariaTypography.chineseButton())
                    .foregroundStyle(KikariaTheme.sky)
                    .frame(width: 42, alignment: .trailing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 16) {
                        Text(presetName)
                            .font(KikariaTypography.chineseTitle(size: 26, weight: .semibold))
                            .foregroundStyle(KikariaTheme.deepText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ProfileTextField(title: "标题", text: $title)
                        ProfileTextField(title: "标签，用逗号分隔", text: $tagsText)

                        EditableLongTextField(title: "提示", text: $hint, minHeight: 150)
                        EditableLongTextField(title: "答案", text: $content, minHeight: 220)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(KikariaTypography.chineseBody(size: 14, weight: .semibold))
                                .foregroundStyle(Color(red: 0.72, green: 0.24, blue: 0.24))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(.white.opacity(0.64), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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

    private func savePoint() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHint = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let tags = tagsText
            .split(whereSeparator: { $0 == "," || $0 == "，" })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !trimmedTitle.isEmpty, !trimmedHint.isEmpty, !trimmedContent.isEmpty else {
            errorMessage = "标题、提示和答案都不能为空。"
            return
        }

        let now = Date()
        let savedPoint = KnowledgePoint(
            id: point?.id ?? UUID(),
            title: trimmedTitle,
            tags: tags,
            hint: trimmedHint,
            content: trimmedContent,
            isReinforced: point?.isReinforced ?? false,
            isMastered: point?.isMastered ?? false,
            createdAt: point?.createdAt ?? now,
            updatedAt: now
        )

        onSave(savedPoint)
        dismiss()
    }
}

private struct EditableLongTextField: View {
    let title: String
    @Binding var text: String
    let minHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(KikariaTypography.chineseHeadline(size: 14))
                .foregroundStyle(KikariaTheme.softText)

            TextEditor(text: $text)
                .font(.system(.body, design: .serif))
                .foregroundStyle(KikariaTheme.deepText)
                .scrollContentBackground(.hidden)
                .padding(14)
                .frame(minHeight: minHeight)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: KikariaTheme.sky.opacity(0.08), radius: 12, y: 7)
        }
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
                        .font(KikariaTypography.chineseHeadline())
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Button("保存") {
                        saveProfile()
                    }
                    .font(KikariaTypography.chineseButton())
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
                                    .font(KikariaTypography.chineseButton(size: 14))
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
        .onChange(of: selectedPhotoItem) { _ in
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
                .font(KikariaTypography.chineseHeadline(size: 14))
                .foregroundStyle(KikariaTheme.softText)

            TextField(title, text: $text)
                .font(KikariaTypography.chineseBody(size: 16))
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
    @Binding var dailyReviewRecords: [KnowledgePoint.ID: DailyReviewRecord]
    @State private var draftText: String
    @State private var errorMessage: String?
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    init(
        markdownText: Binding<String>,
        knowledgePoints: Binding<[KnowledgePoint]>,
        selectedTags: Binding<Set<String>>,
        dailyReviewRecords: Binding<[KnowledgePoint.ID: DailyReviewRecord]>
    ) {
        _markdownText = markdownText
        _knowledgePoints = knowledgePoints
        _selectedTags = selectedTags
        _dailyReviewRecords = dailyReviewRecords
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
                        .font(KikariaTypography.chineseHeadline())
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Button("应用") {
                        applyMarkdown()
                    }
                    .font(KikariaTypography.chineseButton())
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
                            .font(KikariaTypography.chineseBody(size: 14, weight: .semibold))
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
                KikariaToastLayer(message: toastMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
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
                dailyReviewRecords.removeAll()
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
    let countdownDays: Int?
    let presetShortName: String
    @State private var isBreathing = false
    @State private var hasStartedBreathingAnimation = false
    private let orbitDuration: TimeInterval = 150

    var body: some View {
        TimelineView(.animation) { timeline in
            let orbitDegrees = orbitAngle(for: timeline.date)

            ZStack {
                ZStack {
                    MetricBubble(
                        valueText: "\(dailyGoal)",
                        label: "目标",
                        size: 92,
                        colors: [KikariaTheme.cyan, Color(red: 0.73, green: 0.95, blue: 0.90)],
                        opacity: 0.48
                    )
                    .rotationEffect(.degrees(-orbitDegrees))
                    .scaleEffect(isBreathing ? 1.035 : 0.985)
                    .offset(x: -96, y: -68)

                    MetricBubble(
                        valueText: presetShortName,
                        label: "预设",
                        size: 80,
                        colors: [Color(red: 0.75, green: 0.78, blue: 1.0), KikariaTheme.mist],
                        opacity: 0.42
                    )
                    .rotationEffect(.degrees(-orbitDegrees))
                    .scaleEffect(isBreathing ? 0.985 : 1.04)
                    .offset(x: 102, y: -56)

                    MetricBubble(
                        valueText: "\(masteredCount)",
                        label: "已掌握",
                        size: 78,
                        colors: [Color(red: 0.78, green: 0.95, blue: 0.74), KikariaTheme.cyan],
                        opacity: 0.38
                    )
                    .rotationEffect(.degrees(-orbitDegrees))
                    .scaleEffect(isBreathing ? 1.035 : 0.985)
                    .offset(x: 92, y: 80)

                    MetricBubble(
                        valueText: countdownDays.map(String.init) ?? "--",
                        label: "倒数",
                        size: 74,
                        colors: [KikariaTheme.sky, Color.white],
                        opacity: 0.36
                    )
                    .rotationEffect(.degrees(-orbitDegrees))
                    .scaleEffect(isBreathing ? 0.99 : 1.045)
                    .offset(x: -106, y: 78)
                }
                .rotationEffect(.degrees(orbitDegrees))

                Circle()
                    .fill(KikariaTheme.actionGradient)
                    .frame(width: 190, height: 190)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(color: KikariaTheme.sky.opacity(0.28), radius: 28, x: 0, y: 18)
                    .scaleEffect(isBreathing ? 1.018 : 0.992)
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
        }
        .frame(width: 272, height: 260)
        .scaleEffect(isBreathing ? 1.012 : 0.996)
        .offset(y: isBreathing ? -5 : 2)
        .onAppear {
            guard !hasStartedBreathingAnimation else {
                return
            }

            hasStartedBreathingAnimation = true
            withAnimation(.easeInOut(duration: 5.4).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
    }

    private func orbitAngle(for date: Date) -> Double {
        let progress = date.timeIntervalSinceReferenceDate
            .truncatingRemainder(dividingBy: orbitDuration) / orbitDuration
        return progress * 360
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
    let valueText: String
    let label: String
    let size: CGFloat
    let colors: [Color]
    let opacity: Double

    var body: some View {
        ZStack {
            SoftBubble(size: size, colors: colors, opacity: opacity)

            VStack(spacing: 2) {
                Text(valueText)
                    .font(KikariaTypography.chineseHeadline(size: size > 84 ? 24 : 21))
                    .monospacedDigit()
                    .foregroundStyle(KikariaTheme.deepText.opacity(0.86))

                Text(label)
                    .font(KikariaTypography.chineseCaption(size: 11, weight: .semibold))
                    .foregroundStyle(KikariaTheme.softText)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(valueText)")
    }
}

private struct HomeEntryCard: View {
    let title: String
    let countText: String

    var body: some View {
        HStack(spacing: 14) {
            Text(title)
                .font(KikariaTypography.chineseHeadline(size: 20))
                .foregroundStyle(KikariaTheme.deepText)

            Spacer()

            Text(countText)
                .font(KikariaTypography.number(size: 20, weight: .bold))
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
                                .font(KikariaTypography.chineseTitle())
                                .foregroundStyle(KikariaTheme.deepText)

                            Text(selectedTags.isEmpty ? "未选择标签时，会默认使用全部知识点。" : "已选择 \(selectedTags.count) 个标签。")
                                .font(KikariaTypography.chineseBody(size: 15))
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
                        .font(KikariaTypography.chineseButton())
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
            .font(KikariaTypography.tag(size: 13))
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
    @Binding var dailyReviewRecords: [KnowledgePoint.ID: DailyReviewRecord]
    let mode: ReviewMode
    var onReturnHome: (() -> Void)?

    @State private var currentPointID: KnowledgePoint.ID?
    @State private var isShowingHint = false
    @State private var isShowingContent = false
    @State private var reviewQueue: [KnowledgePoint.ID] = []
    @State private var reviewQueueIndex = 0
    @State private var lastQueuePointID: KnowledgePoint.ID?
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

    private var matchingPointIDs: [KnowledgePoint.ID] {
        matchingPoints.map(\.id)
    }

    private var currentTodayReviewCount: Int {
        guard let currentPointID else {
            return 0
        }

        return todayReviewCount(for: currentPointID)
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

                        if isShowingContent {
                            TodayReviewCountPill(count: currentTodayReviewCount)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
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
                                    revealContent()
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
                KikariaToastLayer(message: toastMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(5)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .simultaneousGesture(reviewDragGesture)
        .onAppear {
            if currentPointID == nil {
                rebuildReviewQueue(avoiding: lastQueuePointID)
            }
        }
        .onChange(of: selectedTags) { _ in
            if mode.isNormal {
                rebuildReviewQueue(avoiding: currentPointID)
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

        let dx = translation.width
        let dy = translation.height
        let horizontal = abs(dx)
        let vertical = abs(dy)
        let horizontalThreshold: CGFloat = 80
        let verticalThreshold: CGFloat = 100
        let dominance: CGFloat = 1.4

        if horizontal > horizontalThreshold && horizontal > vertical * dominance {
            if dx > 0 {
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
        } else if vertical > verticalThreshold && vertical > horizontal * dominance {
            if dy < 0 {
                triggerGestureFeedback()
                if isShowingContent {
                    withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                        chooseRandomPoint()
                    }
                } else {
                    withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) {
                        revealContent()
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
                revealContent()
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

    private func chooseRandomPoint() {
        moveToNextInQueue()
    }

    private func rebuildReviewQueue(avoiding avoidedFirstID: KnowledgePoint.ID? = nil) {
        var shuffledIDs = matchingPointIDs.shuffled()

        guard !shuffledIDs.isEmpty else {
            reviewQueue = []
            reviewQueueIndex = 0
            currentPointID = nil
            resetRevealState()
            return
        }

        if let avoidedFirstID,
           shuffledIDs.count > 1,
           shuffledIDs.first == avoidedFirstID,
           let swapIndex = shuffledIDs.firstIndex(where: { $0 != avoidedFirstID }) {
            shuffledIDs.swapAt(0, swapIndex)
        }

        reviewQueue = shuffledIDs
        setCurrentPointFromQueue(at: 0)
    }

    private func moveToNextInQueue() {
        reconcileReviewQueue()

        guard !reviewQueue.isEmpty else {
            rebuildReviewQueue(avoiding: lastQueuePointID)
            return
        }

        let nextIndex: Int
        if let currentPointID,
           let currentIndex = reviewQueue.firstIndex(of: currentPointID) {
            nextIndex = currentIndex + 1
        } else {
            nextIndex = reviewQueueIndex
        }

        if nextIndex < reviewQueue.count {
            setCurrentPointFromQueue(at: nextIndex)
        } else {
            rebuildReviewQueue(avoiding: currentPointID ?? lastQueuePointID)
        }
    }

    private func goBackOrChooseRandom() {
        moveToPreviousInQueue()
    }

    private func moveToPreviousInQueue() {
        reconcileReviewQueue()

        guard !reviewQueue.isEmpty else {
            rebuildReviewQueue(avoiding: lastQueuePointID)
            return
        }

        if let currentPointID,
           let currentIndex = reviewQueue.firstIndex(of: currentPointID) {
            reviewQueueIndex = currentIndex
        }

        if reviewQueue.count == 1 {
            setCurrentPointFromQueue(at: 0)
            return
        }

        let previousIndex = reviewQueueIndex > 0 ? reviewQueueIndex - 1 : reviewQueue.count - 1
        setCurrentPointFromQueue(at: previousIndex)
    }

    private func reconcileReviewQueue() {
        let validIDs = Set(matchingPointIDs)
        reviewQueue = reviewQueue.filter { validIDs.contains($0) }

        if let currentPointID,
           let currentIndex = reviewQueue.firstIndex(of: currentPointID) {
            reviewQueueIndex = currentIndex
        } else if reviewQueueIndex >= reviewQueue.count {
            reviewQueueIndex = max(0, reviewQueue.count - 1)
        }
    }

    private func setCurrentPointFromQueue(at index: Int) {
        guard reviewQueue.indices.contains(index) else {
            rebuildReviewQueue(avoiding: lastQueuePointID)
            return
        }

        reviewQueueIndex = index
        currentPointID = reviewQueue[index]
        lastQueuePointID = currentPointID
        resetRevealState()
    }

    private func resetRevealState() {
        isShowingHint = false
        isShowingContent = false
    }

    private func revealContent() {
        if !isShowingContent, let currentPointID {
            incrementTodayReviewCount(for: currentPointID)
        }

        isShowingContent = true
    }

    private func todayReviewCount(for pointID: KnowledgePoint.ID) -> Int {
        guard let record = dailyReviewRecords[pointID],
              Calendar.current.isDate(record.date, inSameDayAs: Date())
        else {
            return 0
        }

        return record.count
    }

    private func incrementTodayReviewCount(for pointID: KnowledgePoint.ID) {
        let now = Date()

        if let record = dailyReviewRecords[pointID],
           Calendar.current.isDate(record.date, inSameDayAs: now) {
            dailyReviewRecords[pointID] = DailyReviewRecord(
                date: now,
                count: record.count + 1
            )
        } else {
            dailyReviewRecords[pointID] = DailyReviewRecord(date: now, count: 1)
        }
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
                .font(KikariaTypography.chineseButton())
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
                    .font(KikariaTypography.chineseButton())
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
                    .font(KikariaTypography.chineseButton())
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
                                .font(KikariaTypography.chineseTitle())
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
                KikariaToastLayer(message: toastMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
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
                                .font(KikariaTypography.chineseTitle())
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
                KikariaToastLayer(message: toastMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
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
                .font(KikariaTypography.chineseHeadline(size: 20))
                .foregroundStyle(KikariaTheme.deepText)

            Spacer()

            Text("\(count)")
                .font(KikariaTypography.number(size: 20, weight: .bold))
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
                .font(KikariaTypography.chineseHeadline(size: 20))
                .foregroundStyle(KikariaTheme.deepText)

            Spacer()

            Text("\(count)")
                .font(KikariaTypography.number(size: 20, weight: .bold))
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
                    .font(KikariaTypography.chineseButton(size: 14))
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
            .font(KikariaTypography.chineseBody(size: 14, weight: .semibold))
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

private struct KikariaToastLayer: View {
    let message: String

    var body: some View {
        VStack {
            KikariaToast(message: message)
                .padding(.horizontal, 24)
                .padding(.top, 76)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
    }
}

private struct FloatingInfoCard: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(KikariaTypography.chineseHeadline(size: 14, weight: .bold))
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
                    .font(KikariaTypography.tag(size: 12))
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

private struct TodayReviewCountPill: View {
    let count: Int

    var body: some View {
        Text("该知识点今日复习 \(count) 次")
            .font(KikariaTypography.chineseCaption(size: 12, weight: .semibold))
            .foregroundStyle(KikariaTheme.deepText.opacity(0.78))
            .monospacedDigit()
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(.white.opacity(0.54), in: Capsule())
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(KikariaTheme.cyan.opacity(0.32), lineWidth: 1)
            }
            .shadow(color: KikariaTheme.sky.opacity(0.10), radius: 12, y: 6)
            .accessibilityLabel("该知识点今日复习 \(count) 次")
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
                .font(KikariaTypography.chineseHeadline(size: 20, weight: .bold))
                .foregroundStyle(KikariaTheme.deepText)

            Text(subtitle)
                .font(KikariaTypography.chineseBody(size: 15))
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
