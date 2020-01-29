# Tremolo

[![Version](https://img.shields.io/cocoapods/v/Tremolo.svg?style=flat)](https://cocoapods.org/pods/Tremolo)
[![License](https://img.shields.io/cocoapods/l/Tremolo.svg?style=flat)](https://cocoapods.org/pods/Tremolo)
[![Platform](https://img.shields.io/cocoapods/p/Tremolo.svg?style=flat)](https://cocoapods.org/pods/Tremolo)


## Idea

Tremolo is an iOS Networking framework. It's designed to prepare URLRequests and manage failed/recoverable network requests in a structured way.

## Use cases

- Validate and Prepare URLRequests before triggering them.
    - Sometimes URLRequests needs to have some valid information like correct session token. Such as refreshing the token via another network call and insert it into the URLRequest.
    - Sign in the user before triggering the URLRequest if the api requires users to sign in before for the actual endpoint.
- Recover from the errors retrieved from server; 
    - 401 Authentication errors. Such as expired or invalid session token.
    - Password expired or user changed the password recently. Ask user to put new password and continue when the password retrieved from user.
    - etc.

Please refer to the [sample unit test](https://github.com/ismailbozk/Tremolo/blob/master/Example/Tests/NetworkOperationQueueTests.swift) for some use case examples.

## Requirements

## Installation

Tremolo is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile and install/update the pods.

```ruby
pod 'Tremolo'
```

## Author

Ismail Bozkurt, 
ismailbozk@gmail.com 
[LinkedIn](https://www.linkedin.com/in/ismailbozk/)

## License

Tremolo is available under the MIT license. See the LICENSE file for more info.
