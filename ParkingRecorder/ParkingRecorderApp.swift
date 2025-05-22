//
//  ParkingRecorderApp.swift
//  ParkingRecorder
//
//  Created by Charlie Wong on 22-05-2025.
//

import SwiftUI
import TipKit

@main
struct ParkingRecorderApp: App {
    @StateObject private var locationManager = LocationManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .modelContainer(for: History.self)
        }
    }
    init() {
        try? Tips.configure()
//        Tips.showAllTipsForTesting() // Reset tips during testing

    }
}
