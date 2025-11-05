//
//  ClockView.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/4/25.
//

import SwiftUI

struct ClockView: View {
    @ObservedObject var viewModel: ChessClockViewModel
    @Binding var showSelectorView: Bool
    
    @State private var showingTimeControlSelector = false
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                
                // Top Side (Player A)
                sideView(
                    player: .a,
                    time: viewModel.timeA,
                    moves: viewModel.moveCounterA,
                    isActive: viewModel.activePlayer == .a,
                    hasFlagged: viewModel.sideFlagged == .a
                )
                .rotationEffect(Angle(degrees: 180))
                .frame(height: topHeight(totalHeight: geo.size.height))
                .animation(.easeInOut(duration: 0.2), value: topHeight(totalHeight: geo.size.height))

                // Divider with controls
                HStack {
                    Button(action: { showSelectorView = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .padding()
                    }
                    Spacer()
                    Button(action: { viewModel.togglePause() }) {
                        Image(systemName: "pause.fill")
                            .font(.title)
                            .padding()
                    }
                    Button(action: { viewModel.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                            .padding()
                    }
                }
                .background(Color.gray.opacity(0.2))
                .frame(height: geo.size.height * 0.075)
                .animation(.easeInOut(duration: 0.2), value: viewModel.activePlayer)
                
                // Bottom Side (Player B)
                sideView(
                    player: .b,
                    time: viewModel.timeB,
                    moves: viewModel.moveCounterB,
                    isActive: viewModel.activePlayer == .b,
                    hasFlagged: viewModel.sideFlagged == .b
                )
                .frame(height: bottomHeight(totalHeight: geo.size.height))
                .animation(.easeInOut(duration: 0.2), value: bottomHeight(totalHeight: geo.size.height))

                
            }
        }
    }
    
    // MARK: - Dynamic Heights
    private func topHeight(totalHeight: CGFloat) -> CGFloat {
        if let active = viewModel.activePlayer, viewModel.isRunning {
            return active == .a ? totalHeight * 0.6625 : totalHeight * 0.2625
        } else {
            return totalHeight * 0.4625
        }
    }
    
    private func bottomHeight(totalHeight: CGFloat) -> CGFloat {
        if let active = viewModel.activePlayer, viewModel.isRunning {
            return active == .b ? totalHeight * 0.6625 : totalHeight * 0.2625
        } else {
            return totalHeight * 0.4625
        }
    }
    
    
    // MARK: - Side View
    private func sideView(player: Player, time: TimeInterval, moves: Int, isActive: Bool, hasFlagged: Bool) -> some View {
        ZStack {
            // Background color logic
            let backgroundColor: Color = hasFlagged ? Color.red.opacity(0.3) : (isActive ? Color.green.opacity(0.3) : Color.gray.opacity(0.6))
            
            backgroundColor
                .animation(.easeInOut(duration: 0.2), value: isActive)
            
            VStack {
                Text(timeString(from: time))
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .padding(.bottom, 5)
                Text("Moves: \(moves)")
                    .font(.title2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard viewModel.sideFlagged == nil else { return } // block gameplay taps

            if !viewModel.isRunning && viewModel.activePlayer == nil {
                // Clock hasn't started yet — tapping any side starts it
                withAnimation(.easeInOut) {
                    viewModel.start(for: player == .a ? .b : .a)
                    Haptics.lightImpact()
                }
            } else if viewModel.isRunning && viewModel.activePlayer == player {
                // Clock running — only active side can switch
                withAnimation(.easeInOut) {
                    viewModel.switchTurn()
                    Haptics.lightImpact()
                }
            }
        }
    }
    
    // MARK: - Helper
    private func timeString(from interval: TimeInterval) -> String {
        // Clamp to zero to avoid negative times
        let clamped = max(0, interval)
        
        if clamped >= 10 {
            let minutes = Int(clamped) / 60
            let seconds = Int(clamped) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            let seconds = Int(clamped)
            // Milliseconds for display (ss.mmm)
            let milliseconds = Int((clamped - Double(seconds)) * 1000)
            return String(format: "%02d.%03d", seconds, milliseconds)
        }
    }

}
