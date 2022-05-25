//
//  Extensions.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/5/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import WalletCore
import BigInt

// MARK: - Blockchain
extension String {

    func nameHash() -> Data {
        var node = Data.init(count: 32)
        let labels = lowercased().components(separatedBy: ".")
        for label in labels.reversed() {
            let data = label.data(using: .utf8) ?? Data()
            node.append(Hash.keccak256(data: data))
            node = Hash.keccak256(data: node)
        }
        return node
    }

    var drop0x: String {
        if hasPrefix("0x") {
            return String(dropFirst(2))
        }
        return self
    }

}

extension BigInt {
    /// Serializes the `BigInt` with the specified bit width.
    ///
    /// - Returns: the serialized data or `nil` if the number doesn't fit in the specified bit width.
    func serialize(bitWidth: Int) -> Data? {
        let valueData = twosComplement()
        if valueData.count > bitWidth {
            return nil
        }

        var data = Data()
        if sign == .plus {
            data.append(Data(repeating: 0, count: bitWidth - valueData.count))
        } else {
            data.append(Data(repeating: 255, count: bitWidth - valueData.count))
        }
        data.append(valueData)
        return data
    }

    // Computes the two's complement for a `BigInt` with 256 bits
    private func twosComplement() -> Data {
        if sign == .plus {
            return magnitude.serialize()
        }

        let serializedLength = magnitude.serialize().count
        let max = BigUInt(1) << (serializedLength * 8)
        return (max - magnitude).serialize()
    }

}

extension AnyAddress {

    static var ethZero: AnyAddress {
        return AnyAddress(string: "0x0000000000000000000000000000000000000000", coin: .ethereum)!
    }
}

// MARK: - Range
extension String {

    var fullRange: Range<Index> {
        return startIndex..<endIndex
    }

    var fullNSRange: NSRange {
        return NSRange(fullRange, in: self)
    }
}
