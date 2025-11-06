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

    @State private var makingCustomTimeControl: Bool = false
    
    @Query(sort: \TimeControlWrapper.dateCreated, order: .forward)
    private var storedTimeControlWrappers: [TimeControlWrapper]

    @Binding var timeControl: TimeControl
    @Binding var presented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Custom Time Controls")) {
                    ForEach(storedTimeControlWrappers, id: \.id) { wrapper in
                        if let tc = wrapper.timeControl {
                            HStack {
                                Text(tc.description)
                                Spacer()
                                if timeControl == tc {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                timeControl = tc
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let wrapperToDelete = storedTimeControlWrappers[index]
                            moc.delete(wrapperToDelete)
                        }
                        do {
                            try moc.save()
                        } catch {
                            print("Failed to delete time control: \(error)")
                        }
                    }
                    
                    Button("Create Custom Time Control") {
                        makingCustomTimeControl = true
                    }
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
            .navigationDestination(isPresented: $makingCustomTimeControl) {
                CustomTimeControlView(isActive: $makingCustomTimeControl) { tc in
                    let newWrapper = TimeControlWrapper(timeControl: tc, dateCreated: Date())
                    moc.insert(newWrapper)
                    
                    do {
                        try moc.save()
                        self.timeControl = tc
                    } catch {
                        print("Failed to save new time control: \(error)")
                    }
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
