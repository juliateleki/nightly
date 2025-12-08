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
    ZStack(alignment: .trailing) {
      VStack(alignment: .leading, spacing: 16) {
        // Header row
        HStack(spacing: 10) {
          Image(systemName: "moon.stars.fill")
          Text("nightly")
            .font(.title3.weight(.semibold))
          Spacer()
          Button {
            withAnimation(.easeInOut(duration: 0.2)) {
              isOpen = false
            }
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 16, weight: .semibold))
              .padding(8)
              .contentShape(Rectangle())
          }
        }
        .padding(.bottom, 8)

        // Menu items
        ForEach(MenuItem.allCases) { item in
          Button {
            selection = item
            withAnimation(.easeInOut(duration: 0.2)) {
              isOpen = false
            }
          } label: {
            HStack(spacing: 12) {
              Image(systemName: item.systemImage)
              Text(item.rawValue)
                .font(.system(size: 17,
                              weight: selection == item ? .semibold : .regular))
              Spacer()
              if item == selection {
                Image(systemName: "checkmark")
                  .foregroundStyle(.secondary)
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
      .frame(width: width, alignment: .topLeading)   // ✅ valid
      .frame(maxHeight: .infinity)                   // ✅ separate call
      .background(Color(.systemBackground))
      .shadow(radius: 10)
      .offset(x: isOpen ? 0 : width)                 // slide from right
      .animation(.easeInOut(duration: 0.2), value: isOpen)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    .ignoresSafeArea(edges: .bottom)
  }
}
