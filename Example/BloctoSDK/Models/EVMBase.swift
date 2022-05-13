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
            return isProduction
            ? "0x806243c7368a90D957592B55875eF4C3353C5bEa"
            : "0x58F385777aa6699b81f741Dd0d5B272A34C1c774"
        case .bsc:
            return isProduction
            ? "0x806243c7368a90D957592B55875eF4C3353C5bEa"
            : "0xfde90c9Bc193F520d119302a2dB8520D3A4408c8"
        case .polygon:
            return isProduction
            ? "0x806243c7368a90D957592B55875eF4C3353C5bEa"
            : "0xfde90c9Bc193F520d119302a2dB8520D3A4408c8"
        case .avalanche:
            return isProduction
            ? "0x806243c7368a90D957592B55875eF4C3353C5bEa"
            : "0xfde90c9Bc193F520d119302a2dB8520D3A4408c8"
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
        switch self {
        case .ethereum:
            return isProduction
            ? EthereumClient(url: URL(string: "https://mainnet.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0")!)
            : EthereumClient(url: URL(string: "https://rinkeby.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0")!)
//        case .bsc:
//            return isProduction
//            ? EthereumClient(url: URL(string: "https://mainnet.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0")!)
//            : EthereumClient(url: URL(string: "https://rinkeby.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0")!)
        case .polygon:
            return isProduction
            ? EthereumClient(url: URL(string: "https://polygon-mainnet.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0")!)
            : EthereumClient(url: URL(string: "https://polygon-mumbai.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0")!)
//        case .avalanche:
//            return isProduction
//            ? EthereumClient(url: URL(string: "https://mainnet.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0")!)
//            : EthereumClient(url: URL(string: "https://rinkeby.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0")!)
        default:
            return EthereumClient(url: URL(string: "https://mainnet.infura.io/v3/b2f4b3f635d8425c96854c3d28ba6bb0")!)
        }
    }

    func explorerURL(type: ExplorerURLType) -> URL? {
        switch self {
        case .ethereum:
            switch type {
            case let .txhash(hash):
                return isProduction
                ? URL(string: "https://etherscan.io/tx/\(hash)")
                : URL(string: "https://rinkeby.etherscan.io/tx/\(hash)")
            case let .address(address):
                return isProduction
                ? URL(string: "https://etherscan.io/address/\(address)")
                : URL(string: "https://rinkeby.etherscan.io/address/\(address)")
            }
        case .bsc:
            switch type {
            case let .txhash(hash):
                return isProduction
                ? URL(string: "https://bscscan.com/tx/\(hash)")
                : URL(string: "https://testnet.bscscan.com/tx/\(hash)")
            case let .address(address):
                return isProduction
                ? URL(string: "https://bscscan.com/address/\(address)")
                : URL(string: "https://testnet.bscscan.com/address/\(address)")
            }
        case .polygon:
            switch type {
            case let .txhash(hash):
                return isProduction
                ? URL(string: "https://polygonscan.com/tx/\(hash)")
                : URL(string: "https://mumbai.polygonscan.com/tx/\(hash)")
            case let .address(address):
                return isProduction
                ? URL(string: "https://polygonscan.com/address/\(address)")
                : URL(string: "https://mumbai.polygonscan.com/address/\(address)")
            }
        case .avalanche:
            switch type {
            case let .txhash(hash):
                return isProduction
                ? URL(string: "https://snowtrace.io/tx/\(hash)")
                : URL(string: "https://testnet.snowtrace.io/tx/\(hash)")
            case let .address(address):
                return isProduction
                ? URL(string: "https://snowtrace.io/address/\(address)")
                : URL(string: "https://testnet.snowtrace.io/address/\(address)")
            }
        }
    }

}
