//
//  QueryDecoding.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/6.
//

import Foundation

public enum QueryDecoding {

    static func decodeArray<T>(
        param: [String: String],
        queryName: QueryName
    ) -> [T] {
        do {
            let array = try decodeArray(
                param: param,
                target: queryName.rawValue
            )
            switch T.self {
            case is String.Type:
                if let value = array as? [T] {
                    return value
                } else {
                    return [T]()
                }
            case is Data.Type:
                return array.reduce([T]()) { partialResult, value in
                    var result = partialResult
                    if let data = value
                        .bloctoSDK.drop0x
                        .bloctoSDK.hexDecodedData as? T {
                        result.append(data)
                    }
                    return result
                }
            default:
                return [T]()
            }
        } catch {
            return [T]()
        }
    }

    static func decodeDictionary<T>(
        param: [String: String],
        queryName: QueryName
    ) -> [String: T] {
        do {
            let dictionary = try decodeDictionary(
                param: param,
                target: queryName.rawValue
            )
            switch T.self {
            case is String.Type:
                if let value = dictionary[queryName.rawValue] as? [String: T] {
                    return value
                } else {
                    return [String: T]()
                }
            case is Data.Type:
                if let value = dictionary[queryName.rawValue] as? [String: String] {
                    return value.reduce([String: T]()) { partialResult, value in
                        var result = partialResult
                        result[value.key] = value.value
                            .bloctoSDK.drop0x
                            .bloctoSDK.hexDecodedData as? T
                        return result
                    }
                } else {
                    return [String: T]()
                }
            default:
                return [String: T]()
            }
        } catch {
            return [String: T]()
        }
    }

    private static func decodeArray(
        param: [String: String],
        target: String
    ) throws -> [String] {
        let leftBrackets = "["
        let rightBrackets = "]"
        let array: [String] = param.reduce([]) {
            if $1.key == (target + leftBrackets + rightBrackets) {
                var copied = $0
                copied.append($1.value)
                return copied
            }
            return $0
        }
        return array
    }

    private static func decodeDictionary(
        param: [String: String],
        target: String
    ) throws -> [String: Any] {
        let leftBrackets = "["
        let rightBrackets = "]"
        let targets: [String: String] = param.reduce([:]) {
            var copied = $0
            copied[$1.key] = ($1.key.contains(target) ? $1.value : nil)
            return copied
        }
        let regex = try NSRegularExpression(pattern: #"(?<=\\#(leftBrackets))(.*?)(?=\\#(rightBrackets))"#)
        let value = targets.reduce([:]) { result, target -> [String: String] in
            var finalResult = result
            if let result: NSTextCheckingResult = regex.firstMatch(
                in: target.key,
                range: NSRange(target.key.startIndex..., in: target.key)
            ),
                let range = Range(result.range, in: target.key) {
                finalResult[String(target.key[range])] = target.value
                return finalResult
            } else {
                return finalResult
            }
        }
        return [target: value]
    }

}
