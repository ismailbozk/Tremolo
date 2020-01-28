//
//  AsyncOperation.swift
//  Networking
//
//  Created by Ismail Bozkurt on 21/11/2019.
//  Copyright © 2019 Ismail Bozkurt. All rights reserved.
//


import Foundation

/// Async Operation, to support the operation to run and cancel network calls on OperationQueues.
open class AsyncOperation: Operation {

    override open var isConcurrent: Bool {
        return true
    }

    override open var isAsynchronous: Bool {
        return true
    }

    private var _executing: Bool = false
    override open var isExecuting: Bool {
        get {
            return _executing
        }
        set(newValue) {
            if (_executing != newValue) {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }

    private var _finished: Bool = false
    override open var isFinished: Bool {
        get {
            return _finished
        }
        set(newValue) {
            if (_finished != newValue) {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    private var _cancelled: Bool = false
    override open var isCancelled: Bool {
        get {
            return _cancelled
        }
        set(newValue) {
            if (_cancelled != newValue) {
                willChangeValue(forKey: "isCancelled")
                _cancelled = newValue
                didChangeValue(forKey: "isCancelled")
            }
        }
    }
    
    /// Finishes the operation.
    open func finishOperation() {
        isExecuting = false
        isFinished  = true
    }

    override open func start() {
        if (isCancelled) {
            isFinished = true
            return
        }

        isExecuting = true
        main()
    }

    open override func cancel() {
        isExecuting = false
        isCancelled = true
    }
}
