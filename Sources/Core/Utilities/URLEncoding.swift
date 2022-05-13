//
//  URLEncoding.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/21.
//

import Foundation

public enum URLEncoding {

    static func queryItems(
        appId: String,
        requestId: String,
        blockchain: Blockchain,
        method: MethodContentType
    ) -> [QueryItem] {
        var queryItems = [
            QueryItem(name: .appId, value: appId),
            QueryItem(name: .requestId, value: requestId),
            QueryItem(name: .blockchain, value: blockchain.rawValue),
            QueryItem(name: .method, value: method.rawValue)
        ]
        switch method {
        case .requestAccount:
            break
        case let .signMessage(from, message, signType):
            queryItems.append(contentsOf: [
                QueryItem(name: .from, value: from),
                QueryItem(name: .message, value: message),
                QueryItem(name: .signType, value: signType)
            ])
        case let .signAndSendTransaction(from, isInvokeWrapped, transactionInfo):
            queryItems.append(contentsOf: [
                QueryItem(name: .from, value: from),
                QueryItem(name: .isInvokeWrapped, value: isInvokeWrapped),
                QueryItem(name: .message, value: transactionInfo.message),
                QueryItem(name: .appendTx, value: transactionInfo.appendTx ?? [:]),
                QueryItem(name: .publicKeySignaturePairs, value: transactionInfo.publicKeySignaturePairs)
            ])
            if let appendMessages = transactionInfo.appendTx {
                queryItems.append(
                    QueryItem(
                        name: .appendTx,
                        value: appendMessages))
            }
        case let .sendTransaction(transaction):
            queryItems.append(contentsOf: [
                QueryItem(name: .from, value: transaction.from),
                QueryItem(name: .to, value: transaction.to),
                QueryItem(name: .value, value: String(transaction.value, radix: 16)),
                QueryItem(name: .data, value: transaction.data)
            ])
        }
        return queryItems
    }

    static func encode(_ queryItems: [QueryItem]) -> [URLQueryItem] {
        queryItems.flatMap { $0.getQueryComponents }
    }

    static func queryComponents(fromKey key: String, value: Any) -> [URLQueryItem] {
        var components: [URLQueryItem] = []
        switch value {
        case let dictionary as [String: Any]:
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        case let array as [Any]:
            let arrayEncoding = ArrayEncoding()
            for value in array {
                components += queryComponents(fromKey: arrayEncoding.encode(key: key), value: value)
            }
        case let number as NSNumber:
            if number.isBool {
                let boolEncoding = BoolEncoding()
                components.append(
                    .init(
                        name: escape(key),
                        value: escape(boolEncoding.encode(value: number.boolValue))))
            } else {
                components.append(
                    .init(
                        name: escape(key),
                        value: escape("\(number)")))
            }
        case let bool as Bool:
            let boolEncoding = BoolEncoding()
            components.append(
                .init(
                    name: escape(key),
                    value: escape(boolEncoding.encode(value: bool))))
        case let data as Data:
            components.append(
                .init(
                    name: escape(key),
                    value: escape(data.hexString)))
        default:
            components.append(
                .init(
                    name: escape(key),
                    value: escape("\(value)")))
        }
        return components
    }

    private static func escape(_ string: String) -> String {
        QueryEscape.escape(string)
    }

}

struct ArrayEncoding {

    func encode(key: String) -> String {
        "\(key)[]"
    }

}

struct DictionaryEncoding {

    func encode(
        key: String,
        value: [String: Any]
    ) -> String {
        "\(key)[]"
    }

}

struct BoolEncoding {

    func encode(value: Bool) -> String {
        value ? "true" : "false"
    }

}

extension CharacterSet {
    /// Creates a CharacterSet from RFC 3986 allowed characters.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    public static let afURLQueryAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()

}
