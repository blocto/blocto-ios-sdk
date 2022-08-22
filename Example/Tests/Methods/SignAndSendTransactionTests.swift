//
//  SignAndSendTransactionTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/4/8.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import BloctoSDK
import SolanaWeb3

struct ValueAccountData: BufferLayout {
    let instruction: Int
    let value: String
}

class SignAndSendTransactionTests: XCTestCase {

    var mockUIApplication: MockUIApplication!

    override func setUp() {
        super.setUp()
        mockUIApplication = MockUIApplication()
    }

    func testOpenNativeAppWhenInstalled() throws {
        // Given:
        let requestId = UUID()
        var txHash: String?
        let expectedTxHash: String = "65ZG7Retj1acmX2DXv9YdU12JJ53a5sKgBmmDGHVexTyDnFq8C3inKMMvcdMXi5NvZCLSueThdSNNHJBWdw7neUC"
        BloctoSDK.shared.initialize(
            with: appId,
            getWindow: { UIWindow() },
            logging: false,
            testnet: true,
            urlOpening: mockUIApplication
        )

        mockUIApplication.setup(openedOrder: [true])

        let recentBlockhash = "9zTxGCmvmi4pFfAzWNJpKqszpM6LeiK7pGs4f3myWnpH"
        let dappAddress: String = "4AXy5YYCXpMapaVuzKkz25kVHzrdLDgKN3TiQvtf1Eu8"
        let dappPublicKey = try PublicKey(dappAddress)
        let programId: String = "G4YkbRN4nFQGEUg4SXzPsrManWzuk8bNq9JaMhXepnZ6"
        let programPublicKey = try PublicKey(programId)
        let userWallet: String = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        let userWalletPublicKey = try PublicKey(userWallet)

        let valueAccountData = ValueAccountData(
            instruction: 0,
            value: "1"
        )
        let data = try valueAccountData.serialize()

        let transactionInstruction = TransactionInstruction(
            keys: [
                AccountMeta(
                    publicKey: dappPublicKey,
                    isSigner: false,
                    isWritable: true
                ),
                AccountMeta(
                    publicKey: userWalletPublicKey,
                    isSigner: false,
                    isWritable: true
                ),
            ],
            programId: programPublicKey,
            data: data
        )
        var transaction = Transaction(recentBlockhash: recentBlockhash)
        transaction.add(transactionInstruction)
        transaction.feePayer = userWalletPublicKey

        let urlSession = URLSessionMock()
        urlSession.responseJsonString = #"{"raw_tx":"03020208dac7dab484e8d0f174360daad76fe7b849aa929c5103eff76cd6d30fd0ea947d0f2b785bed6b4c9cf079c0ba7ae9264cd3f3d30a9cab45cb442923862c5633a0618db61dfc748ba4ee9e3d0bb4a8364b64ee145c9080ac7af4ceb4039aacdd7e2f044d6abceb87a88416562a21f1bb49e216f5f7a829bc88763a2b0664680fa34aa5298c9669ab8f56b091cc8c6a3f1564d24300f60ab9f313a0ba787ed1ca70e7fdf00ea69dfc9d96968d5108b5c69b0e125ca8794cba62ec9b05af087b30f0aeb08762d01b472df8e2ba21e20132a5c218e2435e02d7e4a84030bcd6b9c2b9dfc7f2af100827ea33addbb9d430e457f5311bb905cb3a86a721bc58d72b2701f14431ce444af93991ca86659d194d68007f51c2b4a5c7afa4ac3654c6db82f401060805040006020107031f030307000001010102030600040205020701030302000601010300be150000","request_id":"dd4bbe67","extra_data":{"append_tx":{}}}"#

        // When:
        let solanaSDK = BloctoSDK.shared.solana
        solanaSDK.signAndSendTransaction(
            uuid: requestId,
            from: userWallet,
            transaction: transaction,
            session: urlSession
        ) { result in
            switch result {
            case let .success(receivedtxHash):
                txHash = receivedtxHash
            case let .failure(error):
                XCTAssert(false, error.localizedDescription)
            }
        }

        var components = URLComponents(string: appCustomSchemeBaseURLString)
        components?.queryItems = [
            .init(name: "request_id", value: requestId.uuidString),
            .init(name: "tx_hash", value: expectedTxHash),
        ]
        BloctoSDK.shared.application(
            open: components!.url!
        )

        // Then:
        XCTAssert(txHash == expectedTxHash, "txHash should be \(expectedTxHash) rather then \(txHash!)")
    }

