//
//  EIP712TypedData2.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/5/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

/// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md
import Foundation
import WalletCore

/// A struct represents EIP712 type tuple
struct EIP712Type: Codable {
    let name: String
    let type: String
}

/// A struct represents EIP712 Domain
struct EIP712Domain: Codable {
    let name: String
    let version: String
    let chainId: Int
    let verifyingContract: String
}

/// A struct represents EIP712 TypedData
struct EIP712TypedData: Codable {
    let types: [String: [EIP712Type]]
    let primaryType: String
    let domain: GenericJSON
    let message: GenericJSON
}

enum EIP712TypedDataSignVersion {
    case v3
    case v4
    case latest
}

extension EIP712TypedData {
    /// Type hash for the primaryType of an `EIP712TypedData`
    var typeHash: Data {
        let data = encodeType(primaryType: primaryType)
        return Hash.keccak256(data: data)
    }

    /// Sign-able hash for an `EIP712TypedData` with version specific.
    func signableHash(version: EIP712TypedDataSignVersion) throws -> Data {
        let data = Data([0x19, 0x01]) +
        Hash.keccak256(data: try encodeData(data: domain, type: "EIP712Domain", version: version)) +
        Hash.keccak256(data: try encodeData(data: message, type: primaryType, version: version))
        return Hash.keccak256(data: data)
    }

    /// Recursively finds all the dependencies of a type
    func findDependencies(primaryType: String, dependencies: Set<String> = Set<String>()) -> Set<String> {
        var found = dependencies
        guard !found.contains(primaryType),
              let primaryTypes = types[primaryType] else {
                  return found
              }
        found.insert(primaryType)
        for type in primaryTypes {
            findDependencies(primaryType: type.type, dependencies: found)
                .forEach { found.insert($0) }
        }
        return found
    }

    /// Encode a type of struct
    func encodeType(primaryType: String) -> Data {
        var depSet = findDependencies(primaryType: primaryType)
        depSet.remove(primaryType)
        let sorted = [primaryType] + Array(depSet).sorted()
        let encoded = sorted.map { type in
            let param = types[type]!.map { "\($0.type) \($0.name)" }.joined(separator: ",")
            return "\(type)(\(param))"
        }.joined()
        return encoded.data(using: .utf8) ?? Data()
    }

    /// Encode an instance of struct
    ///
    /// Implemented with `ABIEncoder` and `ABIValue`
    func encodeData(
        data: GenericJSON,
        type: String,
        version: EIP712TypedDataSignVersion = .latest
    ) throws -> Data {
        let encoder = BTABIEncoder()
        var values: [BTABIValue] = []
        let typeHash = Hash.keccak256(data: encodeType(primaryType: type))
        let typeHashValue = try BTABIValue(typeHash, type: .bytes(32))
        values.append(typeHashValue)
        if let valueTypes = types[type] {
            try valueTypes.forEach { field in
                switch version {
                case .v3:
                    if isCustomType(rawType: field.type),
                       let json = data[field.name] {
                        let nestEncoded = try encodeData(data: json, type: field.type, version: version)
                        values.append(try BTABIValue(Hash.keccak256(data: nestEncoded), type: .bytes(32)))
                    } else if let value = try makeABIValue(name: field.name, data: data[field.name], type: field.type, version: version) {
                        values.append(value)
                    }
                case .v4, .latest:
                    if let value = try encodeField(
                        name: field.name,
                        rawType: field.type,
                        value: data[field.name] ?? GenericJSON.null) {
                        values.append(value)
                    } else {
                        debugPrint("\(field.name) \(field.type) \(String(describing: data[field.name]))")
                        throw BTABIError.invalidArgumentType
                    }
                }
            }
        }
        try encoder.encode(tuple: values)
        return encoder.data
    }

