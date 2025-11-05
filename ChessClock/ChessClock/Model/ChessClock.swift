//
//  ChessClock.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/5/25.
//

import Foundation
import Combine

@MainActor
final class ChessClock: ObservableObject {
    
    // MARK: - Published State
    @Published private(set) var timeA: TimeInterval
    @Published private(set) var timeB: TimeInterval
    @Published private(set) var activePlayer: Player? = nil
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var sideFlagged: Player? = nil
    @Published private(set) var moveCounterA: Int = 0
    @Published private(set) var moveCounterB: Int = 0
    
    // MARK: - Config
    let timeControl: TimeControl
    private let tickRate: TimeInterval = 0.01
    private var timer: Timer?
    private var delayRemaining: TimeInterval = 0
    
    private var clockStageA: Int = 0
    private var clockStageB: Int = 0
    private var movesThisStageA: Int = 0
    private var movesThisStageB: Int = 0
    
    // MARK: - Init
    init(timeControl: TimeControl) {
        self.timeControl = timeControl
        switch timeControl {
        case .normal(let stages):
            clockStageA = 0
            clockStageB = 0
            let firstStage = stages.first!
            timeA = TimeInterval(firstStage.minutes * 60 + firstStage.seconds)
            timeB = TimeInterval(firstStage.minutes * 60 + firstStage.seconds)
        case .hourglass(let baseTimeSeconds):
            self.timeA = TimeInterval(baseTimeSeconds)
            self.timeB = TimeInterval(baseTimeSeconds)
        }
    }
    
    // MARK: - Public API
    func start(for side: Player) {
        guard !isRunning else { return }
        activePlayer = side
        isRunning = true
        
        // Apply delay at start of new turn
        if case .normal(let stages) = timeControl, let currentStage = stages.first {
            if case .delay(let seconds) = currentStage.buffer {
                delayRemaining = TimeInterval(seconds)
            } else {
                delayRemaining = 0
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: tickRate, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
    }
    
    func togglePause() {
        if isRunning {
            // Currently running → pause
            timer?.invalidate()
            timer = nil
            isRunning = false
        } else {
            // Currently paused → resume
            guard let side = activePlayer else { return }
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: tickRate, repeats: true) { [weak self] _ in
                self?.tick()
            }
            activePlayer = side // Ensure the same player resumes
        }
    }
    
    func switchTurn() {
        guard isRunning else { return }
        
        // Determine the player who just finished their move
        let previousPlayer = activePlayer
        
        // Apply increment immediately
        if let player = previousPlayer {
            if player == .a {
                moveCounterA += 1
                movesThisStageA += 1
                advanceStageIfNeeded(for: .a)

                if case .normal(let stages) = timeControl {
                    let idx = previousPlayer == .a ? clockStageA : clockStageB
                    let currentStage = stages[idx]
                    switch currentStage.buffer {
                    case .increment(let seconds):
                        timeA += TimeInterval(seconds)
                    default:
                        break
                    }
                }
            } else {
                moveCounterB += 1
                movesThisStageB += 1
                advanceStageIfNeeded(for: .b)

                if case .normal(let stages) = timeControl {
                    let idx = previousPlayer == .a ? clockStageA : clockStageB
                    let currentStage = stages[idx]
                    switch currentStage.buffer {
                    case .increment(let seconds):
                        timeB += TimeInterval(seconds)
                    default:
                        break
                    }
                }
            }
        }
        
        // Switch active player
        activePlayer = previousPlayer == .a ? .b : .a
        
        // Apply delay at start of new turn
        if case .normal(let stages) = timeControl {
            let idx = previousPlayer == .a ? clockStageA : clockStageB
            let currentStage = stages[idx]
            if case .delay(let seconds) = currentStage.buffer {
                delayRemaining = TimeInterval(seconds)
            } else {
                delayRemaining = 0
            }
        }
    }

    
    func reset() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        sideFlagged = nil
        activePlayer = nil
        moveCounterA = 0
        moveCounterB = 0
        
        clockStageA = 0
        clockStageB = 0
        movesThisStageA = 0
        movesThisStageB = 0
        
        switch timeControl {
        case .normal(let stages):
            let base = TimeInterval((stages.first!.minutes * 60) + stages.first!.seconds)
            timeA = base
            timeB = base
        case .hourglass(let baseTimeSeconds):
            timeA = TimeInterval(baseTimeSeconds)
            timeB = TimeInterval(baseTimeSeconds)
        }
    }
    
    // MARK: - Private logic
    private func tick() {
        guard let side = activePlayer else { return }
        
        if delayRemaining > 0 {
            delayRemaining = max(0, delayRemaining - tickRate)
            return // don't decrement clock yet
        }
        
        switch (timeControl, side) {
        case (.hourglass, .a):
            timeA = max(0, timeA - tickRate)
            timeB = min(timeB + tickRate, max(timeA, timeB)) // hourglass mechanic
        case (.hourglass, .b):
            timeB = max(0, timeB - tickRate)
            timeA = min(timeA + tickRate, max(timeA, timeB))
        default:
            if side == .a {
                timeA = max(0, timeA - tickRate)
            } else {
                timeB = max(0, timeB - tickRate)
            }
        }
        
        checkForFlag()
    }
    
    private func checkForFlag() {
        if timeA == 0 && sideFlagged == nil {
            sideFlagged = .a
            pause()
        } else if timeB == 0 && sideFlagged == nil {
            sideFlagged = .b
            pause()
        }
    }
    
    private func advanceStageIfNeeded(for player: Player) {
        guard case .normal(let stages) = timeControl else { return }
        
        let currentIndex = (player == .a) ? clockStageA : clockStageB
        guard currentIndex < stages.count else { return }
        
        let currentStage = stages[currentIndex]
        
        // Check if enough moves have been made
        let moves = (player == .a) ? movesThisStageA : movesThisStageB
        if let requiredMoves = currentStage.movesInStage, moves >= requiredMoves {
            let nextIndex = currentIndex + 1
            guard nextIndex < stages.count else { return } // No more stages
            
            let nextStage = stages[nextIndex]
            let extraTime = TimeInterval(nextStage.minutes * 60 + nextStage.seconds)
            
            if player == .a {
                timeA += extraTime
                clockStageA = nextIndex
                movesThisStageA = 0
            } else {
                timeB += extraTime
                clockStageB = nextIndex
                movesThisStageB = 0
            }
        }
    }

}
