//
//  NewNightlyView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

//
//  NewNightlyView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//  Updated: adds Mood picker while preserving your structure & behavior
//

import SwiftUI

struct NewNightlyView: View {
  @EnvironmentObject private var store: NightlyStore

  // Full Nightly questions (unchanged)
  private let questions: [String] = [
    "Were we resentful?",
    "Were we selfish?",
    "Were we dishonest?",
    "Were we delusional?",
    "Were we afraid?",
    "Do we owe an apology?",
    "Have we kept something to ourselves which should be discussed with another person at once?",
    "Were we kind and loving toward all?",
    "What could we have done better?",
    "Were we thinking of ourselves most of the time?",
    "Or were we thinking of what we could do for others, of what we could pack into the stream of life?",
    "What are we grateful for today?",
    "What are our corrective measures?"
  ]

  @State private var answers: [String]
  @State private var mood: Mood = .neutral   // NEW
  @State private var showingSaved = false

  init() {
    _answers = State(initialValue: Array(repeating: "", count: 13))
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {

        // NEW: Mood selection at the top
        MoodPicker(mood: $mood)

        // Your existing QuestionCard UI
        ForEach(questions.indices, id: \.self) { i in
          QuestionCard(question: questions[i], answer: bindingForAnswer(i))
        }

        Button(action: saveNightly) {
          HStack(spacing: 8) {
            Image(systemName: "tray.and.arrow.down")
            Text("Save Nightly").fontWeight(.semibold)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .background(.tint.opacity(0.15))
          .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top)
      }
      .padding()
    }
    .alert("Saved!", isPresented: $showingSaved) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("Your nightly has been added to History.")
    }
    .onAppear { ensureAnswerCapacity() }
  }

  // MARK: - Helpers (unchanged)
  private func bindingForAnswer(_ i: Int) -> Binding<String> {
    Binding(
      get: { i < answers.count ? answers[i] : "" },
      set: { newValue in
        if i >= answers.count {
          answers.append(contentsOf: Array(repeating: "", count: i - answers.count + 1))
        }
        answers[i] = newValue
      }
    )
  }

  private func ensureAnswerCapacity() {
    if answers.count < questions.count {
      answers.append(contentsOf: Array(repeating: "", count: questions.count - answers.count))
    } else if answers.count > questions.count {
      answers = Array(answers.prefix(questions.count))
    }
  }

  private func saveNightly() {
    let trimmed: [String] = (0..<questions.count).map { i in
      (i < answers.count ? answers[i] : "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    // Do not save if all answers are empty
    guard trimmed.contains(where: { !$0.isEmpty }) else { return }

    // NEW: Save with mood (see NightlyStore extension below)
    store.add(questions: questions, answers: trimmed, mood: mood)

    // Reset state
    answers = Array(repeating: "", count: questions.count)
    endEditing()
    showingSaved = true
  }
}

private extension NewNightlyView {
  func endEditing() {
    #if canImport(UIKit)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
    #endif
  }
}
