//
//  ValueBasedNavigation.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//

import SwiftUI

// MARK: - 2. Understanding navigationDestination & Value-Based Navigation

struct Account: Hashable {
    let id = UUID()
    let name: String
}

struct AccountDetailView: View {
    let account: Account

    var body: some View {
        Text("Account Details for \(account.name)")
            .navigationTitle("Account Detail")
    }
}

struct ValueBasedNavigationView: View {
    @State private var selectedAccount: Account? = nil

    let accounts = [
        Account(name: "Account 1"),
        Account(name: "Account 2")
    ]

    var body: some View {
        NavigationStack {
            List(accounts, id: \.id) { account in
                NavigationLink(account.name, value: account) // 1. NavigationLink pushes Account value
            }
            .navigationDestination(for: Account.self) { account in // 2. navigationDestination Modifier handles Account.self
                AccountDetailView(account: account) // 4. Instantiate AccountDetailView
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
