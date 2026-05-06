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
    static let nextAmber = Color(red: 0.54, green: 0.49, blue: 0.75)
    static let removeCoral = Color(red: 0.86, green: 0.32, blue: 0.30)
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

    static let nextGradient = LinearGradient(
        colors: [
            Color(red: 0.78, green: 0.72, blue: 0.94),
            Color(red: 0.58, green: 0.53, blue: 0.80)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let removeGradient = LinearGradient(
        colors: [
            Color(red: 0.90, green: 0.38, blue: 0.35),
            Color(red: 0.98, green: 0.58, blue: 0.50)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

private struct LiquidGlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let material: Material
    let fillOpacity: Double
    let strokeOpacity: Double
    let shadowOpacity: Double
    let shadowRadius: CGFloat
    let shadowY: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .background {
                shape
                    .fill(Color.white.opacity(fillOpacity))
            }
            .background(material, in: shape)
            .overlay {
                shape
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(strokeOpacity),
                                Color.white.opacity(strokeOpacity * 0.28),
                                KikariaTheme.sky.opacity(0.13)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .overlay {
                shape
                    .stroke(Color.white.opacity(0.18), lineWidth: 0.5)
                    .blur(radius: 0.4)
                    .offset(y: 0.5)
                    .mask(shape)
            }
            .shadow(color: KikariaTheme.sky.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: shadowY)
            .shadow(color: Color.black.opacity(0.025), radius: shadowRadius * 0.55, x: 0, y: shadowY * 0.55)
    }
}

private struct LiquidGlassCapsuleModifier: ViewModifier {
    let material: Material
    let fillOpacity: Double
    let strokeOpacity: Double
    let shadowOpacity: Double
    let shadowRadius: CGFloat
    let shadowY: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                Capsule()
                    .fill(Color.white.opacity(fillOpacity))
            }
            .background(material, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(strokeOpacity),
                                Color.white.opacity(strokeOpacity * 0.28),
                                KikariaTheme.cyan.opacity(0.16)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: KikariaTheme.sky.opacity(shadowOpacity), radius: shadowRadius, y: shadowY)
    }
}

private struct LiquidGlassCircleModifier: ViewModifier {
    let material: Material
    let fillOpacity: Double
    let strokeOpacity: Double
    let shadowOpacity: Double
    let shadowRadius: CGFloat
    let shadowY: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                Circle()
                    .fill(Color.white.opacity(fillOpacity))
            }
            .background(material, in: Circle())
            .overlay {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(strokeOpacity),
                                Color.white.opacity(strokeOpacity * 0.22),
                                KikariaTheme.sky.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: KikariaTheme.sky.opacity(shadowOpacity), radius: shadowRadius, y: shadowY)
    }
}

private extension View {
    func liquidGlassCard(
        cornerRadius: CGFloat = 28,
        material: Material = .ultraThinMaterial,
        fillOpacity: Double = 0.48,
        strokeOpacity: Double = 0.42,
        shadowOpacity: Double = 0.12,
        shadowRadius: CGFloat = 18,
        shadowY: CGFloat = 10
    ) -> some View {
        modifier(
            LiquidGlassCardModifier(
                cornerRadius: cornerRadius,
                material: material,
                fillOpacity: fillOpacity,
                strokeOpacity: strokeOpacity,
                shadowOpacity: shadowOpacity,
                shadowRadius: shadowRadius,
                shadowY: shadowY
            )
        )
    }

    func liquidGlassCapsule(
        material: Material = .ultraThinMaterial,
        fillOpacity: Double = 0.48,
        strokeOpacity: Double = 0.42,
        shadowOpacity: Double = 0.10,
        shadowRadius: CGFloat = 14,
        shadowY: CGFloat = 7
    ) -> some View {
        modifier(
            LiquidGlassCapsuleModifier(
                material: material,
                fillOpacity: fillOpacity,
                strokeOpacity: strokeOpacity,
                shadowOpacity: shadowOpacity,
                shadowRadius: shadowRadius,
                shadowY: shadowY
            )
        )
    }

    func liquidGlassCircle(
        material: Material = .ultraThinMaterial,
        fillOpacity: Double = 0.44,
        strokeOpacity: Double = 0.42,
        shadowOpacity: Double = 0.14,
        shadowRadius: CGFloat = 14,
        shadowY: CGFloat = 7
    ) -> some View {
        modifier(
            LiquidGlassCircleModifier(
                material: material,
                fillOpacity: fillOpacity,
                strokeOpacity: strokeOpacity,
                shadowOpacity: shadowOpacity,
                shadowRadius: shadowRadius,
                shadowY: shadowY
            )
        )
    }

    @ViewBuilder
    func highPriorityGestureIf<GestureType: Gesture>(_ isActive: Bool, _ gesture: GestureType) -> some View {
        if isActive {
            highPriorityGesture(gesture)
        } else {
            self
        }
    }
}

private enum AppRoute: Hashable {
    case scope
    case review
    case todayOverview
    case reviewHistory
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

private struct UserProfile: Codable, Equatable {
    var displayName = "Vita"
    var userHandle = "vita_0818"
    var avatarSystemName = "person.crop.circle.fill"
    var avatarImageData: Data?
}

struct DailyReviewRecord: Codable, Equatable {
    var date: Date
    var count: Int
}

private func studyProgressNotificationBody(for presetName: String) -> String {
    "今天的「\(presetName)」学习量尚未达标哦，抓紧学习吧。"
}

private struct PresetStudyState: Codable {
    let presetId: String
    var knowledgePoints: [KnowledgePoint]
    var markdownText: String
    var selectedTags: Set<String>
    var dailyReviewRecords: [KnowledgePoint.ID: DailyReviewRecord]
    var activityRecords: [StudyActivityRecord]
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
        activityRecords: [StudyActivityRecord] = [],
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
        self.activityRecords = activityRecords
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
        case activityRecords
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
        activityRecords = try container.decodeIfPresent([StudyActivityRecord].self, forKey: .activityRecords) ?? []
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
        try container.encode(activityRecords, forKey: .activityRecords)
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

private struct KikariaAppState: Codable {
    static let storageKey = "kikaria.appStateJSON"
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var presets: [KnowledgePreset]
    var presetStates: [String: PresetStudyState]
    var currentPresetID: String
    var userProfile: UserProfile
    var hasCompletedOnboarding: Bool

    init(
        schemaVersion: Int = KikariaAppState.currentSchemaVersion,
        presets: [KnowledgePreset],
        presetStates: [String: PresetStudyState],
        currentPresetID: String,
        userProfile: UserProfile,
        hasCompletedOnboarding: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.presets = presets
        self.presetStates = presetStates
        self.currentPresetID = currentPresetID
        self.userProfile = userProfile
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case presets
        case presetStates
        case currentPresetID
        case userProfile
        case hasCompletedOnboarding
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 0
        presets = try container.decodeIfPresent([KnowledgePreset].self, forKey: .presets) ?? KnowledgePreset.all
        presetStates = try container.decodeIfPresent([String: PresetStudyState].self, forKey: .presetStates) ?? [:]
        currentPresetID = try container.decodeIfPresent(String.self, forKey: .currentPresetID) ?? KnowledgePreset.defaultPresetID
        userProfile = try container.decodeIfPresent(UserProfile.self, forKey: .userProfile) ?? UserProfile()
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
    }
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

    func body(for presetName: String) -> String {
        studyProgressNotificationBody(for: presetName)
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

    static func cancelAllKikariaStudyNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests
                .map(\.identifier)
                .filter { $0.hasPrefix("kikaria.studyProgressWarning.") }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    static func rescheduleAllStudyProgressWarnings(
        for states: [String: PresetStudyState],
        presetNames: [String: String]
    ) {
        for state in states.values {
            rescheduleStudyProgressWarning(
                for: state,
                presetName: presetNames[state.presetId] ?? "当前预设"
            )
        }
    }

    static func rescheduleStudyProgressWarning(for state: PresetStudyState, presetName: String) {
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
            content.title = "Kikaria"
            content.body = warning.body(for: presetName)
            content.sound = .default

            let triggerDate = nextTriggerDate(for: state.notificationTime)
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
        }
    }

