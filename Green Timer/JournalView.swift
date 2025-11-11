//
//  JournalView.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import SwiftUI

struct JournalView: View {
    @ObservedObject var viewModel: PlantViewModel
    @State private var showingClearAlert = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Activity Log")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Last 7 Days")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Statistics Cards
                        let stats = viewModel.last7DaysStats()
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Waterings",
                                count: stats.watering,
                                color: Color(red: 0.45, green: 0.82, blue: 0.52),
                                label: "in 7 days"
                            )
                            
                            StatCard(
                                title: "Overdue",
                                count: viewModel.overdueCount,
                                color: Color(red: 0.96, green: 0.45, blue: 0.42),
                                label: "reduced"
                                
                            )
                            
                            StatCard(
                                title: "Next",
                                count: viewModel.next7DaysCount(),
                                color: Color(red: 0.40, green: 0.60, blue: 0.96),
                                label: "upcoming"
                            )
                        }
                        .padding(.horizontal)
                        
                        // Filter Buttons
                        HStack(spacing: 12) {
                            FilterButton(
                                title: "All",
                                isSelected: viewModel.selectedActionFilter == nil
                            ) {
                                viewModel.selectedActionFilter = nil
                            }
                            
                            FilterButton(
                                title: "Water",
                                isSelected: viewModel.selectedActionFilter == .watering
                            ) {
                                viewModel.selectedActionFilter = .watering
                            }
                            
                            FilterButton(
                                title: "Spray",
                                isSelected: viewModel.selectedActionFilter == .spraying
                            ) {
                                viewModel.selectedActionFilter = .spraying
                            }
                            
                            FilterButton(
                                title: "Feed",
                                isSelected: viewModel.selectedActionFilter == .feeding
                            ) {
                                viewModel.selectedActionFilter = .feeding
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding(.horizontal)
                            
                        // Sessions List
                        VStack(spacing: 0) {
                            if viewModel.filteredSessions.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.green.opacity(0.2))
                                    Text("No Records")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    Text("Your actions will appear here")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 80)
                            } else {
                                ForEach(groupedSessions(), id: \.key) { group in
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(group.key)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal)
                                            .padding(.top, 16)
                                            .padding(.bottom, 8)
                                        
                                        ForEach(group.value) { session in
                                            SessionRow(session: session, viewModel: viewModel)
                                            
                                            if session.id != group.value.last?.id {
                                                Divider()
                                                    .padding(.leading, 80)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Clear All Button
                        if !viewModel.sessions.isEmpty {
                            Button(action: {
                                showingClearAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Clear All")
                                }
                                .foregroundColor(.red)
                                .padding()
                            }
                            .padding(.top, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .alert("Clear journal?", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                viewModel.clearAllSessions()
            }
        } message: {
            Text("This action cannot be undone")
        }
    }
    
    func groupedSessions() -> [(key: String, value: [WateringSession])] {
        let grouped = Dictionary(grouping: viewModel.filteredSessions) { session in
            session.dateString
        }
        return grouped.sorted { $0.key > $1.key }
    }
}

struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    let label: String
    
    var body: some View {
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
        .frame(height: 100)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color)
        )
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    isSelected ? Color.black : Color(UIColor.secondarySystemBackground)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(24)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SessionRow: View {
    let session: WateringSession
    @ObservedObject var viewModel: PlantViewModel
    
    var plant: Plant? {
        viewModel.plants.first(where: { $0.id == session.plantId })
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Plant Image/Icon
            Group {
                if let plant = plant,
                   let imageData = plant.imageData,
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
                Text("\(session.actionType.icon) \(session.actionType.rawValue)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Text(session.plantName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(session.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(session.timeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if session.notes != nil {
                    Text("Note")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

