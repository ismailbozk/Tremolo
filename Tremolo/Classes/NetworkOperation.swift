//
//  NetworkOperation.swift
//  Networking
//
//  Created by Ismail Bozkurt on 21/11/2019.
//  Copyright © 2019 Ismail Bozkurt. All rights reserved.
//

import Foundation

/// Network task to perform network calls in a Operation.
class NetworkOperation: NetworkRequestOperation {
    private let request: URLRequest
    private let client: NetworkingClient
    
    private var networkTask: NetworkingClientTask?
    
    init(request: URLRequest, networkClient: NetworkingClient) {
        self.request = request
        self.client = networkClient
    }

    override func main() {
        var request: URLRequest = self.request
                
        // get the latest request from preRequest task if it is present.
        if let preTaskResult = (dependencies.last as? PreNetworkRequestOperation)?.subject {
            switch preTaskResult {
            case .success(let updatedRequest):
                request = updatedRequest
            case .failure(let error):
                completeOperation(with: NetworkResponse(request: request, responseResult: .failure(error)))
                return
            }
        }
                
        networkTask = client.perform(request: request) { (result) in
            let networkResult: NetworkResult
            switch result {
            case .success((let urlResponse, let data)):
                networkResult = .success((urlResponse, data))
            case .failure(let error):
                networkResult = .failure(error)
            }
            
            let networkResponse = NetworkResponse(request: request, responseResult: networkResult)
            self.completeOperation(with: networkResponse)
        }
    }
    
    /// Cancels the network task if is present and not cancelled or finished before.
    override func cancel() {
        networkTask?.cancel()
        
        super.cancel()
    }
}
