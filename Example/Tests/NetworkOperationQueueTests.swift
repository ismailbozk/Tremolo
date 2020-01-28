//
//  NetworkOperationQueueTests.swift
//  NetworkingTests
//
//  Created by Ismail Bozkurt on 10/01/2020.
//  Copyright © 2020 HBC Digital. All rights reserved.
//

import XCTest
@testable import Tremolo

class NetworkOperationQueueTests: XCTestCase {
    
    var networkQueue: NetworkOperationQueue?

    override func tearDown() {
        networkQueue = nil
    }
    
    func testCallChain() {
        let client = MockNetworkClient()
        let url = URL(string: "https://www.apple.com")!
        let request = URLRequest(url: url)
        
        let preTask1 = PutLocalSessionMockPreTask(request: request)
        let preTask2 = UpdateSessionMockPreTask()
        let postTask1 = RefreshSessionPostTask()
        let postTask2 = SignInRetryMockPostTask()
        networkQueue = NetworkOperationQueue(networkClient: client, request: request, preOperations: [preTask1, preTask2], postOperations: [postTask1, postTask2])
        
        let expectation = XCTestExpectation(description: "Make a call chain")
        networkQueue?.run({ (response) in
            
            XCTAssertTrue(client.networkCallMade)
            
            XCTAssertTrue(preTask1.isFinished)
            XCTAssertTrue(preTask2.isFinished)
            XCTAssertTrue(postTask1.isFinished)
            XCTAssertTrue(postTask2.isFinished)
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testCancelCallQueue() {
        let client = MockNetworkClient()
        let url = URL(string: "https://www.apple.com")!
        let request = URLRequest(url: url)

        let preTask1 = PutLocalSessionMockPreTask(request: request)
        let preTask2 = UpdateSessionMockPreTask()
        let postTask1 = RefreshSessionPostTask()
        let postTask2 = SignInRetryMockPostTask()
        networkQueue = NetworkOperationQueue(networkClient: client, request: request, preOperations: [preTask1, preTask2], postOperations: [postTask1, postTask2])
        
        networkQueue?.run({ (response) in
            XCTAssertTrue(false, "Network Queue should have been cancelled.")
        })
        networkQueue?.cancel()

        XCTAssertFalse(client.networkCallMade)

        XCTAssertTrue(preTask1.isCancelled)
        XCTAssertTrue(preTask2.isCancelled)
        XCTAssertTrue(postTask1.isCancelled)
        XCTAssertTrue(postTask2.isCancelled)
    }
}



private class PutLocalSessionMockPreTask: PreNetworkRequestOperation {
    var request: URLRequest
    
    init(request: URLRequest) {
        self.request = request
    }
    
    override func main() {
        sleep(1)
        
        XCTAssertNil(dependencies.last)
        
        request.setValue("oldSession", forHTTPHeaderField: "session")
        
        completeOperation(with: .success(request))
    }
}

private class UpdateSessionMockPreTask: PreNetworkRequestOperation {
    override func main() {
        XCTAssertNotNil(dependencies.last)
        
        guard let lastDependency = dependencies.last else {
            return
        }
        
        XCTAssertTrue(lastDependency is PreNetworkRequestOperation)
        
        guard let dependency = lastDependency as? PreNetworkRequestOperation else {
            return
        }
        let requestOptional = (try? dependency.subject?.get()).flatMap( { $0 })
        XCTAssertNotNil(requestOptional)
        
        guard var request = requestOptional else {
            return
        }
        
        XCTAssertTrue(request.url?.absoluteString == "https://www.apple.com")
        XCTAssertTrue(request.allHTTPHeaderFields?["session"] == "oldSession")
        
        // do the actual work
        request.setValue("newSession", forHTTPHeaderField: "session")
        
        sleep(1)
        completeOperation(with: .success(request))
    }
}

private class RefreshSessionPostTask: PostNetworkRequestOperation {
    override func main() {
        XCTAssertNotNil(dependencies.last)
        
        guard let lastDependency = dependencies.last else {
            return
        }
        
        XCTAssertTrue(lastDependency is NetworkRequestOperation)
        guard let dependency = lastDependency as? NetworkRequestOperation else {
            return
        }
        
        XCTAssertNotNil(dependency.subject)
        guard let response = dependency.subject else {
            return
        }
        
        var request = response.request
        
        XCTAssertTrue(request.allHTTPHeaderFields?["session"] == "newSession")
        
        request.setValue("newnewSession", forHTTPHeaderField: "session")
        
        let newResponse = NetworkResponse(request: request, responseResult: response.responseResult)
        
        sleep(1)
        completeOperation(with: newResponse)
    }
}

private class SignInRetryMockPostTask: PostNetworkRequestOperation {
    override func main() {
        XCTAssertNotNil(dependencies.last)
        
        guard let lastDependency = dependencies.last else {
            return
        }
        
        XCTAssertTrue(lastDependency is PostNetworkRequestOperation)
        guard let dependency = lastDependency as? PostNetworkRequestOperation else {
            return
        }
        
        XCTAssertNotNil(dependency.subject)
        guard let response = dependency.subject else {
            return
        }
        
        let request = response.request
        
        XCTAssertTrue(request.allHTTPHeaderFields?["session"] == "newnewSession")
        
        sleep(1)
        completeOperation(with: response)
    }
}

private class MockNetworkClient: NetworkingClient {
    var networkCallMade = false
    
    func perform(request: URLRequest, completion: @escaping (Result<(urlResponse: URLResponse, data: Data), URLError>) -> Void) -> NetworkingClientTask {
                networkCallMade = request.url?.absoluteString == "https://www.apple.com"
        let response = URLResponse(url: URL(string: "https://www.apple.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        completion(.success((urlResponse: response, data: Data())))
        return MockNetworkTask()
    }
}

private class MockNetworkTask: NetworkingClientTask {
    func cancel() {
        // empty decleration
    }
}
