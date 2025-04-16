//
//  PortfolioWidgetBundle.swift
//  PortfolioWidget
//
//  Created by Cong Le on 4/15/25.
//

import WidgetKit
import SwiftUI

@main
struct PortfolioWidgetBundle: WidgetBundle {
    var body: some Widget {
        PortfolioWidget()
        PortfolioWidgetControl()
        PortfolioWidgetLiveActivity()
    }
}
