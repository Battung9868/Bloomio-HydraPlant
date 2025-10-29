//
//  Green_TimerApp.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import SwiftUI

@main
struct Green_TimerApp: App {
    init() {
        // Запрашиваем разрешение на уведомления при запуске
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                print("Уведомления разрешены")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
