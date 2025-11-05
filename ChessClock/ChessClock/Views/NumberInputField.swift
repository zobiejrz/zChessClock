//
//  NumberInputField.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/5/25.
//

import SwiftUI

struct NumberInputField: View {
    @Binding var value: Int
    @FocusState private var isFocused: Bool  // Track focus for the TextField

    var body: some View {
        TextField("", text: Binding(
            get: { String(value) },
            set: { newValue in
                if let intValue = Int(newValue) {
                    value = intValue
                } else if newValue.isEmpty {
                    value = 0
                }
            }
        ))
        .keyboardType(.numberPad)
        .focused($isFocused)
        .frame(width: 60)
        .multilineTextAlignment(.center)
        .textFieldStyle(.roundedBorder)
    }
}
