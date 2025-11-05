//
//  TimeControl.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/4/25.
//

import Foundation

enum TimeControl: Codable, CustomStringConvertible, Equatable, Hashable {
    case normal(stages: [Stage])
    case hourglass(baseTimeSeconds: Int)
    
    var description: String {
        switch self {
        case .normal(let stages):
            return "\(stages.map(\.description).joined(separator: ", "))"
        case .hourglass(let baseTimeSeconds):
            return "Hourglass \(baseTimeSeconds)s"
        }
    }
    
    static func ==(lhs: TimeControl, rhs: TimeControl) -> Bool {
        return lhs.description == rhs.description // Feels lazy but I'm not sure it matters, just need this to ForEach
    }
}

struct Stage: Codable, CustomStringConvertible, Equatable, Hashable {
    var minutes: Int
    var seconds: Int
    var buffer: TimeBuffer
    var movesInStage: Int?
    
    var description: String {
        var parts: [String] = []
        if minutes > 0 {
            parts.append("\(minutes)min")
        }
        if seconds > 0 {
            parts.append("\(seconds)sec")

        }
        if buffer != .none {
            parts.append("\(buffer.description)")
        }
        if let moves = movesInStage {
            parts.append("(\(moves) moves)")
        }
        
        return parts.joined(separator: " ")
    }
    
    static func ==(lhs: Stage, rhs: Stage) -> Bool {
        return lhs.minutes == rhs.minutes && lhs.seconds == rhs.seconds && lhs.buffer == rhs.buffer && lhs.movesInStage == rhs.movesInStage
    }
}

enum TimeBuffer: Codable, CustomStringConvertible, Equatable, Hashable {
    case delay(seconds: Int)
    case increment(seconds: Int)
    case bronstein(seconds: Int)
    case none
    
    var description: String {
        switch self {
        case .delay(let secs): return "\(secs)s delay"
        case .increment(let secs): return "\(secs)s increment"
        case .bronstein(let secs): return "\(secs)s increment (bronstein)"
        case .none: return "No buffer"
        }
    }
    
    static func ==(lhs: TimeBuffer, rhs: TimeBuffer) -> Bool {
        switch (lhs, rhs) {
        case (.delay(let a), .delay(let b)):
            return a == b
        case (.increment(let a), .increment(let b)):
            return a == b
        case (.bronstein(let a), .bronstein(let b)):
            return a == b
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}
