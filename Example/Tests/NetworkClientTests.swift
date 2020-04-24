
//
//  NetworkingClientTests.swift
//  NetworkingTests
//
//  Created by Ismail Bozkurt on 19/11/2019.
//  Copyright © 2019 Ismail Bozkurt. All rights reserved.
//

import XCTest
@testable import Tremolo

class NetworkClientTests: XCTestCase {

    var networkClient: NetworkingClient?
    
    override func setUp() {
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        networkClient = NetworkClient(urlSession: urlSession)
    }

    func testApiClient404() {
        let expectation = XCTestExpectation(description: "Get Mock")
        let url = URL(string: "https://www.reddit.com/r/321321313123%C2%A723123/")!
        let urlRequest = URLRequest(url: url)
        networkClient?.perform(request: urlRequest, completion: { (result) in
            
            switch result {
                
            case .success((let urlResponse, _)):
                XCTAssertNotNil(urlResponse as? HTTPURLResponse)
            case .failure:
                XCTAssertTrue(false)
            }
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 60)
    }
    
    func testNonExistentEndpoint() {
        let expectation = XCTestExpectation(description: "Get Mock with invalid url address")
        let url = URL(string: "https://www.somethingnotvalidforawebsite.com")!
        let urlRequest = URLRequest(url: url)
        networkClient?.perform(request: urlRequest, completion: { (result) in
            
            switch result {
                
            case .success:
                XCTAssertTrue(false)
            case .failure:
                XCTAssertTrue(true)
            }
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 60)
    }
    
    func testGetSome() {
        let expectation = XCTestExpectation(description: "Get Mock Product")
        let url = URL(string: "https://www.apple.com")!
        let urlRequest = URLRequest(url: url)
        networkClient?.perform(request: urlRequest, completion: { (result) in
            
            switch result {
                
            case .success((let urlResponse, let data)):
                XCTAssertNotNil(data)
                XCTAssertNotNil(urlResponse as? HTTPURLResponse)
                XCTAssertTrue((urlResponse as? HTTPURLResponse)?.statusCode == 200)
            case .failure:
                XCTAssertTrue(false)
            }
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 60)
    }
    
    func testCancel() {
        let expect = expectation(description: "Get Mock Product")
        let url = URL(string: "https://www.saksfifthavenue.com/saks-fifth-avenue-2019-holiday-gift-card/product/0400012043985")!
        let urlRequest = URLRequest(url: url)
        let task = networkClient?.perform(request: urlRequest, completion: { (result) in
            
            switch result {
                
            case .success:
                XCTAssertTrue(false)
            case .failure(let error):
                XCTAssertTrue(error.code.rawValue == NSURLErrorCancelled)
            }
            
            expect.fulfill()
        })
        
        task?.cancel()
        
        wait(for: [expect], timeout: 5)

    }
}
