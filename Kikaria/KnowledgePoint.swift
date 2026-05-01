//
//  KnowledgePoint.swift
//  Kikaria
//
//  Created by Codex on 2026/5/1.
//

import Foundation

struct KnowledgePoint: Identifiable, Equatable {
    let id: UUID
    var title: String
    var tags: [String]
    var hint: String
    var content: String
    var isReinforced: Bool
    var isMastered: Bool
    var createdAt: Date
    var updatedAt: Date
}

enum KnowledgePointMarkdownError: LocalizedError {
    case noValidKnowledgePoints

    var errorDescription: String? {
        switch self {
        case .noValidKnowledgePoints:
            return "No valid knowledge points were found."
        }
    }
}

extension KnowledgePoint {
    static let defaultMarkdownText = """
    # Limit Preservation of Sign

    tags: Calculus, Limit, Basic

    hint:
    If the limit is positive, the function value is positive nearby.

    content:
    If lim f(x) = A and A > 0, then f(x) > 0 in some sufficiently small neighborhood.

    ---

    # Rolle's Theorem

    tags: Calculus, Mean Value Theorem

    hint:
    Check continuity, differentiability, and equal endpoint values.

    content:
    If f is continuous on [a,b], differentiable on (a,b), and f(a) = f(b), then there is a point c in (a,b) with f'(c) = 0.

    ---

    # Derivative Product Rule

    tags: Calculus, Derivative, Basic

    hint:
    Differentiate one factor at a time, then add the two terms.

    content:
    For differentiable functions f and g, (fg)' = f'g + fg'.

    ---

    # Matrix Multiplication Size

    tags: Linear Algebra, Matrix, Basic

    hint:
    The inner dimensions must match.

    content:
    An m by n matrix can multiply an n by p matrix, and the result is an m by p matrix.

    ---

    # Linear Independence

    tags: Linear Algebra, Vector Space

    hint:
    Only the trivial coefficient combination gives the zero vector.

    content:
    Vectors v1 through vn are linearly independent if c1v1 + ... + cnvn = 0 implies c1 = ... = cn = 0.

    ---

    # Bayes' Theorem

    tags: Probability, Conditional Probability

    hint:
    Reverse a conditional probability using the prior and evidence.

    content:
    P(A | B) = P(B | A)P(A) / P(B), assuming P(B) is not zero.
    """

    static let samples: [KnowledgePoint] = {
        (try? parseMarkdown(defaultMarkdownText, date: Date(timeIntervalSince1970: 1_777_654_400))) ?? []
    }()

    static func parseMarkdown(_ markdown: String, date: Date = Date()) throws -> [KnowledgePoint] {
        let normalizedText = markdown
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let chunks = splitMarkdownIntoChunks(normalizedText)
        let points = chunks.compactMap { parseChunk($0, date: date) }

        guard !points.isEmpty else {
            throw KnowledgePointMarkdownError.noValidKnowledgePoints
        }

        return points
    }

    private static func splitMarkdownIntoChunks(_ markdown: String) -> [String] {
        var chunks: [String] = []
        var currentLines: [String] = []

        for line in markdown.components(separatedBy: "\n") {
            if line.trimmingCharacters(in: .whitespacesAndNewlines) == "---" {
                let chunk = currentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                if !chunk.isEmpty {
                    chunks.append(chunk)
                }
                currentLines.removeAll()
            } else {
                currentLines.append(line)
            }
        }

        let finalChunk = currentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        if !finalChunk.isEmpty {
            chunks.append(finalChunk)
        }

        return chunks
    }

    private static func parseChunk(_ chunk: String, date: Date) -> KnowledgePoint? {
        let lines = chunk.components(separatedBy: "\n")
        guard let titleIndex = lines.firstIndex(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            return nil
        }

        let rawTitle = lines[titleIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        guard rawTitle.hasPrefix("#") else {
            return nil
        }

        let title = rawTitle
            .drop(while: { $0 == "#" })
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            return nil
        }

        let tags = parseTags(from: lines)
        guard let hintIndex = markerIndex("hint:", in: lines),
              let contentIndex = markerIndex("content:", in: lines),
              hintIndex < contentIndex
        else {
            return nil
        }

        let hint = lines[(hintIndex + 1)..<contentIndex]
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let content = lines[(contentIndex + 1)..<lines.count]
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !hint.isEmpty, !content.isEmpty else {
            return nil
        }

        return KnowledgePoint(
            id: UUID(),
            title: title,
            tags: tags,
            hint: hint,
            content: content,
            isReinforced: false,
            isMastered: false,
            createdAt: date,
            updatedAt: date
        )
    }

    private static func parseTags(from lines: [String]) -> [String] {
        guard let tagLine = lines.first(where: {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().hasPrefix("tags:")
        }) else {
            return []
        }

        let tagText = tagLine
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .dropFirst("tags:".count)

        return tagText
            .split(whereSeparator: { $0 == "," || $0 == "，" })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func markerIndex(_ marker: String, in lines: [String]) -> Int? {
        lines.firstIndex {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == marker
        }
    }
}
