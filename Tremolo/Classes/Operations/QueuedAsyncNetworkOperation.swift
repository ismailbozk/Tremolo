//
//  QueuedAsyncNetworkOperation.swift
//  Networking
//
//  Created by Ismail Bozkurt on 21/11/2019.
//  Copyright © 2019 Ismail Bozkurt. All rights reserved.
//

import Foundation

/// Queued network task's designed to talk to next and previous tasks in the queue via Operation's dependencies property, so they can transfer data between tasks and work on them.
/// - Parameters:
///   - subject: Task's generic subject, that data to be passed to the next operation.
///   - completion: Completion closure to be triggered on task finish time along with the subject.
open class QueuedAsyncNetworkOperation<T>: AsyncOperation {
    
    /// Task's generic subject, that data to be passed to the next operation.
    ///
    /// **Warning:** This field is used to pass data the next network task, so for succesfully completed operations, this field is needed to be assigned to value.
    open var subject: T?
    /// Completion closure to be triggered on task finish time along with the subject.
    open var completion: ((T) -> Void)?

    override open func main() {
        fatalError("Method must be overriden")
    }
    
    /// Finalizes the task with the given subject.
    /// - Parameter subject: subject to be passed to next operation.
    public func completeOperation(with subject: T) {
        self.subject = subject
        completion?(subject)
        finishOperation()
    }
}
