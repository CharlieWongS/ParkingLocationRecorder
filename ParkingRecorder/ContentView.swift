//
//  ContentView.swift
//  ParkingRecorder
//
//  Created by Charlie Wong on 22-05-2025.
//

import SwiftUI
import TipKit

struct ContentView: View {
    @EnvironmentObject var lm: LocationManager
    
    var body: some View {
        VStack {
            TabView {
                MapView()
                    .tabItem {
                        Image(systemName: "map")
                        Text("Map")
                        
                    }
                
                HistoryView()
                    .tabItem {
                        
                        Image(systemName: "list.bullet")
                        Text("History")
                    }
                
            }
        }
    }
}
    
#Preview {
    ContentView()
}
