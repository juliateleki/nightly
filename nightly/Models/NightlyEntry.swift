import Foundation

public struct NightlyEntry: Identifiable, Codable, Equatable {
  public let id: UUID
  public let date: Date
  public let questions: [String]
  public let answers: [String]
  public var mood: Mood // NEW

  public init(id: UUID = UUID(),
              date: Date = Date(),
              questions: [String],
              answers: [String],
              mood: Mood = .neutral) { // default
    self.id = id
    self.date = date
    self.questions = questions
    self.answers = answers
    self.mood = mood
  }

  enum CodingKeys: String, CodingKey { case id, date, questions, answers, mood }

  // Backward-compatible decoding for existing JSON without `mood`
  public init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    id = try c.decode(UUID.self, forKey: .id)
    date = try c.decode(Date.self, forKey: .date)
    questions = try c.decode([String].self, forKey: .questions)
    answers = try c.decode([String].self, forKey: .answers)
    mood = (try? c.decode(Mood.self, forKey: .mood)) ?? .neutral // migrate
  }
}
