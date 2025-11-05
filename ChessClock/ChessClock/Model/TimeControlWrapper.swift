//
//  TimeControlWrapper.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/5/25.
//

import Foundation
import SwiftData

@Model
final class TimeControlWrapper: Identifiable, Hashable {
    var id: UUID?
    var timeControlData: Data?
    var dateCreated: Date?
    
    init(id: UUID = UUID(), timeControl: TimeControl, dateCreated: Date?) {
        self.id = id
        self.timeControlData = try? JSONEncoder().encode(timeControl)
        self.dateCreated = dateCreated
    }
    
    var timeControl: TimeControl? {
        get { timeControlData.flatMap { try? JSONDecoder().decode(TimeControl.self, from: $0) } }
        set { timeControlData = newValue.flatMap { try? JSONEncoder().encode($0) } }
    }
}
