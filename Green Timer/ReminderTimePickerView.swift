//
//  ReminderTimePickerView.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import SwiftUI

struct ReminderTimePickerView: View {
    @ObservedObject var viewModel: PlantViewModel
    @Environment(\.dismiss) var dismiss
    @State private var startTime: Date
    @State private var endTime: Date
    
    init(viewModel: PlantViewModel) {
        self.viewModel = viewModel
        _startTime = State(initialValue: viewModel.reminderWindowStart)
        _endTime = State(initialValue: viewModel.reminderWindowEnd)
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    
                    Spacer()
                    
                    Text("Reminder Window")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("Done") {
                        viewModel.reminderWindowStart = startTime
                        viewModel.reminderWindowEnd = endTime
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                .padding()
                
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("Start")
                            .font(.headline)
                        
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                    
                    VStack(spacing: 16) {
                        Text("End")
                            .font(.headline)
                        
                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

