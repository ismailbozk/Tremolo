//
//  NetworkOperationQueue.swift
//  Networking
//
//  Created by Ismail Bozkurt on 25/11/2019.
//  Copyright © 2019 Ismail Bozkurt. All rights reserved.
//

import Foundation

/// Network Task Queue to put operations in order and execute them one by one in a sequence.
public class NetworkOperationQueue {
    /// Operation queue that then network task will be runing on.
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    private var triggeredOnce: Bool = false
    private let runAccessSemaphore = DispatchSemaphore(value: 1)
        
    private let networkClient: NetworkingClient
    private let request: URLRequest
    private let preOperations: [PreNetworkRequestOperation]
    private let postOperations: [PostNetworkRequestOperation]
    
    /// the network call operator, this componet is responsible for putting the network call operations in order and execution
    /// - Parameters:
    ///   - networkClient: network client to perform the calls, this client will be use to trigger request.
    ///   - request: the call meant to be made after the pre and before the post tasks.
    ///   - preTasks: pre tasks, which are meant to be running before request triger.
    ///   - postTasks: post tasks, which are meant to be running after the request response.
    public init(networkClient: NetworkingClient,
         request: URLRequest,
         preOperations: [PreNetworkRequestOperation] = [],
         postOperations: [PostNetworkRequestOperation] = []) {
        self.networkClient = networkClient
        self.request = request
        self.preOperations = preOperations
        self.postOperations = postOperations
    }
    
    /// Triggers the network call chain with the given request and tasks
    /// - Parameter completion: Response completion of the latest post task if present or the network task reponse.
    ///
    /// **Warning:** Operations are a single-shot objects. Therefore this function meant to be called only once, if you need to trigger the same call again,
    ///  you'll need to create a new pre and post task instances along with a new operator.
    public func run(_ completion: @escaping (NetworkResponse) -> Void) {
        runAccessSemaphore.wait()
        guard !triggeredOnce else {
            assertionFailure("A NetworkOperationQueue can be submitted only once due to a single-shot object nature of Operations. Please create a new NetworkOperator with new task instances.")
            return
        }
        triggeredOnce = true
        runAccessSemaphore.signal()
                
        let mainOperation = NetworkOperation(request: self.request, networkClient: self.networkClient)
        
        let lastOperation: NetworkRequestOperation = postOperations.last ?? mainOperation
        let completionOperation = self.completionOperation(with: completion, dependency: lastOperation)
        
        var operations: [Operation] = Array(preOperations)
        operations.append(mainOperation)
        operations.append(contentsOf: postOperations)
        operations.append(completionOperation)
        
        for i in 0..<operations.count-1 {
            operations[i+1].addDependency(operations[i])
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    /// Cancels the call chain, if there is any.
    public func cancel() {
        self.queue.cancelAllOperations()
    }
    
    private func completionOperation(with completion: @escaping ((NetworkResponse) -> Void), dependency: NetworkRequestOperation) -> BlockOperation {
        return BlockOperation { [weak dependency] in
            guard let lastDependencySubject = dependency?.subject else {
                assertionFailure("NetworkOperationQueue needs last network task to pass the _subject_ to complete the operation.")
                return
            }
            
            completion(lastDependencySubject)
        }
    }
}

extension NetworkOperationQueue: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    public static func == (left: NetworkOperationQueue, right: NetworkOperationQueue) -> Bool {
        return left === right
    }
}
