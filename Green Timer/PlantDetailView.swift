//
//  PlantDetailView.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import SwiftUI

struct PlantDetailView: View {
    let plant: Plant
    @ObservedObject var viewModel: PlantViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Plant Image
                    Group {
                        if let imageData = plant.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(20)
                                .padding(.horizontal)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.green.opacity(0.2))
                                    .frame(height: 200)
                                
                                Text("🌱")
                                    .font(.system(size: 80))
                            }
                            .padding()
                        }
                    }
                    
                    // Plant Info
                    VStack(spacing: 16) {
                        Text(plant.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(plant.location, systemImage: "location.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Care Schedule
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Care Schedule")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            CareScheduleRow(
                                icon: "💧",
                                title: "Watering",
                                frequency: "Every \(plant.wateringIntervalDays) days",
                                nextDate: plant.nextWateringDate,
                                status: plant.wateringStatus
                            )
                            
                            if let sprayingDays = plant.sprayingIntervalDays {
                                Divider()
                                    .padding(.leading, 60)
                                
                                CareScheduleRow(
                                    icon: "⬛️",
                                    title: "Spraying",
                                    frequency: "Every \(sprayingDays) days",
                                    nextDate: Date(),
                                    status: .today
                                )
                            }
                            
                            if let feedingDays = plant.feedingIntervalDays {
                                Divider()
                                    .padding(.leading, 60)
                                
                                CareScheduleRow(
                                    icon: "✓",
                                    title: "Feeding",
                                    frequency: "Every \(feedingDays) days",
                                    nextDate: Date(),
                                    status: .today
                                )
                            }
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Notes
                    if let notes = plant.notes {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.waterPlant(plant, actionType: .watering)
                            dismiss()
                        }) {
                            HStack {
                                Text("💧")
                                Text("Water Now")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        HStack(spacing: 12) {
                            if plant.sprayingIntervalDays != nil {
                                Button(action: {
                                    viewModel.waterPlant(plant, actionType: .spraying)
                                    dismiss()
                                }) {
                                    HStack {
                                        Text("⬛️")
                                        Text("Spray")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            if plant.feedingIntervalDays != nil {
                                Button(action: {
                                    viewModel.waterPlant(plant, actionType: .feeding)
                                    dismiss()
                                }) {
                                    HStack {
                                        Text("✓")
                                        Text("Feed")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Text("Delete Plant")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete plant?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deletePlant(plant)
                    dismiss()
                }
            } message: {
                Text("This action cannot be undone")
            }
        }
    }
}

struct CareScheduleRow: View {
    let icon: String
    let title: String
    let frequency: String
    let nextDate: Date
    let status: PlantStatus
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(frequency)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(dateString(nextDate))
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(status.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(status.color.opacity(0.2))
                    .foregroundColor(status.color)
                    .cornerRadius(6)
            }
        }
        .padding()
    }
    
    func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

