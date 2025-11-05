//
//  CustomTimeControlView.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/5/25.
//

import SwiftUI

struct CustomTimeControlView: View {
    
    
    // MARK: - Inputs & Outputs
    var didCreate: (TimeControl) -> Void
    
    // MARK: - State
    @State private var mode: CreationMode = .normal
    @State private var stages: [Stage] = [
        Stage(minutes: 5, seconds: 0, buffer: .none, movesInStage: nil)
    ]
    @State private var hourglassSeconds: Int = 300 // default 5 min
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Mode Selector
                Section {
                    Picker("Mode", selection: $mode) {
                        ForEach(CreationMode.allCases) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                switch mode {
                case .normal:
                    normalModeForm
                    
                    Section {
                        Button {
                            stages.append(Stage(minutes: 5, seconds: 0, buffer: .none, movesInStage: nil))
                        } label: {
                            Label("Add New Stage", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                case .hourglass:
                    hourglassModeForm
                }
                
                Section {
                    Button("Create Time Control") {
                        createTimeControl()
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Custom Time Control")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        // Save or dismiss
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    // MARK: Normal Mode Form
    var normalModeForm: some View {
        ForEach(stages.indices, id: \.self) { index in
            Section(header: Text("Stage \(index + 1)")) {
                StageEditorView(stage: $stages[index])
                
                if stages.count > 1 {
                    Button(role: .destructive) {
                        stages.remove(at: index)
                    } label: {
                        Label("Delete Stage", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    // MARK: Hourglass Mode Form
    var hourglassModeForm: some View {
        HourglassModeForm(hourglassSeconds: $hourglassSeconds)
    }
    
    // MARK: Creation Handler
    func createTimeControl() {
        let timeControl: TimeControl
        switch mode {
        case .normal:
            timeControl = .normal(stages: stages)
        case .hourglass:
            timeControl = .hourglass(baseTimeSeconds: hourglassSeconds)
        }
        didCreate(timeControl)
    }
}

// MARK: - HourGlassModeForm: View
fileprivate struct HourglassModeForm: View {
    @Binding var hourglassSeconds: Int
    @FocusState private var isFocused: Bool  // for keyboard dismissal
    
    var body: some View {
        Section(header: Text("Hourglass Settings")) {
            HStack {
                Text("Base Time (minutes):")
                Spacer()
                
                NumberInputField(value: Binding(
                    get: { hourglassSeconds / 60 },
                    set: { hourglassSeconds = $0 * 60 }
                ))
                .focused($isFocused)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: {
                        isFocused = false
                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
        }
    }
}


// MARK: - StageEditorView
fileprivate struct StageEditorView: View {
    @Binding var stage: Stage
    
    @State private var selectedBuffer: BufferType = .none
    
    enum StageField: Hashable {
        case minutes
        case seconds
        case movesInStage
        case buffer
    }
    @FocusState private var focusedField: StageField?  // single focus tracker

    init(stage: Binding<Stage>) {
        self._stage = stage
        
        // Initialize selectedBuffer from the stage's buffer
        switch stage.wrappedValue.buffer {
        case .none:
            self._selectedBuffer = State(initialValue: .none)
        case .increment:
            self._selectedBuffer = State(initialValue: .increment)
        case .delay:
            self._selectedBuffer = State(initialValue: .delay)
        case .bronstein:
            self._selectedBuffer = State(initialValue: .bronstein)
        }
    }
    
    var body: some View {
        VStack {
            // Base Time
            HStack {
                Text("Minutes:")
                Spacer()
                NumberInputField(value: $stage.minutes)
                    .focused($focusedField, equals: .minutes)
            }
            
            HStack {
                Text("Seconds:")
                Spacer()
                NumberInputField(value: $stage.seconds)
                    .focused($focusedField, equals: .seconds)
            }
            
            // Moves in stage
            HStack {
                Text("Moves (0 = unlimited):")
                Spacer()
                NumberInputField(value: Binding(
                    get: { stage.movesInStage ?? 0 },
                    set: { stage.movesInStage = $0 == 0 ? nil : $0 }
                ))
                .focused($focusedField, equals: .movesInStage)
            }
            
            // Buffer picker
            VStack {
                Picker("Buffer", selection: $selectedBuffer) {
                    ForEach(BufferType.allCases) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedBuffer) { newType in
                    switch newType {
                    case .none:
                        stage.buffer = .none
                    case .increment:
                        stage.buffer = .increment(seconds: 5) // default
                    case .delay:
                        stage.buffer = .delay(seconds: 5) // default
                    case .bronstein:
                        stage.buffer = .bronstein(seconds: 5) // default
                    }
                }
                
                // Stepper for buffer seconds
                Group {
                    if case .increment(let sec) = stage.buffer {
                        HStack {
                            Text("Increment seconds:")
                            Spacer()
                            NumberInputField(value: Binding(
                                get: { sec },
                                set: { stage.buffer = .increment(seconds: $0) }
                            ))
                        }
                    } else if case .delay(let sec) = stage.buffer {
                        HStack {
                            Text("Delay seconds:")
                            Spacer()
                            NumberInputField(value: Binding(
                                get: { sec },
                                set: { stage.buffer = .delay(seconds: $0) }
                            ))
                        }
                    } else if case .bronstein(let sec) = stage.buffer {
                        HStack {
                            Text("Bronstein seconds:")
                            Spacer()
                            NumberInputField(value: Binding(
                                get: { sec },
                                set: { stage.buffer = .bronstein(seconds: $0) }
                            ))
                        }
                    }
                }
                .padding()
                .focused($focusedField, equals: .buffer)
            }
        }
        .padding(.vertical, 8)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(action: {
                    focusedField = nil
                }) {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
    }
}

// MARK: - Helper enum for Picker
fileprivate enum BufferType: String, CaseIterable, Identifiable {
    case none
    case increment
    case delay
    case bronstein
    
    var id: String { rawValue }
}

fileprivate enum CreationMode: String, CaseIterable, Identifiable {
    case normal
    case hourglass
    
    var id: String { rawValue }
}
