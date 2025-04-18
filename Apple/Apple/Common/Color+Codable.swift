//
//  Color+Codable.swift
//  Apple
//
//  Created by Y1616 on 2025/4/18.
//

import SwiftUI

extension Color: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let components = try container.decode([CGFloat].self)
        self = Color(.sRGB, red: components[0], green: components[1], blue: components[2], opacity: components[3])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let resolved = self.resolve(in: .init())
        try container.encode([resolved.red, resolved.green, resolved.blue, resolved.opacity])
    }
}
