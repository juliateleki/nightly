//
//  QuestionCard.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

struct QuestionCard: View {
  let question: String
  @Binding var answer: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(question).font(.headline)
      ZStack(alignment: .topLeading) {
        if answer.isEmpty {
          Text("Type your answer…")
            .foregroundStyle(.secondary)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
        }
        TextEditor(text: $answer)
          .padding(8)
          .frame(minHeight: 110)
          .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
          .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary, lineWidth: 1))
          .scrollContentBackground(.hidden)
          .textInputAutocapitalization(.sentences)
          .disableAutocorrection(false)
      }
    }
  }
}
