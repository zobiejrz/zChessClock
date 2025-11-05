//
//  Constants.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/5/25.
//

struct Constants {
    
    static let presetTimeControls: [TimeControl] = [
        .normal(stages: [ // 15 min | 10 sec
            Stage(
                minutes: 15,
                seconds: 0,
                buffer: .increment(seconds: 10),
                movesInStage: nil
            )
        ]),
        .normal(stages: [ // 10 min | 2 sec
            Stage(
                minutes: 10,
                seconds: 0,
                buffer: .increment(seconds: 2),
                movesInStage: nil
            )
        ]),
        .normal(stages: [ // 10 min
            Stage(
                minutes: 10,
                seconds: 0,
                buffer: .none,
                movesInStage: nil
            )
        ]),
        .normal(stages: [ // 3 min
            Stage(
                minutes: 3,
                seconds: 0,
                buffer: .none,
                movesInStage: nil
            )
        ]),
        .normal(stages: [ // 3 min | 2 sec
            Stage(
                minutes: 3,
                seconds: 0,
                buffer: .increment(seconds: 2),
                movesInStage: nil
            )
        ]),
        .normal(stages: [ // 5 min
            Stage(
                minutes: 5,
                seconds: 0,
                buffer: .none,
                movesInStage: nil
            )
        ]),
        .normal(stages: [ // 15 min | 2 sec
            Stage(
                minutes: 15,
                seconds: 0,
                buffer: .increment(seconds: 2),
                movesInStage: nil
            )
        ]),
        .normal(stages: [ // 2hr (40 moves) + 1hr (5 sec delay)
            Stage(
                minutes: 120,
                seconds: 0,
                buffer: .none,
                movesInStage: 40
            ),
            Stage(
                minutes: 60,
                seconds: 0,
                buffer: .delay(seconds: 5),
                movesInStage: nil
            )
        ]),
    ]
}
