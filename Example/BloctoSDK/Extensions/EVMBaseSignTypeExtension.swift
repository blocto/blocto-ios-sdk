//
//  EVMBaseSignTypeExtension.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/5/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import BloctoSDK

extension EVMBaseSignType {

    var displayTitle: String {
        switch self {
        case .sign:
            return "eth_sign"
        case .personalSign:
            return "personal sign"
        case .typedSignV3:
            return "typedSign v3"
        case .typedSignV4:
            return "typedSign v4"
        case .typedSign:
            return "latest typedSign"
        }
    }

    func defaultText(chainId: Int) -> String {
        switch self {
        case .sign:
            return "0x506173746520746865207465787420796F75207769736820746F2048657820656E636F646520686572653A"
        case .personalSign:
            return "Any Message you wanna sign"
        case .typedSignV3:
            return """
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
        "chainId": \(chainId),
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
        case .typedSignV4,
                .typedSign:
            return """
{
    "domain": {
        "chainId": \(chainId),
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
        }
    }

}
