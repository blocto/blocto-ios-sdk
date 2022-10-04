//
//  EVMBase.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/5/13.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import BloctoSDK
import web3

enum EVMBase: CaseIterable {
    case ethereum
    case bsc
    case polygon
    case avalanche

    var displayString: String {
        switch self {
        case .ethereum:
            return "ETH"
        case .bsc:
            return "BSC"
        case .polygon:
            return "MATIC"
        case .avalanche:
            return "AVAX"
        }
    }

    var dappAddress: String {
        switch self {
        case .ethereum:
            switch bloctoEnvironment {
            case .prod:
                return "0x806243c7368a90D957592B55875eF4C3353C5bEa"
            case .dev:
                return "0x58F385777aa6699b81f741Dd0d5B272A34C1c774"
            }
        case .bsc:
            switch bloctoEnvironment {
            case .prod:
                return "0x806243c7368a90D957592B55875eF4C3353C5bEa"
            case .dev:
                return "0xfde90c9Bc193F520d119302a2dB8520D3A4408c8"
            }
        case .polygon:
            switch bloctoEnvironment {
            case .prod:
                return "0x806243c7368a90D957592B55875eF4C3353C5bEa"
            case .dev:
                return "0xfde90c9Bc193F520d119302a2dB8520D3A4408c8"
            }
        case .avalanche:
            switch bloctoEnvironment {
            case .prod:
                return "0x806243c7368a90D957592B55875eF4C3353C5bEa"
            case .dev:
                return "0xfde90c9Bc193F520d119302a2dB8520D3A4408c8"
            }
        }
    }

    var blockchain: Blockchain {
        switch self {
        case .ethereum:
            return .ethereum
        case .bsc:
            return .binanceSmartChain
        case .polygon:
            return .polygon
        case .avalanche:
            return .avalanche
        }
    }

    var sdkProvider: EVMBaseSDKProvider {
        switch self {
        case .ethereum:
            return BloctoSDK.shared.ethereum
        case .bsc:
            return BloctoSDK.shared.bsc
        case .polygon:
            return BloctoSDK.shared.polygon
        case .avalanche:
            return BloctoSDK.shared.avalanche
        }
    }

    var rpcClient: EthereumClient {
        let urlString: String
        switch self {
        case .ethereum:
            switch bloctoEnvironment {
            case .prod:
                urlString = "https://mainnet.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0"
            case .dev:
                urlString = "https://rinkeby.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0"
            }
        case .bsc:
            switch bloctoEnvironment {
            case .prod:
                urlString = "https://bsc-dataseed.binance.org"
            case .dev:
                urlString = "https://data-seed-prebsc-1-s1.binance.org:8545"
            }
        case .polygon:
            switch bloctoEnvironment {
            case .prod:
                urlString = "https://polygon-rpc.com/"
            case .dev:
                urlString = "https://rpc-mumbai.matic.today"
            }
        case .avalanche:
            switch bloctoEnvironment {
            case .prod:
                urlString = "https://api.avax.network/ext/bc/C/rpc"
            case .dev:
                urlString = "https://api.avax-test.network/ext/bc/C/rpc"
            }
        }
        return EthereumClient(url: URL(string: urlString)!)
    }

    func explorerURL(type: ExplorerURLType) -> URL? {
        switch self {
        case .ethereum:
            switch type {
            case let .txhash(hash):
                switch bloctoEnvironment {
                case .prod:
                    return URL(string: "https://etherscan.io/tx/\(hash)")
                case .dev:
                    return URL(string: "https://rinkeby.etherscan.io/tx/\(hash)")
                }
            case let .address(address):
                switch bloctoEnvironment {
                case .prod:
                    return URL(string: "https://etherscan.io/address/\(address)")
                case .dev:
                    return URL(string: "https://rinkeby.etherscan.io/address/\(address)")
                }
            }
        case .bsc:
            switch type {
            case let .txhash(hash):
                switch bloctoEnvironment {
                case .prod:
                    return URL(string: "https://bscscan.com/tx/\(hash)")
                case .dev:
                    return URL(string: "https://testnet.bscscan.com/tx/\(hash)")
                }
            case let .address(address):
                switch bloctoEnvironment {
                case .prod:
                    return URL(string: "https://bscscan.com/address/\(address)")
                case .dev:
                    return URL(string: "https://testnet.bscscan.com/address/\(address)")
                }
            }
        case .polygon:
            switch type {
            case let .txhash(hash):
                switch bloctoEnvironment {
                case .prod:
                    return URL(string: "https://polygonscan.com/tx/\(hash)")
                case .dev:
                    return URL(string: "https://mumbai.polygonscan.com/tx/\(hash)")
                }
            case let .address(address):
                switch bloctoEnvironment {
                case .prod:
                    return URL(string: "https://polygonscan.com/address/\(address)")
                case .dev:
                    return URL(string: "https://mumbai.polygonscan.com/address/\(address)")
                }
            }
        case .avalanche:
            switch type {
            case let .txhash(hash):
                switch bloctoEnvironment {
                case .prod:
                    return URL(string: "https://snowtrace.io/tx/\(hash)")
                case .dev:
                    return URL(string: "https://testnet.snowtrace.io/tx/\(hash)")
                }
            case let .address(address):
                switch bloctoEnvironment {
                case .prod:
                    return URL(string: "https://snowtrace.io/address/\(address)")
                case .dev:
                    return URL(string: "https://testnet.snowtrace.io/address/\(address)")
                }
            }
        }
    }

}
