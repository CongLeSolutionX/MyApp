//
//  CodeDuplicationAccess.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//
//
//import SwiftUI
//
//// MARK: - 5. Addressing Code Duplication & Sheet/Cover Access Issues
//
//// Conceptual example - Not directly runnable as it points to design issues
//
//// Problem 1: Code Duplication (Conceptual)
//struct HomeView_Duplication: View {
//    var accounts: [Account]
//
//    var body: some View {
//        NavigationStack {
//            List(accounts, id: \.id) { account in
//                NavigationLink("Account Details", value: Account.self) // Value type doesn't matter as much here, conceptual
//            }
//            .navigationDestination(for: Account.self) { _ in // View builder Logic Set 1 - Duplicated Logic!
//                AccountDetailView(account: accounts.first!) // Example detail view
//            }
//            .navigationTitle("Home Accounts")
//        }
//    }
//}
//
//struct SettingsView_Duplication: View {
//    var accounts: [Account]
//
//    var body: some View {
//        NavigationStack {
//            List(accounts, id: \.id) { account in
//                NavigationLink("Account Details", value: Account.self) // Same NavigationLink as above
//            }
//            .navigationDestination(for: Account.self) { _ in // View builder Logic Set 2 - Duplicated Logic! - very similar to above
//                AccountDetailView(account: accounts.first!) // Same example detail view
//            }
//            .navigationTitle("Settings Accounts")
//        }
//    }
//}
//
//// Problem 2: Limited Sheet/Cover Access (Conceptual)
//struct ContentView_LimitedAccess: View {
//    @State private var isSheetPresented = false
//
//    var body: some View {
//        VStack {
//            Button("Present Sheet") {
//                isSheetPresented = true
//            }
//            // .sheet modifier - How do you reuse the navigationDestination logic here?
//            .sheet(isPresented: $isSheetPresented) {
//                NavigationView { // Could be NavigationStack in newer versions for sheet
//                    Text("Sheet Content - How to reuse 'navigationDestination' logic easily in sheets/covers without a Protocol?")
//                        .navigationTitle("Sheet")
//                        .toolbar {
//                            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                                Button("Dismiss") { isSheetPresented = false }
//                            }
//                        }
//                }
//            }
//        }
//    }
//}
//
//
//struct CodeDuplicationAccess_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            Text("Conceptual Examples (See Code Comments)")
//                .font(.caption)
//                .padding()
//            HomeView_Duplication(accounts: [Account(name: "Demo Account")])
//            Divider()
//            SettingsView_Duplication(accounts: [Account(name: "Demo Account")])
//            Divider()
//            ContentView_LimitedAccess()
//        }
//    }
//}
