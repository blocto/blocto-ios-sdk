//
//  SolanaMethodURLEncodeTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/5/28.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import BloctoSDK

class SolanaMethodURLEncodeTests: XCTestCase {

    let platform = "sdk_ios"
    func testSolanaRequestAccount() throws {
        // Given:
        let requestId = UUID()
        let method = RequestAccountMethod(
            id: requestId,
            blockchain: .solana) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.solana.rawValue),
            URLQueryItem(name: .method, value: MethodName.requestAccount.rawValue),
            URLQueryItem(name: .platform, value: platform)
        ]

        // When:
        guard let requestURL = try method.encodeToURL(
            appId: appId,
            baseURLString: BloctoSDK.shared.requestBloctoBaseURLString) else {
                XCTFail("requestURL not found.")
                return
            }

        // Then:
        XCTAssertURLEqual(requestURL, expectURLComponents?.url)
    }

    func testSolanaSignAndSendMethod() throws {
        // Given:
        let requestId = UUID()
        // swiftlint:disable line_length
        let messageHex = "03020208dac7dab484e8d0f174360daad76fe7b849aa929c5103eff76cd6d30fd0ea947d0f2b785bed6b4c9cf079c0ba7ae9264cd3f3d30a9cab45cb442923862c5633a0618db61dfc748ba4ee9e3d0bb4a8364b64ee145c9080ac7af4ceb4039aacdd7e2f044d6abceb87a88416562a21f1bb49e216f5f7a829bc88763a2b0664680fa34aa5298c9669ab8f56b091cc8c6a3f1564d24300f60ab9f313a0ba787ed1ca70e7fdf00ea69dfc9d96968d5108b5c69b0e125ca8794cba62ec9b05af087b30f0aeb08762d01b472df8e2ba21e20132a5c218e2435e02d7e4a84030bcd6b9c2b9dfc7f2af100827ea33addbb9d430e457f5311bb905cb3a86a721bc58d72b2701fc5744c3c866b88b2eb769024d5115f372bf37019126a2254ca9eac587592ac2010607050400070201030d030302000601010300be150000"
        let method = SignAndSendSolanaTransactionMethod(
            id: requestId,
            blockchain: .solana,
            from: solanaAddress,
            transactionInfo: SolanaTransactionInfo(
                message: messageHex,
                appendTx: [:],
                publicKeySignaturePairs: [:]),
            isInvokeWrapped: true) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.solana.rawValue),
            URLQueryItem(name: .method, value: SolanaMethodType.signAndSendTransaction.rawValue),
            URLQueryItem(name: .from, value: solanaAddress),
            URLQueryItem(name: .isInvokeWrapped, value: "true"),
            URLQueryItem(name: .message, value: messageHex),
            URLQueryItem(name: .platform, value: platform)
        ]

        // When:
        guard let requestURL = try method.encodeToURL(
            appId: appId,
            baseURLString: BloctoSDK.shared.requestBloctoBaseURLString) else {
                XCTFail("requestURL not found.")
                return
            }

        // Then:
        XCTAssertURLEqual(requestURL, expectURLComponents?.url)
    }

    func testSolanaSignAndSendPartialSignMethod() throws {
        // Given:
        let requestId = UUID()
        // swiftlint:disable line_length
        let messageHex = "0200050bdac7dab484e8d0f174360daad76fe7b849aa929c5103eff76cd6d30fd0ea947d7d05f650e930daffbe1c4353d265e7c7243d564ffbe2a28046d8e3a52b068bf32f044d6abceb87a88416562a21f1bb49e216f5f7a829bc88763a2b0664680fa34aa5298c9669ab8f56b091cc8c6a3f1564d24300f60ab9f313a0ba787ed1ca70939caebd467f9a655612dd75684a0cfce30d1ee909770c9f9dc154376947ec3bf89fce5ebc54cc43cf3de7c6d8eb921ef1466502b9150a7e6c199082d7e730180000000000000000000000000000000000000000000000000000000000000000aeb08762d01b472df8e2ba21e20132a5c218e2435e02d7e4a84030bcd6b9c2b9dfc7f2af100827ea33addbb9d430e457f5311bb905cb3a86a721bc58d72b2701e7fdf00ea69dfc9d96968d5108b5c69b0e125ca8794cba62ec9b05af087b30f006a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000015605c03143987af784c92a219892c063e40bc8450b35908948250819895ffb1020603050a0004040000000708090400030601080203080200"
        let appendTxKey1 = "81919d8e-f9e8-4f5f-a9bb-85562e815ee6"
        // swiftlint:disable line_length
        let appendTxValue1 = "03020409dac7dab484e8d0f174360daad76fe7b849aa929c5103eff76cd6d30fd0ea947d0f2b785bed6b4c9cf079c0ba7ae9264cd3f3d30a9cab45cb442923862c5633a0618db61dfc748ba4ee9e3d0bb4a8364b64ee145c9080ac7af4ceb4039aacdd7e2fbf2110a3601118d1eaf31837058c208c92319d2a5054b19449f928502ee0af939caebd467f9a655612dd75684a0cfce30d1ee909770c9f9dc154376947ec3b000000000000000000000000000000000000000000000000000000000000000006a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea9400000aeb08762d01b472df8e2ba21e20132a5c218e2435e02d7e4a84030bcd6b9c2b9e7fdf00ea69dfc9d96968d5108b5c69b0e125ca8794cba62ec9b05af087b30f0ee64d227f6c783bf7903bb9a3905e1a0c243b2ded31fd21f8f6e1761185f5f310205030306000404000000070508040002016e079a000200022f044d6abceb87a88416562a21f1bb49e216f5f7a829bc88763a2b0664680fa3034aa5298c9669ab8f56b091cc8c6a3f1564d24300f60ab9f313a0ba787ed1ca70dfc7f2af100827ea33addbb9d430e457f5311bb905cb3a86a721bc58d72b2701050000be150000"
        let appendTxKey2 = "e92baece-e93a-405d-8b02-1985ee34e900"
        // swiftlint:disable line_length
        let appendTxValue2 = "03020409dac7dab484e8d0f174360daad76fe7b849aa929c5103eff76cd6d30fd0ea947d0f2b785bed6b4c9cf079c0ba7ae9264cd3f3d30a9cab45cb442923862c5633a0618db61dfc748ba4ee9e3d0bb4a8364b64ee145c9080ac7af4ceb4039aacdd7e939caebd467f9a655612dd75684a0cfce30d1ee909770c9f9dc154376947ec3bc44c8980450964e1579b3dd5b2f156b0ea19917be945afb8677922627775eb22000000000000000000000000000000000000000000000000000000000000000006a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea9400000aeb08762d01b472df8e2ba21e20132a5c218e2435e02d7e4a84030bcd6b9c2b9e7fdf00ea69dfc9d96968d5108b5c69b0e125ca8794cba62ec9b05af087b30f05c225c4f7a5e9b74258b252271cd4fadd8e1f8390b1c9c42d28f86facdf6462e0205030406000404000000070508030002019d010700000200034aa5298c9669ab8f56b091cc8c6a3f1564d24300f60ab9f313a0ba787ed1ca70037d05f650e930daffbe1c4353d265e7c7243d564ffbe2a28046d8e3a52b068bf30000000000000000000000000000000000000000000000000000000000000000340000000000e0a70e00000000000a00000000000000dfc7f2af100827ea33addbb9d430e457f5311bb905cb3a86a721bc58d72b2701"
        let appendTx: [String: Data] = [
            appendTxKey1: appendTxValue1.bloctoSDK.hexDecodedData,
            appendTxKey2: appendTxValue2.bloctoSDK.hexDecodedData
        ]
        let publicKey = "9R3EeCSfeQNkh7vU1YpXeFUZNM765Dv8mFNgPsfY4DML"
        let signature = "d04bdefd01f1c826e68b6f61f904d6176e8fc4029345d41ec309c410e0f36aee9434c5168fa2bff4e62c26c843b1f3b4df8a479e403512ce70171af8cbb7cc02"
        let publicKeySignaturePairs = [
            publicKey: signature
        ]
        let method = SignAndSendSolanaTransactionMethod(
            id: requestId,
            blockchain: .solana,
            from: solanaAddress,
            transactionInfo: SolanaTransactionInfo(
                message: messageHex,
                appendTx: appendTx,
                publicKeySignaturePairs: publicKeySignaturePairs),
            isInvokeWrapped: true) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.solana.rawValue),
            URLQueryItem(name: .method, value: SolanaMethodType.signAndSendTransaction.rawValue),
            URLQueryItem(name: .from, value: solanaAddress),
            URLQueryItem(name: .isInvokeWrapped, value: "true"),
            URLQueryItem(name: .message, value: messageHex),
            URLQueryItem(name: "\(QueryName.appendTx.rawValue)[\(appendTxKey1)]", value: appendTxValue1),
            URLQueryItem(name: "\(QueryName.appendTx.rawValue)[\(appendTxKey2)]", value: appendTxValue2),
            URLQueryItem(name: "\(QueryName.publicKeySignaturePairs.rawValue)[\(publicKey)]", value: signature),
            URLQueryItem(name: .platform, value: platform)
        ]

        // When:
        guard let requestURL = try method.encodeToURL(
            appId: appId,
            baseURLString: BloctoSDK.shared.requestBloctoBaseURLString) else {
                XCTFail("requestURL not found.")
                return
            }

        // Then:
        XCTAssertURLEqual(requestURL, expectURLComponents?.url)
    }

}