    static func scheduleDebugTestNotification(presetName: String, completion: @escaping (String) -> Void) {
        #if DEBUG
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                scheduleAuthorizedDebugTestNotification(presetName: presetName, completion: completion)
            case .notDetermined:
                requestAuthorization { granted in
                    if granted {
                        scheduleAuthorizedDebugTestNotification(presetName: presetName, completion: completion)
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

    private static func scheduleAuthorizedDebugTestNotification(presetName: String, completion: @escaping (String) -> Void) {
        #if DEBUG
        let center = UNUserNotificationCenter.current()
        let identifier = "kikaria.test.notification"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Kikaria"
        content.body = studyProgressNotificationBody(for: presetName)
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
                    completion("提醒将在 5 秒后发送")
                } else {
                    completion("提醒发送失败")
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
    @State private var activityRecords: [StudyActivityRecord] = []
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
    @State private var hasCompletedOnboarding = false
    @State private var isShowingOnboarding = false

    private var allTags: [String] {
        Array(Set(knowledgePoints.flatMap(\.tags))).sorted()
    }

    private var selectedScopeCountText: String {
        selectedTags.isEmpty ? "\(allTags.count)" : "\(selectedTags.count)"
    }

    private var reinforcedCount: Int {
        knowledgePoints.filter { $0.reinforcementCount > 0 }.count
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

    private var currentPresetActivityRecords: [StudyActivityRecord] {
        activityRecords.filter { $0.presetId == currentPresetID }
    }

    private var todayReviewedAnswerCount: Int {
        records(on: Date(), type: .reviewedAnswer).count
    }

    private var todayMarkedMasteredCount: Int {
        Set(records(on: Date(), type: .markedMastered).map(\.pointId)).count
    }

    private var homeDateTitle: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"

        let day = Calendar.current.component(.day, from: date)
        return "\(formatter.string(from: date)) \(day)\(ordinalSuffix(for: day))"
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

                        Spacer(minLength: 16)

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
                            countdownDays: countdownDayCount
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("开始背诵")

                    Spacer(minLength: 30)

                    VStack(spacing: 12) {
                        NavigationLink(value: AppRoute.todayOverview) {
                            TodayOverviewHomeProgressButton(
                                dateText: homeDateTitle,
                                daysLeftText: "\(countdownDayCount.map(String.init) ?? "--") Days Left",
                                progressText: "\(todayMarkedMasteredCount)/\(dailyGoal)"
                            )
                        }
                        .buttonStyle(.plain)

                        HomeDashboardGridCard(
                            scopeCountText: selectedScopeCountText,
                            reinforcedCount: reinforcedCount,
                            masteredCount: masteredCount,
                            presetName: currentPreset.name
                        )
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
                        knowledgePoints: knowledgePoints,
                        allTags: allTags
                    )
                case .review:
                    ReviewView(
                        knowledgePoints: $knowledgePoints,
                        selectedTags: $selectedTags,
                        dailyReviewRecords: $dailyReviewRecords,
                        mode: .normal,
                        onRecordActivity: recordStudyActivity
                    )
                case .todayOverview:
                    TodayOverviewView(
                        presetName: currentPreset.name,
                        activityRecords: currentPresetActivityRecords,
                        knowledgePoints: knowledgePoints,
                        dailyGoal: dailyGoal,
                        countdownEndDate: countdownEndDate,
                        onOpenHistory: {
                            navigationPath.append(.reviewHistory)
                        }
                    )
                case .reviewHistory:
                    ReviewHistoryView(
                        activityRecords: currentPresetActivityRecords
                    )
                case .reinforcement:
                    ReinforcementView(
                        knowledgePoints: $knowledgePoints,
                        onRecordActivity: recordStudyActivity,
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
                        onRecordActivity: recordStudyActivity,
                        onReturnHome: {
                            navigationPath.removeAll()
                        }
                    )
                case .mastered:
                    MasteredView(
                        knowledgePoints: $knowledgePoints,
                        onRecordActivity: recordStudyActivity,
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
                        onRecordActivity: recordStudyActivity,
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
                        onOpenOnboarding: {
                            isShowingOnboarding = true
                        },
                        onOpenMarkdownGuide: {
                            navigationPath.append(.markdownFormatGuide)
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
                if !hasCompletedOnboarding {
                    isShowingOnboarding = true
                }
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
            .onChange(of: activityRecords) { _ in
                persistCurrentStudyStateIfReady()
            }
            .onChange(of: userProfile) { _ in
                saveAppStateIfReady()
            }
            .onChange(of: hasCompletedOnboarding) { _ in
                saveAppStateIfReady()
            }
            .onChange(of: markdownText) { _ in
                persistCurrentStudyStateIfReady()
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    rescheduleAllPresetNotifications()
                } else if phase == .inactive || phase == .background {
                    saveAppStateIfReady()
                }
            }
            .fullScreenCover(isPresented: $isShowingOnboarding) {
                OnboardingView {
                    hasCompletedOnboarding = true
                    isShowingOnboarding = false
                }
                .interactiveDismissDisabled(!hasCompletedOnboarding)
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
        loadAppState()

        guard let state = studyState(for: currentPreset) else {
            return
        }

        presetStates[currentPresetID] = state
        restorePresetState(state)
        rescheduleAllPresetNotifications()
    }

    private func switchToPreset(_ preset: KnowledgePreset) -> Bool {
        guard let targetState = studyState(for: preset) else {
            return false
        }

        saveCurrentPresetState()

        withAnimation(.spring(response: 0.36, dampingFraction: 0.9)) {
            if presetStates[preset.id] == nil {
                presetStates[preset.id] = targetState
            }

            restorePresetState(targetState)
        }

        persistLibrary()
        rescheduleAllPresetNotifications()
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
            activityRecords: [],
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
            activityRecords: activityRecords,
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
        activityRecords = state.activityRecords.filter { record in
            state.knowledgePoints.contains { $0.id == record.pointId }
        }
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
            rescheduleAllPresetNotifications()
            updateWidgetSnapshot()
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
        updateWidgetSnapshot()
    }

    private func updateCountdownRange(startDate: Date?, endDate: Date?) {
        countdownStartDate = startDate
        countdownEndDate = endDate
        presetStates[currentPresetID] = currentPresetStateSnapshot()
        persistLibrary()
        rescheduleAllPresetNotifications()
        updateWidgetSnapshot()
    }

    private func updateNotificationsEnabled(_ newValue: Bool, completion: @escaping (Bool, String?) -> Void) {
        if newValue {
            KikariaNotificationManager.requestAuthorization { granted in
                notificationsEnabled = granted
                presetStates[currentPresetID] = currentPresetStateSnapshot()
                persistLibrary()
                rescheduleAllPresetNotifications()
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
        rescheduleAllPresetNotifications()
        updateWidgetSnapshot()
    }

    private func updateDangerPercent(_ newValue: Int) {
        dangerPercent = clampedDangerPercent(newValue)
        presetStates[currentPresetID] = currentPresetStateSnapshot()
        persistLibrary()
        rescheduleAllPresetNotifications()
    }

    private func sendDebugTestNotification(completion: @escaping (String) -> Void) {
        KikariaNotificationManager.scheduleDebugTestNotification(
            presetName: currentPreset.name,
            completion: completion
        )
    }

    private func dailyGoal(forPresetID presetID: String) -> Int {
        if let goal = presetStates[presetID]?.dailyGoal {
            return clampedDailyGoal(goal)
        }

        if presetID == KnowledgePreset.defaultPresetID {
            return clampedDailyGoal(legacyDailyGoalValue())
        }

        return 20
    }

    private func legacyDailyGoalValue() -> Int {
        if let value = UserDefaults.standard.object(forKey: "dailyLearningGoal") as? Int {
            return value
        }

        return 20
    }

    private func persistCurrentStudyStateIfReady() {
        guard hasLoadedInitialPresetState, !isApplyingPresetState else {
            return
        }

        presetStates[currentPresetID] = currentPresetStateSnapshot()
        persistLibrary()
        rescheduleAllPresetNotifications()
    }

    private func loadAppState() {
        let defaults = UserDefaults.standard

        if let data = defaults.data(forKey: KikariaAppState.storageKey) {
            do {
                let appState = try JSONDecoder().decode(KikariaAppState.self, from: data)
                applyLoadedAppState(appState)
                #if DEBUG
                print("Kikaria app state loaded")
                #endif
                return
            } catch {
                #if DEBUG
                print("Kikaria app state decode failed: \(error)")
                #endif
            }
        }

        if let legacyEncodedLibrary = defaults.string(forKey: "presetLibraryJSON"),
           let data = legacyEncodedLibrary.data(using: .utf8),
           let snapshot = try? JSONDecoder().decode(PresetLibrarySnapshot.self, from: data),
           !snapshot.presets.isEmpty {
            presets = mergedPresets(with: snapshot.presets)
            presetStates = snapshot.presetStates
            if presets.contains(where: { $0.id == snapshot.currentPresetID }) {
                currentPresetID = snapshot.currentPresetID
            } else {
                currentPresetID = presets.first?.id ?? KnowledgePreset.defaultPresetID
            }
        } else {
            presets = KnowledgePreset.all
            presetStates = [:]
            currentPresetID = KnowledgePreset.defaultPresetID
        }

        if let completed = defaults.object(forKey: "hasCompletedOnboarding") as? Bool {
            hasCompletedOnboarding = completed
        }

        userProfile = UserProfile()
        ensurePresetStatesExist()
        #if DEBUG
        print("Kikaria app state loaded")
        #endif
    }

    private func applyLoadedAppState(_ appState: KikariaAppState) {
        presets = mergedPresets(with: appState.presets)
        presetStates = appState.presetStates
        userProfile = appState.userProfile
        hasCompletedOnboarding = appState.hasCompletedOnboarding

        if presets.contains(where: { $0.id == appState.currentPresetID }) {
            currentPresetID = appState.currentPresetID
        } else {
            currentPresetID = presets.first?.id ?? KnowledgePreset.defaultPresetID
        }

        ensurePresetStatesExist()
    }

    private func ensurePresetStatesExist() {
        let validPresetIDs = Set(presets.map(\.id))
        presetStates = presetStates.filter { validPresetIDs.contains($0.key) }

        for preset in presets where presetStates[preset.id] == nil {
            if let state = initialStudyState(for: preset) {
                presetStates[preset.id] = state
            }
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
        saveAppState()
    }

    private func saveAppStateIfReady() {
        guard hasLoadedInitialPresetState, !isApplyingPresetState else {
            return
        }

        saveAppState()
    }

    private func saveAppState() {
        var states = presetStates

        if hasLoadedInitialPresetState {
            states[currentPresetID] = currentPresetStateSnapshot()
        }

        let appState = KikariaAppState(
            presets: presets,
            presetStates: states,
            currentPresetID: currentPresetID,
            userProfile: userProfile,
            hasCompletedOnboarding: hasCompletedOnboarding
        )

        do {
            let data = try JSONEncoder().encode(appState)
            UserDefaults.standard.set(data, forKey: KikariaAppState.storageKey)
            #if DEBUG
            print("Kikaria app state saved")
            #endif
        } catch {
            #if DEBUG
            print("Kikaria app state save failed: \(error)")
            #endif
        }
    }

    private func createPreset(name: String, category: String, description: String, markdownText: String) -> PresetCreationOutcome {
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
            activityRecords: [],
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

    private func updatePresetMetadata(presetID: String, name: String, category: String, description: String) {
        guard let index = presets.firstIndex(where: { $0.id == presetID }) else {
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        presets[index].name = trimmedName.isEmpty ? presets[index].name : trimmedName
        presets[index].category = trimmedCategory.isEmpty ? "自定义" : trimmedCategory
        presets[index].subtitle = trimmedDescription.isEmpty ? presets[index].subtitle : trimmedDescription
        presets[index].description = trimmedDescription.isEmpty ? presets[index].description : trimmedDescription
        persistLibrary()
        rescheduleAllPresetNotifications()
        if presetID == currentPresetID {
            updateWidgetSnapshot()
        }
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
            rescheduleAllPresetNotifications()
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
        state.activityRecords.removeAll { $0.pointId == pointID }
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
            rescheduleAllPresetNotifications()
        }
        updateWidgetSnapshot()
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

    private func rescheduleAllPresetNotifications() {
        guard hasLoadedInitialPresetState else {
            return
        }

        var states = presetStates
        states[currentPresetID] = currentPresetStateSnapshot()
        let presetNames = Dictionary(uniqueKeysWithValues: presets.map { ($0.id, $0.name) })
        KikariaNotificationManager.rescheduleAllStudyProgressWarnings(for: states, presetNames: presetNames)
    }

    private func records(on date: Date, type: StudyActivityType? = nil) -> [StudyActivityRecord] {
        currentPresetActivityRecords.filter { record in
            Calendar.current.isDate(record.date, inSameDayAs: date) &&
                (type == nil || record.type == type)
        }
    }

    private func ordinalSuffix(for day: Int) -> String {
        let lastTwoDigits = day % 100
        if lastTwoDigits == 11 || lastTwoDigits == 12 || lastTwoDigits == 13 {
            return "th"
        }

        switch day % 10 {
        case 1:
            return "st"
        case 2:
            return "nd"
        case 3:
            return "rd"
        default:
            return "th"
        }
    }

    private func recordStudyActivity(_ type: StudyActivityType, point: KnowledgePoint) {
        activityRecords.append(
            StudyActivityRecord(
                presetId: currentPresetID,
                type: type,
                pointId: point.id,
                pointTitle: point.title
            )
        )
    }

    private func updateWidgetSnapshot() {
        WidgetDataStore.save(
            WidgetSnapshot(
                presetName: currentPreset.name,
                masteredCount: masteredCount,
                dailyGoal: dailyGoal,
                countdownDays: countdownDayCount,
                todayReviewCount: todayReviewedAnswerCount,
                lastUpdated: Date()
            )
        )
    }

}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

private struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var selectedPage = 0

    private let pages = [
        OnboardingPage(
            title: "选择一套预设",
            subtitle: "从高等数学、英语、医学等预设开始，也可以上传自己的 Markdown 知识点。",
            systemImage: "books.vertical.fill"
        ),
        OnboardingPage(
            title: "先回忆，再查看",
            subtitle: "背诵时先看知识点名称，必要时查看提示，再查看答案。",
            systemImage: "lightbulb.max.fill"
        ),
        OnboardingPage(
            title: "整理你的学习状态",
            subtitle: "把不熟的内容加入重点集锦，把已经掌握的内容标记为已掌握。",
            systemImage: "checkmark.seal.fill"
        )
    ]

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            VStack(spacing: 28) {
                HStack {
                    Text("Kikaria")
                        .font(KikariaTypography.appTitle(size: 36))
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)

                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageCard(page: page)
                            .tag(index)
                            .padding(.horizontal, 28)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))

                Button {
                    if selectedPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                            selectedPage += 1
                        }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(selectedPage == pages.count - 1 ? "开始使用" : "下一步")
                        .font(KikariaTypography.chineseButton(size: 18))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(KikariaTheme.actionGradient, in: Capsule())
                        .shadow(color: KikariaTheme.sky.opacity(0.22), radius: 18, y: 10)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
            }
        }
    }
}

private struct OnboardingPageCard: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 26) {
            ZStack {
                Circle()
                    .fill(KikariaTheme.actionGradient)
                    .frame(width: 132, height: 132)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(color: KikariaTheme.sky.opacity(0.20), radius: 24, y: 14)

                Circle()
                    .fill(.white.opacity(0.24))
                    .frame(width: 86, height: 86)
                    .offset(x: 28, y: -26)

                Image(systemName: page.systemImage)
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.96))
            }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(KikariaTypography.chineseTitle(size: 29, weight: .bold))
                    .foregroundStyle(KikariaTheme.deepText)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(KikariaTypography.chineseBody(size: 16, weight: .medium))
                    .foregroundStyle(KikariaTheme.softText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 44)
        .frame(maxWidth: .infinity, maxHeight: 430)
        .liquidGlassCard(cornerRadius: 34, fillOpacity: 0.50, strokeOpacity: 0.48, shadowOpacity: 0.13, shadowRadius: 24, shadowY: 14)
    }
}

private extension KnowledgePoint {
    func matchesSearchQuery(_ query: String) -> Bool {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return true
        }

        let searchableFields = [
            title,
            tags.joined(separator: " "),
            hint,
            content
        ]

        return searchableFields.contains { field in
            field.range(
                of: trimmedQuery,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) != nil
        }
    }
}

private struct KikariaSearchBar: View {
    @Binding var text: String
    var placeholder = "搜索知识点"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KikariaTheme.blueGray)

