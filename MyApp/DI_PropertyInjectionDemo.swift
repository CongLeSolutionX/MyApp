//
//  DI_PropertyInjectionDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//
import Foundation

class AnotherViewModel {
    // Dependency declared as an optional var
    var networkFetcher: NetworkFetching?

    // No dependency in init
    init() {}

    func loadData() {
        guard let fetcher = networkFetcher else {
            print("Error: NetworkFetcher not set!")
            return
        }
        let data = fetcher.fetchData()
        // ... process data ...
        print("Data loaded using \(type(of: fetcher))")
        print(String(data: data ?? Data(), encoding: .utf8) ?? "No data")
    }
}
