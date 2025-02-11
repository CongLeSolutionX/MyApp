//
//  EnumNavigationDestination.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//

import SwiftUI

// MARK: - 4. Enumerated Navigation Destinations - The Enum Solution

struct AccountForEnumNavigationDestination: Hashable {
    let id = UUID()
    let name: String
}

enum AccountDestinations: Hashable { // AccountDestinations Enum - Centralized
    case details(AccountForEnumNavigationDestination)
    case disclaimers(AccountForEnumNavigationDestination)
}

struct AccountForEnumNavigationDestination_DetailView: View {
    let account: AccountForEnumNavigationDestination

    var body: some View {
        Text("Account Details for \(account.name)")
            .navigationTitle("Account Detail")
    }
}

extension AccountDestinations: View { // Conforming enum to View - for direct usage (explicit destinations later)
    var body: some View {
        switch self {
        case .details(let account):
            AccountForEnumNavigationDestination_DetailView(account: account)
        case .disclaimers(let account):
            Text("Disclaimers for \(account.name)")
                .navigationTitle("Disclaimers")
        }
    }
}

struct EnumNavigationSolutionView: View {
    @State private var selectedDestination: AccountDestinations? = nil

    let accounts = [
        AccountForEnumNavigationDestination(name: "Account Alpha"),
        AccountForEnumNavigationDestination(name: "Account Beta")
    ]

    var body: some View {
        NavigationStack {
            List(accounts, id: \.id) { account in
                VStack(alignment: .leading) {
                    Text(account.name).font(.headline)
                    HStack {
                        NavigationLink("Details", value: AccountDestinations.details(account)) // Using enum cases as values
                        NavigationLink("Disclaimers", value: AccountDestinations.disclaimers(account)) // Using different enum cases
                    }
                }
                .padding(.vertical)
            }
            .navigationDestination(for: AccountDestinations.self) { destination in // Single handler for AccountDestinations
                destination // View is built by the enum itself (via View conformance)
            }
            .navigationTitle("Account Options")
        }
    }
}

// MARK: - Preview
struct EnumNavigationDestination_Previews: PreviewProvider {
    static var previews: some View {
        EnumNavigationSolutionView()
    }
}