            TextField(placeholder, text: $text)
                .font(KikariaTypography.chineseBody(size: 15, weight: .medium))
                .foregroundStyle(KikariaTheme.deepText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KikariaTheme.blueGray.opacity(0.75))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 50)
        .liquidGlassCard(cornerRadius: 22, fillOpacity: 0.44, strokeOpacity: 0.40, shadowOpacity: 0.08, shadowRadius: 12, shadowY: 7)
    }
}

private struct ShareFile: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private func sanitizedFilename(_ name: String) -> String {
    let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        .union(.newlines)
    let components = name.components(separatedBy: invalidCharacters)
    let sanitized = components.joined(separator: "-")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    return sanitized.isEmpty ? "预设" : sanitized
}

private struct ActivitySummary {
    let viewedHintCount: Int
    let reviewedAnswerCount: Int
    let markedMasteredCount: Int
    let addedReinforcementCount: Int
    let removedMasteredCount: Int
    let removedReinforcementCount: Int

    var totalCount: Int {
        viewedHintCount + reviewedAnswerCount + markedMasteredCount + addedReinforcementCount + removedMasteredCount + removedReinforcementCount
    }

    static func make(from records: [StudyActivityRecord]) -> ActivitySummary {
        ActivitySummary(
            viewedHintCount: records.filter { $0.type == .viewedHint }.count,
            reviewedAnswerCount: records.filter { $0.type == .reviewedAnswer }.count,
            markedMasteredCount: Set(records.filter { $0.type == .markedMastered }.map(\.pointId)).count,
            addedReinforcementCount: records.filter { $0.type == .addedReinforcement }.count,
            removedMasteredCount: records.filter { $0.type == .removedMastered }.count,
            removedReinforcementCount: records.filter { $0.type == .removedReinforcement }.count
        )
    }
}

private struct TodayOverviewView: View {
    let presetName: String
    let activityRecords: [StudyActivityRecord]
    let knowledgePoints: [KnowledgePoint]
    let dailyGoal: Int
    let countdownEndDate: Date?
    let onOpenHistory: () -> Void

    private var todayRecords: [StudyActivityRecord] {
        activityRecords.filter { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
    }

    private var todaySummary: ActivitySummary {
        ActivitySummary.make(from: todayRecords)
    }

    private var masteredTotal: Int {
        knowledgePoints.filter(\.isMastered).count
    }

    private var remainingToGoal: Int {
        max(0, dailyGoal - todaySummary.markedMasteredCount)
    }

    private var progressMessage: String {
        if todaySummary.markedMasteredCount >= dailyGoal {
            return "今日目标已经达成，保持这份节奏就很好。"
        }

        if todaySummary.reviewedAnswerCount > 0 {
            return "今日已经进入状态，还差 \(remainingToGoal) 个新增掌握达到目标。"
        }

        return "今天还很安静，可以从一个知识点开始。"
    }

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("今日概览")
                            .font(KikariaTypography.chineseTitle())
                            .foregroundStyle(KikariaTheme.deepText)

                        Text(presetName)
                            .font(KikariaTypography.chineseBody(size: 15, weight: .medium))
                            .foregroundStyle(KikariaTheme.softText)
                    }
                    .padding(.top, 18)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("今日新增已掌握")
                            .font(KikariaTypography.chineseHeadline(size: 15))
                            .foregroundStyle(KikariaTheme.softText)

                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(todaySummary.markedMasteredCount)")
                                .font(KikariaTypography.number(size: 58, weight: .bold))
                                .monospacedDigit()
                                .foregroundStyle(KikariaTheme.masteredDeepGreen)

