//
//  UIDevice+Ext.swift
//  Apple
//
//  Created by Y1616 on 2025/6/12.
//

import SwiftUI

#if os(iOS)
@available(iOS 2.0, *)
extension UIDevice.BatteryState {
    var name: String {
        switch self {
        case .unknown:
            "未知"
        case .unplugged:
            "未充电"
        case .charging:
            "充电中"
        case .full:
            "已充满"
        @unknown default:
            "未知类型\(self.rawValue)"
        }
    }
}
#endif
