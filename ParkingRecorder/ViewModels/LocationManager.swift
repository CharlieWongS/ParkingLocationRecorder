//
//  LocationManager.swift
//  ParkingRecorder
//
//  Created by Charlie Wong on 22-05-2025.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData
import CoreData

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // Permission Reminder
    @Published var showPermissionAlert = false
    

    // Psychology Mode Switching function
    @Published var selected: Selection = .car
    
    
    // History Button
    @Published var focusLocation: CLLocationCoordinate2D? = nil
    
    
    // Set for data
    var modelContext: ModelContext?
    
    
    // Set var for location
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    
    // selectedHistory -> choosed on map's record, change to 2D by using CLLocationCoordinate2D(latitude: selectedHistory!.latitude, longitude: selectedHistory!.longitude)
    @Published var selectedHistory: History?

    
    
    // Follow User location
    @Published var shouldFollowUser = true
    @Published var userPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()

    }
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        userLocation = latest
        
    }
    

    
    // Record user location infomation
    func recordLocation(userLocation: CLLocation?) {
        
        // Check for Authorization
        guard checkLocationAuthorization() else {
            print("❌ Location permission not granted.")
            return
        }
        
        guard let loc = userLocation else {
                print("❌ Location not available yet.")
                return
            }

            print("--- User Location Info ---")
            print("Coordinate: \(loc.coordinate)")
            print("Altitude: \(loc.altitude)")
            print("Speed: \(loc.speed)")
            print("Accuracy: \(loc.horizontalAccuracy)")
            print("Timestamp: \(loc.timestamp)")

            let history = History(
                timestamp: loc.timestamp,
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                altitude: loc.altitude,
                speed: loc.speed,
                accuracy: loc.horizontalAccuracy
            )

            if let context = modelContext {
                context.insert(history)
                print("✅ Location saved to model.")
            } else {
                print("❌ modelContext not set.")
            }
        
            
        }
    
    func relocateUserPosition() {
        // Check for Authorization
        
        guard checkLocationAuthorization() else {
            print("❌ Location permission not granted.")
            return
        }
        
        
        guard userLocation != nil else { return }

        userPosition = .userLocation(fallback: .automatic)

        // Re-enable follow mode after short delay to avoid instant snap-back
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.shouldFollowUser = true
        }
    }
 
    
    // Deletion
    func delete(history: History) {
        selectedHistory = nil // Clean the selected one
        guard let context = modelContext else {
            print("❌ modelContext is not set. Cannot delete history.")
            return
        }

        context.delete(history)
        
    }
    

    func deleteAllHistories() {
        selectedHistory = nil // Clean the selected one
        guard let context = modelContext else {
            print("❌ modelContext is not set.")
            return
        }

        let cutoffDate = Date().addingTimeInterval(0) // change time to 0 to delete all

        // Query all histories
        let descriptor = FetchDescriptor<History>(
            predicate: #Predicate { $0.timestamp < cutoffDate }
        )

        do {
            let oldRecords = try context.fetch(descriptor)
            for record in oldRecords {
                context.delete(record)
            }
            
            print("🗑️ Deleted \(oldRecords.count) old history items.")
        } catch {
            print("❌ Failed to fetch or delete old history: \(error)")
        }
    }

    func deleteOldHistory() {
        selectedHistory = nil // Clean the selected one
        guard let context = modelContext else {
            print("❌ modelContext is not set.")
            return
        }

        let cutoffDate = Date().addingTimeInterval(-72 * 60 * 60) // 72 hours ago

        // Query all histories
        let descriptor = FetchDescriptor<History>(
            predicate: #Predicate { $0.timestamp < cutoffDate }
        )

        do {
            let oldRecords = try context.fetch(descriptor)
            for record in oldRecords {
                context.delete(record)
            }
            
            print("🗑️ Deleted \(oldRecords.count) old history items.")
        } catch {
            print("❌ Failed to fetch or delete old history: \(error)")
        }
    }

    
    
    // Mode Switching Button
    enum Selection {
        case car, bike
    }
    
    func modeButton(selection: Selection, label: () -> some View) -> some View {
        Button(action: {
            self.selected = selection
        }) {
            label()
                .frame(width: 43, height: 43)
                .foregroundColor(selected == selection ? .white : .blue)
                .background(selected == selection ? Color.blue : Color.clear)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                )
                .scaleEffect(selected == selection ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: selected)
        }
        
        .shadow(radius: 15, x: 0, y: 15)

    }

    // Permission Reminder
    func checkLocationAuthorization() -> Bool {
        let status = manager.authorizationStatus  // use instance, not class method

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            
            return true
        case .denied, .restricted, .notDetermined:
            showPermissionAlert = true
            
            return false
        @unknown default:
            return false
        }
    }

    
    
    // Navigation
    
    func openInAppleMaps() {
        
        let destination = CLLocationCoordinate2D(latitude: selectedHistory!.latitude, longitude: selectedHistory!.longitude)
        let placemark = MKPlacemark(coordinate: destination)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

}
