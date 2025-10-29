//
//  HomeView.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: PlantViewModel
    @State private var showingAddPlant = false
    @State private var showingWateringSession = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dateString())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Green Timer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Status Cards
                        HStack(spacing: 12) {
                            StatusCard(
                                title: "Today",
                                count: viewModel.todayCount,
                                label: "today",
                                color: Color(red: 0.45, green: 0.82, blue: 0.52),
                                isSelected: viewModel.selectedDateFilter == .today
                            ) {
                                viewModel.selectedDateFilter = viewModel.selectedDateFilter == .today ? nil : .today
                            }
                            
                            StatusCard(
                                title: "Overdue",
                                count: viewModel.overdueCount,
                                label: "urgent",
                                color: Color(red: 0.96, green: 0.45, blue: 0.42),
                                isSelected: viewModel.selectedDateFilter == .overdue
                            ) {
                                viewModel.selectedDateFilter = viewModel.selectedDateFilter == .overdue ? nil : .overdue
                            }
                            
                            StatusCard(
                                title: "Tomorrow",
                                count: viewModel.tomorrowCount,
                                label: "waiting",
                                color: Color(red: 0.96, green: 0.71, blue: 0.40),
                                isSelected: viewModel.selectedDateFilter == .tomorrow
                            ) {
                                viewModel.selectedDateFilter = viewModel.selectedDateFilter == .tomorrow ? nil : .tomorrow
                            }
                        }
                        .padding(.horizontal)
                        
                        // Location Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.locations, id: \.self) { location in
                                    LocationChip(
                                        title: location,
                                        isSelected: viewModel.selectedLocation == location
                                    ) {
                                        viewModel.selectedLocation = location
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Plants List
                        if viewModel.filteredPlants.isEmpty {
                            VStack(spacing: 16) {
                                Text("No plants")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Add your first plant")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.filteredPlants) { plant in
                                    PlantRow(plant: plant, viewModel: viewModel)
                                    
                                    if plant.id != viewModel.filteredPlants.last?.id {
                                        Divider()
                                            .padding(.leading, 80)
                                    }
                                }
                            }
                        }
                        
                        Color.clear.frame(height: 1)
                    }
                    .padding(.top, 8)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddPlant = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color(red: 0.45, green: 0.82, blue: 0.52))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
                .frame(height: 96)
            }
        }
        .sheet(isPresented: $showingAddPlant) {
            AddPlantView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingWateringSession) {
            WateringSessionView(viewModel: viewModel)
        }
    }
    
    func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date()).capitalized
    }
}

struct StatusCard: View {
    let title: String
    let count: Int
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(alignment: .center, spacing: 4) {
                    Text("\(count)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(label)
                        .font(.system(size: 8))
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(5)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LocationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    isSelected ? Color.white : Color(UIColor.secondarySystemBackground)
                )
                .foregroundColor(isSelected ? .black : .primary)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(isSelected ? 0 : 0.2), lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.black.opacity(0.1) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlantRow: View {
    let plant: Plant
    @ObservedObject var viewModel: PlantViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 16) {
                // Plant Image/Icon
                Group {
                    if let imageData = plant.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 60, height: 60)
                            
                            Text("🌱")
                                .font(.system(size: 30))
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(plant.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Text(plant.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                    Text("Pot \(plant.wateringIntervalDays) cm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    // Action Icons
                    HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Text("💧")
                            .font(.system(size: 14))
                        Text("Water")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if plant.sprayingIntervalDays != nil {
                        HStack(spacing: 4) {
                            Text("⬛")
                                .font(.system(size: 14))
                            Text("Spray")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if plant.feedingIntervalDays != nil {
                        HStack(spacing: 4) {
                            Text("✓")
                                .font(.system(size: 14))
                            Text("Feed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    }
                }
                
                Spacer(minLength: 0)
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(plant.daysUntilWatering)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor(for: plant))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    Button(action: {
                        viewModel.waterPlant(plant)
                    }) {
                        Text("Mark")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.45, green: 0.82, blue: 0.52))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            PlantDetailView(plant: plant, viewModel: viewModel)
        }
    }
    
    func statusColor(for plant: Plant) -> Color {
        switch plant.wateringStatus {
        case .today:
            return Color(red: 0.45, green: 0.82, blue: 0.52)
        case .overdue:
            return Color(red: 0.96, green: 0.45, blue: 0.42)
        case .tomorrow:
            return Color(red: 0.96, green: 0.71, blue: 0.40)
        }
    }
}