                            Text("/ \(dailyGoal)")
                                .font(KikariaTypography.number(size: 24, weight: .semibold))
                                .foregroundStyle(KikariaTheme.softText)
                        }

                        Text(progressMessage)
                            .font(KikariaTypography.chineseBody(size: 15, weight: .medium))
                            .foregroundStyle(KikariaTheme.deepText.opacity(0.82))
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .liquidGlassCard(cornerRadius: 30, fillOpacity: 0.48, strokeOpacity: 0.46, shadowOpacity: 0.13, shadowRadius: 22, shadowY: 12)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        OverviewMetricCard(title: "查看答案", value: "\(todaySummary.reviewedAnswerCount)", detail: "今日次数")
                        OverviewMetricCard(title: "总已掌握", value: "\(masteredTotal)", detail: "当前清单")
                        OverviewMetricCard(title: "查看提示", value: "\(todaySummary.viewedHintCount)", detail: "今日次数")
                        OverviewMetricCard(title: "倒数", value: countdownText(for: countdownEndDate), detail: "距结束日")
                    }

                    Button(action: onOpenHistory) {
                        HStack(spacing: 12) {
                            Text("复习历史")
                                .font(KikariaTypography.chineseHeadline(size: 18))
                                .foregroundStyle(KikariaTheme.deepText)

                            Spacer()

                            Image(systemName: "calendar")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(KikariaTheme.sky)

                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KikariaTheme.blueGray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 19)
                        .liquidGlassCard(cornerRadius: 26, fillOpacity: 0.46, strokeOpacity: 0.42, shadowOpacity: 0.12, shadowRadius: 18, shadowY: 10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("今日概览")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct OverviewMetricCard: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(KikariaTypography.chineseCaption(size: 13, weight: .semibold))
                .foregroundStyle(KikariaTheme.softText)

            Text(value)
                .font(KikariaTypography.number(size: 25, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(KikariaTheme.deepText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(detail)
                .font(KikariaTypography.chineseCaption(size: 12, weight: .medium))
                .foregroundStyle(KikariaTheme.blueGray)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlassCard(cornerRadius: 24, material: .thinMaterial, fillOpacity: 0.42, strokeOpacity: 0.36, shadowOpacity: 0.08, shadowRadius: 14, shadowY: 8)
    }
}

private struct ReviewHistoryView: View {
    let activityRecords: [StudyActivityRecord]
    @State private var visibleMonth = Date()
    @State private var selectedDate = Date()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekdaySymbols = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        ZStack {
            KikariaTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("复习历史")
                        .font(KikariaTypography.chineseTitle())
                        .foregroundStyle(KikariaTheme.deepText)
                        .padding(.top, 18)

                    VStack(spacing: 18) {
                        HStack {
                            Button {
                                changeMonth(by: -1)
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(KikariaTheme.sky)
                                    .frame(width: 40, height: 40)
                                    .liquidGlassCircle(fillOpacity: 0.36, strokeOpacity: 0.36, shadowOpacity: 0.06, shadowRadius: 8, shadowY: 4)
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            Text(monthTitle)
                                .font(KikariaTypography.chineseHeadline(size: 20))
                                .foregroundStyle(KikariaTheme.deepText)

                            Spacer()

                            Button {
                                changeMonth(by: 1)
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(KikariaTheme.sky)
                                    .frame(width: 40, height: 40)
                                    .liquidGlassCircle(fillOpacity: 0.36, strokeOpacity: 0.36, shadowOpacity: 0.06, shadowRadius: 8, shadowY: 4)
                            }
                            .buttonStyle(.plain)
                        }

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(weekdaySymbols, id: \.self) { symbol in
                                Text(symbol)
                                    .font(KikariaTypography.chineseCaption(size: 12, weight: .semibold))
                                    .foregroundStyle(KikariaTheme.softText)
                                    .frame(maxWidth: .infinity)
                            }

                            ForEach(Array(monthCells.enumerated()), id: \.offset) { _, date in
                                HistoryCalendarDayCell(
                                    date: date,
                                    count: date.map(recordCount(on:)) ?? 0,
                                    isToday: date.map { Calendar.current.isDateInToday($0) } ?? false,
                                    isSelected: date.map { Calendar.current.isDate($0, inSameDayAs: selectedDate) } ?? false
                                ) {
                                    if let date {
                                        selectedDate = date
                                    }
                                }
                            }
                        }
                    }
                    .padding(18)
                    .liquidGlassCard(cornerRadius: 30, fillOpacity: 0.44, strokeOpacity: 0.42, shadowOpacity: 0.12, shadowRadius: 20, shadowY: 12)

                    HistoryDaySummaryCard(date: selectedDate, summary: ActivitySummary.make(from: records(on: selectedDate)))
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("复习历史")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var monthTitle: String {
        let components = Calendar.current.dateComponents([.year, .month], from: visibleMonth)
        return "\(components.year ?? 0)年 \(components.month ?? 1)月"
    }

    private var monthCells: [Date?] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: visibleMonth)
        guard let monthStart = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: monthStart)
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingBlankCount = (firstWeekday + 5) % 7
        var cells = Array<Date?>(repeating: nil, count: leadingBlankCount)

        for day in range {
            cells.append(calendar.date(byAdding: .day, value: day - 1, to: monthStart))
        }

        while cells.count % 7 != 0 {
            cells.append(nil)
        }

        return cells
    }

    private func changeMonth(by offset: Int) {
        visibleMonth = Calendar.current.date(byAdding: .month, value: offset, to: visibleMonth) ?? visibleMonth
    }

    private func records(on date: Date) -> [StudyActivityRecord] {
        activityRecords.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private func recordCount(on date: Date) -> Int {
        records(on: date).count
    }
}

private struct HistoryCalendarDayCell: View {
    let date: Date?
    let count: Int
    let isToday: Bool
    let isSelected: Bool
    let action: () -> Void

    private var fillColor: Color {
        switch count {
        case 0:
            return .white.opacity(0.42)
        case 1...2:
            return KikariaTheme.cyan.opacity(0.42)
        case 3...5:
            return KikariaTheme.sky.opacity(0.54)
        default:
            return KikariaTheme.masteredGreen.opacity(0.62)
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(date == nil ? Color.clear : fillColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                isSelected ? KikariaTheme.deepText.opacity(0.45) : (isToday ? KikariaTheme.sky.opacity(0.65) : .clear),
                                lineWidth: isSelected ? 2 : 1.4
                            )
                    }

                if let date {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(KikariaTypography.number(size: 12, weight: .semibold))
                        .foregroundStyle(KikariaTheme.deepText.opacity(count == 0 ? 0.58 : 0.86))
                }
            }
            .frame(height: 38)
        }
        .buttonStyle(.plain)
        .disabled(date == nil)
    }
}

private struct HistoryDaySummaryCard: View {
    let date: Date
    let summary: ActivitySummary

    private var title: String {
        let components = Calendar.current.dateComponents([.month, .day], from: date)
        return "\(components.month ?? 1)月\(components.day ?? 1)日"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(KikariaTypography.chineseHeadline(size: 19))
                    .foregroundStyle(KikariaTheme.deepText)

                Spacer()

                Text("\(summary.totalCount) 条记录")
                    .font(KikariaTypography.chineseCaption(size: 12, weight: .semibold))
                    .foregroundStyle(KikariaTheme.softText)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .liquidGlassCapsule(fillOpacity: 0.36, strokeOpacity: 0.34, shadowOpacity: 0.04, shadowRadius: 6, shadowY: 3)
            }

            if summary.totalCount == 0 {
                Text("这一天还没有学习记录。")
                    .font(KikariaTypography.chineseBody(size: 15, weight: .medium))
                    .foregroundStyle(KikariaTheme.softText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 9) {
                    HistorySummaryRow(title: "查看提示", count: summary.viewedHintCount)
                    HistorySummaryRow(title: "查看答案", count: summary.reviewedAnswerCount)
                    HistorySummaryRow(title: "新增掌握", count: summary.markedMasteredCount)
                    HistorySummaryRow(title: "加入重点", count: summary.addedReinforcementCount)
                }
            }
        }
        .padding(20)
        .liquidGlassCard(cornerRadius: 28, fillOpacity: 0.44, strokeOpacity: 0.40, shadowOpacity: 0.10, shadowRadius: 18, shadowY: 10)
    }
}

private struct HistorySummaryRow: View {
    let title: String
    let count: Int

    var body: some View {
        HStack {
            Text(title)
                .font(KikariaTypography.chineseBody(size: 15, weight: .medium))
                .foregroundStyle(KikariaTheme.deepText)

            Spacer()

            Text("\(count)")
                .font(KikariaTypography.number(size: 17, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(KikariaTheme.sky)
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
                    .frame(width: size, height: size)
            }
        }
        .padding(size <= 48 ? 3 : 5)
        .liquidGlassCircle(fillOpacity: 0.36, strokeOpacity: 0.50, shadowOpacity: 0.16, shadowRadius: 12, shadowY: 6)
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
    let onOpenOnboarding: () -> Void
    let onOpenMarkdownGuide: () -> Void
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
    @State private var isShowingPrivacyPolicy = false

    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

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
                            .liquidGlassCircle(fillOpacity: 0.40, strokeOpacity: 0.42, shadowOpacity: 0.10, shadowRadius: 12, shadowY: 6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 18)

                ScrollView {
                    VStack(spacing: 22) {
                        VStack(spacing: 12) {
                            ProfileAvatarView(
                                systemName: profile.avatarSystemName,
                                imageData: profile.avatarImageData,
                                size: 86
                            )

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
                                    .liquidGlassCapsule(fillOpacity: 0.44, strokeOpacity: 0.46, shadowOpacity: 0.10, shadowRadius: 14, shadowY: 8)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                        .padding(.bottom, 2)

                        SettingsSectionCard(title: "当前预设") {
                            SettingsListRow(
                                title: "当前预设",
                                valueText: currentPresetName,
                                showsChevron: false
                            )

                            SettingsSectionDivider()

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

                            SettingsSectionDivider()

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

                            SettingsSectionDivider()

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
                        }

                        SettingsSectionCard(title: "通知") {
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
                                SettingsSectionDivider()

                                SettingsTimePickerRow(
                                    title: "通知时间",
                                    selectedTime: $notificationTime
                                )

                                if countdownStartDate == nil || countdownEndDate == nil {
                                    Text("需设置倒数日")
                                        .font(KikariaTypography.chineseCaption(size: 12, weight: .medium))
                                        .foregroundStyle(KikariaTheme.softText)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 18)
                                        .padding(.bottom, 10)
                                }

                                #if DEBUG
                                SettingsSectionDivider()

                                Button {
                                    onSendTestNotification { message in
                                        showToast(message)
                                    }
                                } label: {
                                    SettingsRowContent(title: "预览提醒", valueText: "")
                                }
                                .buttonStyle(.plain)
                                #endif
                            }
                        }

                        SettingsSectionCard(title: "帮助") {
                            SettingsListRow(
                                title: "新手引导",
                                valueText: ""
                            ) {
                                onOpenOnboarding()
                            }

                            SettingsSectionDivider()

                            SettingsListRow(
                                title: "Markdown 格式",
                                valueText: ""
                            ) {
                                onOpenMarkdownGuide()
                            }
                        }

                        SettingsSectionCard(title: "关于") {
                            SettingsListRow(
                                title: "隐私政策",
                                valueText: ""
                            ) {
                                isShowingPrivacyPolicy = true
                            }

                            SettingsSectionDivider()

                            SettingsListRow(
                                title: "版权声明",
                                valueText: "© 2026 Vita",
                                showsChevron: false
                            )

                            SettingsSectionDivider()

                            SettingsListRow(
                                title: "版本",
                                valueText: versionText,
                                showsChevron: false
                            )
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
        .alert("隐私政策", isPresented: $isShowingPrivacyPolicy) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text("Kikaria 当前仅在本机保存你的学习资料、预设、头像和学习进度。学习进度通知使用 iOS 本地通知，不会上传到服务器。")
        }
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

private struct SettingsSectionCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(KikariaTypography.chineseCaption(size: 13, weight: .semibold))
                .foregroundStyle(KikariaTheme.softText)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content
            }
            .liquidGlassCard(cornerRadius: 28, fillOpacity: 0.40, strokeOpacity: 0.42, shadowOpacity: 0.10, shadowRadius: 16, shadowY: 9)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SettingsSectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(KikariaTheme.blueGray.opacity(0.13))
            .frame(height: 1)
            .padding(.leading, 18)
    }
}

private struct SettingsRowContent: View {
    let title: String
    let valueText: String
    var showsChevron = true

