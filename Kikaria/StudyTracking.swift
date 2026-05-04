//
//  StudyTracking.swift
//  Kikaria
//
//  Created by Codex on 2026/5/4.
//

import Foundation
import WidgetKit

enum StudyActivityType: String, Codable, CaseIterable {
    case viewedHint
    case reviewedAnswer
    case markedMastered
    case removedMastered
    case addedReinforcement
    case removedReinforcement
}

struct StudyActivityRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var presetId: String
    var date: Date
    var type: StudyActivityType
    var pointId: UUID
    var pointTitle: String

    init(
        id: UUID = UUID(),
        presetId: String,
        date: Date = Date(),
        type: StudyActivityType,
        pointId: UUID,
        pointTitle: String
    ) {
        self.id = id
        self.presetId = presetId
        self.date = date
        self.type = type
        self.pointId = pointId
        self.pointTitle = pointTitle
    }
}

struct WidgetSnapshot: Codable {
    var presetName: String
    var masteredCount: Int
    var dailyGoal: Int
    var countdownDays: Int?
    var todayReviewCount: Int
    var lastUpdated: Date

    static let placeholder = WidgetSnapshot(
        presetName: "高等数学知识点",
        masteredCount: 0,
        dailyGoal: 20,
        countdownDays: nil,
        todayReviewCount: 0,
        lastUpdated: Date()
    )
}

enum WidgetDataStore {
    static let appGroupID = "group.com.vita0818.kikaria"
    static let snapshotKey = "kikaria.widgetSnapshot"

    static func save(_ snapshot: WidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        if let appGroupDefaults = UserDefaults(suiteName: appGroupID) {
            appGroupDefaults.set(data, forKey: snapshotKey)
            appGroupDefaults.synchronize()
        }

        UserDefaults.standard.set(data, forKey: snapshotKey)
        UserDefaults.standard.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
