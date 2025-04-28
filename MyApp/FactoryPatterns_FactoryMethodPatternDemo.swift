//
//  FactoryPatterns_FactoryMethodPatternDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

// Product Protocol
protocol Logger {
    func log(message: String)
}

// Concrete Products
struct ConsoleLogger: Logger {
    func log(message: String) {
        print("[Console] \(message)")
    }
}

struct FileLogger: Logger {
    let filePath: String
    func log(message: String) {
        // In reality, append message to file at filePath
        print("[File:\(filePath)] \(message)")
    }
}

// Creator Protocol (with the factory method)
protocol LoggerFactory {
    // The Factory Method
    func createLogger() -> Logger

    // Other operations that might use the logger
    func logProcess(action: String)
}

// Default implementation using the created logger
extension LoggerFactory {
     func logProcess(action: String) {
        let logger = createLogger() // Use the factory method
        logger.log(message: "Performing action: \(action)")
    }
}

// Concrete Creators
struct ConsoleLoggerFactory: LoggerFactory {
    func createLogger() -> Logger {
        return ConsoleLogger() // Creates ConsoleLogger
    }
}

struct FileLoggerFactory: LoggerFactory {
    let logFilePath: String
    init(logFilePath: String = "app.log") {
        self.logFilePath = logFilePath
    }

    func createLogger() -> Logger {
        return FileLogger(filePath: logFilePath) // Creates FileLogger
    }
}
