//
//  URLSessionProtocol.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/8/22.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}
