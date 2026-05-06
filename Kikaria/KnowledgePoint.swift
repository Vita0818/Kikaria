//
//  KnowledgePoint.swift
//  Kikaria
//
//  Created by Codex on 2026/5/1.
//

import Foundation

struct KnowledgePoint: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var tags: [String]
    var hint: String
    var content: String
    var isReinforced: Bool
    var reinforcementCount: Int
    var lastReinforcedAt: Date?
    var isMastered: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        title: String,
        tags: [String],
        hint: String,
        content: String,
        isReinforced: Bool = false,
        isMastered: Bool = false,
        createdAt: Date,
        updatedAt: Date,
        reinforcementCount: Int? = nil,
        lastReinforcedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.tags = tags
        self.hint = hint
        self.content = content
        let migratedReinforcementCount = max(0, reinforcementCount ?? (isReinforced ? 1 : 0))
        self.reinforcementCount = migratedReinforcementCount
        self.isReinforced = migratedReinforcementCount > 0
        self.lastReinforcedAt = migratedReinforcementCount > 0 ? lastReinforcedAt : nil
        self.isMastered = isMastered
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case tags
        case hint
        case content
        case isReinforced
        case reinforcementCount
        case lastReinforcedAt
        case isMastered
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        tags = try container.decode([String].self, forKey: .tags)
        hint = try container.decode(String.self, forKey: .hint)
        content = try container.decode(String.self, forKey: .content)
        let legacyIsReinforced = try container.decodeIfPresent(Bool.self, forKey: .isReinforced) ?? false
        let decodedReinforcementCount = try container.decodeIfPresent(Int.self, forKey: .reinforcementCount)
        reinforcementCount = max(0, decodedReinforcementCount ?? (legacyIsReinforced ? 1 : 0))
        isReinforced = reinforcementCount > 0
        lastReinforcedAt = try container.decodeIfPresent(Date.self, forKey: .lastReinforcedAt)
        if reinforcementCount == 0 {
            lastReinforcedAt = nil
        }
        isMastered = try container.decodeIfPresent(Bool.self, forKey: .isMastered) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(tags, forKey: .tags)
        try container.encode(hint, forKey: .hint)
        try container.encode(content, forKey: .content)
        try container.encode(reinforcementCount > 0, forKey: .isReinforced)
        try container.encode(reinforcementCount, forKey: .reinforcementCount)
        try container.encodeIfPresent(lastReinforcedAt, forKey: .lastReinforcedAt)
        try container.encode(isMastered, forKey: .isMastered)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }

    mutating func addReinforcement(at date: Date = Date()) -> Int {
        reinforcementCount = max(0, reinforcementCount) + 1
        isReinforced = true
        lastReinforcedAt = date
        updatedAt = date
        return reinforcementCount
    }

    mutating func clearReinforcement(at date: Date = Date()) {
        reinforcementCount = 0
        isReinforced = false
        lastReinforcedAt = nil
        updatedAt = date
    }
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

    static func markdownText(from points: [KnowledgePoint]) -> String {
        points.map { point in
            """
            # \(point.title)

            tags: \(point.tags.joined(separator: ", "))

            hint:
            \(point.hint)

            content:
            \(point.content)
            """
        }
        .joined(separator: "\n\n---\n\n")
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

struct KnowledgePreset: Identifiable, Equatable, Codable {
    var id: String
    var name: String
    var subtitle: String
    var description: String
    var category: String
    var markdownText: String
    var isBuiltIn: Bool

    init(
        id: String,
        name: String,
        subtitle: String,
        description: String,
        category: String,
        markdownText: String,
        isBuiltIn: Bool
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.description = description
        self.category = category
        self.markdownText = markdownText
        self.isBuiltIn = isBuiltIn
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case subtitle
        case description
        case category
        case markdownText
        case isBuiltIn
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? subtitle
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "自定义"
        markdownText = try container.decode(String.self, forKey: .markdownText)
        isBuiltIn = try container.decodeIfPresent(Bool.self, forKey: .isBuiltIn) ?? false
    }

    var knowledgePointCount: Int {
        (try? KnowledgePoint.parseMarkdown(markdownText).count) ?? 0
    }

    static let defaultPresetID = "advanced-math"

    static var defaultPreset: KnowledgePreset {
        all.first { $0.id == defaultPresetID } ?? all[0]
    }

    static let all: [KnowledgePreset] = [
        KnowledgePreset(
            id: "advanced-math",
            name: "高等数学知识点",
            subtitle: "微积分、线性代数基础概念",
            description: "覆盖极限、导数、矩阵和基础概率概念，适合作为 Kikaria 默认示例。",
            category: "数学",
            markdownText: KnowledgePoint.defaultMarkdownText,
            isBuiltIn: true
        ),
        KnowledgePreset(
            id: "college-english",
            name: "大学英语单词",
            subtitle: "高频词汇与短语",
            description: "用简短英文词汇卡片练习释义、用法和记忆提示。",
            category: "英语",
            markdownText: """
            # inevitable

            tags: English, Vocabulary, Adjective

            hint:
            Something that cannot be avoided.

            content:
            Inevitable means certain to happen and impossible to prevent, as in "Change is inevitable."

            ---

            # concise

            tags: English, Vocabulary, Writing

            hint:
            Short, clear, and not using unnecessary words.

            content:
            Concise writing expresses an idea clearly in few words, without losing important meaning.

            ---

            # derive

            tags: English, Vocabulary, Verb

            hint:
            To get something from a source or origin.

            content:
            Derive means to obtain or develop something from another thing, such as deriving a word from Latin.

            ---

            # take into account

            tags: English, Phrase, Academic

            hint:
            To consider something when making a decision.

            content:
            To take something into account means to include it as an important factor in your thinking.
            """,
            isBuiltIn: true
        ),
        KnowledgePreset(
            id: "anatomy",
            name: "解剖学",
            subtitle: "人体结构与基础术语",
            description: "包含骨骼、神经和呼吸系统等基础医学概念示例。",
            category: "医学",
            markdownText: """
            # femur

            tags: Anatomy, Bone, Lower Limb

            hint:
            The longest and strongest bone in the human body.

            content:
            The femur is the thigh bone. It connects the hip joint to the knee joint and supports body weight during standing and walking.

            ---

            # neuron

            tags: Anatomy, Nervous System, Cell

            hint:
            A specialized cell that transmits nerve signals.

            content:
            A neuron is a nerve cell made of a cell body, dendrites, and an axon. It receives, processes, and sends electrical or chemical signals.

            ---

            # alveoli

            tags: Anatomy, Respiratory System, Lung

            hint:
            Tiny air sacs where gas exchange occurs.

            content:
            Alveoli are small air sacs in the lungs. Oxygen enters the blood and carbon dioxide leaves the blood across their thin walls.

            ---

            # diaphragm

            tags: Anatomy, Muscle, Breathing

            hint:
            The main muscle used for breathing.

            content:
            The diaphragm is a dome-shaped muscle below the lungs. When it contracts, the chest cavity expands and air is drawn into the lungs.
            """,
            isBuiltIn: true
        ),
        KnowledgePreset(
            id: "template",
            name: "示例模板",
            subtitle: "用于后续自定义扩展",
            description: "提供最小格式样例，方便后续替换为课程或课本内容。",
            category: "模板",
            markdownText: """
            # Concept Title

            tags: Template, Concept

            hint:
            Write a short clue that helps you recall the concept.

            content:
            Write the full explanation, formula, definition, or example here.

            ---

            # Keyword Card

            tags: Template, Keyword

            hint:
            Add a memory cue or related phrase.

            content:
            Add the meaning, usage, or important details for this keyword.

            ---

            # Question Prompt

            tags: Template, Practice

            hint:
            Add the first step or a gentle reminder.

            content:
            Add the complete answer or solution process.
            """,
            isBuiltIn: true
        )
    ]
}
