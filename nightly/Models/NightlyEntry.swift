//
//  NightlyEntry.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import Foundation

struct NightlyEntry: Identifiable, Codable, Equatable {
  let id: UUID
  let date: Date
  let questions: [String]
  let answers: [String]

  init(id: UUID = UUID(), date: Date = Date(), questions: [String], answers: [String]) {
    self.id = id
    self.date = date
    self.questions = questions
    self.answers = answers
  }
}
