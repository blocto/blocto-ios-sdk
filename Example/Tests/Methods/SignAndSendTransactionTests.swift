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
            environment: .dev,
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

        // When:
        let solanaSDK = BloctoSDK.shared.solana
        solanaSDK.signAndSendTransaction(
            uuid: requestId,
            from: userWallet,
            transaction: transaction
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
        let expectation = XCTestExpectation(description: "wait for received address")
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
            environment: .dev,
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
        urlSession.responseJsonString = #"{"status":"PENDING","authorizationId":"XjBJU_TbC2yG4C723uLkR"}"#
        let solanaSDK = BloctoSDK.shared.solana
        solanaSDK.sessionId = "XRqupAW5jt1DogqLjbCkE-N8Iqo-XYgwBphqUIiRqQ-"

        // When:
        solanaSDK.signAndSendTransaction(
            uuid: requestId,
            from: userWallet,
            transaction: transaction,
            session: urlSession
        ) { result in
            switch result {
            case let .success(receivedtxHash):
                txHash = receivedtxHash
                XCTAssert(txHash == expectedTxHash, "txHash should be \(expectedTxHash) rather then \(txHash!)")
                expectation.fulfill()
            case let .failure(error):
                XCTAssert(false, error.localizedDescription)
            }
        }

        // Then:
        wait(for: [expectation], timeout: 4)
    }

}