    var body: some View {
        HStack(spacing: 14) {
            Text(title)
                .font(KikariaTypography.chineseHeadline(size: 16))
                .foregroundStyle(KikariaTheme.deepText)
                .lineLimit(1)
                .minimumScaleFactor(0.84)

            Spacer(minLength: 12)

            if !valueText.isEmpty {
                Text(valueText)
                    .font(KikariaTypography.chineseHeadline(size: 16))
                    .foregroundStyle(showsChevron ? KikariaTheme.sky : KikariaTheme.softText)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KikariaTheme.blueGray)
            }
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, minHeight: 58)
        .contentShape(Rectangle())
    }
}

private struct SettingsListRow: View {
    let title: String
    let valueText: String
    var showsChevron = true
    var action: (() -> Void)? = nil

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    SettingsRowContent(title: title, valueText: valueText, showsChevron: showsChevron)
                }
                .buttonStyle(.plain)
            } else {
                SettingsRowContent(title: title, valueText: valueText, showsChevron: false)
            }
        }
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
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, minHeight: 58)
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
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, minHeight: 58)
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
                    .liquidGlassCircle(fillOpacity: 0.36, strokeOpacity: 0.34, shadowOpacity: 0.06, shadowRadius: 8, shadowY: 4)

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
            .liquidGlassCard(cornerRadius: 26, fillOpacity: 0.44, strokeOpacity: 0.42, shadowOpacity: 0.12, shadowRadius: 18, shadowY: 10)
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
        .liquidGlassCard(cornerRadius: 28, material: .regularMaterial, fillOpacity: 0.50, strokeOpacity: 0.52, shadowOpacity: 0.18, shadowRadius: 24, shadowY: 14)
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
                        .liquidGlassCapsule(fillOpacity: 0.44, strokeOpacity: 0.42, shadowOpacity: 0.06, shadowRadius: 8, shadowY: 4)
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
        .liquidGlassCard(cornerRadius: 28, material: .regularMaterial, fillOpacity: 0.50, strokeOpacity: 0.52, shadowOpacity: 0.18, shadowRadius: 24, shadowY: 14)
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
        .liquidGlassCard(cornerRadius: 28, material: .regularMaterial, fillOpacity: 0.50, strokeOpacity: 0.52, shadowOpacity: 0.18, shadowRadius: 24, shadowY: 14)
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
                                .liquidGlassCapsule(fillOpacity: 0.42, strokeOpacity: 0.40, shadowOpacity: 0.04, shadowRadius: 6, shadowY: 3)
                        }
                    }

                    HStack(spacing: 9) {
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
                        .liquidGlassCircle(fillOpacity: 0.40, strokeOpacity: 0.38, shadowOpacity: 0.08, shadowRadius: 8, shadowY: 4)
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
        .liquidGlassCard(cornerRadius: 24, fillOpacity: isCurrent ? 0.52 : 0.42, strokeOpacity: isCurrent ? 0.62 : 0.38, shadowOpacity: isCurrent ? 0.15 : 0.09, shadowRadius: 18, shadowY: 10)
    }
}

