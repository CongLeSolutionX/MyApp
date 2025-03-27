//
//  MortgageNewsView.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI

struct MortgageNewsView: View {
    @State private var selectedTab: Tab = .rates

    var body: some View {
        TabView(selection: $selectedTab) {
            RatesView()
                .tabItem {
                    Label("Rates", systemImage: "percent")
                }
                .tag(Tab.rates)

            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell")
                }
                .tag(Tab.alerts)

            CalculatorsView()
                .tabItem {
                    Label("Calculators", systemImage: "function")
                }
                .tag(Tab.calculators)

            NewsView()
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }
                .tag(Tab.news)

            LendersView()
                .badge(6)
                .tabItem {
                    Label("Lenders", systemImage: "house.fill")
                }
                .tag(Tab.lenders)
        }
        .overlay(alignment: .bottomTrailing) {
            if selectedTab != .alerts && selectedTab != .calculators { // Example condition
                FloatingActionButton()
                    .padding()
            }
        }
    }
}

struct TopNavigationBar: View {
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .font(.title2)
            Spacer()
            VStack {
                Text("MORTGAGE")
                    .font(.caption2)
                Text("News Daily")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            Spacer()
            Image(systemName: "gearshape")
                .font(.title2)
        }
        .padding()
        .background(Color.black)
        .foregroundColor(.white)
    }
}

struct RatesView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TopNavigationBar()

                    HStack {
                        RateCard(title: "30 Yr. Fixed", rate: "6.80%", change: "+0.00%", changeColor: .green)
                        Spacer()
                        RateCard(title: "15 Yr. Fixed", rate: "6.22%", change: "+0.01%", changeColor: .red)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 10) {
                        RateRow(loanType: "30 Yr. FHA", rate: "6.24%", change: "+0.00%", changeColor: .green)
                        RateRow(loanType: "30 Yr. Jumbo", rate: "6.95%", change: "+0.00%", changeColor: .green)
                        RateRow(loanType: "7/6 SOFR ARM", rate: "6.41%", change: "-0.01%", changeColor: .red)
                        RateRow(loanType: "30 Yr. VA", rate: "6.25%", change: "+0.00%", changeColor: .green)
                    }
                    .padding(.horizontal)

                    Text("Updated: 3/26/2025 | Rates based on National Averages")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    Divider()
                        .padding(.vertical)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mortgage Rates Hold Steady Near Recent Highs")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("It depends what one's definition of \"recent\" is, but if it involves the past few weeks, mortgage rates were at their highest recen...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("Wednesday's Rate Trend")
                            .font(.title3)
                            .fontWeight(.semibold)

                        HStack {
                            Text("UMBS 30YR 5.5")
                            Spacer()
                            Text("99.49")
                            Text("+0.04")
                                .foregroundColor(.green)
                        }

                        HStack {
                            Text("10 YR Treasury")
                            Spacer()
                            Text("4.341")
                            Text("-0.012")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's Markets Potential Effect on Rates")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack {
                            Text("POSITIVE")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                                .background(Color.green)
                                .cornerRadius(5)
                            Spacer()
                            Text("MINIMAL")
                                .font(.caption)
                                .foregroundColor(.black)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                                .background(Color.yellow)
                                .cornerRadius(5)
                            Spacer()
                            Text("NEGATIVE")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                                .background(Color.red)
                                .cornerRadius(5)
                        }
                        .frame(maxWidth: .infinity)

                        Text("MBS prices have increased slightly today. This may result in minimal positive impact on mortgage rates today.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .background(Color.black)
            .foregroundColor(.white)
        }
    }
}

struct RateCard: View {
    let title: String
    let rate: String
    let change: String
    let changeColor: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            Text(rate)
                .font(.largeTitle)
                .fontWeight(.bold)
            HStack {
                Text(change)
                    .foregroundColor(changeColor)
                Image(systemName: "waveform.path.ecg") // Placeholder for the wavy line icon
                    .foregroundColor(changeColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.init(white: 0.1))
        .cornerRadius(10)
    }
}

struct RateRow: View {
    let loanType: String
    let rate: String
    let change: String
    let changeColor: Color

    var body: some View {
        HStack {
            Text(loanType)
            Spacer()
            Text(rate)
            HStack {
                Text(change)
                    .foregroundColor(changeColor)
                Image(systemName: "arrow.up.arrow.down") // Placeholder
                    .foregroundColor(changeColor)
                    .font(.caption2)
            }
        }
        .padding(.vertical, 5)
    }
}

struct AlertsView: View {
    var body: some View {
        Text("Alerts Content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .foregroundColor(.white)
            .navigationTitle("Alerts")
    }
}

struct CalculatorsView: View {
    var body: some View {
        Text("Calculators Content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .foregroundColor(.white)
            .navigationTitle("Calculators")
    }
}

struct NewsView: View {
    var body: some View {
        Text("News Content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .foregroundColor(.white)
            .navigationTitle("News")
    }
}

struct LendersView: View {
    var body: some View {
        Text("Lenders Content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .foregroundColor(.white)
            .navigationTitle("Lenders")
    }
}

struct FloatingActionButton: View {
    var body: some View {
        Button(action: {
            // Action for the floating button
        }) {
            Image(systemName: "square.and.arrow.up")
                .font(.title2)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .clipShape(Circle())
        }
    }
}

enum Tab {
    case rates, alerts, calculators, news, lenders
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MortgageNewsView()
            .preferredColorScheme(.dark)
    }
}
