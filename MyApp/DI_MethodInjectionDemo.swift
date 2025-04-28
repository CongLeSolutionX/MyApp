//
//  DI_MethodInjectionDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//
import Foundation

class ReportGenerator {
    func generateReport(data: Data, formatter: ReportFormatting) -> String {
        // Dependency 'formatter' injected directly into the method
        let formattedReport = formatter.format(data: data)
        print("Generating report using \(type(of: formatter))")
        return formattedReport
    }
}

// Protocol and implementations
protocol ReportFormatting {
    func format(data: Data) -> String
}

class StandardFormatter: ReportFormatting {
    func format(data: Data) -> String {
        return "Standard: \(data.count) bytes"
    }
}

class FancyFormatter: ReportFormatting {
    func format(data: Data) -> String {
        return "** Fancy: \(data.count) bytes **"
    }
}
