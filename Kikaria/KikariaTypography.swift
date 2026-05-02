//
//  KikariaTypography.swift
//  Kikaria
//
//  Created by Codex on 2026/5/2.
//

import SwiftUI

enum KikariaTypography {
    static func appTitle(size: CGFloat = 39, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static func chineseLargeTitle(size: CGFloat = 34, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight)
    }

    static func chineseTitle(size: CGFloat = 32, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight)
    }

    static func chineseHeadline(size: CGFloat = 17, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight)
    }

    static func chineseBody(size: CGFloat = 15, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static func chineseButton(size: CGFloat = 17, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight)
    }

    static func chineseCaption(size: CGFloat = 12, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight)
    }

    static func tag(size: CGFloat = 12, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight)
    }

    static func number(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}