private struct NewPresetView: View {
    @Environment(\.dismiss) private var dismiss
    let createPreset: (String, String, String, String) -> PresetCreationOutcome
    @State private var name = ""
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
                            .liquidGlassCircle(fillOpacity: 0.40, strokeOpacity: 0.42, shadowOpacity: 0.08, shadowRadius: 10, shadowY: 5)
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
                                .liquidGlassCard(cornerRadius: 22, fillOpacity: 0.42, strokeOpacity: 0.38, shadowOpacity: 0.08, shadowRadius: 12, shadowY: 7)
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
                                        .liquidGlassCapsule(fillOpacity: 0.38, strokeOpacity: 0.36, shadowOpacity: 0.04, shadowRadius: 6, shadowY: 3)
                                }
                                .buttonStyle(.plain)
                            }

                            TextEditor(text: $markdownText)
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(KikariaTheme.deepText)
                                .scrollContentBackground(.hidden)
                                .padding(14)
                                .frame(minHeight: 260)
                                .liquidGlassCard(cornerRadius: 24, material: .thinMaterial, fillOpacity: 0.56, strokeOpacity: 0.34, shadowOpacity: 0.10, shadowRadius: 14, shadowY: 8)
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(KikariaTypography.chineseBody(size: 14, weight: .semibold))
                                .foregroundStyle(Color(red: 0.72, green: 0.24, blue: 0.24))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .liquidGlassCard(cornerRadius: 18, fillOpacity: 0.50, strokeOpacity: 0.36, shadowOpacity: 0.06, shadowRadius: 8, shadowY: 4)
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
        switch createPreset(name, category, description, markdownText) {
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
                            .liquidGlassCircle(fillOpacity: 0.40, strokeOpacity: 0.42, shadowOpacity: 0.08, shadowRadius: 10, shadowY: 5)
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
        .liquidGlassCard(cornerRadius: 24, fillOpacity: 0.44, strokeOpacity: 0.40, shadowOpacity: 0.10, shadowRadius: 16, shadowY: 8)
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
        .liquidGlassCard(cornerRadius: 18, material: .thinMaterial, fillOpacity: 0.54, strokeOpacity: 0.28, shadowOpacity: 0.04, shadowRadius: 8, shadowY: 4)
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
    let onSavePreset: (String, String, String, String) -> Void
    let onAddPoint: () -> Void
    let onEditPoint: (UUID) -> Void
    let onDeletePoint: (UUID, String) -> Void
    let onDeletePreset: (String) -> Void
    @State private var name: String
    @State private var category: String
    @State private var description: String
    @State private var searchText = ""
    @State private var pendingDeletePoint: KnowledgePoint?
    @State private var isConfirmingPresetDelete = false
    @State private var shareFile: ShareFile?
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    init(
        preset: KnowledgePreset,
        knowledgePoints: [KnowledgePoint],
        onSavePreset: @escaping (String, String, String, String) -> Void,
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
        _category = State(initialValue: preset.category)
        _description = State(initialValue: preset.description)
    }

    private var filteredKnowledgePoints: [KnowledgePoint] {
        knowledgePoints.filter { $0.matchesSearchQuery(searchText) }
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
                            .liquidGlassCircle(fillOpacity: 0.40, strokeOpacity: 0.42, shadowOpacity: 0.08, shadowRadius: 10, shadowY: 5)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("编辑预设")
                        .font(KikariaTypography.chineseHeadline())
                        .foregroundStyle(KikariaTheme.deepText)

                    Spacer()

                    Button("保存") {
                        onSavePreset(preset.id, name, category, description)
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
                        ProfileTextField(title: "分类", text: $category)
                        ProfileTextField(title: "简短描述", text: $description)

                        Button(action: exportMarkdown) {
                            Label("导出 Markdown", systemImage: "square.and.arrow.up")
                                .font(KikariaTypography.chineseButton())
                                .foregroundStyle(KikariaTheme.deepText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .liquidGlassCard(cornerRadius: 22, fillOpacity: 0.42, strokeOpacity: 0.38, shadowOpacity: 0.08, shadowRadius: 12, shadowY: 7)
                        }
                        .buttonStyle(.plain)

                        Button(action: onAddPoint) {
                            Label("添加知识点", systemImage: "plus.circle.fill")
                                .font(KikariaTypography.chineseButton())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(KikariaTheme.actionGradient, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        KikariaSearchBar(text: $searchText)

                        VStack(spacing: 12) {
                            if filteredKnowledgePoints.isEmpty {
                                SoftEmptyState(
                                    title: "没有找到相关知识点",
                                    subtitle: "换个关键词试试看。",
                                    systemImage: "magnifyingglass"
                                )
                                .padding(.vertical, 18)
                            } else {
                                ForEach(filteredKnowledgePoints) { point in
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
                                                .liquidGlassCircle(fillOpacity: 0.36, strokeOpacity: 0.34, shadowOpacity: 0.05, shadowRadius: 7, shadowY: 3)
                                        }
                                        .buttonStyle(.plain)

                                        Button {
                                            pendingDeletePoint = point
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.headline.weight(.semibold))
                                                .foregroundStyle(Color(red: 0.72, green: 0.24, blue: 0.24))
                                                .frame(width: 34, height: 34)
                                                .liquidGlassCircle(fillOpacity: 0.36, strokeOpacity: 0.34, shadowOpacity: 0.05, shadowRadius: 7, shadowY: 3)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(16)
                                    .liquidGlassCard(cornerRadius: 22, fillOpacity: 0.42, strokeOpacity: 0.36, shadowOpacity: 0.08, shadowRadius: 12, shadowY: 7)
                                }
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
                                    .liquidGlassCard(cornerRadius: 22, fillOpacity: 0.42, strokeOpacity: 0.36, shadowOpacity: 0.08, shadowRadius: 12, shadowY: 7)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 6)
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
        .sheet(item: $shareFile) { file in
            ActivityView(activityItems: [file.url])
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

    private func exportMarkdown() {
        let markdown = KnowledgePoint.markdownText(from: knowledgePoints)
        let filename = "Kikaria-\(sanitizedFilename(preset.name)).md"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try markdown.write(to: url, atomically: true, encoding: .utf8)
            shareFile = ShareFile(url: url)
        } catch {
            showToast("导出失败")
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
                            .liquidGlassCircle(fillOpacity: 0.40, strokeOpacity: 0.42, shadowOpacity: 0.08, shadowRadius: 10, shadowY: 5)
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
                                .liquidGlassCard(cornerRadius: 18, fillOpacity: 0.50, strokeOpacity: 0.36, shadowOpacity: 0.06, shadowRadius: 8, shadowY: 4)
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
            updatedAt: now,
            reinforcementCount: point?.reinforcementCount,
            lastReinforcedAt: point?.lastReinforcedAt
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
                .liquidGlassCard(cornerRadius: 22, material: .thinMaterial, fillOpacity: 0.56, strokeOpacity: 0.32, shadowOpacity: 0.08, shadowRadius: 12, shadowY: 7)
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
                            .liquidGlassCircle(fillOpacity: 0.40, strokeOpacity: 0.42, shadowOpacity: 0.08, shadowRadius: 10, shadowY: 5)
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
                                    .liquidGlassCapsule(fillOpacity: 0.38, strokeOpacity: 0.36, shadowOpacity: 0.06, shadowRadius: 8, shadowY: 4)
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
                guard let compressedData = compressedAvatarData(from: data) else {
                    return
                }

                profile.avatarImageData = compressedData
            }
        }
    }

    private func compressedAvatarData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }

        let maxDimension: CGFloat = 512
        let largestSide = max(image.size.width, image.size.height)
        let scale = largestSide > 0 ? min(1, maxDimension / largestSide) : 1

        let outputImage: UIImage
        if scale < 1 {
            let targetSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
            outputImage = UIGraphicsImageRenderer(size: targetSize).image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        } else {
            outputImage = image
        }

        return outputImage.jpegData(compressionQuality: 0.82) ?? outputImage.pngData()
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
                .liquidGlassCard(cornerRadius: 20, fillOpacity: 0.50, strokeOpacity: 0.34, shadowOpacity: 0.08, shadowRadius: 12, shadowY: 7)
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
                            .liquidGlassCircle(fillOpacity: 0.40, strokeOpacity: 0.42, shadowOpacity: 0.08, shadowRadius: 10, shadowY: 5)
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
                        .liquidGlassCard(cornerRadius: 26, material: .thinMaterial, fillOpacity: 0.56, strokeOpacity: 0.34, shadowOpacity: 0.12, shadowRadius: 18, shadowY: 10)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(KikariaTypography.chineseBody(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 0.72, green: 0.24, blue: 0.24))
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .liquidGlassCard(cornerRadius: 18, fillOpacity: 0.50, strokeOpacity: 0.36, shadowOpacity: 0.06, shadowRadius: 8, shadowY: 4)
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
    @State private var isBreathing = false
    @State private var hasStartedBreathingAnimation = false
    private let orbitDuration: TimeInterval = 150

    var body: some View {
        TimelineView(.animation) { timeline in
            let orbitDegrees = orbitAngle(for: timeline.date)

            ZStack {
                ZStack {
                    DecorativeBubble(
                        size: 92,
                        colors: [KikariaTheme.cyan, Color(red: 0.73, green: 0.95, blue: 0.90)],
                        opacity: 0.48
                    )
                    .rotationEffect(.degrees(-orbitDegrees))
                    .scaleEffect(isBreathing ? 1.035 : 0.985)
                    .offset(x: -96, y: -68)

                    DecorativeBubble(
                        size: 80,
                        colors: [Color(red: 0.75, green: 0.78, blue: 1.0), KikariaTheme.mist],
                        opacity: 0.42
                    )
                    .rotationEffect(.degrees(-orbitDegrees))
                    .scaleEffect(isBreathing ? 0.985 : 1.04)
                    .offset(x: 102, y: -56)

                    DecorativeBubble(
                        size: 78,
                        colors: [Color(red: 0.78, green: 0.95, blue: 0.74), KikariaTheme.cyan],
                        opacity: 0.38
                    )
                    .rotationEffect(.degrees(-orbitDegrees))
                    .scaleEffect(isBreathing ? 1.035 : 0.985)
                    .offset(x: 92, y: 80)

                    DecorativeBubble(
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
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.30),
                                        Color.white.opacity(0.10),
                                        Color.white.opacity(0.02)
                                    ],
                                    center: .topLeading,
                                    startRadius: 12,
                                    endRadius: 150
                                )
                            )
                            .padding(1)
                    }
                    .overlay {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.48),
                                        Color.white.opacity(0.12),
                                        KikariaTheme.cyan.opacity(0.22)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.1
                            )
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
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.24),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 4,
                            endRadius: size * 0.72
                        )
                    )
            }
            .overlay {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.42),
                                Color.white.opacity(0.08),
                                KikariaTheme.cyan.opacity(0.16)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: KikariaTheme.sky.opacity(0.10), radius: 14, y: 8)
    }
}

private struct DecorativeBubble: View {
    let size: CGFloat
    let colors: [Color]
    let opacity: Double

    var body: some View {
        SoftBubble(size: size, colors: colors, opacity: opacity)
            .accessibilityHidden(true)
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

private struct TodayOverviewHomeProgressButton: View {
    let dateText: String
    let daysLeftText: String
    let progressText: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(dateText)
                    .font(.system(size: 23, weight: .semibold, design: .serif))
                    .foregroundStyle(KikariaTheme.deepText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(daysLeftText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(KikariaTheme.softText)
                    .lineLimit(1)
            }

            Spacer(minLength: 12)

            Text(progressText)
                .font(KikariaTypography.number(size: 25, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(KikariaTheme.masteredDeepGreen)
                .lineLimit(1)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(KikariaTheme.blueGray.opacity(0.52))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .liquidGlassCard(cornerRadius: 25, fillOpacity: 0.42, strokeOpacity: 0.46, shadowOpacity: 0.11, shadowRadius: 17, shadowY: 9)
    }
}

private struct HomeDashboardGridCard: View {
    let scopeCountText: String
    let reinforcedCount: Int
    let masteredCount: Int
    let presetName: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                NavigationLink(value: AppRoute.scope) {
                    HomeDashboardMetricColumn(title: "范围", valueText: scopeCountText, tint: KikariaTheme.sky)
                }
                .buttonStyle(.plain)

                HomeDashboardDivider()

                NavigationLink(value: AppRoute.reinforcement) {
                    HomeDashboardMetricColumn(title: "重点集锦", valueText: "\(reinforcedCount)", tint: KikariaTheme.cyan)
                }
                .buttonStyle(.plain)

                HomeDashboardDivider()

                NavigationLink(value: AppRoute.mastered) {
                    HomeDashboardMetricColumn(title: "已掌握", valueText: "\(masteredCount)", tint: KikariaTheme.masteredGreen)
                }
                .buttonStyle(.plain)
            }

            Rectangle()
                .fill(KikariaTheme.blueGray.opacity(0.12))
                .frame(height: 1)
                .padding(.horizontal, 18)

            NavigationLink(value: AppRoute.presetSelection) {
                HStack(spacing: 8) {
                    Text(presetName)
                        .font(KikariaTypography.chineseHeadline(size: 16))
                        .foregroundStyle(KikariaTheme.deepText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)

                    Text("当前预设")
                        .font(KikariaTypography.chineseCaption(size: 12, weight: .semibold))
                        .foregroundStyle(KikariaTheme.softText)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KikariaTheme.blueGray.opacity(0.58))
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: 56)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .liquidGlassCard(cornerRadius: 28, fillOpacity: 0.40, strokeOpacity: 0.44, shadowOpacity: 0.12, shadowRadius: 18, shadowY: 10)
    }
}

private struct HomeDashboardMetricColumn: View {
    let title: String
    let valueText: String
    let tint: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(KikariaTypography.chineseCaption(size: 13, weight: .semibold))
                .foregroundStyle(KikariaTheme.softText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(valueText)
                .font(KikariaTypography.number(size: 24, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, minHeight: 82)
        .contentShape(Rectangle())
    }
}

private struct HomeDashboardDivider: View {
    var body: some View {
        Rectangle()
            .fill(KikariaTheme.blueGray.opacity(0.16))
            .frame(width: 1, height: 42)
    }
}

struct ScopeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTags: Set<String>
    let knowledgePoints: [KnowledgePoint]
    let allTags: [String]
    var onDone: (() -> Void)? = nil
    @State private var searchText = ""

    private let columns = [
        GridItem(.adaptive(minimum: 132), spacing: 12)
    ]

    private var filteredTags: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return allTags
        }

        let relevantTags = Set(
            knowledgePoints
                .filter { $0.matchesSearchQuery(query) }
                .flatMap(\.tags)
        )

        return allTags.filter { tag in
            tag.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil ||
                relevantTags.contains(tag)
        }
    }

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

