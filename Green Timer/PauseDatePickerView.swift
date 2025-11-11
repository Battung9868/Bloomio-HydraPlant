//
//  PauseDatePickerView.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import SwiftUI

struct PauseDatePickerView: View {
    @ObservedObject var viewModel: PlantViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate: Date
    
    init(viewModel: PlantViewModel) {
        self.viewModel = viewModel
        _selectedDate = State(initialValue: viewModel.pauseUntilDate ?? Date())
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
                    
                    Text("Pause Until")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("Done") {
                        viewModel.pauseUntilDate = selectedDate
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                .padding()
                
                VStack(spacing: 16) {
                    Text("Select Date")
                        .font(.headline)
                    
                    DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                }
                
                Text("Reminders will be paused until the selected date")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

