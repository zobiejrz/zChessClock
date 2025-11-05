//
//  TimeControl.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/4/25.
//

enum TimeControl: Codable, CustomStringConvertible {
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
}

struct Stage: Codable, CustomStringConvertible {
    let minutes: Int
    let seconds: Int
    let buffer: TimeBuffer
    let movesInStage: Int?
    
    var description: String {
        var parts: [String] = []
        parts.append("\(minutes)m \(seconds)s")
        if let moves = movesInStage {
            parts.append("\(moves) moves")
        }
        if buffer != .none {
            parts.append(buffer.description)
        }
        return parts.joined(separator: ", ")
    }
}

enum TimeBuffer: Codable, CustomStringConvertible, Equatable {
    case delay(seconds: Int)
    case increment(seconds: Int)
    case bronstein(seconds: Int)
    case none
    
    var description: String {
        switch self {
        case .delay(let secs): return "Delay \(secs)s"
        case .increment(let secs): return "Increment \(secs)s"
        case .bronstein(let secs): return "Bronstein \(secs)s"
        case .none: return "No buffer"
        }
    }
}
