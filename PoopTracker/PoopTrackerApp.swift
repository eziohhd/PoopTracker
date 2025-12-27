//
//  PoopTrackerApp.swift
//  PoopTracker
//
//  Created on 2024
//

import SwiftUI

@main
struct PoopTrackerApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}

