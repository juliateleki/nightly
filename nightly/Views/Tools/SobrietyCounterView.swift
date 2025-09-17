//
//  SobrietyCounterView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

struct SobrietyCounterView: View {
  @AppStorage("sobrietyStart_ts") private var sobrietyStartTS: Double = 0
  @State private var showingPicker = false
  @State private var tempDate: Date = Date()

  private var sobrietyStart: Date? {
    sobrietyStartTS > 0 ? Date(timeIntervalSince1970: sobrietyStartTS) : nil
  }

  private var daysSober: Int? {
    guard let start = sobrietyStart else { return nil }
    let cal = Calendar.current
    let startDay = cal.startOfDay(for: start)
    let today = cal.startOfDay(for: Date())
    return cal.dateComponents([.day], from: startDay, to: today).day
  }

  var body: some View {
    VStack(spacing: 20) {
      if let days = daysSober {
        Text("\(days) days sober")
          .font(.system(size: 40, weight: .bold, design: .rounded))
        if let start = sobrietyStart {
          Text("Since \(DF.long.string(from: start))").foregroundStyle(.secondary)
        }
      } else {
        Text("No sobriety date set")
          .font(.title3.weight(.semibold))
          .foregroundStyle(.secondary)
      }

      HStack(spacing: 12) {
        Button {
          tempDate = sobrietyStart ?? Date()
          showingPicker = true
        } label: {
          Label(sobrietyStart == nil ? "Set Sobriety Date" : "Change Date", systemImage: "calendar")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.tint.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        if sobrietyStart != nil {
          Button(role: .destructive) {
            sobrietyStartTS = 0
          } label: {
            Label("Clear", systemImage: "xmark.circle")
              .frame(maxWidth: .infinity)
              .padding(.vertical, 12)
              .background(Color.red.opacity(0.12))
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }
        }
      }

      Spacer()
    }
    .padding()
    .sheet(isPresented: $showingPicker) {
      NavigationStack {
        VStack(alignment: .leading, spacing: 16) {
          DatePicker("Sobriety start date", selection: $tempDate, displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .padding(.top)
          Spacer()
        }
        .padding()
        .navigationTitle("Set Date")
        .toolbar {
          ToolbarItem(placement: .topBarLeading) { Button("Cancel") { showingPicker = false } }
          ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
              sobrietyStartTS = tempDate.timeIntervalSince1970
              showingPicker = false
            }.bold()
          }
        }
      }
    }
  }
}
