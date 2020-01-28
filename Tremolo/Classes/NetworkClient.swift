//
//  NetworkClient.swift
//  Networking
//
//  Created by Ismail Bozkurt on 14/11/2019.
//  Copyright © 2019 Ismail Bozkurt. All rights reserved.
//

import Foundation

/// Default Network client task which can be used to cancel ongoing network calls.
public struct NetworkClientTask: NetworkingClientTask {
    private let dataTask: URLSessionDataTask

    init(dataTask: URLSessionDataTask) {
        self.dataTask = dataTask
    }
    
    public func cancel() {
        dataTask.cancel()
    }
}

/// Default Network client to perform network calls.
final public class NetworkClient: NetworkingClient {
    
    private let urlSession: URLSession
    
    /// Network client initializer.
    /// - Parameter urlSession: URLSession to perform network calls.
    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    /// Performs given request and returns the response on the given completion callback closure.
    /// - Parameters:
    ///   - request: URLRequest to be performed
    ///   - completion: Completion closure for the given request, returns success, Data and URLResponse or and URLError.
    /// - returns: A dicardable network task.
    ///
    /// **Note:** This function completion block data types are not optionals as they are in URLSession.dataTaskPublisher function signature.
    @discardableResult
    public func perform(request: URLRequest, completion: @escaping (Result<(urlResponse: URLResponse, data: Data), URLError>) -> Void) -> NetworkingClientTask {
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            let result: Result<(urlResponse: URLResponse, data: Data), URLError>
            if let response = response {
                let data = data ?? Data()
                result = .success((response, data))
            }
            else {
                let error = error as? URLError ?? URLError(URLError.badServerResponse)
                result = .failure(error)
            }
            completion(result)
        }
        task.resume()
        return NetworkClientTask(dataTask: task)
    }
}
