//
//  SideMenuRight.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

struct SideMenuRight: View {
  @Binding var isOpen: Bool
  @Binding var selection: MenuItem

  private let width: CGFloat = 300

  private var safeTopInset: CGFloat {
    #if canImport(UIKit)
    return UIApplication.shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })?
      .safeAreaInsets.top ?? 0
    #else
    return 0
    #endif
  }

  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 10) {
        HStack(spacing: 10) {
          Image(systemName: "moon.stars.fill")
          Text("nightly").font(.title3.weight(.semibold))
        }
        .padding(.bottom, 12)

        ForEach(MenuItem.allCases) { item in
          Button {
            withAnimation(.easeInOut(duration: 0.2)) {
              selection = item
              isOpen = false
            }
          } label: {
            HStack(spacing: 12) {
              Image(systemName: item.systemImage)
              Text(item.rawValue)
              Spacer()
              if item == selection {
                Image(systemName: "checkmark").foregroundStyle(.secondary)
              }
            }
            .padding(12)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(item == selection ? Color.accentColor.opacity(0.12) : .clear)
            )
          }
          .buttonStyle(.plain)
        }

        Spacer()
      }
      .padding(.top, safeTopInset + 8)
      .padding(.horizontal, 16)
      .frame(width: width, alignment: .topLeading)
      .frame(maxHeight: .infinity)
      .background(Color(.systemBackground))
      .shadow(radius: 10)
      .offset(x: isOpen ? 0 : width)
      .animation(.easeInOut(duration: 0.2), value: isOpen)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    .ignoresSafeArea(edges: .bottom)
  }
}
