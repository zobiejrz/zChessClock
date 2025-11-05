//
//  ContentView.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var timeControl: TimeControl
    @State private var showSelectorView: Bool = false
    @AppStorage("lastTimeControl") private var lastTimeControlData: Data?

    init() {
        if let data = UserDefaults.standard.data(forKey: "lastTimeControl"),
           let decoded = try? JSONDecoder().decode(TimeControl.self, from: data) {
            timeControl = decoded
        } else {
            timeControl = Constants.presetTimeControls.first!
        }
    }
    
    var body: some View {
        ClockView(
            viewModel: ChessClockViewModel(timeControl: timeControl),
            showSelectorView: $showSelectorView
        )
        .statusBar(hidden: true)
        .edgesIgnoringSafeArea(.all)
        .popover(isPresented: $showSelectorView) {
            TimeControlSelectorView(timeControl: $timeControl, presented: $showSelectorView)
                .onChange(of: timeControl){ oldValue, newValue in
                    if let data = try? JSONEncoder().encode(newValue) {
                        lastTimeControlData = data
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
