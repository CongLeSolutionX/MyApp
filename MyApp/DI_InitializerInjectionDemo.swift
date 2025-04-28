//
//  DependencyInjections_InitializerInjectionDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//
import Foundation

// Protocol defining the dependency
protocol NetworkFetching {
    func fetchData() -> Data?
}

// Concrete implementation
class NetworkService: NetworkFetching {
    func fetchData() -> Data? {
        print("Fetching data from network...")
        // ... actual network call ...
        return Data()
    }
}

// Dependent class using Initializer Injection
class DataViewModel {
    private let networkFetcher: NetworkFetching // Dependency declared using protocol

    // Dependency injected via initializer
    init(networkFetcher: NetworkFetching) {
        self.networkFetcher = networkFetcher
    }

    func loadData() {
        let data = networkFetcher.fetchData()
        // ... process data ...
        print("Data loaded using \(type(of: networkFetcher))")
        print(String(data: data ?? Data(), encoding: .utf8) ?? "No data")
    }
}
