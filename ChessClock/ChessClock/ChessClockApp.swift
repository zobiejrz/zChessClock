//
//  ChessClockApp.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/4/25.
//

import SwiftUI
import SwiftData

@main
struct ChessClockApp: App {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TimeControlWrapper.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(Self.sharedModelContainer)
    }
}
