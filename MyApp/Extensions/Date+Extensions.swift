//
//  Date+Extensions.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Extended Date values used to return DateComponents for a given Calendar.
*/

import Foundation

extension Date {
    func components(
        _ components: Set<Calendar.Component> = [.year, .month, .day],
        from calendar: Calendar
    ) -> DateComponents {
        var dateComponents = calendar.dateComponents(components, from: self)
        dateComponents.calendar = calendar
        return dateComponents
    }
}
