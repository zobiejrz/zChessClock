//
//  TimeControlSelector.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/5/25.
//

import SwiftUI

struct TimeControlSelectorView: View {
    @Binding var timeControl: TimeControl
    @Binding var presented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Presets")) {
                    Picker("", selection: $timeControl) {
                        ForEach(Constants.presetTimeControls, id: \.self) { tc in
                            Text(tc.description)
                                .tag(tc)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Time Controls")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        presented = false
                    }.tint(.blue)
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
