//
//  ContentView.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var timeControl: TimeControl = Constants.presetTimeControls.first!
    @State private var showSelectorView: Bool = false
    
    var body: some View {
        ClockView(
            viewModel: ChessClockViewModel(timeControl: timeControl),
            showSelectorView: $showSelectorView
        )
        .statusBar(hidden: true)
        .edgesIgnoringSafeArea(.all)
        .popover(isPresented: $showSelectorView) {
            TimeControlSelectorView(timeControl: $timeControl, presented: $showSelectorView)
        }
    }
}

#Preview {
    ContentView()
}
