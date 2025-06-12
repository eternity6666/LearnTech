//
//  WidgetBundle.swift
//  Widget
//
//  Created by Y1616 on 2025/6/6.
//

import WidgetKit
import SwiftUI

@main
struct MyWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        MyWidget()
    }
}