    func testOpenWebSDK() throws {
        // Given:
        let requestId = UUID()
        var txHash: String?
        let expectedTxHash: String = "65ZG7Retj1acmX2DXv9YdU12JJ53a5sKgBmmDGHVexTyDnFq8C3inKMMvcdMXi5NvZCLSueThdSNNHJBWdw7neUC"

        let recentBlockhash = "9zTxGCmvmi4pFfAzWNJpKqszpM6LeiK7pGs4f3myWnpH"
        let dappAddress: String = "4AXy5YYCXpMapaVuzKkz25kVHzrdLDgKN3TiQvtf1Eu8"
        let dappPublicKey = try PublicKey(dappAddress)
        let programId: String = "G4YkbRN4nFQGEUg4SXzPsrManWzuk8bNq9JaMhXepnZ6"
        let programPublicKey = try PublicKey(programId)
        let userWallet: String = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        let userWalletPublicKey = try PublicKey(userWallet)

        let valueAccountData = ValueAccountData(
            instruction: 0,
            value: "1"
        )
        let data = try valueAccountData.serialize()

        let transactionInstruction = TransactionInstruction(
            keys: [
                AccountMeta(
                    publicKey: dappPublicKey,
                    isSigner: false,
                    isWritable: true
                ),
                AccountMeta(
                    publicKey: userWalletPublicKey,
                    isSigner: false,
                    isWritable: true
                ),
            ],
            programId: programPublicKey,
            data: data
        )
        var transaction = Transaction(recentBlockhash: recentBlockhash)
        transaction.add(transactionInstruction)
        transaction.feePayer = userWalletPublicKey

        BloctoSDK.shared.initialize(
            with: appId,
            getWindow: { UIWindow() },
            logging: false,
            testnet: true,
            urlOpening: mockUIApplication,
            sessioningType: MockAuthenticationSession.self
        )

        mockUIApplication.setup(openedOrder: [false])

        var components = URLComponents(string: webRedirectBaseURLString)
        components?.queryItems = [
            .init(name: "request_id", value: requestId.uuidString),
            .init(name: "tx_hash", value: expectedTxHash),
        ]
        MockAuthenticationSession.setCallbackURL(components!.url!)

        let urlSession = URLSessionMock()
        urlSession.responseJsonString = #"{"raw_tx":"03020208dac7dab484e8d0f174360daad76fe7b849aa929c5103eff76cd6d30fd0ea947d0f2b785bed6b4c9cf079c0ba7ae9264cd3f3d30a9cab45cb442923862c5633a0618db61dfc748ba4ee9e3d0bb4a8364b64ee145c9080ac7af4ceb4039aacdd7e2f044d6abceb87a88416562a21f1bb49e216f5f7a829bc88763a2b0664680fa34aa5298c9669ab8f56b091cc8c6a3f1564d24300f60ab9f313a0ba787ed1ca70e7fdf00ea69dfc9d96968d5108b5c69b0e125ca8794cba62ec9b05af087b30f0aeb08762d01b472df8e2ba21e20132a5c218e2435e02d7e4a84030bcd6b9c2b9dfc7f2af100827ea33addbb9d430e457f5311bb905cb3a86a721bc58d72b2701f14431ce444af93991ca86659d194d68007f51c2b4a5c7afa4ac3654c6db82f401060805040006020107031f030307000001010102030600040205020701030302000601010300be150000","request_id":"dd4bbe67","extra_data":{"append_tx":{}}}"#

        // When:
        let solanaSDK = BloctoSDK.shared.solana
        solanaSDK.signAndSendTransaction(
            uuid: requestId,
            from: userWallet,
            transaction: transaction,
            session: urlSession
        ) { result in
            switch result {
            case let .success(receivedtxHash):
                txHash = receivedtxHash
            case let .failure(error):
                XCTAssert(false, error.localizedDescription)
            }
        }

        // Then:
        XCTAssert(txHash == expectedTxHash, "txHash should be \(expectedTxHash) rather then \(txHash!)")
    }

}
