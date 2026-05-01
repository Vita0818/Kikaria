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
    var createdAt: Date
    var updatedAt: Date
}

extension KnowledgePoint {
    static let samples: [KnowledgePoint] = {
        let now = Date(timeIntervalSince1970: 1_777_654_400)

        return [
            KnowledgePoint(
                id: UUID(uuidString: "E3DD3564-99E2-41E5-8B92-4D5938507801")!,
                title: "Limit Preservation of Sign",
                tags: ["Calculus", "Limit", "Basic"],
                hint: "If the limit is positive, the function value is positive nearby.",
                content: "If lim f(x) = A and A > 0, then f(x) > 0 in some sufficiently small neighborhood.",
                isReinforced: false,
                createdAt: now,
                updatedAt: now
            ),
            KnowledgePoint(
                id: UUID(uuidString: "B0F2855E-0E8A-4C67-99F6-4382042DA1EB")!,
                title: "Rolle's Theorem",
                tags: ["Calculus", "Mean Value Theorem"],
                hint: "Check continuity, differentiability, and equal endpoint values.",
                content: "If f is continuous on [a,b], differentiable on (a,b), and f(a) = f(b), then there is a point c in (a,b) with f'(c) = 0.",
                isReinforced: false,
                createdAt: now,
                updatedAt: now
            ),
            KnowledgePoint(
                id: UUID(uuidString: "13D41F98-44B9-4843-B269-B69B6D2AD40C")!,
                title: "Derivative Product Rule",
                tags: ["Calculus", "Derivative", "Basic"],
                hint: "Differentiate one factor at a time, then add the two terms.",
                content: "For differentiable functions f and g, (fg)' = f'g + fg'.",
                isReinforced: false,
                createdAt: now,
                updatedAt: now
            ),
            KnowledgePoint(
                id: UUID(uuidString: "0617A73C-8F30-48E7-8C1E-E44FE9D66E5B")!,
                title: "Matrix Multiplication Size",
                tags: ["Linear Algebra", "Matrix", "Basic"],
                hint: "The inner dimensions must match.",
                content: "An m by n matrix can multiply an n by p matrix, and the result is an m by p matrix.",
                isReinforced: false,
                createdAt: now,
                updatedAt: now
            ),
            KnowledgePoint(
                id: UUID(uuidString: "29C78EBF-5D0C-4DD5-A56E-D3BCFF1267E9")!,
                title: "Linear Independence",
                tags: ["Linear Algebra", "Vector Space"],
                hint: "Only the trivial coefficient combination gives the zero vector.",
                content: "Vectors v1 through vn are linearly independent if c1v1 + ... + cnvn = 0 implies c1 = ... = cn = 0.",
                isReinforced: false,
                createdAt: now,
                updatedAt: now
            ),
            KnowledgePoint(
                id: UUID(uuidString: "C4F665A4-E3D0-4BE7-8B77-F9F83014625B")!,
                title: "Bayes' Theorem",
                tags: ["Probability", "Conditional Probability"],
                hint: "Reverse a conditional probability using the prior and evidence.",
                content: "P(A | B) = P(B | A)P(A) / P(B), assuming P(B) is not zero.",
                isReinforced: false,
                createdAt: now,
                updatedAt: now
            )
        ]
    }()
}
