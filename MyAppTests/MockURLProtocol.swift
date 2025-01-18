//
//  MockURLProtocol.swift
//  MyApp
//
//  Created by Cong Le on 1/18/25.
//

import XCTest
import SwiftUI
@testable import MyApp

// Mock URLProtocol to intercept network requests
class MockURLProtocol: URLProtocol {
    // Handler to return mock responses
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    // Determines whether to handle the request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    // Returns the canonical version of the request
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // Starts handling the request
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Handler is unavailable.")
            return
        }
        
        do {
            // Get the mock response and data
            let (response, data) = try handler(request)
            
            // Provide the response to the client
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            // Provide the data to the client
            client?.urlProtocol(self, didLoad: data)
            
            // Notify that the request has finished
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // Relay the error to the client
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    // Stops handling the request
    override func stopLoading() {
        // No additional cleanup required
    }
}
