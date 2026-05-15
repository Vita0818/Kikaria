//
//  KikariaMathText.swift
//  Kikaria
//
//  Created by Codex on 2026/5/10.
//

import SwiftUI

struct KikariaMathBlockFramePreferenceKey: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct KikariaMathText: View {
    let text: String
    var fontSize: CGFloat
    var textColor: Color
    var accentColor: Color
    var lineSpacing: CGFloat
    var usesSystemChineseFont: Bool
    var usesGenerousFormulaSpacing: Bool

    private let tokens: [KikariaLatexToken]

    init(
        _ text: String,
        fontSize: CGFloat,
        textColor: Color,
        accentColor: Color,
        lineSpacing: CGFloat = 3,
        usesSystemChineseFont: Bool = false,
        usesGenerousFormulaSpacing: Bool = false
    ) {
        self.text = text
        self.fontSize = fontSize
        self.textColor = textColor
        self.accentColor = accentColor
        self.lineSpacing = lineSpacing
        self.usesSystemChineseFont = usesSystemChineseFont
        self.usesGenerousFormulaSpacing = usesGenerousFormulaSpacing
        tokens = KikariaLatexParser.tokenize(text)
    }

    var body: some View {
        if let unchangedText = unchangedPlainText {
            mathPlainText(unchangedText)
                .foregroundStyle(textColor)
                .lineSpacing(effectiveLineSpacing)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            VStack(alignment: .leading, spacing: blockVerticalSpacing) {
                ForEach(Array(displayBlocks.enumerated()), id: \.offset) { _, block in
                    switch block {
                    case .paragraph(let segments):
                        let items = inlineItems(from: segments)
                        KikariaInlineMathFlow(horizontalSpacing: 0.5, rowSpacing: effectiveLineSpacing) {
                            ForEach(items.indices, id: \.self) { index in
                                inlineItemView(items[index])
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    case .blockMath(let source, let body):
                        blockMathView(source: source, body: body)

                    case .blankLine:
                        Color.clear
                            .frame(height: fontSize * 0.35)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var unchangedPlainText: String? {
        guard tokens.count == 1,
              case .text(let value) = tokens[0],
              value == text
        else {
            return nil
        }

        return value
    }

    private var displayBlocks: [KikariaMathTextBlock] {
        var blocks: [KikariaMathTextBlock] = []
        var currentSegments: [KikariaInlineMathSegment] = []

        func flushParagraph() {
            if currentSegments.isEmpty {
                blocks.append(.blankLine)
            } else {
                appendParagraphOrStandaloneMath(currentSegments, to: &blocks)
                currentSegments.removeAll()
            }
        }

        func appendText(_ value: String) {
            let parts = value.components(separatedBy: "\n")
            for partIndex in parts.indices {
                if !parts[partIndex].isEmpty {
                    currentSegments.append(.text(parts[partIndex]))
                }

                if partIndex < parts.index(before: parts.endIndex) {
                    flushParagraph()
                }
            }
        }

        for token in tokens {
            switch token {
            case .text(let value):
                appendText(value)
            case .fallback(let value):
                appendText(value)
            case .inlineMath(let source, let body):
                currentSegments.append(.inlineMath(source: source, body: body))
            case .blockMath(let source, let body):
                if !currentSegments.isEmpty {
                    appendParagraphOrStandaloneMath(currentSegments, to: &blocks)
                    currentSegments.removeAll()
                }
                blocks.append(.blockMath(source: source, body: body))
            }
        }

        if !currentSegments.isEmpty {
            appendParagraphOrStandaloneMath(currentSegments, to: &blocks)
        }

        return normalizedBlocks(blocks.isEmpty ? [.paragraph([.text("")])] : blocks)
    }

    private func appendParagraphOrStandaloneMath(
        _ segments: [KikariaInlineMathSegment],
        to blocks: inout [KikariaMathTextBlock]
    ) {
        if let standaloneMath = standaloneInlineMath(in: segments) {
            blocks.append(.blockMath(source: standaloneMath.source, body: standaloneMath.body))
        } else {
            blocks.append(.paragraph(segments))
        }
    }

    private func standaloneInlineMath(
        in segments: [KikariaInlineMathSegment]
    ) -> (source: String, body: String)? {
        var standaloneMath: (source: String, body: String)?

        for segment in segments {
            switch segment {
            case .text(let value):
                if !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return nil
                }
            case .inlineMath(let source, let body):
                guard standaloneMath == nil else {
                    return nil
                }
                standaloneMath = (source, body)
            }
        }

        return standaloneMath
    }

    private var blockVerticalSpacing: CGFloat {
        let baseSpacing = max(effectiveLineSpacing + 6, 9)
        return usesGenerousFormulaSpacing ? max(baseSpacing, 15) : baseSpacing
    }

    private var effectiveLineSpacing: CGFloat {
        usesGenerousFormulaSpacing ? max(lineSpacing, 7) : lineSpacing
    }

    private var blockFontSize: CGFloat {
        min(max(fontSize * 1.34, fontSize + 5), fontSize + 8)
    }

    private func mathPlainText(_ value: String) -> Text {
        #if os(macOS)
        if usesSystemChineseFont {
            return KikariaTypography.mixedText(
                value,
                chineseFont: .system(size: fontSize, weight: .regular),
                serifFont: .system(size: fontSize, weight: .regular, design: .serif)
            )
        }
        #endif

        return Text(value)
            .font(.system(size: fontSize, weight: .regular, design: .serif))
    }

    private func inlineItems(from segments: [KikariaInlineMathSegment]) -> [KikariaInlineMathItem] {
        let rawItems = segments.flatMap { segment in
            switch segment {
            case .text(let value):
                return splitPlainTextIntoItems(value)
            case .inlineMath(let source, let body):
                return [.inlineMath(source: source, body: body)]
            }
        }

        return attachingTrailingPunctuation(in: rawItems)
    }

    private func splitPlainTextIntoItems(_ value: String) -> [KikariaInlineMathItem] {
        var items: [KikariaInlineMathItem] = []
        var currentWord = ""

        func flushWord() {
            guard !currentWord.isEmpty else {
                return
            }

            items.append(.text(currentWord))
            currentWord.removeAll(keepingCapacity: true)
        }

        for character in value {
            if character.isASCIIWordCharacter {
                currentWord.append(character)
            } else {
                flushWord()
                items.append(.text(String(character)))
            }
        }

        flushWord()
        return items
    }

    private func attachingTrailingPunctuation(in items: [KikariaInlineMathItem]) -> [KikariaInlineMathItem] {
        var result: [KikariaInlineMathItem] = []

        for item in items {
            if case .text(let value) = item,
               value.isNonbreakingTrailingPunctuation,
               let previous = result.popLast() {
                result.append(previous.appendingTrailingText(value))
            } else {
                result.append(item)
            }
        }

        return result
    }

    @ViewBuilder
    private func inlineItemView(_ item: KikariaInlineMathItem) -> some View {
        switch item {
        case .text(let value):
            mathPlainText(value)
                .foregroundStyle(textColor)
                .fixedSize()
        case .inlineMath(let source, let body):
            inlineFormulaView(source: source, body: body)
        case .inlineMathWithTrailingText(let source, let body, let trailingText):
            HStack(spacing: 0) {
                inlineFormulaView(source: source, body: body)

                mathPlainText(trailingText)
                    .foregroundStyle(textColor)
                    .fixedSize()
            }
            .fixedSize()
        }
    }

    private func inlineFormulaView(source: String, body: String) -> some View {
        KikariaMathFormulaView(
            latex: body,
            fallbackSource: source,
            displayStyle: .inline,
            fontSize: fontSize * 1.02,
            textColor: textColor,
            alignment: .left,
            usesGenerousVerticalSpacing: usesGenerousFormulaSpacing
        )
            .fixedSize()
    }

    private func blockMathView(source: String, body: String) -> some View {
        let verticalPadding: CGFloat = usesGenerousFormulaSpacing ? 14 : 9

        return ViewThatFits(in: .horizontal) {
            HStack {
                Spacer(minLength: 0)

                blockRenderer(source: source, body: body)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity, alignment: .center)

            ScrollView(.horizontal, showsIndicators: false) {
                blockRenderer(source: source, body: body)
                    .padding(.horizontal, 8)
                    .padding(.vertical, verticalPadding)
            }
            .contentShape(Rectangle())
        }
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: KikariaMathBlockFramePreferenceKey.self,
                    value: [proxy.frame(in: .global)]
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func blockRenderer(source: String, body: String) -> some View {
        KikariaMathFormulaView(
            latex: body,
            fallbackSource: body,
            displayStyle: .block,
            fontSize: blockFontSize,
            textColor: textColor,
            alignment: .center,
            usesGenerousVerticalSpacing: usesGenerousFormulaSpacing
        )
            .fixedSize(horizontal: false, vertical: true)
    }

    private func normalizedBlocks(_ blocks: [KikariaMathTextBlock]) -> [KikariaMathTextBlock] {
        blocks.enumerated().compactMap { index, block in
            guard case .blankLine = block else {
                return block
            }

            let previousIsFormula = index > 0 && blocks[index - 1].isBlockMath
            let nextIsFormula = index + 1 < blocks.count && blocks[index + 1].isBlockMath
            return previousIsFormula || nextIsFormula ? nil : block
        }
    }
}

private enum KikariaMathTextBlock {
    case paragraph([KikariaInlineMathSegment])
    case blockMath(source: String, body: String)
    case blankLine

    var isBlockMath: Bool {
        if case .blockMath = self {
            return true
        }

        return false
    }
}

private enum KikariaInlineMathSegment {
    case text(String)
    case inlineMath(source: String, body: String)
}

private enum KikariaInlineMathItem {
    case text(String)
    case inlineMath(source: String, body: String)
    case inlineMathWithTrailingText(source: String, body: String, trailingText: String)

    func appendingTrailingText(_ text: String) -> KikariaInlineMathItem {
        switch self {
        case .text(let value):
            return .text(value + text)
        case .inlineMath(let source, let body):
            return .inlineMathWithTrailingText(source: source, body: body, trailingText: text)
        case .inlineMathWithTrailingText(let source, let body, let trailingText):
            return .inlineMathWithTrailingText(source: source, body: body, trailingText: trailingText + text)
        }
    }
}

private struct KikariaInlineMathFlow: Layout {
    var horizontalSpacing: CGFloat
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
            var x = bounds.minX

            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y + (row.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: item.size.width, height: item.size.height)
                )
                x += item.size.width + horizontalSpacing
            }

            y += row.height + rowSpacing
        }
    }

    private func makeRows(maxWidth: CGFloat, subviews: Subviews) -> [KikariaInlineMathFlowRow] {
        let availableWidth = maxWidth.isFinite ? maxWidth : .greatestFiniteMagnitude
        var rows: [KikariaInlineMathFlowRow] = []
        var current = KikariaInlineMathFlowRow()

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let nextWidth = current.items.isEmpty ? size.width : current.width + horizontalSpacing + size.width

            if nextWidth > availableWidth && !current.items.isEmpty {
                rows.append(current)
                current = KikariaInlineMathFlowRow()
            }

            if !current.items.isEmpty {
                current.width += horizontalSpacing
            }

            current.items.append(KikariaInlineMathFlowItem(index: index, size: size))
            current.width += size.width
            current.height = max(current.height, size.height)
        }

        if !current.items.isEmpty {
            rows.append(current)
        }

        return rows
    }
}

private struct KikariaInlineMathFlowRow {
    var items: [KikariaInlineMathFlowItem] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
}

private struct KikariaInlineMathFlowItem {
    let index: Int
    let size: CGSize
}

private extension Character {
    var isASCIIWordCharacter: Bool {
        guard unicodeScalars.count == 1,
              let scalar = unicodeScalars.first,
              scalar.value < 128
        else {
            return false
        }

        return CharacterSet.alphanumerics.contains(scalar) || scalar == "_"
    }

    var isNonbreakingTrailingPunctuation: Bool {
        "，。；：？！、）》】」』〉》〕］｝,.;:?!)]}".contains(self)
    }
}

private extension String {
    var isNonbreakingTrailingPunctuation: Bool {
        !isEmpty && allSatisfy(\.isNonbreakingTrailingPunctuation)
    }
}
