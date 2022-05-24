//
//  HashingTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/5/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import WalletCore
@testable import BloctoSDK_Example

class HashingTests: XCTestCase {

    func testHashing() throws {
        // Given:
        let personalSignMessage = "Any Message you wanna sign"
        let data = Data(personalSignMessage.utf8)

        let expectResult = "aaceed9f3778b20273e2a2d80509d8f18f068d0e8b277a8e2da50dd72f25db41"

        // When:
        let result = Hash.keccak256(data: data)

        // Then:
        XCTAssertEqual(result.hexString, expectResult)
    }

    func testHashingPersonalSign() throws {
        // Given:
        let personalSignMessage = "Any Message you wanna sign"
        let messageData = Data(personalSignMessage.utf8)

        let rawData = Hash.keccak256(data: messageData)
        let expectResult = "ef3938cef5da4283b4997b93661a1a6334f55fd9af489442f294701a8095f42c"
        let ethAddress = "c823994cdddae5cb4bd1adfe5afd03f8e06bc7ef"

        // When:
        var signingData = Data()
        signingData.append(0x19)
        signingData.append(0x00)
        signingData.append(ethAddress.hexDecodedData)
        signingData.append(rawData)

        let result = Hash.keccak256(data: signingData)

        // Then:
        XCTAssertEqual(result.hexString, expectResult)
    }

}
