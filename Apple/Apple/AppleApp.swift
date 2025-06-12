//
//  AppleApp.swift
//  Apple
//
//  Created by Y1616 on 2025/4/18.
//

import SwiftUI

@main
struct AppleApp: App {

    init() {
#if os(iOS)
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        device.isProximityMonitoringEnabled = true
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
