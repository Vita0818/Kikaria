//
//  KikariaMathFormulaView.swift
//  Kikaria
//
//  Created by Codex on 2026/5/10.
//

import SwiftMath
import SwiftUI
import UIKit

enum KikariaFormulaDisplayStyle {
    case inline
    case block
}

enum KikariaFormulaAlignment {
    case left
    case center
}

struct KikariaMathFormulaView: View {
    let latex: String
    let fallbackSource: String
    var displayStyle: KikariaFormulaDisplayStyle
    var fontSize: CGFloat
    var textColor: Color
    var alignment: KikariaFormulaAlignment

    @State private var renderFailed = false

    var body: some View {
        if renderFailed || normalizedLatex.isEmpty {
            fallbackView
        } else {
            KikariaSwiftMathLabel(
                latex: normalizedLatex,
                displayStyle: displayStyle,
                fontSize: fontSize,
                textColor: textColor,
                alignment: alignment,
                renderFailed: $renderFailed
            )
            .fixedSize()
            .accessibilityLabel(fallbackSource)
        }
    }

    private var normalizedLatex: String {
        latex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\dfrac", with: "\\frac")
            .replacingOccurrences(of: "\\tfrac", with: "\\frac")
    }

    private var fallbackView: some View {
        Text(fallbackSource)
            .font(.system(size: fallbackFontSize, weight: .regular, design: .serif))
            .foregroundStyle(textColor.opacity(0.82))
            .fixedSize()
    }

    private var fallbackFontSize: CGFloat {
        switch displayStyle {
        case .inline:
            return fontSize * 0.95
        case .block:
            return fontSize * 0.9
        }
    }
}

private struct KikariaSwiftMathLabel: UIViewRepresentable {
    let latex: String
    var displayStyle: KikariaFormulaDisplayStyle
    var fontSize: CGFloat
    var textColor: Color
    var alignment: KikariaFormulaAlignment

    @Binding var renderFailed: Bool

    func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ label: MTMathUILabel, context: Context) {
        label.displayErrorInline = false
        label.labelMode = labelMode
        label.textAlignment = textAlignment
        label.textColor = MTColor(textColor)
        label.contentInsets = contentInsets

        if let mathFont = MTFontManager().font(withName: MathFont.latinModernFont.rawValue, size: fontSize) {
            label.font = mathFont
        }
        label.fontSize = fontSize
        label.latex = latex

        label.invalidateIntrinsicContentSize()

        let hasError = label.error != nil
        if renderFailed != hasError {
            DispatchQueue.main.async {
                renderFailed = hasError
            }
        }
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView label: MTMathUILabel,
        context: Context
    ) -> CGSize? {
        let size = label.intrinsicContentSize
        let expansion = measurementSafetyExpansion
        return CGSize(
            width: ceil(max(size.width + expansion.width, 1)),
            height: ceil(max(size.height + expansion.height, 1))
        )
    }

    private var labelMode: MTMathUILabelMode {
        switch displayStyle {
        case .inline:
            return .text
        case .block:
            return .display
        }
    }

    private var textAlignment: MTTextAlignment {
        switch alignment {
        case .left:
            return .left
        case .center:
            return .center
        }
    }

    private var contentInsets: MTEdgeInsets {
        switch displayStyle {
        case .inline:
            return MTEdgeInsets(top: 2, left: 0, bottom: 2, right: 1)
        case .block:
            return MTEdgeInsets(top: 4, left: 4, bottom: 4, right: 8)
        }
    }

    private var measurementSafetyExpansion: CGSize {
        switch displayStyle {
        case .inline:
            return CGSize(width: 0, height: 2)
        case .block:
            return CGSize(width: 4, height: 2)
        }
    }
}
