import SwiftUI
import UIKit
import WidgetKit

private enum WidgetTheme {
    private static func adaptive(
        light: (CGFloat, CGFloat, CGFloat),
        dark: (CGFloat, CGFloat, CGFloat)
    ) -> Color {
        Color(
            UIColor { traits in
                let color = traits.userInterfaceStyle == .dark ? dark : light
                return UIColor(red: color.0, green: color.1, blue: color.2, alpha: 1)
            }
        )
    }

    static let backgroundGradient = LinearGradient(
        colors: [
            adaptive(light: (0.93, 0.98, 1.0), dark: (0.02, 0.07, 0.11)),
            adaptive(light: (0.80, 0.94, 0.98), dark: (0.04, 0.15, 0.20))
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

private struct WidgetSnapshot: Codable {
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

private enum WidgetDataStore {
    static let appGroupID = "group.com.vita0818.kikaria"
    static let snapshotKey = "kikaria.widgetSnapshot"

    static func loadSnapshot() -> WidgetSnapshot {
        if let appGroupDefaults = UserDefaults(suiteName: appGroupID),
           let data = appGroupDefaults.data(forKey: snapshotKey),
           let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) {
            return snapshot
        }

        if let data = UserDefaults.standard.data(forKey: snapshotKey),
           let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) {
            return snapshot
        }

        return .placeholder
    }
}

private struct KikariaWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

private struct KikariaWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> KikariaWidgetEntry {
        KikariaWidgetEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (KikariaWidgetEntry) -> Void) {
        completion(KikariaWidgetEntry(date: Date(), snapshot: WidgetDataStore.loadSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KikariaWidgetEntry>) -> Void) {
        let entry = KikariaWidgetEntry(date: Date(), snapshot: WidgetDataStore.loadSnapshot())
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

private struct KikariaWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.colorScheme) private var colorScheme
    let entry: KikariaWidgetEntry

    var body: some View {
        ZStack {
            widgetGradient

            Circle()
                .fill(widgetHighlight.opacity(colorScheme == .dark ? 0.16 : 0.26))
                .frame(width: 118, height: 118)
                .blur(radius: 1.5)
                .offset(x: -54, y: -46)

            Circle()
                .fill(widgetAccent.opacity(colorScheme == .dark ? 0.22 : 0.24))
                .frame(width: 96, height: 96)
                .blur(radius: 1.0)
                .offset(x: 58, y: 48)

            switch widgetFamily {
            case .systemMedium:
                mediumContent
            default:
                smallContent
            }
        }
        .widgetBackground()
    }

    private var widgetGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color(red: 0.02, green: 0.07, blue: 0.11),
                    Color(red: 0.04, green: 0.15, blue: 0.20)
                ]
                : [
                    Color(red: 0.93, green: 0.98, blue: 1.0),
                    Color(red: 0.80, green: 0.94, blue: 0.98)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var widgetPrimaryText: Color {
        colorScheme == .dark
            ? Color(red: 0.90, green: 0.96, blue: 1.0)
            : Color(red: 0.13, green: 0.25, blue: 0.33)
    }

    private var widgetSecondaryText: Color {
        colorScheme == .dark
            ? Color(red: 0.66, green: 0.77, blue: 0.86)
            : Color(red: 0.42, green: 0.54, blue: 0.62)
    }

    private var widgetAccent: Color {
        colorScheme == .dark
            ? Color(red: 0.32, green: 0.80, blue: 0.82)
            : Color(red: 0.57, green: 0.88, blue: 0.91)
    }

    private var widgetHighlight: Color {
        colorScheme == .dark
            ? Color(red: 0.25, green: 0.53, blue: 0.70)
            : .white
    }

    private var widgetMasteredText: Color {
        colorScheme == .dark
            ? Color(red: 0.58, green: 0.94, blue: 0.74)
            : Color(red: 0.12, green: 0.47, blue: 0.30)
    }

    private var smallContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Kikaria")
                .font(.system(size: 21, weight: .semibold, design: .serif))
                .foregroundStyle(widgetPrimaryText)

            Spacer(minLength: 6)

            Text(entry.snapshot.presetName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(widgetSecondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text("\(entry.snapshot.masteredCount) / \(entry.snapshot.dailyGoal)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(widgetMasteredText)

            HStack(spacing: 5) {
                Image(systemName: "calendar")
                    .font(.caption.weight(.semibold))
                Text(countdownText)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(colorScheme == .dark ? Color(red: 0.62, green: 0.86, blue: 1.0) : Color(red: 0.39, green: 0.73, blue: 0.96))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
    }

    private var mediumContent: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 9) {
                Text("Kikaria")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(widgetPrimaryText)

                Text(entry.snapshot.presetName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(widgetSecondaryText)
                    .lineLimit(1)

                Spacer()

                Text("今日复习 \(entry.snapshot.todayReviewCount) 次")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(widgetSecondaryText)
            }

            VStack(alignment: .leading, spacing: 10) {
                WidgetMetricBubble(title: "已掌握", value: "\(entry.snapshot.masteredCount)")
                WidgetMetricBubble(title: "目标", value: "\(entry.snapshot.dailyGoal)")
                WidgetMetricBubble(title: "倒数", value: countdownText)
            }
        }
        .padding(18)
    }

    private var countdownText: String {
        if let countdownDays = entry.snapshot.countdownDays {
            return "\(countdownDays) 天"
        }

        return "--"
    }
}

private struct WidgetMetricBubble: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? Color(red: 0.66, green: 0.77, blue: 0.86) : Color(red: 0.42, green: 0.54, blue: 0.62))
                .frame(width: 42, alignment: .leading)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(colorScheme == .dark ? Color(red: 0.90, green: 0.96, blue: 1.0) : Color(red: 0.13, green: 0.25, blue: 0.33))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background((colorScheme == .dark ? Color(red: 0.06, green: 0.13, blue: 0.18).opacity(0.52) : .white.opacity(0.48)), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(colorScheme == .dark ? 0.22 : 0.42), lineWidth: 1)
        }
    }
}

private extension View {
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) {
                WidgetTheme.backgroundGradient
            }
        } else {
            background(WidgetTheme.backgroundGradient)
        }
    }
}

struct KikariaProgressWidget: Widget {
    let kind = "KikariaProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KikariaWidgetProvider()) { entry in
            KikariaWidgetView(entry: entry)
        }
        .configurationDisplayName("Kikaria 学习概览")
        .description("查看当前预设的已掌握、目标和倒数日。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct KikariaWidgetBundle: WidgetBundle {
    var body: some Widget {
        KikariaProgressWidget()
    }
}
