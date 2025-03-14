//
//  AVCameraControlCenterBundle.swift
//  AVCameraControlCenter
//
//  Created by Cong Le on 3/14/25.
//

import WidgetKit
import SwiftUI

@main
struct AVCameraControlCenterBundle: WidgetBundle {
    var body: some Widget {
        AVCameraControlCenter()
        AVCameraControlCenterControl()
        AVCameraControlCenterLiveActivity()
    }
}
