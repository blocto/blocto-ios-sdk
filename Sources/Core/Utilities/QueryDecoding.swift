//
//  QueryDecoding.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/6.
//

import Foundation

public enum QueryDecoding {

    static func decodeDictionary(
        param: [String: String],
        queryName: QueryName
    ) -> [String: String] {
        do {
            let dictionary = try decodeDictionary(
                param: param,
                target: queryName.rawValue)
            if let value = dictionary[queryName.rawValue] {
                return value
            } else {
                return [:]
            }
        } catch {
            return [:]
        }
    }

    private static func decodeDictionary(
        param: [String: String],
        target: String
    ) throws -> [String: [String: String]] {
        let leftBrackets = QueryEscape.escape("[")
        let rightBrackets = QueryEscape.escape("]")
        let targets: [String: String] = param.reduce([:], {
            var copied = $0
            copied[$1.key] = ($1.key.contains(target) ? $1.value : nil)
            return copied
        })
        let regex = try NSRegularExpression(pattern: "(?<=\(leftBrackets))(.*?)(?=\(rightBrackets))")
        let value = targets.reduce([:], { result, target -> [String: String] in
            var finalResult = result
            if let result: NSTextCheckingResult = regex.firstMatch(
                in: target.key,
                range: NSRange(target.key.startIndex..., in: target.key)),
               let range = Range(result.range, in: target.key) {
                finalResult[String(target.key[range])] = target.value
                return finalResult
            } else {
                return finalResult
            }
        })
        return [target: value]
    }

}
