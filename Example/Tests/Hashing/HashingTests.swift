//
//  HashingTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/5/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import EthereumSignTypedDataUtil
@testable import BloctoSDK_Example

class HashingTests: XCTestCase {

    func testHashing() throws {
        // Given:
        let personalSignMessage = "Any Message you wanna sign"
        let data = Data(personalSignMessage.utf8)

        let expectResult = "aaceed9f3778b20273e2a2d80509d8f18f068d0e8b277a8e2da50dd72f25db41"

        // When:
        let result = data.sha3(.keccak256)

        // Then:
        XCTAssertEqual(result.bloctoSDK.hexString, expectResult)
    }

    func testHashingPersonalSign() throws {
        // Given:
        let personalSignMessage = "Any Message you wanna sign"
        let messageData = Data(personalSignMessage.utf8)

        let rawData = messageData.sha3(.keccak256)
        let expectResult = "ef3938cef5da4283b4997b93661a1a6334f55fd9af489442f294701a8095f42c"
        let ethAddress = "0xc823994cdddae5cb4bd1adfe5afd03f8e06bc7ef"

        // When:
        var signingData = Data()
        signingData.append(0x19)
        signingData.append(0x00)
        signingData.append(ethAddress
                            .bloctoSDK.drop0x
                            .bloctoSDK.hexDecodedData)
        signingData.append(rawData)

        let result = signingData.sha3(.keccak256)

        // Then:
        XCTAssertEqual(result.bloctoSDK.hexString, expectResult)
    }

    func testHashingTypeDataV3() throws {
        // Given:
        let typeDataSignMessage = #"{"types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}],"Person":[{"name":"name","type":"string"},{"name":"wallet","type":"address"}],"Mail":[{"name":"from","type":"Person"},{"name":"to","type":"Person"},{"name":"contents","type":"string"}]},"primaryType":"Mail","domain":{"name":"Ether Mail","version":"1","chainId":4,"verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"},"message":{"from":{"name":"Cow","wallet":"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"},"to":{"name":"Bob","wallet":"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"},"contents":"Hello, Bob!"}}"#
        let expectResult = "63c6fa5cdb67f841c70b2ca6dd1260a82378cef8a4c4ca3a21d59dfaec81a2fa"

        // When:
        let typedData = try JSONDecoder().decode(EIP712TypedData.self, from: Data(typeDataSignMessage.utf8))
        let result = try typedData.signableHash(version: EIP712TypedDataSignVersion.v3)

        // Then:
        XCTAssertEqual(result.bloctoSDK.hexString, expectResult)
    }

    func testHashingTypeDataV4() throws {
        // Given:
        let typeDataSignMessage = #"{"domain":{"chainId":4,"name":"Ether Mail","verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC","version":"1"},"message":{"contents":"Hello, Bob!","from":{"name":"Cow","wallets":["0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826","0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF"]},"to":[{"name":"Bob","wallets":["0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB","0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57","0xB0B0b0b0b0b0B000000000000000000000000000"]}]},"primaryType":"Mail","types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}],"Group":[{"name":"name","type":"string"},{"name":"members","type":"Person[]"}],"Mail":[{"name":"from","type":"Person"},{"name":"to","type":"Person[]"},{"name":"contents","type":"string"}],"Person":[{"name":"name","type":"string"},{"name":"wallets","type":"address[]"}]}}"#
        let expectResult = "edeff92a8dcf61f70eb77c8cc8291a38779616bcf47f48adce044b8c9347aa7c"

        // When:
        let typedData = try JSONDecoder().decode(EIP712TypedData.self, from: Data(typeDataSignMessage.utf8))
        let result = try typedData.signableHash(version: EIP712TypedDataSignVersion.v4)

        // Then:
        XCTAssertEqual(result.bloctoSDK.hexString, expectResult)
    }

}
