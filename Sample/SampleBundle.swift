//
//  SampleBundle.swift
//  Sample
//
//  Created by Cong Le on 3/14/25.
//

import WidgetKit
import SwiftUI

@main
struct SampleBundle: WidgetBundle {
    var body: some Widget {
        Sample()
        SampleControl()
        SampleLiveActivity()
    }
}
