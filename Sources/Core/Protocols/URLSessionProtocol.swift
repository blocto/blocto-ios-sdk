//
//  URLSessionProtocol.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/8/22.
//

import Foundation
import UIKit

public protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}
