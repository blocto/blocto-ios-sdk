//
//  ABITypeParser.swift
//  Blocto
//
//  Created by Scott Chou on 2020/1/20.
//  Copyright © 2020 Portto Co., Ltd. All rights reserved.
//

import Foundation

struct BTABITypeParser {

    enum TypeParsingExpressions {
        static var typeEatingRegex = "^((u?int|bytes)([1-9][0-9]*)|(address|bool|string|tuple|bytes)|(\\[([1-9][0-9]*)\\]))"
        static var arrayEatingRegex = "^(\\[([1-9][0-9]*)?\\])?.*$"
    }

    private enum BaseParameterType: String {
        case address
        case uint
        case int
        case bool
        case function
        case bytes
        case string
        case tuple
    }

    private static func baseTypeMatch(from string: String, length: Int = 0) -> BTABIType? {
        switch BaseParameterType(rawValue: string) {
        case .address?:
            return .address
        case .uint?:
            return .uint(bits: length == 0 ? 256: length)
        case .int?:
            return .int(bits: length == 0 ? 256: length)
        case .bool?:
            return .bool
        case .function?:
            return .function(BTFunction(name: "", parameters: []))
        case .bytes?:
            if length == 0 {
                return .dynamicBytes
            }
            return .bytes(length)
        case .string?:
            return .string
        case .tuple?:
            return .tuple([BTABIType]())
        default:
            return nil
        }
    }

    public static func parseTypeString(_ string: String) -> BTABIType? {
        let (type, tail) = recursiveParseType(string)
        guard let t = type, tail == nil else {
            return nil
        }
        return t
    }

    public static func recursiveParseType(_ string: String) -> (type: BTABIType?, tail: String?) {
        guard let matcher = try? NSRegularExpression(pattern: TypeParsingExpressions.typeEatingRegex, options: NSRegularExpression.Options.dotMatchesLineSeparators) else {
            return (nil, nil)
        }
        let match = matcher.matches(in: string, options: NSRegularExpression.MatchingOptions.anchored, range: string.fullNSRange)
        guard match.count == 1 else {
            return (nil, nil)
        }
        var tail: String = ""
        var type: BTABIType
        guard match[0].numberOfRanges >= 1 else { return (nil, nil) }
        guard let baseTypeRange = Range(match[0].range(at: 1), in: string) else { return (nil, nil) }
        let baseTypeString = String(string[baseTypeRange])
        if match[0].numberOfRanges >= 2, let exactTypeRange = Range(match[0].range(at: 2), in: string) {
            let typeString = String(string[exactTypeRange])
            if match[0].numberOfRanges >= 3, let lengthRange = Range(match[0].range(at: 3), in: string) {
                let lengthString = String(string[lengthRange])
                guard let typeLength = Int(lengthString) else { return (nil, nil) }
                guard let baseType = baseTypeMatch(from: typeString, length: typeLength) else { return (nil, nil) }
                type = baseType
            } else {
                guard let baseType = baseTypeMatch(from: typeString, length: 0) else { return (nil, nil) }
                type = baseType
            }
        } else {
            guard let baseType = baseTypeMatch(from: baseTypeString, length: 0) else { return (nil, nil) }
            type = baseType
        }

        guard let range = string.range(of: baseTypeString) else { return (nil, nil) }
        tail = string.replacingCharacters(in: range, with: "")
        if tail == "" {
            return (type, nil)
        }
        return recursiveParseArray(baseType: type, string: tail)
    }

    public static func recursiveParseArray(baseType: BTABIType, string: String) -> (type: BTABIType?, tail: String?) {
        guard let matcher = try? NSRegularExpression(pattern: TypeParsingExpressions.arrayEatingRegex, options: NSRegularExpression.Options.dotMatchesLineSeparators) else {
            return (nil, nil)
        }
        let match = matcher.matches(in: string, options: NSRegularExpression.MatchingOptions.anchored, range: string.fullNSRange)
        guard match.count == 1 else { return (nil, nil) }
        var tail: String = ""
        let type: BTABIType
        guard match[0].numberOfRanges >= 1 else { return (nil, nil) }
        guard let baseArrayRange = Range(match[0].range(at: 1), in: string) else { return (nil, nil) }
        let baseArrayString = String(string[baseArrayRange])
        if match[0].numberOfRanges >= 2, let exactArrayRange = Range(match[0].range(at: 2), in: string) {
            let lengthString = String(string[exactArrayRange])
            guard let arrayLength = Int(lengthString) else { return (nil, nil) }
            type = BTABIType.array(baseType, arrayLength)
        } else {
            type = BTABIType.array(baseType, 0)
        }

        guard let range = string.range(of: baseArrayString) else { return (nil, nil) }
        tail = string.replacingCharacters(in: range, with: "")
        if tail == "" {
            return (type, nil)
        }
        return recursiveParseArray(baseType: type, string: tail)
    }
}