    // encode field for typedDataSignV4 (support array)
    func encodeField(
        name: String,
        rawType: String,
        value: GenericJSON
    ) throws -> BTABIValue? {
        if isCustomType(rawType: rawType) {
            let typeValue: Data
            if value == .null {
                typeValue = Data("0x0000000000000000000000000000000000000000000000000000000000000000".utf8)
            } else {
                typeValue = Hash.keccak256(data: try encodeData(data: value, type: rawType, version: .v4))
            }
            return try BTABIValue(typeValue, type: .bytes(32))
        }

        // Arrays
        let components = rawType.components(separatedBy: CharacterSet(charactersIn: "[]"))
        if case let .array(jsons) = value {
            if components.count == 3 && components[1].isEmpty {
                let rawType = components[0]
                let encoder = BTABIEncoder()
                let values = jsons.compactMap {
                    try? encodeField(name: name, rawType: rawType, value: $0)
                }
                try? encoder.encode(tuple: values)
                return try? BTABIValue(Hash.keccak256(data: encoder.data), type: .bytes(32))
            } else if components.count == 3 && !components[1].isEmpty {
                let num = String(components[1].filter { "0"..."9" ~= $0 })
                guard Int(num) != nil else { return nil }
                let rawType = components[0]
                let encoder = BTABIEncoder()
                let values = jsons.compactMap {
                    try? encodeField(name: name, rawType: rawType, value: $0)
                }
                try? encoder.encode(tuple: values)
                return try? BTABIValue(Hash.keccak256(data: encoder.data), type: .bytes(32))
            } else {
                throw BTABIError.invalidArgumentType
            }
        }

        return try makeABIValue(
            name: name,
            data: value,
            type: rawType,
            version: .v4)
    }

    /// Helper func for `encodeData`
    private func makeABIValue(
        name: String,
        data: GenericJSON?,
        type: String,
        version: EIP712TypedDataSignVersion
    ) throws -> BTABIValue? {
        if (type == "string" || type == "bytes"),
           let value = data?.stringValue,
           let valueData = value.data(using: .utf8) {
            return try? BTABIValue(Hash.keccak256(data: valueData), type: .bytes(32))
        } else if type == "bool",
                  let value = data?.boolValue {
            return try? BTABIValue(value, type: .bool)
        } else if type == "address",
                  let value = data?.stringValue,
                  let address = AnyAddress(string: value, coin: .ethereum) {
            return try? BTABIValue(address, type: .address)
        } else if type.starts(with: "uint") {
            let size = parseIntSize(type: type, prefix: "uint")
            if size > 0, let value = data?.floatValue {
                return try? BTABIValue(Int(value), type: .uint(bits: size))
            }
        } else if type.starts(with: "int") {
            let size = parseIntSize(type: type, prefix: "int")
            if size > 0, let value = data?.floatValue {
                return try? BTABIValue(Int(value), type: .int(bits: size))
            }
        } else if type.starts(with: "bytes") {
            if let length = Int(type.dropFirst("bytes".count)),
               let value = data?.stringValue {
                if value.starts(with: "0x"),
                   let hex = Data(hexString: value) {
                    return try? BTABIValue(hex, type: .bytes(length))
                } else {
                    return try? BTABIValue(Data(Array(value.utf8)), type: .bytes(length))
                }
            }
        }

        // Arrays
        let components = type.components(separatedBy: CharacterSet(charactersIn: "[]"))
        if components.count == 3 {
            switch version {
            case .v3:
                throw BTABIError.arrayNotSupported
            case .v4, .latest:
                let components = type.components(separatedBy: CharacterSet(charactersIn: "[]"))
                if case let .array(jsons) = data {
                    if components[1].isEmpty {
                        let rawType = components[0]
                        let encoder = BTABIEncoder()
                        let values = jsons.compactMap {
                            try? encodeField(name: name, rawType: rawType, value: $0)
                        }
                        try? encoder.encode(tuple: values)
                        return try? BTABIValue(Hash.keccak256(data: encoder.data), type: .bytes(32))
                    } else if !components[1].isEmpty {
                        let num = String(components[1].filter { "0"..."9" ~= $0 })
                        guard Int(num) != nil else { return nil }
                        let rawType = components[0]
                        let encoder = BTABIEncoder()
                        let values = jsons.compactMap {
                            try? encodeField(name: name, rawType: rawType, value: $0)
                        }
                        try? encoder.encode(tuple: values)
                        return try? BTABIValue(Hash.keccak256(data: encoder.data), type: .bytes(32))
                    } else {
                        throw BTABIError.invalidArgumentType
                    }
                }
            }
        }

        return nil
    }

    func isCustomType(rawType: String) -> Bool {
        types[rawType] != nil
    }

    /// Helper func for encoding uint / int types
    private func parseIntSize(type: String, prefix: String) -> Int {
        guard type.starts(with: prefix),
              let size = Int(type.dropFirst(prefix.count)) else {
                  return -1
              }

        if size < 8 || size > 256 || size % 8 != 0 {
            return -1
        }
        return size
    }
}
