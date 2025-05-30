//
//  RecordTip.swift
//  ParkingRecorder
//
//  Created by Charlie Wong on 22-05-2025.
//


import TipKit
import Foundation


import TipKit

struct RecordTip: Tip {
    var title: Text {
        Text("Tap it!")
    }
    
    var message: Text? {
        Text("Tap here to mark your location manually.")
    }
    
    var image: Image? {
        Image(systemName: "mappin.circle.fill")
    }
}

struct RelocationTip: Tip {
    var title: Text {
        Text("Tap it!")
    }
    var message: Text? {  
        Text("Tap show where you are.")
    }
    
    var image: Image? {
        Image(systemName: "location.circle.fill")
        
    }
}



struct HistoryTip: Tip {
    var title: Text {
        Text("History")
    }
    
    var message: Text? {
        Text("Tap to copy & navigate.")
    }
    
    var image: Image? {
        Image(systemName: "list.bullet")
    }
}
    
struct NavigationTip: Tip {
        var title: Text {
            Text("Tap to Navigate")
        }
        
        var message: Text? {
            Text("The accuracy may be effected by GPS signal strength.")
        }
        
        var image: Image? {
            Image(systemName: "figure.walk")
        }
    }