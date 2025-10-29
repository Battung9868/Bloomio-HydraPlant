//
//  WateringSessionView.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import SwiftUI

struct WateringSessionView: View {
    @ObservedObject var viewModel: PlantViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlants: Set<UUID> = []
    @State private var actionType: ActionType = .watering
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Action Type Selector
                HStack(spacing: 12) {
                    ForEach(ActionType.allCases, id: \.self) { type in
                        Button(action: {
                            actionType = type
                        }) {
                            HStack {
                                Text(type.icon)
                                Text(type.rawValue)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                actionType == type ? type.color : Color(UIColor.secondarySystemBackground)
                            )
                            .foregroundColor(actionType == type ? .white : .primary)
                            .cornerRadius(20)
                        }
                    }
                }
                .padding()
                
                Divider()
                
                // Plants List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.todayPlants) { plant in
                            WateringSessionRow(
                                plant: plant,
                                isSelected: selectedPlants.contains(plant.id)
                            ) {
                                if selectedPlants.contains(plant.id) {
                                    selectedPlants.remove(plant.id)
                                } else {
                                    selectedPlants.insert(plant.id)
                                }
                            }
                            
                            if plant.id != viewModel.todayPlants.last?.id {
                                Divider()
                                    .padding(.leading, 70)
                            }
                        }
                    }
                }
                
                // Bottom Button
                VStack {
                    Divider()
                    
                    Button(action: {
                        waterSelectedPlants()
                    }) {
                        HStack {
                            Spacer()
                            Text("Отметить (\(selectedPlants.count))")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding()
                        .background(selectedPlants.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(selectedPlants.isEmpty)
                    .padding()
                }
            }
            .navigationTitle("Сессия полива")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(selectedPlants.count == viewModel.todayPlants.count ? "Снять все" : "Выбрать все") {
                        if selectedPlants.count == viewModel.todayPlants.count {
                            selectedPlants.removeAll()
                        } else {
                            selectedPlants = Set(viewModel.todayPlants.map { $0.id })
                        }
                    }
                }
            }
            .onAppear {
                selectedPlants = Set(viewModel.todayPlants.map { $0.id })
            }
        }
    }
    
    func waterSelectedPlants() {
        for plantId in selectedPlants {
            if let plant = viewModel.plants.first(where: { $0.id == plantId }) {
                viewModel.waterPlant(plant, actionType: actionType)
            }
        }
        dismiss()
    }
}

struct WateringSessionRow: View {
    let plant: Plant
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .green : .gray)
                
                // Plant Icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text("🌱")
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Text(plant.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(plant.daysUntilWatering)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.green.opacity(0.1) : Color.clear)
        }
    }
}

