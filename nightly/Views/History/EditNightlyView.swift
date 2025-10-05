//
//  EditNightlyView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

//
//  EditNightlyView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//  Updated: adds Mood editing while preserving original structure.
//

import SwiftUI

struct EditNightlyView: View {
  @EnvironmentObject private var store: NightlyStore
  let entryID: UUID

  @Environment(\.dismiss) private var dismiss

  @State private var questions: [String] = []
  @State private var answers: [String] = []
  @State private var mood: Mood = .neutral   // NEW

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {

          // NEW: Mood editor at the top
          MoodPicker(mood: $mood)

          ForEach(questions.indices, id: \.self) { i in
            QuestionCard(question: questions[i], answer: bindingForAnswer(i))
          }

          Button {
            saveChanges()
          } label: {
            HStack(spacing: 8) {
              Image(systemName: "tray.and.arrow.down")
              Text("Save Changes").fontWeight(.semibold)
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
      .navigationTitle("Edit Nightly")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") { dismiss() }
        }
      }
      .onAppear(perform: loadEntryIfNeeded)
    }
  }

  private func loadEntryIfNeeded() {
    guard questions.isEmpty else { return }
    guard let entry = store.entries.first(where: { $0.id == entryID }) else { return }
    questions = entry.questions

    // Answers (trim and align to current questions count)
    let trimmed = entry.answers.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    answers = trimmed.count < questions.count
      ? trimmed + Array(repeating: "", count: questions.count - trimmed.count)
      : Array(trimmed.prefix(questions.count))

    // NEW: seed mood from entry
    mood = entry.mood
  }

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

  private func saveChanges() {
    let cleaned = (0..<questions.count).map { i in
      (i < answers.count ? answers[i] : "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Save answers and mood (works with the NightlyStore you shared)
    store.updateAnswers(for: entryID, answers: cleaned)
    store.updateMood(for: entryID, mood: mood)

    // If you added the combined method earlier, you can use this one-liner instead:
    // store.update(for: entryID, questions: questions, answers: cleaned, mood: mood)

    dismiss()
  }
}
