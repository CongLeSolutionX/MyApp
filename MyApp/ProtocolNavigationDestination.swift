//
//  ProtocolNavigationDestination.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//

import SwiftUI

// MARK: - 6. NavigationDestination Protocol - Moving View Building to the Enum

protocol NavigationDestinationProtocol: Hashable, Equatable, Identifiable { // NavigationDestination Protocol
    associatedtype Content: View
    @MainActor @ViewBuilder var view: Self.Content { get } // Requirement: 'view' property
}

// Enum AccountDestinations now implements NavigationDestinationProtocol
enum AccountDestinationsEnumProto: Hashable, Equatable, Identifiable { // AccountDestinations Enum - Implements Protocol
    case details(AccountForProtocolNavigationView)
    case disclaimers(AccountForProtocolNavigationView)

    var id: Self { self } // For Identifiable conformance
}

struct AccountForProtocolNavigation_DetailView: View {
    let account: AccountForProtocolNavigationView

    var body: some View {
        Text("Account Details for \(account.name)")
            .navigationTitle("Account Detail")
    }
}



extension AccountDestinationsEnumProto: NavigationDestinationProtocol { // Conform enum to NavigationDestinationProtocol
    var view: some View { // Implementing the required 'view' property - View Building INSIDE Enum Now!
        switch self {
        case .details(let account):
            AccountForProtocolNavigation_DetailView(account: account)
        case .disclaimers(let account):
            Text("Disclaimers Protocol for \(account.name)")
                .navigationTitle("Disclaimers Proto")
        }
    }
}

struct AccountForProtocolNavigationView: Hashable {
    let id = UUID()
    let name: String
}

struct ProtocolNavigationDestinationView: View {
    @State private var selectedProtoDestination: AccountDestinationsEnumProto? = nil

    let accounts = [
        AccountForProtocolNavigationView(name: "Account Gamma"),
        AccountForProtocolNavigationView(name: "Account Delta")
    ]

    var body: some View {
        NavigationStack {
            List(accounts, id: \.id) { account in
                VStack(alignment: .leading) {
                    Text(account.name).font(.headline)
                    HStack {
                        NavigationLink("Details Proto", value: AccountDestinationsEnumProto.details(account))
                        NavigationLink("Disclaimers Proto", value: AccountDestinationsEnumProto.disclaimers(account))
                    }
                }
                .padding(.vertical)
            }
            .navigationDestination(for: AccountDestinationsEnumProto.self) { destination in // Using enum conforming to protocol
                destination.view // Accessing the 'view' property of the enum - View building from enum!
            }
            .navigationTitle("Account Options Protocol")
        }
    }
}

// MARK: - Preview
struct ProtocolNavigationDestination_Previews: PreviewProvider {
    static var previews: some View {
        ProtocolNavigationDestinationView()
    }
}
