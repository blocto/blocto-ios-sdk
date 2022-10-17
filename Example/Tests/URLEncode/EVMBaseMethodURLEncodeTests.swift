//
//  EVMBaseMethodURLEncodeTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/5/28.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import BigInt
@testable import BloctoSDK

// swiftlint:disable type_body_length
class EVMBaseMethodURLEncodeTests: XCTestCase {
    
    func testURLComponent() throws {
        // Given:
        let item = URLQueryItem(name: .accountProof, value: "123 456 % 1")

        let expectedURL = URL(string: "https://123?account_proof=123%20456%20%25%201")
        // When:
        var component = URLComponents(string: "https://123")
        component?.queryItems = [item]
        
        // Then:
        XCTAssertEqual(component?.url, expectedURL)
    }

    func testEVMBaseRequestAccount() throws {
        // Given:
        let requestId = UUID()
        let method = RequestAccountMethod(
            id: requestId,
            blockchain: .ethereum) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.ethereum.rawValue),
            URLQueryItem(name: .method, value: MethodName.requestAccount.rawValue)
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

    func testEVMBaseSignMethod() throws {
        // Given:
        let requestId = UUID()

        let message: String = "0x506173746520746865207465787420796F75207769736820746F2048657820656E636F646520686572653A"

        let method = SignEVMBaseMessageMethod(
            id: requestId,
            from: ethereumAddress,
            message: message,
            signType: .sign,
            blockchain: .ethereum) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.ethereum.rawValue),
            URLQueryItem(name: .method, value: EVMBaseMethodType.signMessage.rawValue),
            URLQueryItem(name: .signType, value: EVMBaseSignType.sign.rawValue),
            URLQueryItem(name: .from, value: ethereumAddress),
            URLQueryItem(name: .message, value: message)
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

    func testEVMBasePersonalSignMethod() throws {
        // Given:
        let requestId = UUID()

        let message: String = "Any Message you wanna sign"

        let method = SignEVMBaseMessageMethod(
            id: requestId,
            from: ethereumAddress,
            message: message,
            signType: .personalSign,
            blockchain: .ethereum) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.ethereum.rawValue),
            URLQueryItem(name: .method, value: EVMBaseMethodType.signMessage.rawValue),
            URLQueryItem(name: .signType, value: EVMBaseSignType.personalSign.rawValue),
            URLQueryItem(name: .from, value: ethereumAddress),
            URLQueryItem(name: .message, value: message)
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

    func testEVMBaseTypedSignV3Method() throws {
        // Given:
        let requestId = UUID()

        let message: String = """
{
    "types": {
        "EIP712Domain": [
            {
                "name": "name",
                "type": "string"
            },
            {
                "name": "version",
                "type": "string"
            },
            {
                "name": "chainId",
                "type": "uint256"
            },
            {
                "name": "verifyingContract",
                "type": "address"
            }
        ],
        "Person": [
            {
                "name": "name",
                "type": "string"
            },
            {
                "name": "wallet",
                "type": "address"
            }
        ],
        "Mail": [
            {
                "name": "from",
                "type": "Person"
            },
            {
                "name": "to",
                "type": "Person"
            },
            {
                "name": "contents",
                "type": "string"
            }
        ]
    },
    "primaryType": "Mail",
    "domain": {
        "name": "Ether Mail",
        "version": "1",
        "chainId": 4,
        "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
    },
    "message": {
        "from": {
            "name": "Cow",
            "wallet": "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"
        },
        "to": {
            "name": "Bob",
            "wallet": "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"
        },
        "contents": "Hello, Bob!"
    }
}
"""

        let method = SignEVMBaseMessageMethod(
            id: requestId,
            from: ethereumAddress,
            message: message,
            signType: .typedSignV3,
            blockchain: .ethereum) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.ethereum.rawValue),
            URLQueryItem(name: .method, value: EVMBaseMethodType.signMessage.rawValue),
            URLQueryItem(name: .signType, value: EVMBaseSignType.typedSignV3.rawValue),
            URLQueryItem(name: .from, value: ethereumAddress),
            URLQueryItem(name: .message, value: message)
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

