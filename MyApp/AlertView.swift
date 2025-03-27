//
//  AlertView.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI

struct AlertView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("MORTGAGE RATES")) {
                    NotificationRow(
                        title: "National Average Mortgage Rates",
                        subtitle: "Updated Daily\n1 Notification Per Day"
                    )
                }

                Section(header: Text("NEWS AND COMMENTARY")) {
                    NotificationRow(
                        title: "Mortgage Rate Watch",
                        subtitle: "Commentary published daily\n1 notification per day"
                    )
                    NotificationRow(
                        title: "Housing News",
                        subtitle: "Housing news other than rates\n1 - 4 notifications per day"
                    )
                    NotificationRow(
                        title: "MBS Commentary",
                        subtitle: "MBS Commentary published daily\n2 - 3 notifications per day"
                    )
                    NotificationRow(
                        title: "Rob Chrisman",
                        subtitle: "Rob Chrisman Commentary published daily\n1 notification per day"
                    )
                }
            }
            .navigationTitle("Mobile Alerts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "gearshape")
                }
            }
            .safeAreaInset(edge: .bottom) {
                BottomTabView()
            }
        }
    }
}

struct NotificationRow: View {
    @State private var isEnabled = false
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: $isEnabled)
        }
        .padding(.vertical, 8)
    }
}

struct BottomTabView: View {
    var body: some View {
        HStack {
            BottomTabItem(icon: "percent", label: "Rates")
            BottomTabItem(icon: "bell.fill", label: "Alerts", isSelected: true)
            BottomTabItem(icon: "function", label: "Calculators")
            BottomTabItem(icon: "newspaper", label: "News")
            BottomTabItem(icon: "house.fill", label: "Lenders", badgeCount: 6)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(Color(.systemBackground))
    }
}

struct BottomTabItem: View {
    let icon: String
    let label: String
    var isSelected: Bool = false
    var badgeCount: Int? = nil

    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .blue : .gray)
                if let count = badgeCount {
                    Circle()
                        .fill(.red)
                        .frame(width: 16, height: 16)
                        .offset(x: 8, y: -8)
                        .overlay(
                            Text("\(count)")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                        )
                }
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Alert View") {
    AlertView()
}
