//
//  DockedInputDataPickerView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

struct DatePickerDemoView: View {
    // State for the selected date and the currently displayed month/year
    @State private var selectedDate: Date? = Calendar.current.date(bySetting: .day, value: 17, of: Date()) // Default to 17th of current month
    @State private var displayDate: Date = Date() // Month/Year currently shown in the calendar

    // Constants for styling
    let selectedColor = Color(red: 123/255, green: 111/255, blue: 189/255)
    let primaryTextColor = Color.primary.opacity(0.8)
    let secondaryTextColor = Color.secondary.opacity(0.7)
    let popupBackgroundColor = Color(red: 234/255, green: 234/255, blue: 242/255) // Approximate pale purple/grey
    let buttonTextColor = Color(red: 123/255, green: 111/255, blue: 189/255) // Using the selection color for buttons

    // Calendar related helpers
    var calendar = Calendar.current
    let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        ZStack {
            // Background matching the screenshot's dark theme
            Color(white: 0.15).edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // --- Top Input Field ---
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Date")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("MM/DD/YYYY") // Placeholder - could be dynamic based on selectedDate
                            .font(.body)
                            .foregroundColor(selectedDate == nil ? .gray.opacity(0.5) : primaryTextColor)
                    }
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(white: 0.25)) // Darker input background
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )

                // --- Calendar Popup ---
                VStack(spacing: 0) {
                    // --- Header ---
                    HStack {
                        // Month Controls
                        Button { changeMonth(by: -1) } label: { Image(systemName: "chevron.left") }
                        Text(monthYearString(from: displayDate).components(separatedBy: " ")[0] + " ▼") // Simple dropdown indicator
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Button { changeMonth(by: 1) } label: { Image(systemName: "chevron.right") }

                        Spacer() // Add space between month and year controls

                        // Year Controls
                        Button { changeYear(by: -1) } label: { Image(systemName: "chevron.left") }
                        Text(monthYearString(from: displayDate).components(separatedBy: " ")[1] + " ▼") // Simple dropdown indicator
                             .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Button { changeYear(by: 1) } label: { Image(systemName: "chevron.right") }
                    }
                    .padding()
                    .foregroundColor(primaryTextColor)

                    Divider().background(Color.gray.opacity(0.3))

                    // --- Weekday Labels ---
                    HStack {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(secondaryTextColor)
                        }
                    }
                    .padding(.vertical, 8)

                    // --- Date Grid ---
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                        ForEach(daysInMonth(), id: \.self) { date in
                            dateCell(for: date)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom) // Add padding below the grid

                    // --- Separator ---
                     Path { path in
                         path.move(to: CGPoint(x: 0, y: 0))
                         path.addLine(to: CGPoint(x: 300, y: 0)) // Adjust width as needed
                     }
                     .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                     .frame(height: 1)
                     .foregroundColor(Color.gray.opacity(0.5))
                     .padding(.horizontal)

                    // --- Action Buttons ---
                    HStack {
                        Button("Clear") { selectedDate = nil }
                        Spacer()
                        Button("Cancel") { /* Add cancel action */ }
                        Button("OK") { /* Add OK action, e.g., dismiss picker */ }
                    }
                    .padding()
                    .font(.body.weight(.medium))
                    .foregroundColor(buttonTextColor) // Apply consistent button color

                }
                .background(popupBackgroundColor)
                .cornerRadius(16)

                Spacer() // Pushes content to the top
            }
            .padding() // Overall padding for the VStack
        }
    }

    // --- Helper Functions ---

    func dateCell(for date: Date?) -> some View {
        Group { // Use Group to handle conditional content
            if let validDate = date {
                let isSelected = calendar.isDate(validDate, inSameDayAs: selectedDate ?? Date(timeIntervalSince1970: 0))
                let isCurrentMonth = calendar.isDate(validDate, equalTo: displayDate, toGranularity: .month)
                let day = calendar.component(.day, from: validDate)

                Text("\(day)")
                    .frame(width: 32, height: 32) // Consistent cell size
                    .background(isSelected ? selectedColor : Color.clear)
                    .clipShape(Circle())
                    .foregroundColor(isSelected ? .white : (isCurrentMonth ? primaryTextColor : secondaryTextColor))
                    .fontWeight(isSelected ? .bold : .regular)
                    .opacity(isCurrentMonth ? 1.0 : 0.5) // Grey out non-current month days
                    .onTapGesture {
                        if isCurrentMonth {
                            selectedDate = validDate
                        }
                        // Optionally change month if a non-current month date is tapped
                        // displayDate = validDate
                    }
            } else {
                 // Placeholder for empty cells if needed, though `daysInMonth` should handle padding
                 Rectangle().fill(Color.clear).frame(width: 32, height: 32)
            }
        }
    }

    func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return [] }

        var dates: [Date?] = []
        let firstDayOfMonthWeekday = calendar.component(.weekday, from: monthInterval.start) // Sunday = 1, Saturday = 7
        let numberOfPaddingDays = (firstDayOfMonthWeekday - calendar.firstWeekday + 7) % 7

        // Add padding days from the previous month
        if numberOfPaddingDays > 0 {
            let previousMonthDay = calendar.date(byAdding: .day, value: -numberOfPaddingDays, to: monthInterval.start)!
             for i in 0..<numberOfPaddingDays {
                 dates.append(calendar.date(byAdding: .day, value: i, to: previousMonthDay))
             }
        }

        // Add days of the current month
        let range = calendar.range(of: .day, in: .month, for: displayDate)!
        for day in range {
            if let date = calendar.date(bySetting: .day, value: day, of: displayDate) {
                dates.append(date)
            }
        }

         // Add padding days from the next month to fill the grid (usually up to 6 weeks = 42 cells)
         let remainingCells = (7 * 6) - dates.count // Assuming 6 rows max for typical calendar view
         if remainingCells > 0 {
             let nextMonthDay = monthInterval.end // Start of the next month
             for i in 0..<remainingCells {
                 dates.append(calendar.date(byAdding: .day, value: i, to: nextMonthDay))
            }
         }

        // We might only need to pad to the end of the *last* week containing days of the month,
        // rather than always filling 6 rows. Let's recalculate padding for the end.
        dates = [] // Reset dates for revised logic

        // Add padding days from the previous month (same as before)
        if numberOfPaddingDays > 0 {
            let previousMonthDay = calendar.date(byAdding: .day, value: -numberOfPaddingDays, to: monthInterval.start)!
            for i in 0..<numberOfPaddingDays {
                dates.append(calendar.date(byAdding: .day, value: i, to: previousMonthDay))
            }
        }

        // Add days of the current month (same as before)
        let currentMonthRange = calendar.range(of: .day, in: .month, for: displayDate)!
        for day in currentMonthRange {
            if let date = calendar.date(bySetting: .day, value: day, of: displayDate) {
                dates.append(date)
            }
        }

        // Add padding days from the next month to complete the last week
        let totalDaysWithPaddingStart = dates.count
        let remainingWeekDays = (7 - (totalDaysWithPaddingStart % 7)) % 7
        if remainingWeekDays > 0 {
            let nextMonthDay = monthInterval.end // Start of the next month
             for i in 0..<remainingWeekDays {
                 dates.append(calendar.date(byAdding: .day, value: i, to: nextMonthDay))
            }
        }

        return dates
    }

    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy" // Short month name, full year
        return formatter.string(from: date)
    }

    func changeMonth(by amount: Int) {
        if let newDate = calendar.date(byAdding: .month, value: amount, to: displayDate) {
            displayDate = newDate
        }
    }
     func changeYear(by amount: Int) {
        if let newDate = calendar.date(byAdding: .year, value: amount, to: displayDate) {
            displayDate = newDate
        }
    }
}

struct DatePickerDemoView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerDemoView()
    }
}
