//
//  ContentView.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ClockView(
            viewModel: ChessClockViewModel(
                timeControl: .normal(
                    stages: [
                        Stage(minutes: 3, seconds: 0, buffer: .increment(seconds: 2), movesInStage: nil)
                    ]
                )
            )
        )
        .statusBar(hidden: true)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
