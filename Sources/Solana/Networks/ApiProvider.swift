//
//  ApiProvider.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/15.
//

import Moya

final public class ApiProvider: MoyaProvider<ConvertTransactionRequest> {

    public init(
        plugins: [PluginType] = [],
        endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping,
        stubClosure: @escaping StubClosure = MoyaProvider.neverStub
    ) {
        var plugins: [PluginType] = plugins
#if DEBUG
        plugins.append(BONetworkLoggerPlugin(verbose: true))
#endif
        super.init(
            endpointClosure: endpointClosure,
            stubClosure: stubClosure,
            plugins: plugins)
    }
}

public final class BONetworkLoggerPlugin: PluginType {
    fileprivate let separator = ", "
    fileprivate let terminator = "\n"
    fileprivate let cURLTerminator = "\\\n"
    fileprivate let output: (_ separator: String, _ terminator: String, _ items: Any...) -> Void
    fileprivate let responseDataFormatter: ((Data) -> (Data))?

    /// If true, also logs response body data.
    public let isVerbose: Bool
    public let cURL: Bool

    public init(verbose: Bool = false, cURL: Bool = false, output: @escaping (_ separator: String, _ terminator: String, _ items: Any...) -> Void = BONetworkLoggerPlugin.reversedPrint, responseDataFormatter: ((Data) -> (Data))? = nil) {
        self.cURL = cURL
        self.isVerbose = verbose
        self.output = output
        self.responseDataFormatter = responseDataFormatter
    }

    public func willSend(_ request: RequestType, target: TargetType) {
        if let request = request as? CustomDebugStringConvertible, cURL {
            output(separator, terminator, request.debugDescription)
            return
        }
        outputItems(logNetworkRequest(request.request as URLRequest?))
    }

    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            outputItems(logNetworkResponse(response.response, data: response.data, target: target))
        } else {
            outputItems(logNetworkResponse(nil, data: nil, target: target))
        }
    }

    fileprivate func outputItems(_ items: [String]) {
        if isVerbose {
            items.forEach { output(separator, terminator, $0) }
        } else {
            output(separator, terminator, items)
        }
    }
}

private extension BONetworkLoggerPlugin {

    func format(identifier: String, message: String) -> String {
        return "\(identifier): \(message)"
    }

    func logNetworkRequest(_ request: URLRequest?) -> [String] {

        var output = [String]()

        output += [format(identifier: "Request", message: request?.url?.absoluteString ?? "nil")]

        if let headers = request?.allHTTPHeaderFields {
            output += [format(identifier: "Request Headers", message: headers.description)]
        }

        if let bodyStream = request?.httpBodyStream {
            output += [format(identifier: "Request Body Stream", message: bodyStream.description)]
        }

        if let httpMethod = request?.httpMethod {
            output += [format(identifier: "HTTP Request Method", message: httpMethod)]
        }

        if let body = request?.httpBody, let stringOutput = String(data: body, encoding: .utf8), isVerbose {
            output += [format(identifier: "Request Body", message: stringOutput)]
        }

        return output
    }

    func logNetworkResponse(_ response: URLResponse?, data: Data?, target: TargetType) -> [String] {
        guard let response = response else {
            return [format(identifier: "Response", message: "Received empty network response for \(target).")]
        }

        var output = [String]()

        output += [format(identifier: "Response", message: response.url?.absoluteString ?? "nil")]

        if let data = data {
            if let jsonObject = try? JSONSerialization.jsonObject(with: data) {
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
                    output += [String(decoding: jsonData, as: UTF8.self)]
                } else {
                    output += [String(describing: jsonObject)]
                }
            } else if let stringData = String(data: responseDataFormatter?(data) ?? data, encoding: String.Encoding.utf8), isVerbose {
                output += [stringData]
            }
        }

        return output
    }
}

public extension BONetworkLoggerPlugin {
    static func reversedPrint(_ separator: String, terminator: String, items: Any...) {
        for item in items {
            print(item, separator: separator, terminator: terminator)
        }
    }
}
