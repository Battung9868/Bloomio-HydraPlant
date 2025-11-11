//
//  PlantViewModel.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import Foundation
import SwiftUI

class PlantViewModel: ObservableObject {
    @Published var plants: [Plant] = []
    @Published var sessions: [WateringSession] = []
    @Published var selectedLocation: String = "All locations"
    @Published var selectedActionFilter: ActionType? = nil
    @Published var selectedDateFilter: PlantStatus? = nil
    
    // Settings
    @Published var isDarkMode: Bool = false
    @Published var reminderWindowStart: Date = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date() {
        didSet {
            saveSettings()
            // Recreate all notifications with new time
            NotificationManager.shared.scheduleAllNotifications(
                for: plants,
                reminderStart: reminderWindowStart,
                reminderEnd: reminderWindowEnd,
                pauseUntil: pauseUntilDate
            )
        }
    }
    
    @Published var reminderWindowEnd: Date = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date() {
        didSet {
            saveSettings()
        }
    }
    
    @Published var dailySummaryEnabled: Bool = true
    @Published var dailySummaryTime: Date = Calendar.current.date(from: DateComponents(hour: 18, minute: 30)) ?? Date() {
        didSet {
            saveSettings()
        }
    }
    
    @Published var hapticEnabled: Bool = true
    @Published var postponeToTomorrowEnabled: Bool = true
    @Published var winterRestEnabled: Bool = false
    
    @Published var pauseUntilDate: Date? {
        didSet {
            saveSettings()
            // Recreate all notifications with pause consideration
            NotificationManager.shared.scheduleAllNotifications(
                for: plants,
                reminderStart: reminderWindowStart,
                reminderEnd: reminderWindowEnd,
                pauseUntil: pauseUntilDate
            )
        }
    }
    
    private let plantsKey = "saved_plants"
    private let sessionsKey = "saved_sessions"
    private let settingsKey = "app_settings"
    
    init() {
        loadData()
    }
    
    var locations: [String] {
        var locs = Array(Set(plants.map { $0.location })).sorted()
        locs.insert("All locations", at: 0)
        return locs
    }
    
    var filteredPlants: [Plant] {
        var filtered = plants
        
        if selectedLocation != "All locations" {
            filtered = filtered.filter { $0.location == selectedLocation }
        }
        
        if let dateFilter = selectedDateFilter {
            filtered = filtered.filter { $0.wateringStatus == dateFilter }
        }
        
        return filtered.sorted { $0.nextWateringDate < $1.nextWateringDate }
    }
    
    var todayCount: Int {
        plants.filter { $0.wateringStatus == .today }.count
    }
    
    var overdueCount: Int {
        plants.filter { $0.wateringStatus == .overdue }.count
    }
    
    var tomorrowCount: Int {
        plants.filter { $0.wateringStatus == .tomorrow }.count
    }
    
    var todayPlants: [Plant] {
        plants.filter { $0.wateringStatus == .today }
    }
    
    var filteredSessions: [WateringSession] {
        var filtered = sessions
        
        if let actionFilter = selectedActionFilter {
            filtered = filtered.filter { $0.actionType == actionFilter }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    func last7DaysStats() -> (watering: Int, spraying: Int, feeding: Int) {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentSessions = sessions.filter { $0.date >= sevenDaysAgo }
        
        let watering = recentSessions.filter { $0.actionType == .watering }.count
        let spraying = recentSessions.filter { $0.actionType == .spraying }.count
        let feeding = recentSessions.filter { $0.actionType == .feeding }.count
        
        return (watering, spraying, feeding)
    }
    
    func next7DaysCount() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today) ?? Date()
        
        return plants.filter { plant in
            let nextDate = plant.nextWateringDate
            return nextDate >= today && nextDate < nextWeek
        }.count
    }
    
    func addPlant(_ plant: Plant) {
        plants.append(plant)
        saveData()
        NotificationManager.shared.scheduleNotifications(
            for: plant,
            reminderStart: reminderWindowStart,
            reminderEnd: reminderWindowEnd,
            pauseUntil: pauseUntilDate
        )
    }
    
