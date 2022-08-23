//
//  URLSessionMock.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/8/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import BloctoSDK

class URLSessionMock: URLSessionProtocol {

    var responseJsonString: String?
    var error: Error?

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        let error = error
        if let dataString = responseJsonString {
            return URLSessionDataTaskMock {
                completionHandler(Data(dataString.utf8), nil, error)
            }
        }
        return URLSessionDataTaskMock {
            completionHandler(nil, nil, error)
        }
    }

}

class URLSessionDataTaskMock: URLSessionDataTask {

    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }

}
