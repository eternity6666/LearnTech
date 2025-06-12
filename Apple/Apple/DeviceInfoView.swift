//
//  DeviceInfoView.swift
//  Apple
//
//  Created by Y1616 on 2025/6/12.
//

import SwiftUI

@available(iOS 2.0, *)
struct DeviceInfoView: View {
    var body: some View {
        VStack {
#if os(iOS)
            Text("\(UIDevice.current.batteryLevel)")
            Text("\(UIDevice.current.batteryState)")
            Text("\(UIDevice.current.proximityState)")
#endif
        }
    }
}