    func testEVMBaseTypedSignV4Method() throws {
        // Given:
        let requestId = UUID()

        let message: String = """
{
    "domain": {
        "chainId": 4,
        "name": "Ether Mail",
        "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
        "version": "1"
    },
    "message": {
        "contents": "Hello, Bob!",
        "from": {
            "name": "Cow",
            "wallets": [
                "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
                "0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF"
            ]
        },
        "to": [
            {
                "name": "Bob",
                "wallets": [
                    "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
                    "0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57",
                    "0xB0B0b0b0b0b0B000000000000000000000000000"
                ]
            }
        ]
    },
    "primaryType": "Mail",
    "types": {
        "EIP712Domain": [
            {
                "name": "name",
                "type": "string"
            },
            {
                "name": "version",
                "type": "string"
            },
            {
                "name": "chainId",
                "type": "uint256"
            },
            {
                "name": "verifyingContract",
                "type": "address"
            }
        ],
        "Group": [
            {
                "name": "name",
                "type": "string"
            },
            {
                "name": "members",
                "type": "Person[]"
            }
        ],
        "Mail": [
            {
                "name": "from",
                "type": "Person"
            },
            {
                "name": "to",
                "type": "Person[]"
            },
            {
                "name": "contents",
                "type": "string"
            }
        ],
        "Person": [
            {
                "name": "name",
                "type": "string"
            },
            {
                "name": "wallets",
                "type": "address[]"
            }
        ]
    }
}
"""

        let method = SignEVMBaseMessageMethod(
            id: requestId,
            from: ethereumAddress,
            message: message,
            signType: .typedSignV4,
            blockchain: .ethereum) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.ethereum.rawValue),
            URLQueryItem(name: .method, value: EVMBaseMethodType.signMessage.rawValue),
            URLQueryItem(name: .signType, value: EVMBaseSignType.typedSignV4.rawValue),
            URLQueryItem(name: .from, value: ethereumAddress),
            URLQueryItem(name: .message, value: message)
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

    func testEVMBaseSendMethod() throws {
        let requestId = UUID()
        let to: String = "0x58F385777aa6699b81f741Dd0d5B272A34C1c774"
        let value: BigUInt = 0
        let dataString = "5524107700000000000000000000000000000000000000000000000000000000000015be"
        let evmBaseTransaction = EVMBaseTransaction(
            to: to,
            from: ethereumAddress,
            value: value,
            data: dataString.bloctoSDK.hexDecodedData)
        let method = SendEVMBasedTransactionMethod(
            id: requestId,
            blockchain: .ethereum,
            transaction: evmBaseTransaction) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.ethereum.rawValue),
            URLQueryItem(name: .method, value: EVMBaseMethodType.sendTransaction.rawValue),
            URLQueryItem(name: .from, value: ethereumAddress),
            URLQueryItem(name: .to, value: to),
            URLQueryItem(name: .value, value: "0x0"),
            URLQueryItem(name: .data, value: "0x" + dataString)
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

    func testEVMBaseSendMethodWithValue() throws {
        let requestId = UUID()
        let to: String = "0x58F385777aa6699b81f741Dd0d5B272A34C1c774"
        let value: BigUInt = 256
        let dataString = "5524107700000000000000000000000000000000000000000000000000000000000015be"
        let evmBaseTransaction = EVMBaseTransaction(
            to: to,
            from: ethereumAddress,
            value: value,
            data: dataString.bloctoSDK.hexDecodedData)
        let method = SendEVMBasedTransactionMethod(
            id: requestId,
            blockchain: .ethereum,
            transaction: evmBaseTransaction) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.ethereum.rawValue),
            URLQueryItem(name: .method, value: EVMBaseMethodType.sendTransaction.rawValue),
            URLQueryItem(name: .from, value: ethereumAddress),
            URLQueryItem(name: .to, value: to),
            URLQueryItem(name: .value, value: "0x100"),
            URLQueryItem(name: .data, value: "0x" + dataString)
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
