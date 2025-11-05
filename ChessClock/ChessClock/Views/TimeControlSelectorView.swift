//
//  TimeControlSelector.swift
//  ChessClock
//
//  Created by Ben Zobrist on 11/5/25.
//

import SwiftUI
import SwiftData

struct TimeControlSelectorView: View {
    @Environment(\.modelContext) private var moc

    @Query(sort: \TimeControlWrapper.dateCreated, order: .forward)
    private var storedTimeControlWrappers: [TimeControlWrapper]

    @Binding var timeControl: TimeControl
    @Binding var presented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("")) {
                    Picker("", selection: $timeControl) {
                        ForEach(storedTimeControlWrappers, id: \.id) { wrapper in
                            if let tc = wrapper.timeControl {
                                Text(tc.description)
                                    .tag(tc)
                            }
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                    
                    NavigationLink("Create Custom Time Control", destination: CustomTimeControlView(didCreate: { tc in
                        let newWrapper = TimeControlWrapper(timeControl: tc, dateCreated: Date())
                        moc.insert(newWrapper)
                        
                        do {
                            try moc.save()
                            self.timeControl = tc
                        } catch {
                            print("Failed to save new time control: \(error)")
                        }
                    }))
                }
                
                Section(header: Text("Presets")) {
                    Picker("", selection: $timeControl) {
                        ForEach(Constants.presetTimeControls, id: \.self) { tc in
                            Text(tc.description)
                                .tag(tc)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Time Controls")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        presented = false
                    }.tint(.blue)
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
