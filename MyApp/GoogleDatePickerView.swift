//
//  GoogleDatePickerView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// MARK: - Main View

struct GoogleDatePickerView: View {
    @State private var selectedDate = Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 17)) ?? Date()
    @State private var currentMonthDate = Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1)) ?? Date()
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    // Example static "today" for styling the outline circle as per screenshot
    private let todayComponents = DateComponents(year: 2025, month: 8, day: 5)
    
    var body: some View {
        ZStack {
            // Dimmed background typically used for modals
            // Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Header Section
                HeaderView(selectedDate: $selectedDate)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 8)
                
                // 2. Month Navigation
                MonthNavigationView(currentMonthDate: $currentMonthDate)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                // 3. Calendar Grid Section
                CalendarGridView(
                    selectedDate: $selectedDate,
                    currentMonthDate: $currentMonthDate,
                    daysOfWeek: daysOfWeek,
                    todayComponents: todayComponents
                )
                .padding(.horizontal)
                .padding(.bottom) // Add some space before actions
                
                // Thin divider line
                Divider().padding(.horizontal)
                
                // 4. Action Buttons Section
                ActionButtonsView()
                    .padding()
            }
            .background(Color(.systemGray6)) // Light background for the card
            .cornerRadius(20)
            .shadow(radius: 5)
            .frame(width: 360) // Approximate width from screenshot
            // .frame(maxWidth: 360) // Alternative for responsiveness
        }
        // .frame(maxWidth: .infinity, maxHeight: .infinity) // To center the card in the view
        // .background(Color.black.opacity(0.6)) // Example background if used as modal
    }
}

// MARK: - Subviews

struct HeaderView: View {
    @Binding var selectedDate: Date
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d" // e.g., Mon, Aug 17
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Select date")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(dateFormatter.string(from: selectedDate))
                    .font(.largeTitle)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "pencil")
                    .foregroundColor(.secondary)
                    .font(.title2)
            }
        }
    }
}

struct MonthNavigationView: View {
    @Binding var currentMonthDate: Date
    private let calendar = Calendar.current
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // e.g., August 2025
        return formatter
    }()
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Text(monthYearFormatter.string(from: currentMonthDate))
                    .font(.headline)
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
            }
            
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
            }
        }
    }
    
    private func changeMonth(by amount: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: amount, to: currentMonthDate) {
            currentMonthDate = newMonth
        }
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonthDate: Date
    let daysOfWeek: [String]
    let todayComponents: DateComponents // To check against for 'today' styling
    
    private let calendar = Calendar.current
    private var today: Date { calendar.date(from: todayComponents) ?? Date() }
    
    var body: some View {
        VStack(spacing: 15) { // Increased spacing between headers and grid
            // Day Headers (S M T W T F S)
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.primary.opacity(0.8))
                }
            }
            
            // Grid of Days
            let days = generateDaysInMonth(for: currentMonthDate)
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 10) { // Spacing between rows
                ForEach(days, id: \.self) { day in
                    if let date = day {
                        DayCell(
                            date: date,
                            selectedDate: $selectedDate,
                            currentMonthDate: currentMonthDate,
                            isToday: calendar.isDate(date, inSameDayAs: today)
                        )
                    } else {
                        // Placeholder for empty spots in the grid
                        Text("")
                            .frame(maxWidth: .infinity, minHeight: 40) // Match DayCell height
                    }
                }
            }
        }
    }
    
    
    // Generates Date objects for the current month grid, including nil placeholders
    private func generateDaysInMonth(for baseDate: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: baseDate),
              // `monthInterval.start` is already non-optional here, so use it directly below
              let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: monthInterval.end),
              // Use monthInterval.start directly in the 'for:' parameter
              let firstWeekday = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: monthInterval.start)
        else {
            // If any optional above was nil, return empty
            return []
        }
        
        // If the guard passed, we know monthInterval exists, so we can safely access .start
        let firstDayOfMonth = monthInterval.start
        
        // ... (rest of the function remains the same)
        let numberOfDays = calendar.component(.day, from: lastDayOfMonth)
        // Note: Calendar firstWeekday is often 1 for Sunday. Adjust if your calendar settings differ.
        // Calculation assumes calendar.firstWeekday = 1 (Sunday). If it's 2 (Monday), adjust accordingly.
        let startingSpaces = (firstWeekday - calendar.firstWeekday + 7) % 7 // More robust calculation
        
        var days: [Date?] = Array(repeating: nil, count: startingSpaces)
        
        for dayOffset in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth) {
                days.append(date)
            } else {
                days.append(nil) // Should not happen within the month range
            }
        }
        
        // Optional: Add trailing placeholders to fill the last week if needed
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
}

struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    let currentMonthDate: Date
    let isToday: Bool
    
    private let calendar = Calendar.current
    private var isSelected: Bool { calendar.isDate(date, inSameDayAs: selectedDate) }
    private var isCurrentMonth: Bool { calendar.isDate(date, equalTo: currentMonthDate, toGranularity: .month) }
    private var dayNumber: String {
        let day = calendar.component(.day, from: date)
        return String(day)
    }
    
    var body: some View {
        Text(dayNumber)
            .font(.body)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 40) // Consistent height for cells
            .background(backgroundView)
            .clipShape(Circle()) // Ensure background stays circular
            .overlay(overlayView) // For the 'today' outline
            .opacity(isCurrentMonth ? 1.0 : 0.0) // Hide days not in the current month visually
            .allowsHitTesting(isCurrentMonth) // Make non-month days non-interactive
            .onTapGesture {
                selectedDate = date
            }
    }
    
    // Determine background view based on selection state
    private var backgroundView: some View {
        Group {
            if isSelected {
                Circle()
                    .fill(Color.purple.opacity(0.8)) // Selected background
            } else {
                Color.clear // Default transparent background
            }
        }
    }
    
    // Determine overlay view for 'today' outline
    private var overlayView: some View {
        Group {
            // Show outline only if it's today AND not also selected
            if isToday && !isSelected {
                Circle()
                    .stroke(Color.purple.opacity(0.8), lineWidth: 1.5)
            }
        }
    }
    
    // Determine text color based on selection and today state
    private var foregroundColor: Color {
        if isSelected {
            return .white // Text color when selected
        } else {
            return .primary // Default text color
        }
    }
}

struct ActionButtonsView: View {
    var body: some View {
        HStack {
            Spacer() // Pushes buttons to the right
            
            Button("Cancel") {
                // Add cancel action
                print("Cancel tapped")
            }
            .foregroundColor(.purple)
            .padding(.horizontal) // Add padding between buttons
            
            Button("OK") {
                // Add OK action
                print("OK tapped")
            }
            .foregroundColor(.purple)
            .fontWeight(.medium) // OK often has slightly more emphasis
        }
    }
}

// MARK: - Preview

struct GoogleDatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleDatePickerView()
            .padding() // Add padding around the card in preview
            .background(Color.black.opacity(0.5)) // Simulate modal background in preview
    }
}
