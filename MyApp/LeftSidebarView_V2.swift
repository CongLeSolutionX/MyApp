//
//  LeftSidebarView_V2.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI

struct LeftSidebarView_V2: View {
    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Sidebar
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("MORTGAGE RATES")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.leading)
                            .padding(.top)

                        NavigationLink(destination: Text("Current Mortgage Rates")) {
                            HStack {
                                Image(systemName: "percent")
                                Text("Current Mortgage Rates")
                            }
                            .padding(.leading)
                            .padding(.vertical, 5)
                        }

                        NavigationLink(destination: Text("Mortgage Calculators")) {
                            HStack {
                                Image(systemName: "function")
                                Text("Mortgage Calculators")
                            }
                            .padding(.leading)
                            .padding(.vertical, 5)
                        }

                        NavigationLink(destination: Text("Other Rate Averages")) {
                            HStack {
                                Image(systemName: "chart.line")
                                Text("Other Rate Averages")
                            }
                            .padding(.leading)
                            .padding(.vertical, 5)
                        }

                        NavigationLink(destination: Text("Learn")) {
                            HStack {
                                Image(systemName: "book.closed")
                                Text("Learn")
                            }
                            .padding(.leading)
                            .padding(.vertical, 5)
                        }

                        Divider()
                            .padding(.vertical)

                        Text("NEWS")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.leading)

                        NavigationLink(destination: Text("All News")) {
                            HStack {
                                Image(systemName: "list.bullet.rectangle")
                                Text("All News")
                            }
                            .padding(.leading)
                            .padding(.vertical, 5)
                        }

                        NavigationLink(destination: Text("Mortgage Rate Watch")) {
                            HStack {
                                Image(systemName: "eye")
                                Text("Mortgage Rate Watch")
                            }
                            .padding(.leading)
                            .padding(.vertical, 5)
                        }

                        NavigationLink(destination: Text("Rob Chrisman")) {
                            HStack {
                                Image(systemName: "house")
                                Text("Rob Chrisman")
                            }
                            .padding(.leading)
                            .padding(.vertical, 5)
                        }

                        NavigationLink(destination: Text("MBS Commentary")) {
                            HStack {
                                Image(systemName: "list.bullet.indent")
                                Text("MBS Commentary")
                            }
                            .padding(.leading)
                            .padding(.vertical, 5)
                        }

                        Divider()
                            .padding(.vertical)

                        Text("OTHER DATA")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.leading)

                        NavigationLink(destination: Text("MBS Dashboard")) {
                            HStack {
                                Image(systemName: "desktopcomputer")
                                Text("MBS Dashboard")
                            }
                            .padding(.leading)
                            .padding(.vertical, 5)
                        }

                        Spacer()

                        Button("Contact Us") {
                            // Action for Contact Us
                        }
                        .foregroundColor(.blue)
                        .padding(.leading)
                        .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                }
                .frame(width: 250) // Adjust width for iPad/iPhone

                // Main Content
                VStack {
                    Text("Mortgage Calculation Results")
                        .font(.title2)
                        .padding()

                    HStack {
                        Text("$255.78")
                            .font(.title3)
                        Spacer()
                        Text("$1,700.00")
                            .font(.title3)
                    }
                    .padding(.horizontal)

                    HStack {
                        Text("0 points")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("6.930%")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    Text("$1,955.78")
                        .font(.largeTitle)
                        .padding(.top)

                    Divider()
                        .padding(.vertical)

                    HStack {
                        Text("Principal")
                            .font(.headline)
                        Spacer()
                        Text("$255.78")
                            .font(.headline)
                    }
                    .padding(.horizontal)

                    ProgressView(value: 0.2) // Example progress
                        .padding(.horizontal)

                    HStack {
                        Text("Interest")
                            .font(.headline)
                        Spacer()
                        Text("$1700.00")
                            .font(.headline)
                    }
                    .padding(.horizontal)

                    // Placeholder for Circle Plot
                    Circle()
                        .stroke(lineWidth: 20)
                        .foregroundColor(.blue.opacity(0.3))
                        .overlay(
                            Circle()
                                .trim(from: 0, to: 0.8) // Example progress
                                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(-90))
                        )
                        .frame(width: 150, height: 150)
                        .padding()

                    Spacer()

                    HStack {
                        Spacer()
                        Button {
                            // Upload action
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title)
                                .padding()
                                .background(Color(.systemGray4))
                                .clipShape(Circle())
                        }
                    }
                    .padding()

                    Text("Payoff Date:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
            .navigationTitle("MORTGAGE RATES") // Could be dynamic
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "gearshape")
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Image(systemName: "house.fill")
                        Spacer()
                        Image(systemName: "chart.bar.fill")
                        Spacer()
                        ZStack {
                            Image(systemName: "bell.fill")
                            Circle()
                                .foregroundColor(.red)
                                .frame(width: 10, height: 10)
                                .offset(x: 8, y: -8)
                                .overlay(
                                    Text("6")
                                        .foregroundColor(.white)
                                        .font(.caption2)
                                        .offset(x: 8, y: -8)
                                )
                        }
                        Spacer()
                        Image(systemName: "person.2.fill")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle()) // For iPad layout
    }
}

struct LeftSidebarView_V2_Previews: PreviewProvider {
    static var previews: some View {
        LeftSidebarView_V2()
    }
}
