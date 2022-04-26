//
//  QueryItem.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/16.
//

import Foundation

public struct QueryItem {

    let name: QueryName
    let value: Any

    init(name: QueryName, value: Any) {
        self.name = name
        self.value = value
    }

    var getQueryComponents: [URLQueryItem] {
        queryComponents(fromKey: name.rawValue, value: value)
    }

    private func queryComponents(fromKey key: String, value: Any) -> [URLQueryItem] {
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

    private func escape(_ string: String) -> String {
        QueryEscape.escape(string)
    }

}

enum QueryEscape {

    static func escape(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? string
    }

}
