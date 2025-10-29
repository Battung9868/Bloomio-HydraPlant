//
//  AddPlantView.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import SwiftUI

struct AddPlantView: View {
    @ObservedObject var viewModel: PlantViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var location = "Living Room"
    @State private var wateringDays = 7
    @State private var enableSpraying = false
    @State private var sprayingDays = 3
    @State private var enableFeeding = false
    @State private var feedingDays = 14
    @State private var notes = ""
    @State private var plantImage: UIImage?
    @State private var showingImagePicker = false
    
    let locations = ["Living Room", "Kitchen", "Bedroom", "Bathroom", "Balcony", "Office"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Photo")) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            if let image = plantImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.title)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(plantImage == nil ? "Add Photo" : "Change Photo")
                                    .foregroundColor(.primary)
                                Text("Optional")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                        }
                    }
                }
                
                Section(header: Text("Basic Information")) {
                    TextField("Plant name", text: $name)
                    
                    Picker("Location", selection: $location) {
                        ForEach(locations, id: \.self) { loc in
                            Text(loc).tag(loc)
                        }
                    }
                }
                
                Section(header: Text("Watering Schedule")) {
                    Stepper("Water every \(wateringDays) days", value: $wateringDays, in: 1...90)
                }
                
                Section(header: Text("Additional Care")) {
                    Toggle("Spraying", isOn: $enableSpraying)
                    
                    if enableSpraying {
                        Stepper("Every \(sprayingDays) days", value: $sprayingDays, in: 1...30)
                    }
                    
                    Toggle("Feeding", isOn: $enableFeeding)
                    
                    if enableFeeding {
                        Stepper("Every \(feedingDays) days", value: $feedingDays, in: 7...90)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addPlant()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $plantImage)
            }
        }
    }
    
    func addPlant() {
        let imageData = plantImage?.jpegData(compressionQuality: 0.7)
        
        let plant = Plant(
            name: name,
            location: location,
            imageData: imageData,
            wateringIntervalDays: wateringDays,
            sprayingIntervalDays: enableSpraying ? sprayingDays : nil,
            feedingIntervalDays: enableFeeding ? feedingDays : nil,
            lastWatered: Date(),
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.addPlant(plant)
        dismiss()
    }
}