                        KikariaSearchBar(text: $searchText, placeholder: "搜索标签或知识点")

                        if filteredTags.isEmpty {
                            SoftEmptyState(
                                title: "没有找到相关标签",
                                subtitle: "换个关键词试试看。",
                                systemImage: "magnifyingglass"
                            )
                            .padding(.top, 18)
                        } else {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(filteredTags, id: \.self) { tag in
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
    let onRecordActivity: (StudyActivityType, KnowledgePoint) -> Void
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
            return knowledgePoints.filter { $0.reinforcementCount > 0 }
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
                GeometryReader { proxy in
                    ScrollView {
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
                                                revealHint()
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
                                        ReinforcementReviewAnsweredActionGrid(
                                            point: currentPoint,
                                            removeFromReinforcement: {
                                                removeCurrentPointFromReinforcement(shouldShowToast: true)
                                                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                                    chooseRandomPoint()
                                                }
                                            },
                                            markAsMastered: {
                                                markCurrentPointAsMastered()
                                                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                                    chooseRandomPoint()
                                                }
                                            },
                                            next: {
                                                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                                    chooseRandomPoint()
                                                }
                                            }
                                        )
                                    } else if mode.isMastered {
                                        MasteredReviewAnsweredActionGrid(
                                            point: currentPoint,
                                            addToReinforcement: {
                                                addCurrentPointToReinforcementAndAdvance()
                                            },
                                            removeFromMastered: {
                                                removeCurrentPointFromMastered(shouldShowToast: true)
                                                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                                    chooseRandomPoint()
                                                }
                                            },
                                            next: {
                                                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                                    chooseRandomPoint()
                                                }
                                            }
                                        )
                                    } else {
                                        NormalReviewAnsweredActionGrid(
                                            point: currentPoint,
                                            addToReinforcement: {
                                                addCurrentPointToReinforcementAndAdvance()
                                            },
                                            markAsMastered: {
                                                markCurrentPointAsMastered()
                                                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                                    chooseRandomPoint()
                                                }
                                            },
                                            next: {
                                                withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
                                                    chooseRandomPoint()
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 28)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: proxy.size.height, alignment: .top)
                    }
                    .scrollIndicators(.hidden)
                    .highPriorityGestureIf(!isShowingContent, preAnswerSwipeUpGesture)
                    .scaleEffect(gestureFeedback ? 0.985 : 1.0)
                }
            } else {
                ProgressView()
            }

            if isShowingScopePanel {
                ScopeSelectionView(
                    selectedTags: $selectedTags,
                    knowledgePoints: knowledgePoints,
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

    private var preAnswerSwipeUpGesture: some Gesture {
        DragGesture(minimumDistance: 24, coordinateSpace: .local)
            .onEnded { value in
                guard !isShowingScopePanel, !isShowingContent else {
                    return
                }

                let dx = value.translation.width
                let dy = value.translation.height
                let horizontal = abs(dx)
                let vertical = abs(dy)

                guard dy < 0,
                      vertical > 80,
                      vertical > horizontal * 1.4
                else {
                    return
                }

                triggerGestureFeedback()
                withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) {
                    revealContent()
                }
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
        let verticalThreshold: CGFloat = isShowingContent ? 180 : 90
        let dominance: CGFloat = 1.4
        let isCentralReadingArea = startLocation.y > 190 && startLocation.y < UIScreen.main.bounds.height - 190

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
                if isShowingContent, isCentralReadingArea, vertical < 240 {
                    return
                }

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
                if isShowingContent, isCentralReadingArea {
                    return
                }

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
        // Normal-mode left swipe only adds/re-adds to reinforcement; it must never mark a point as mastered.
        let wasMastered = currentPoint?.isMastered
        withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
            revealContent()
        }
        addCurrentPointToReinforcement(shouldShowToast: true)
        assert(currentPoint?.isMastered == wasMastered)
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

    private func revealHint() {
        if !isShowingHint,
           let currentPointID,
           let point = knowledgePoints.first(where: { $0.id == currentPointID }) {
            onRecordActivity(.viewedHint, point)
        }

        isShowingHint = true
    }

    private func revealContent() {
        if !isShowingContent,
           let currentPointID,
           let point = knowledgePoints.first(where: { $0.id == currentPointID }) {
            incrementTodayReviewCount(for: currentPointID)
            onRecordActivity(.reviewedAnswer, point)
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

    private func addCurrentPointToReinforcement(shouldShowToast: Bool = false) {
        guard let currentPointID,
              let index = knowledgePoints.firstIndex(where: { $0.id == currentPointID })
        else {
            return
        }

        let title = knowledgePoints[index].title
        let wasMastered = knowledgePoints[index].isMastered
        let newCount = knowledgePoints[index].addReinforcement()
        assert(knowledgePoints[index].isMastered == wasMastered)
        onRecordActivity(.addedReinforcement, knowledgePoints[index])

        if shouldShowToast {
            showToast(reinforcementAddedToastTitle(for: title, count: newCount))
        }
    }

    private func addCurrentPointToReinforcementAndAdvance() {
        addCurrentPointToReinforcement(shouldShowToast: true)
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
        knowledgePoints[index].clearReinforcement()
        knowledgePoints[index].updatedAt = Date()
        onRecordActivity(.markedMastered, knowledgePoints[index])
        showToast("\(title) 已掌握")
    }

    @discardableResult
    private func removeCurrentPointFromReinforcement(shouldShowToast: Bool = false) -> Bool {
        guard let currentPointID,
              let index = knowledgePoints.firstIndex(where: { $0.id == currentPointID })
        else {
            return false
        }

        guard knowledgePoints[index].reinforcementCount > 0 else {
            return false
        }

        let title = knowledgePoints[index].title
        let wasMastered = knowledgePoints[index].isMastered
        knowledgePoints[index].clearReinforcement()
        assert(knowledgePoints[index].isMastered == wasMastered)
        onRecordActivity(.removedReinforcement, knowledgePoints[index])

        if shouldShowToast {
            showToast("\(title) 已移出重点集锦")
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
        onRecordActivity(.removedMastered, knowledgePoints[index])

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

    private func reinforcementAddedToastTitle(for title: String, count: Int) -> String {
        count <= 1 ? "\(title) 已加入重点集锦" : "\(title) 已加入重点集锦 ×\(count)"
    }
}

private enum ReviewActionTone {
    case blue
    case green
    case amber
    case red
}

private struct ReviewAnsweredActionGrid<TopButton: View, BottomButton: View>: View {
    let next: () -> Void
    private let topButton: () -> TopButton
    private let bottomButton: () -> BottomButton

    init(
        next: @escaping () -> Void,
        @ViewBuilder topButton: @escaping () -> TopButton,
        @ViewBuilder bottomButton: @escaping () -> BottomButton
    ) {
        self.next = next
        self.topButton = topButton
        self.bottomButton = bottomButton
    }

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 12
            let availableWidth = max(0, proxy.size.width - spacing)
            let leftWidth = availableWidth * 0.65
            let rightWidth = availableWidth - leftWidth

            HStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    topButton()
                    bottomButton()
                }
                .frame(width: leftWidth)

                ReviewActionButton(
                    title: "下一个",
                    systemImage: "shuffle",
                    isPrimary: false,
                    tone: .amber,
                    isVerticalContent: true,
                    minHeight: 144
                ) {
                    next()
                }
                .frame(width: rightWidth)
            }
        }
        .frame(height: 144)
    }
}

private struct NormalReviewAnsweredActionGrid: View {
    let point: KnowledgePoint
    let addToReinforcement: () -> Void
    let markAsMastered: () -> Void
    let next: () -> Void

    var body: some View {
        ReviewAnsweredActionGrid(next: next) {
            ReviewActionButton(
                title: point.reinforcementCount > 0 ? "再次加入 ×\(point.reinforcementCount)" : "加入重点集锦",
                systemImage: "plus.circle.fill",
                isPrimary: true,
                minHeight: 66
            ) {
                addToReinforcement()
            }
        } bottomButton: {
            MasteredReviewButton(isMastered: point.isMastered, minHeight: 66) {
                markAsMastered()
            }
        }
    }
}

private struct ReinforcementReviewAnsweredActionGrid: View {
    let point: KnowledgePoint
    let removeFromReinforcement: () -> Void
    let markAsMastered: () -> Void
    let next: () -> Void

    var body: some View {
        ReviewAnsweredActionGrid(next: next) {
            ReviewActionButton(
                title: "移出重点集锦",
                systemImage: "minus.circle.fill",
                isPrimary: true,
                tone: .red,
                minHeight: 66
            ) {
                removeFromReinforcement()
            }
        } bottomButton: {
            MasteredReviewButton(isMastered: point.isMastered, minHeight: 66) {
                markAsMastered()
            }
        }
    }
}

private struct MasteredReviewAnsweredActionGrid: View {
    let point: KnowledgePoint
    let addToReinforcement: () -> Void
    let removeFromMastered: () -> Void
    let next: () -> Void

    var body: some View {
        ReviewAnsweredActionGrid(next: next) {
            ReviewActionButton(
                title: point.reinforcementCount > 0 ? "再次加入 ×\(point.reinforcementCount)" : "加入重点集锦",
                systemImage: "plus.circle.fill",
                isPrimary: true,
                minHeight: 66
            ) {
                addToReinforcement()
            }
        } bottomButton: {
            ReviewActionButton(
                title: "移出已掌握",
                systemImage: "minus.circle.fill",
                isPrimary: true,
                tone: .red,
                minHeight: 66
            ) {
                removeFromMastered()
            }
        }
    }
}

private struct ReviewActionButton: View {
    let title: String
    let systemImage: String
    let isPrimary: Bool
    var tone: ReviewActionTone = .blue
    var isEnabled = true
    var isVerticalContent = false
    var minHeight: CGFloat? = nil
    let action: () -> Void

    private var primaryFill: AnyShapeStyle {
        switch tone {
        case .blue:
            return AnyShapeStyle(KikariaTheme.actionGradient)
        case .green:
            return AnyShapeStyle(KikariaTheme.masteredGradient)
        case .amber:
            return AnyShapeStyle(KikariaTheme.nextGradient)
        case .red:
            return AnyShapeStyle(KikariaTheme.removeGradient)
        }
    }

    private var secondaryFill: AnyShapeStyle {
        switch tone {
        case .blue, .green:
            return AnyShapeStyle(.white.opacity(0.46))
        case .amber:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.78, green: 0.72, blue: 0.94).opacity(0.68),
                        Color(red: 0.58, green: 0.53, blue: 0.80).opacity(0.56)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .red:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.90, green: 0.38, blue: 0.35).opacity(0.58),
                        Color(red: 0.98, green: 0.58, blue: 0.50).opacity(0.46)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    private var foregroundColor: Color {
        if isPrimary {
            return .white
        }

        switch tone {
        case .amber:
            return .white.opacity(0.94)
        default:
            return KikariaTheme.deepText
        }
    }

    private var textShadowColor: Color {
        switch tone {
        case .amber:
            return Color(red: 0.23, green: 0.20, blue: 0.36).opacity(0.22)
        default:
            return .clear
        }
    }

    private var strokeAccentOpacity: Double {
        switch tone {
        case .amber:
            return 0.16
        default:
            return 0.18
        }
    }

    private var buttonShadowOpacity: Double {
        switch tone {
        case .amber:
            return isPrimary ? 0.12 : 0.055
        default:
            return isPrimary ? 0.22 : 0.10
        }
    }

    private var shadowColor: Color {
        switch tone {
        case .blue:
            return KikariaTheme.sky
        case .green:
            return KikariaTheme.masteredGreen
        case .amber:
            return KikariaTheme.nextAmber
        case .red:
            return KikariaTheme.removeCoral
        }
    }

    var body: some View {
        Button(action: action) {
            content
                .foregroundStyle(foregroundColor)
                .shadow(color: textShadowColor, radius: tone == .amber ? 4 : 0, y: tone == .amber ? 1 : 0)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 19)
                .frame(minHeight: minHeight)
                .background {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(isPrimary ? primaryFill : secondaryFill)
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isPrimary ? 0.44 : 0.48),
                                    Color.white.opacity(0.12),
                                    shadowColor.opacity(strokeAccentOpacity)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: shadowColor.opacity(buttonShadowOpacity), radius: 16, y: 9)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.82)
    }

    @ViewBuilder
    private var content: some View {
        if isVerticalContent {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))

                Text(title)
                    .font(KikariaTypography.chineseButton())
            }
            .frame(maxWidth: .infinity)
        } else {
            Label(title, systemImage: systemImage)
                .font(KikariaTypography.chineseButton())
        }
    }
}

