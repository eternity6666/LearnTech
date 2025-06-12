//
//  ContentView.swift
//  Apple
//
//  Created by Y1616 on 2025/4/18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
//            AnimatedSineWaveDemo()
//            ColorTextView()
//            TopBottomTextView()
            DeviceInfoView()
        }
        .padding()
    }
}

@available(iOS 2.0, *)
struct DeviceInfoView: View {
    var body: some View {
        VStack {
            Text("\(UIDevice.current.batteryLevel)")
            Text("\(UIDevice.current.batteryState)")
            Text("\(UIDevice.current.proximityState)")
        }
    }
}

#Preview {
    ContentView()
}
