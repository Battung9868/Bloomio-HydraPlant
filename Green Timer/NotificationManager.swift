//
//  NotificationManager.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleNotifications(for plant: Plant, reminderStart: Date, reminderEnd: Date, pauseUntil: Date?) {
        // Отменяем старые уведомления для этого растения
        cancelNotifications(for: plant.id)
        
        // Проверяем паузу
        if let pauseDate = pauseUntil, Date() < pauseDate {
            print("Уведомления на паузе до \(pauseDate)")
            return
        }
        
        let calendar = Calendar.current
        
        // 1. Watering notification
        if let nextWateringDate = getNextActionDate(
            lastDate: plant.lastWatered,
            intervalDays: plant.wateringIntervalDays,
            reminderStart: reminderStart
        ) {
            scheduleNotification(
                id: "watering-\(plant.id.uuidString)",
                title: "💧 Time to water",
                body: "\(plant.name) needs watering",
                date: nextWateringDate
            )
        }
        
        // 2. Spraying notification
        if let sprayingInterval = plant.sprayingIntervalDays,
           let lastSprayed = plant.lastSprayed,
           let nextSprayingDate = getNextActionDate(
            lastDate: lastSprayed,
            intervalDays: sprayingInterval,
            reminderStart: reminderStart
        ) {
            scheduleNotification(
                id: "spraying-\(plant.id.uuidString)",
                title: "💦 Time to spray",
                body: "\(plant.name) needs spraying",
                date: nextSprayingDate
            )
        }
        
        // 3. Feeding notification
        if let feedingInterval = plant.feedingIntervalDays,
           let lastFed = plant.lastFed,
           let nextFeedingDate = getNextActionDate(
            lastDate: lastFed,
            intervalDays: feedingInterval,
            reminderStart: reminderStart
        ) {
            scheduleNotification(
                id: "feeding-\(plant.id.uuidString)",
                title: "🌿 Time to feed",
                body: "\(plant.name) needs feeding",
                date: nextFeedingDate
            )
        }
    }
    
    private func getNextActionDate(lastDate: Date?, intervalDays: Int, reminderStart: Date) -> Date? {
        guard let lastDate = lastDate else { return nil }
        
        let calendar = Calendar.current
        
        // Вычисляем день следующего действия
        guard let nextActionDay = calendar.date(byAdding: .day, value: intervalDays, to: lastDate) else {
            return nil
        }
        
        // Если день уже прошёл, возвращаем nil
        if calendar.isDateInToday(nextActionDay) || nextActionDay < Date() {
            // Для сегодняшних/просроченных - уведомление на начало окна
            let reminderComponents = calendar.dateComponents([.hour, .minute], from: reminderStart)
            return calendar.date(bySettingHour: reminderComponents.hour ?? 19, minute: reminderComponents.minute ?? 0, second: 0, of: Date())
        }
        
        // Устанавливаем время из окна напоминаний
        let reminderComponents = calendar.dateComponents([.hour, .minute], from: reminderStart)
        return calendar.date(
            bySettingHour: reminderComponents.hour ?? 19,
            minute: reminderComponents.minute ?? 0,
            second: 0,
            of: nextActionDay
        )
    }
    
    private func scheduleNotification(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка создания уведомления: \(error)")
            } else {
                print("✅ Уведомление запланировано: \(title) на \(date)")
            }
        }
    }
    
    func cancelNotifications(for plantId: UUID) {
        let identifiers = [
            "watering-\(plantId.uuidString)",
            "spraying-\(plantId.uuidString)",
            "feeding-\(plantId.uuidString)"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func scheduleAllNotifications(for plants: [Plant], reminderStart: Date, reminderEnd: Date, pauseUntil: Date?) {
        // Удаляем все старые уведомления
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Создаем новые для всех растений
        for plant in plants {
            scheduleNotifications(for: plant, reminderStart: reminderStart, reminderEnd: reminderEnd, pauseUntil: pauseUntil)
        }
    }
    
    func checkNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // Показать все запланированные уведомления (для отладки)
    func printScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📱 Запланировано уведомлений: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let nextTriggerDate = trigger.nextTriggerDate() {
                    print("  - \(request.content.title): \(nextTriggerDate)")
                }
            }
        }
    }
}

