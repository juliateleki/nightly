//
//  ContentView.swift
//  nightly
//
//  Created by Julia Teleki on 8/22/25.
//

import SwiftUI

struct ContentView: View {
    // Your questions
    private let questions: [String] = [
        "Were we resentful?",
        "Were we selfish?",
        "Were we dishonest?",
        "Were we afraid?",
        "Do we owe an apology?",
        "Have we kept something to ourselves which should be discussed with another person at once?",
        "Were we kind and loving toward all?",
        "What could we have done better?",
        "Were we thinking of ourselves most of the time?",
        "Or were we thinking of what we could do for others, of what we could pack into the stream of life?"
    ]

    // One answer per question (same order)
    @State private var answers: [String]
    @FocusState private var focusedIndex: Int?

    init() {
        _answers = State(initialValue: Array(repeating: "", count: questions.count))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(questions.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(questions[i])
                                .font(.headline)

                            ZStack(alignment: .topLeading) {
                                // Placeholder
                                if answers[i].isEmpty {
                                    Text("Type your answer…")
                                        .foregroundStyle(.secondary)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                }

                                TextEditor(text: $answers[i])
                                    .focused($focusedIndex, equals: i)
                                    .padding(8)
                                    .frame(minHeight: 100)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.quaternary, lineWidth: 1)
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                    )
                                    .scrollContentBackground(.hidden) // cleaner on iOS 16+
                                    .textInputAutocapitalization(.sentences)
                                    .disableAutocorrection(false)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Nightly Inventory")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedIndex = nil }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
