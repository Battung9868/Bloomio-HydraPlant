//
//  SettingsView.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: PlantViewModel
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Settings")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Green Timer")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "bell.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        
                        VStack(spacing: 32) {
                            // THEME
                            VStack(alignment: .leading, spacing: 12) {
                                Text("THEME")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    SettingRow(
                                        title: "Dark Theme",
                                        subtitle: "Enable dark mode"
                                    ) {
                                        Toggle("", isOn: $viewModel.isDarkMode)
                                            .labelsHidden()
                                    }
                                }
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            // REMINDERS Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("REMINDERS")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                SettingRow(
                                    title: "Reminder Window",
                                    subtitle: timeRangeString()
                                ) {
                                    NavigationLink(destination: ReminderTimePickerView(viewModel: viewModel)) {
                                        Text("Change")
                                            .font(.subheadline)
                                    }
                                }
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                    
                                    SettingRow(
                                        title: "Daily Summary",
                                        subtitle: "18:30"
                                    ) {
                                        Toggle("", isOn: $viewModel.dailySummaryEnabled)
                                            .labelsHidden()
                                    }
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                    
                                    SettingRow(
                                        title: "Postpone to Tomorrow",
                                        subtitle: "Let roots strengthen"
                                    ) {
                                        Toggle("", isOn: $viewModel.postponeToTomorrowEnabled)
                                            .labelsHidden()
                                    }
                                }
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            // PAUSES & MODES Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("PAUSES & MODES")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                SettingRow(
                                    title: "Pause Until",
                                    subtitle: pauseDateString()
                                ) {
                                    NavigationLink(destination: PauseDatePickerView(viewModel: viewModel)) {
                                        Text("Select Date")
                                            .font(.subheadline)
                                    }
                                }
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                    
                                    SettingRow(
                                        title: "Winter Rest (Auto)",
                                        subtitle: "For certain species"
                                    ) {
                                        Toggle("", isOn: $viewModel.winterRestEnabled)
                                            .labelsHidden()
                                    }
                                    
                                }
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            // DATA & SYNC Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("DATA & SYNC")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    Button(action: {
                                        showingClearAlert = true
                                    }) {
                                        HStack {
                                            Text("Erase All")
                                                .foregroundColor(.red)
                                            Spacer()
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                        .padding()
                                    }
                                }
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.top, 20)
                    }
                }
                .ignoresSafeArea(.keyboard)
                .alert("Delete all data?", isPresented: $showingClearAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        viewModel.clearAllData()
                    }
                } message: {
                    Text("This will delete all plants and history")
                }
                .navigationBarHidden(true)
             }
         }
     }
     
     func timeRangeString() -> String {
         let formatter = DateFormatter()
         formatter.dateFormat = "HH:mm"
         let start = formatter.string(from: viewModel.reminderWindowStart)
         let end = formatter.string(from: viewModel.reminderWindowEnd)
         return "\(start) – \(end)"
     }
     
     func pauseDateString() -> String {
         guard let date = viewModel.pauseUntilDate else {
             return "—"
         }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
     }
 }
 
 struct SettingRow<Content: View>: View {
        let title: String
        let subtitle: String
        let content: () -> Content
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                content()
            }
            .padding()
        }
    }

