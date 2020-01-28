//
//  Networking.swift
//  Networking
//
//  Created by Ismail Bozkurt on 30/12/2019.
//  Copyright © 2019 Ismail Bozkurt. All rights reserved.
//

import Foundation

/// Pre Request Task which is meant to be running before the actual network call.
public typealias PreNetworkRequestOperation = QueuedAsyncNetworkOperation<Result<URLRequest, Error>>
/// Network call that will be runnning after _PreNetworkRequestOperation_ and  before _PostNetworkRequestOperation_.
public typealias NetworkRequestOperation = QueuedAsyncNetworkOperation<NetworkResponse>
/// Post Request Task which is meant to be used as a post network request response task.
public typealias PostNetworkRequestOperation = NetworkRequestOperation

/// Network request callback for any network call.
public typealias NetworkResult = Result<(urlResponse: URLResponse, data: Data), Error>

/// Network call response wrapper
/// - Parameters:
///   - request: URLRequest to be performed
///   - responseResult: response which came from network call, either an URLError or an Data and URLResponse tuple.
public struct NetworkResponse {
    public let request: URLRequest
    public let responseResult: NetworkResult
    
    public init(request: URLRequest, responseResult: NetworkResult) {
        self.request = request
        self.responseResult = responseResult
    }
}
