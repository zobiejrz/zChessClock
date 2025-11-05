//
//  ClockViewModel.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/5/25.
//

import Foundation
import Combine

@MainActor
final class ChessClockViewModel: ObservableObject {
    
    @Published private(set) var moveCounterA: Int = 0
    @Published private(set) var moveCounterB: Int = 0
    @Published private(set) var sideFlagged: Player? = nil
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var activePlayer: Player? = nil
    @Published private(set) var timeA: TimeInterval = 0
    @Published private(set) var timeB: TimeInterval = 0
    
    private(set) var clock: ChessClock
    private var cancellables = Set<AnyCancellable>()
    
    init(timeControl: TimeControl) {
        self.clock = ChessClock(timeControl: timeControl)
        bindToClock()
    }
    
    private func bindToClock() {
        clock.$moveCounterA.assign(to: &$moveCounterA)
        clock.$moveCounterB.assign(to: &$moveCounterB)
        clock.$sideFlagged.assign(to: &$sideFlagged)
        clock.$isRunning.assign(to: &$isRunning)
        clock.$activePlayer.assign(to: &$activePlayer)
        clock.$timeA.assign(to: &$timeA)
        clock.$timeB.assign(to: &$timeB)
    }
    
    func start(for side: Player) { clock.start(for: side) }
    func togglePause() { clock.togglePause() }
    func switchTurn() { clock.switchTurn() }
    func reset() { clock.reset() }
}
