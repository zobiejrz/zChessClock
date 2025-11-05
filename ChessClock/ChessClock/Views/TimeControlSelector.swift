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
        VStack(spacing: 16) {
            Button("1+1 delay Bullet") {
                timeControl = .normal(
                    stages: [
                        Stage(minutes: 1, seconds: 0, buffer: .delay(seconds: 5), movesInStage: nil)
                    ]
                )
                presented = false
            }
            
            Button("1+1 Bullet") {
                timeControl = .normal(
                    stages: [
                        Stage(minutes: 1, seconds: 0, buffer: .increment(seconds: 1), movesInStage: nil)
                    ]
                )
                presented = false
            }
            
            Button("3+2 Blitz") {
                timeControl = .normal(
                    stages: [
                        Stage(minutes: 3, seconds: 0, buffer: .increment(seconds: 2), movesInStage: nil)
                    ]
                )
                presented = false
            }
            
            Button("5+0 Rapid") {
                timeControl = .normal(
                    stages: [
                        Stage(minutes: 5, seconds: 0, buffer: .none, movesInStage: nil)
                    ]
                )
                presented = false
            }
            
            Button("10+0 Rapid") {
                timeControl = .normal(
                    stages: [
                        Stage(minutes: 10, seconds: 0, buffer: .none, movesInStage: nil)
                    ]
                )
                presented = false
            }
        }
        .buttonStyle(.bordered)
    }
}
