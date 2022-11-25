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
        guard let url = request.url else {
            return URLSessionDataTaskMock {
                completionHandler(nil, nil, nil)
            }
        }
        let error = error
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        if let dataString = responseJsonString {
            return URLSessionDataTaskMock {
                completionHandler(Data(dataString.utf8), response, error)
            }
        }
        return URLSessionDataTaskMock {
            completionHandler(nil, response, error)
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
