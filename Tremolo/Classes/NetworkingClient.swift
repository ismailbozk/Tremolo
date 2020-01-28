//
//  NetworkingClient.swift
//  Networking
//
//  Created by Ismail Bozkurt on 10/01/2020.
//  Copyright © 2020 HBC Digital. All rights reserved.
//

import Foundation

/// Network client to perform network calls. This protocol defines the interface of the networking layer and can be used for unit tests mocks.
public protocol NetworkingClient {
    @discardableResult
    func perform(request: URLRequest, completion: @escaping (Result<(urlResponse: URLResponse, data: Data), URLError>) -> Void) -> NetworkingClientTask
}

/// Network client task interface which can be used to cancel ongoing network calls.
public protocol NetworkingClientTask {
    func cancel()
}