    func updatePlant(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index] = plant
            saveData()
        }
    }
    
    func deletePlant(_ plant: Plant) {
        plants.removeAll { $0.id == plant.id }
        sessions.removeAll { $0.plantId == plant.id }
        NotificationManager.shared.cancelNotifications(for: plant.id)
        saveData()
    }
    
    func waterPlant(_ plant: Plant, actionType: ActionType = .watering, notes: String? = nil) {
        var updatedPlant = plant
        
        switch actionType {
        case .watering:
            updatedPlant.lastWatered = Date()
        case .spraying:
            updatedPlant.lastSprayed = Date()
        case .feeding:
            updatedPlant.lastFed = Date()
        }
        
        updatePlant(updatedPlant)
        
        let session = WateringSession(
            plantId: plant.id,
            plantName: plant.name,
            actionType: actionType,
            date: Date(),
            notes: notes,
            location: plant.location
        )
        sessions.append(session)
        saveData()
        
        // Update notification for this plant
        NotificationManager.shared.scheduleNotifications(
            for: updatedPlant,
            reminderStart: reminderWindowStart,
            reminderEnd: reminderWindowEnd,
            pauseUntil: pauseUntilDate
        )
    }
    
    func clearAllSessions() {
        sessions.removeAll()
        saveData()
    }
    
    func clearAllData() {
        plants.removeAll()
        sessions.removeAll()
        saveData()
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(encoded, forKey: plantsKey)
        }
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
        saveSettings()
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: plantsKey),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            plants = decoded
        } else {
            // Add sample data
            addSampleData()
        }
        
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([WateringSession].self, from: data) {
            sessions = decoded
        }
        
        loadSettings()
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        UserDefaults.standard.set(dailySummaryEnabled, forKey: "dailySummaryEnabled")
        UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled")
        UserDefaults.standard.set(postponeToTomorrowEnabled, forKey: "postponeToTomorrowEnabled")
        UserDefaults.standard.set(winterRestEnabled, forKey: "winterRestEnabled")
        UserDefaults.standard.set(reminderWindowStart, forKey: "reminderWindowStart")
        UserDefaults.standard.set(reminderWindowEnd, forKey: "reminderWindowEnd")
        UserDefaults.standard.set(dailySummaryTime, forKey: "dailySummaryTime")
        if let pauseDate = pauseUntilDate {
            UserDefaults.standard.set(pauseDate, forKey: "pauseUntilDate")
        } else {
            UserDefaults.standard.removeObject(forKey: "pauseUntilDate")
        }
    }
    
    private func loadSettings() {
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        dailySummaryEnabled = UserDefaults.standard.bool(forKey: "dailySummaryEnabled")
        hapticEnabled = UserDefaults.standard.bool(forKey: "hapticEnabled")
        postponeToTomorrowEnabled = UserDefaults.standard.bool(forKey: "postponeToTomorrowEnabled")
        winterRestEnabled = UserDefaults.standard.bool(forKey: "winterRestEnabled")
        
        if let start = UserDefaults.standard.object(forKey: "reminderWindowStart") as? Date {
            reminderWindowStart = start
        }
        if let end = UserDefaults.standard.object(forKey: "reminderWindowEnd") as? Date {
            reminderWindowEnd = end
        }
        if let summary = UserDefaults.standard.object(forKey: "dailySummaryTime") as? Date {
            dailySummaryTime = summary
        }
        pauseUntilDate = UserDefaults.standard.object(forKey: "pauseUntilDate") as? Date
    }
    
    private func addSampleData() {
        let monstera = Plant(
            name: "Monstera",
            location: "Living Room",
            wateringIntervalDays: 3,
            sprayingIntervalDays: 2,
            feedingIntervalDays: 14,
            lastWatered: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            notes: "Water moderately"
        )

        let sansevieria = Plant(
            name: "Snake Plant",
            location: "Bedroom",
            wateringIntervalDays: 14,
            sprayingIntervalDays: nil,
            feedingIntervalDays: 30,
            lastWatered: Calendar.current.date(byAdding: .day, value: -13, to: Date()),
            notes: "14 cm pot"
        )

        let succulent = Plant(
            name: "Succulent",
            location: "Kitchen",
            wateringIntervalDays: 8,
            sprayingIntervalDays: nil,
            feedingIntervalDays: 30,
            lastWatered: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
            notes: "Reminder window: 19:00 - 21:00"
        )
        
        plants = [monstera, sansevieria, succulent]
        saveData()
    }
}

