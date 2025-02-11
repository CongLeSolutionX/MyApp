//
//  ValueBasedNavigation.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//

import SwiftUI

// MARK: - 2. Understanding navigationDestination & Value-Based Navigation

struct AccountForValueBasedNavigation: Hashable {
    let id = UUID()
    let name: String
}

struct AccountForValueBasedNavigation_DetailView: View {
    let account: AccountForValueBasedNavigation

    var body: some View {
        Text("Account Details for \(account.name)")
            .navigationTitle("Account Detail")
    }
}

struct ValueBasedNavigationView: View {
    @State private var selectedAccount: AccountForValueBasedNavigation? = nil

    let accounts = [
        AccountForValueBasedNavigation(name: "Account 1"),
        AccountForValueBasedNavigation(name: "Account 2")
    ]

    var body: some View {
        NavigationStack {
            List(accounts, id: \.id) { account in
                NavigationLink(account.name, value: account) // 1. NavigationLink pushes Account value
            }
            .navigationDestination(for: AccountForValueBasedNavigation.self) { account in // 2. navigationDestination Modifier handles Account.self
                AccountForValueBasedNavigation_DetailView(account: account) // 4. Instantiate AccountDetailView
            }
            .navigationTitle("Accounts")
        }
    }
}

// MARK: - Preview
struct ValueBasedNavigation_Previews: PreviewProvider {
    static var previews: some View {
        ValueBasedNavigationView()
    }
}
