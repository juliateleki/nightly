//
//  DateFormatters.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import Foundation

enum DF {
  static let full: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .full
    df.timeStyle = .short
    return df
  }()

  static let long: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .long
    df.timeStyle = .short
    return df
  }()
}