private struct MasteredReviewButton: View {
    let isMastered: Bool
    var minHeight: CGFloat? = nil
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
            .frame(minHeight: minHeight)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        isMastered
                            ? AnyShapeStyle(.white.opacity(0.42))
                            : AnyShapeStyle(KikariaTheme.masteredActionGradient)
                    )
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.46),
                                Color.white.opacity(0.12),
                                KikariaTheme.masteredGreen.opacity(0.20)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
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
    let onRecordActivity: (StudyActivityType, KnowledgePoint) -> Void
    let onStartReview: () -> Void
    @State private var searchText = ""
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    private var reinforcedPoints: [KnowledgePoint] {
        knowledgePoints
            .filter { $0.reinforcementCount > 0 }
            .sorted { lhs, rhs in
                if lhs.reinforcementCount != rhs.reinforcementCount {
                    return lhs.reinforcementCount > rhs.reinforcementCount
                }

                switch (lhs.lastReinforcedAt, rhs.lastReinforcedAt) {
                case let (lhsDate?, rhsDate?):
                    return lhsDate > rhsDate
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }
            }
    }

    private var filteredReinforcedPoints: [KnowledgePoint] {
        reinforcedPoints.filter { $0.matchesSearchQuery(searchText) }
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

                            KikariaSearchBar(text: $searchText)

                            if filteredReinforcedPoints.isEmpty {
                                SoftEmptyState(
                                    title: "没有找到相关知识点",
                                    subtitle: "换个关键词试试看。",
                                    systemImage: "magnifyingglass"
                                )
                                .padding(.top, 12)
                            } else {
                                ForEach(filteredReinforcedPoints) { point in
                                    ReinforcementCard(point: point) {
                                        removeFromReinforcement(point)
                                    }
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
            knowledgePoints[index].clearReinforcement()
        }

        onRecordActivity(.removedReinforcement, point)
        showToast("\(point.title) 已移出重点集锦")
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
    let onRecordActivity: (StudyActivityType, KnowledgePoint) -> Void
    let onStartReview: () -> Void
    @State private var searchText = ""
    @State private var toastMessage: String?
    @State private var toastToken = UUID()

    private var masteredPoints: [KnowledgePoint] {
        knowledgePoints.filter(\.isMastered)
    }

    private var filteredMasteredPoints: [KnowledgePoint] {
        masteredPoints.filter { $0.matchesSearchQuery(searchText) }
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

                            KikariaSearchBar(text: $searchText)

                            if filteredMasteredPoints.isEmpty {
                                SoftEmptyState(
                                    title: "没有找到相关知识点",
                                    subtitle: "换个关键词试试看。",
                                    systemImage: "magnifyingglass"
                                )
                                .padding(.top, 12)
                            } else {
                                ForEach(filteredMasteredPoints) { point in
                                    ReinforcementCard(
                                        point: point,
                                        removeTitle: "移出已掌握",
                                        removeSystemImage: "minus.circle.fill",
                                        showsReinforcementCountBadge: false
                                    ) {
                                        removeFromMastered(point)
                                    }
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

        onRecordActivity(.removedMastered, point)
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
        .liquidGlassCard(cornerRadius: 28, fillOpacity: 0.46, strokeOpacity: 0.46, shadowOpacity: 0.16, shadowRadius: 20, shadowY: 10)
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
        .liquidGlassCard(cornerRadius: 28, fillOpacity: 0.46, strokeOpacity: 0.46, shadowOpacity: 0.16, shadowRadius: 20, shadowY: 10)
    }
}

private struct ReinforcementCard: View {
    let point: KnowledgePoint
    var removeTitle = "移出重点集锦"
    var removeSystemImage = "minus.circle.fill"
    var showsReinforcementCountBadge = true
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
            HStack(alignment: .top, spacing: 12) {
                Text(point.title)
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(KikariaTheme.deepText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if showsReinforcementCountBadge, point.reinforcementCount > 0 {
                    Text("×\(point.reinforcementCount)")
                        .font(KikariaTypography.number(size: 14, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(KikariaTheme.sky)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .liquidGlassCard(cornerRadius: 16, material: .ultraThinMaterial, fillOpacity: 0.52, strokeOpacity: 0.42, shadowOpacity: 0.08, shadowRadius: 10, shadowY: 5)
                }
            }

            LightTagRow(tags: point.tags)

            FloatingInfoCard(title: "提示", text: point.hint)
                .shadow(color: .clear, radius: 0)

            FloatingInfoCard(title: "答案", text: point.content)
                .shadow(color: .clear, radius: 0)

            Button(action: removeAction) {
                Label(removeTitle, systemImage: removeSystemImage)
                    .font(KikariaTypography.chineseButton(size: 14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background {
                        Capsule(style: .continuous)
                            .fill(KikariaTheme.removeGradient)
                    }
                    .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.48),
                                        Color.white.opacity(0.12),
                                        KikariaTheme.removeCoral.opacity(0.22)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: KikariaTheme.removeCoral.opacity(0.18), radius: 14, y: 8)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .liquidGlassCard(cornerRadius: 30, material: .thinMaterial, fillOpacity: 0.42, strokeOpacity: 0.40, shadowOpacity: 0.12, shadowRadius: 20, shadowY: 12)
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
            .liquidGlassCard(cornerRadius: 22, material: .regularMaterial, fillOpacity: 0.52, strokeOpacity: 0.52, shadowOpacity: 0.18, shadowRadius: 18, shadowY: 10)
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
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .liquidGlassCard(cornerRadius: 26, material: .thinMaterial, fillOpacity: 0.56, strokeOpacity: 0.42, shadowOpacity: 0.14, shadowRadius: 18, shadowY: 10)
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
                    .liquidGlassCapsule(fillOpacity: 0.38, strokeOpacity: 0.34, shadowOpacity: 0.04, shadowRadius: 6, shadowY: 3)
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
            .liquidGlassCapsule(fillOpacity: 0.42, strokeOpacity: 0.38, shadowOpacity: 0.10, shadowRadius: 12, shadowY: 6)
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
        .liquidGlassCard(cornerRadius: 30, material: .thinMaterial, fillOpacity: 0.54, strokeOpacity: 0.42, shadowOpacity: 0.12, shadowRadius: 18, shadowY: 10)
    }
}

#Preview {
    ContentView()
}
