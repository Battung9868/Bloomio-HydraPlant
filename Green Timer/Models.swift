//
//  Models.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import Foundation
import SwiftUI

enum ActionType: String, Codable, CaseIterable {
    case watering = "Watering"
    case spraying = "Spraying"
    case feeding = "Feeding"
    
    var icon: String {
        switch self {
        case .watering: return "💧"
        case .spraying: return "⬛️"
        case .feeding: return "✓"
        }
    }
    
    var color: Color {
        switch self {
        case .watering: return .blue
        case .spraying: return .gray
        case .feeding: return .green
        }
    }
}

enum PlantStatus: String, Codable {
    case today = "today"
    case overdue = "overdue"
    case tomorrow = "tomorrow"
    
    var color: Color {
        switch self {
        case .today: return .green
        case .overdue: return .red
        case .tomorrow: return .orange
        }
    }
}

struct Plant: Identifiable, Codable {
    var id = UUID()
    var name: String
    var location: String
    var imageData: Data?
    var wateringIntervalDays: Int
    var sprayingIntervalDays: Int?
    var feedingIntervalDays: Int?
    var lastWatered: Date?
    var lastSprayed: Date?
    var lastFed: Date?
    var notes: String?
    
    var nextWateringDate: Date {
        guard let lastWatered = lastWatered else {
            return Date()
        }
        return Calendar.current.date(byAdding: .day, value: wateringIntervalDays, to: lastWatered) ?? Date()
    }
    
    var wateringStatus: PlantStatus {
        let today = Calendar.current.startOfDay(for: Date())
        let nextDate = Calendar.current.startOfDay(for: nextWateringDate)
        
        if nextDate < today {
            return .overdue
        } else if nextDate == today {
            return .today
        } else if Calendar.current.isDateInTomorrow(nextDate) {
            return .tomorrow
        }
        return .tomorrow
    }
    
    var daysUntilWatering: String {
        let today = Calendar.current.startOfDay(for: Date())
        let nextDate = Calendar.current.startOfDay(for: nextWateringDate)
        let days = Calendar.current.dateComponents([.day], from: today, to: nextDate).day ?? 0
        
        if days < 0 {
            return "\(abs(days))d ago"
        } else if days == 0 {
            return "today"
        } else if days == 1 {
            return "tomorrow"
        } else {
            return "in \(days)d"
        }
    }
    
    var locationEmoji: String {
        switch location.lowercased() {
        case "living room": return "🛋️"
        case "kitchen": return "🍳"
        case "bedroom": return "🛏️"
        case "bathroom": return "🚿"
        case "balcony": return "🪴"
        case "office": return "💼"
        default: return "🏠"
        }
    }
}

struct WateringSession: Identifiable, Codable {
    var id = UUID()
    var plantId: UUID
    var plantName: String
    var actionType: ActionType
    var date: Date
    var notes: String?
    var location: String
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, EE"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

struct DailyStats: Codable {
    var date: Date
    var wateringCount: Int
    var sprayingCount: Int
    var feedingCount: Int
    var overdueCount: Int
}

