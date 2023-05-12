//
//  URLSessionProtocol.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/8/22.
//

import Foundation
import UIKit

public protocol URLSessionProtocol {
//    func dataTask(
//        with request: URLRequest,
//        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
//    ) -> URLSessionDataTask

    func asyncDataTask<Response: Decodable>(with request: URLRequest) async throws -> Response
}

// MARK: - URLSession + URLSessionProtocol

extension URLSession: URLSessionProtocol {

    public func asyncDataTask<Response: Decodable>(with request: URLRequest) async throws -> Response {
        do {
            logNetworkRequest(request)
            let (data, response) = try await data(for: request)
            logNetworkResponse(response, request: request, data: data)
            guard let response = response as? HTTPURLResponse,
                  (200 ..< 300) ~= response.statusCode else {
                throw BloctoSDKError.responseUnexpected
            }
            let model = try JSONDecoder().decode(Response.self, from: data)
            return model
        } catch {
            log(enable: BloctoSDK.shared.logging, message: "error: \(error.localizedDescription)")
            throw error
        }
    }

    private func format(identifier: String, message: String) -> String {
        "\(identifier): \(message)"
    }

    private func logNetworkRequest(_ request: URLRequest) {

        var outputs = [String]()

        outputs += [format(identifier: "🚀 Request", message: request.url?.absoluteString ?? "nil")]

        if let headers = request.allHTTPHeaderFields {
            if let data = try? JSONSerialization.data(withJSONObject: headers, options: [.prettyPrinted]),
               let prettyPrintedString = String(data: data, encoding: .utf8) {
                outputs += [format(identifier: "🚀 Request Headers", message: prettyPrintedString)]
            } else {
                outputs += [format(identifier: "🚀 Request Headers", message: headers.description)]
            }
        }

        if let bodyStream = request.httpBodyStream {
            outputs += [format(identifier: "🚀 Request Body Stream", message: bodyStream.description)]
        }

        if let httpMethod = request.httpMethod {
            outputs += [format(identifier: "🚀 HTTP Request Method", message: httpMethod)]
        }

        if let body = request.httpBody {
            outputs += [format(identifier: "🚀 Request Body", message: body.prettyPrintedJSONString ?? "")]
        }

        for output in outputs {
            reversedPrint(items: output)
        }
    }
    
    private func logNetworkResponse(_ response: URLResponse, request: URLRequest, data: Data?) {
        var outputs = [String]()
        
        outputs += [format(identifier: "📩 Response", message: response.url?.absoluteString ?? "nil")]
        
        if let data = data {
            if let jsonObject = try? JSONSerialization.jsonObject(with: data) {
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
                    outputs += [String(decoding: jsonData, as: UTF8.self)]
                } else {
                    outputs += [String(describing: jsonObject)]
                }
            }
        }
        
        for output in outputs {
            reversedPrint(items: output)
        }
    }

    private func reversedPrint(items: Any...) {
        let separator = ", "
        let terminator = "\n"
        for item in items {
            print(item, separator: separator, terminator: terminator)
        }
    }

}
