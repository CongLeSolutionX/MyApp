//
//  CalculatorView.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//
//
//
import SwiftUI
import Charts

struct MortgageCalculatorView: View {
    @State private var term = "30 YR"
    @State private var interestRate = "6.8%"
    @State private var purchaseType = "Purchase"
    @State private var loanAmount = "$300K"
    
    // Financial details
    let principal: Double = 255.78
    let interest: Double = 1700.00
    let apr: Double = 6.930
    let taxes: Double = 333.33
    let insurance: Double = 333.33
    let hoaDues: Double = 0.00
    let totalPayment: Double = 2622.44
    
    // Timeline details
    let paymentNumber = 1
    let totalPayments = 360
    let paymentDate = "Apr 2025"
    let startDate = "Mar 2025"
    let payoffDate = "Mar 2055"
    
    // Payment breakdown structure
    struct PaymentComponent: Identifiable {
        let id = UUID()
        let name: String
        let amount: Double
    }
    var paymentBreakdown: [PaymentComponent] {
        [
            PaymentComponent(name: "Principal", amount: principal),
            PaymentComponent(name: "Interest", amount: interest),
            PaymentComponent(name: "Taxes", amount: taxes),
            PaymentComponent(name: "Insurance", amount: insurance)
        ]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.white)
                        .padding(.leading)
                        .opacity(0)
                    
                    Spacer()
                    
                    Text("Mortgage Calculators")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "gearshape")
                        .foregroundColor(.white)
                        .padding(.trailing)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.black)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Section title and icon
                        HStack {
                            Text("Basic Mortgage Payment")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image(systemName: "rhombus")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Option Buttons using the reusable OptionButton view
                        HStack(spacing: 10) {
                            OptionButton(title: "30 YR", isSelected: term == "30 YR") {
                                term = "30 YR"
                            }
                            OptionButton(title: "6.8%", isSelected: interestRate == "6.8%") {
                                interestRate = "6.8%"
                            }
                            OptionButton(title: "Purchase", isSelected: purchaseType == "Purchase") {
                                purchaseType = "Purchase"
                            }
                            OptionButton(title: "$300K", isSelected: loanAmount == "$300K") {
                                loanAmount = "$300K"
                            }
                            Spacer()
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        // Payment details
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Payment Details")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                            
                            paymentDetailRow(label: "Principal:", value: "$\(String(format: "%.2f", principal))")
                            paymentDetailRow(label: "Interest:", value: "$\(String(format: "%.2f", interest))")
                            paymentDetailRow(label: "APR:", value: "\(String(format: "%.3f", apr))%")
                            
                            paymentDetailRow(label: "Principal & Interest:", value: "$\(String(format: "%.2f", principal + interest))")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.top, 5)
                            
                            paymentDetailRow(label: "Taxes:", value: "$\(String(format: "%.2f", taxes))")
                            paymentDetailRow(label: "Insurance:", value: "$\(String(format: "%.2f", insurance))")
                            paymentDetailRow(label: "HOA Dues:", value: "$\(String(format: "%.2f", hoaDues))")
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            paymentDetailRow(label: "Total Payment:", value: "$\(String(format: "%.2f", totalPayment))")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Timeline and chart
                        VStack(alignment: .center) {
                            Text("Mortgage Timeline")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top)
                            Text("Payment: \(paymentNumber) of \(totalPayments) (\(paymentDate))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            if #available(iOS 17.0, *) {
                                Chart(paymentBreakdown) { component in
                                    SectorMark(
                                        angle: .value("Amount", component.amount),
                                        innerRadius: .ratio(0.5)
                                    )
                                    .foregroundStyle(by: .value("Component", component.name))
                                }
                                .chartLegend(.visible)
                                .frame(height: 200)
                                .padding()
                            } else {
                                Text("Pie Chart not available on this iOS version.")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Start Date:")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(startDate)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Button(action: {}) {
                                    HStack {
                                        Text("Reset")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                        Image(systemName: "arrow.clockwise")
                                            .foregroundColor(.white)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Payoff Date:")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(payoffDate)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                            
                            Text("Based on your start date of \(startDate) w/ no extra payments made or missed payments.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            
                            Button(action: {}) {
                                Text("View Full Amortization Table")
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                            }
                            .padding(.bottom, 5)
                            
                            Button(action: {}) {
                                Text("Have Feedback?")
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                            }
                            .padding(.bottom)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Bottom Tab Bar
                HStack(spacing: 0) {
                    tabBarItem(icon: "percent", label: "Rates", isActive: false)
                    tabBarItem(icon: "bell.fill", label: "Alerts", isActive: false)
                    tabBarItem(icon: "function", label: "Calculators", isActive: true)
                    tabBarItem(icon: "newspaper", label: "News", isActive: false)
                    tabBarItem(icon: "person.3.fill", label: "Lenders", isActive: false, badgeCount: 6)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .background(Color(.secondarySystemBackground))
            }
            .background(Color.black)
            .navigationBarHidden(true)
        }
    }
    
    // Reusable function to render a payment detail row.
    func paymentDetailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
        }
    }
    
    // Reusable function to render a tab bar item.
    func tabBarItem(icon: String, label: String, isActive: Bool, badgeCount: Int? = nil) -> some View {
        VStack {
            ZStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isActive ? .teal : .gray)
                if let count = badgeCount, count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 10, y: -8)
                }
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(isActive ? .teal : .gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Reusable Option Button

struct OptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color.gray.opacity(0.5) : Color.secondary.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

@available(iOS 14.0, *)
struct PieChartSlice: View {
    var value: Double
    var label: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 5) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    MortgageCalculatorView()
}
