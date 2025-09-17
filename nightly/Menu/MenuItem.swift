//
//  MenuItem.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

enum MenuItem: String, CaseIterable, Identifiable {
  case new = "New Nightly"
  case history = "Past Nightlies"
  case sobriety = "Sobriety Counter"
  case onAwakening = "On Awakening"
  case serenity = "Serenity Prayer"

  var id: String { rawValue }

  var systemImage: String {
    switch self {
      case .new: return "square.and.pencil"
      case .history: return "clock.arrow.circlepath"
      case .sobriety: return "heart.text.square"
      case .onAwakening: return "sun.max"
      case .serenity: return "hands.sparkles"
    }
  }
}
