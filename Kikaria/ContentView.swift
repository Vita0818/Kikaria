//
//  ContentView.swift
//  Kikaria
//
//  Created by Vita on 2026/5/1.
//

import SwiftUI

struct ContentView: View {
    @State private var knowledgePoints = KnowledgePoint.samples
    @State private var selectedTags = Set<String>()

    private var allTags: [String] {
        Array(Set(knowledgePoints.flatMap(\.tags))).sorted()
    }

    private var reinforcedCount: Int {
        knowledgePoints.filter(\.isReinforced).count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kikaria")
                            .font(.largeTitle.bold())
                        Text("Local memorization review")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("Tags") {
                    ForEach(allTags, id: \.self) { tag in
                        Button {
                            toggleTag(tag)
                        } label: {
                            HStack {
                                Text(tag)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedTags.contains(tag) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Section {
                    NavigationLink {
                        ReviewView(
                            knowledgePoints: $knowledgePoints,
                            selectedTags: selectedTags
                        )
                    } label: {
                        Label("Start Review", systemImage: "play.fill")
                    }
                    .disabled(selectedTags.isEmpty)

                    NavigationLink {
                        ReinforcementView(knowledgePoints: $knowledgePoints)
                    } label: {
                        HStack {
                            Label("Reinforcement", systemImage: "tray.full")
                            Spacer()
                            Text("\(reinforcedCount)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Home")
        }
    }

    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}

struct ReviewView: View {
    @Binding var knowledgePoints: [KnowledgePoint]
    let selectedTags: Set<String>

    @State private var currentPointID: KnowledgePoint.ID?
    @State private var isShowingHint = false
    @State private var isShowingContent = false

    private var matchingPoints: [KnowledgePoint] {
        knowledgePoints.filter { point in
            point.tags.contains { selectedTags.contains($0) }
        }
    }

    private var currentPoint: KnowledgePoint? {
        guard let currentPointID else {
            return nil
        }

        return knowledgePoints.first { $0.id == currentPointID }
    }

    var body: some View {
        Group {
            if matchingPoints.isEmpty {
                ContentUnavailableView(
                    "No Matching Points",
                    systemImage: "tag.slash",
                    description: Text("Select a different tag set from Home.")
                )
            } else if let currentPoint {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(currentPoint.title)
                                .font(.title.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)

                            TagRow(tags: currentPoint.tags)
                        }

                        if isShowingHint {
                            InfoBlock(title: "Hint", text: currentPoint.hint)
                        }

                        if isShowingContent {
                            InfoBlock(title: "Content", text: currentPoint.content)
                        }

                        VStack(spacing: 12) {
                            Button {
                                isShowingHint = true
                            } label: {
                                Label("Show Hint", systemImage: "lightbulb")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)

                            Button {
                                isShowingContent = true
                            } label: {
                                Label("Show Content", systemImage: "doc.text")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)

                            Button {
                                addCurrentPointToReinforcement()
                            } label: {
                                Label(
                                    currentPoint.isReinforced ? "Added to Reinforcement" : "Add to Reinforcement",
                                    systemImage: currentPoint.isReinforced ? "checkmark.circle.fill" : "plus.circle"
                                )
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!isShowingContent || currentPoint.isReinforced)

                            Button {
                                chooseRandomPoint()
                            } label: {
                                Label("Next Random Point", systemImage: "shuffle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if currentPointID == nil {
                chooseRandomPoint()
            }
        }
    }

    private func chooseRandomPoint() {
        currentPointID = matchingPoints.randomElement()?.id
        isShowingHint = false
        isShowingContent = false
    }

    private func addCurrentPointToReinforcement() {
        guard let currentPointID,
              let index = knowledgePoints.firstIndex(where: { $0.id == currentPointID })
        else {
            return
        }

        knowledgePoints[index].isReinforced = true
        knowledgePoints[index].updatedAt = Date()
    }
}

struct ReinforcementView: View {
    @Binding var knowledgePoints: [KnowledgePoint]

    private var reinforcedPoints: [KnowledgePoint] {
        knowledgePoints.filter(\.isReinforced)
    }

    var body: some View {
        Group {
            if reinforcedPoints.isEmpty {
                ContentUnavailableView(
                    "No Reinforcement Points",
                    systemImage: "tray",
                    description: Text("Add points from Review after showing their content.")
                )
            } else {
                List {
                    ForEach(reinforcedPoints) { point in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(point.title)
                                .font(.headline)

                            TagRow(tags: point.tags)

                            InfoBlock(title: "Hint", text: point.hint)
                            InfoBlock(title: "Content", text: point.content)

                            Button(role: .destructive) {
                                removeFromReinforcement(point)
                            } label: {
                                Label("Remove", systemImage: "minus.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle("Reinforcement")
    }

    private func removeFromReinforcement(_ point: KnowledgePoint) {
        guard let index = knowledgePoints.firstIndex(where: { $0.id == point.id }) else {
            return
        }

        knowledgePoints[index].isReinforced = false
        knowledgePoints[index].updatedAt = Date()
    }
}

struct TagRow: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.thinMaterial, in: Capsule())
                }
            }
        }
    }
}

struct InfoBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(text)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ContentView()
}
