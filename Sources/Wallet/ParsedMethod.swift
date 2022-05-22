//
//  ParsedMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/29.
//

import Foundation
import BigInt

public struct ParsedMethod {

    public let appId: String
    public let requestId: String
    public let blockchain: Blockchain
    public let methodContentType: GeneralMethodContentType

    public init?(param: [String: String]) {
        guard let appId = param[QueryName.appId.rawValue] else { return nil }
        self.appId = appId

        guard let requestId = param[QueryName.requestId.rawValue] else { return nil }
        self.requestId = requestId

        guard let rawBlockchain = param[QueryName.blockchain.rawValue],
              let blockchain = Blockchain(rawValue: rawBlockchain) else { return nil }
        self.blockchain = blockchain

        guard let rawMethod = param[QueryName.method.rawValue] else { return nil }

        switch blockchain {
        case .solana:
            guard let methodType = SolanaMethodType(rawValue: rawMethod) else { return nil }
            switch methodType {
            case .requestAccount:
                methodContentType = .solana(SolanaMethodContentType.requestAccount)
            case .signAndSendTransaction:
                guard let from = param[QueryName.from.rawValue],
                      let message = param[QueryName.message.rawValue],
                      let isInvokeWrappedString = param[QueryName.isInvokeWrapped.rawValue],
                      let isInvokeWrapped = Bool(isInvokeWrappedString) else { return nil }

                let appendTx: [String: Data] = QueryDecoding.decodeDictionary(
                    param: param,
                    queryName: .appendTx)

                let publicKeySignaturePairs: [String: String] = QueryDecoding.decodeDictionary(
                    param: param,
                    queryName: .publicKeySignaturePairs)

                methodContentType = .solana(
                    SolanaMethodContentType.signAndSendTransaction(
                        from: from,
                        isInvokeWrapped: isInvokeWrapped,
                        transactionInfo: .init(
                            message: message,
                            appendTx: appendTx,
                            publicKeySignaturePairs: publicKeySignaturePairs)))
            }
        case .ethereum,
                .binanceSmartChain,
                .polygon,
                .avalanche:
            guard let methodType = EVMBaseMethodType(rawValue: rawMethod) else { return nil }
            switch methodType {
            case .requestAccount:
                methodContentType = .evmBase(.requestAccount)
            case .signMessage:
                guard let from = param[QueryName.from.rawValue],
                      let message = param[QueryName.message.rawValue],
                      let rawSignType = param[QueryName.signType.rawValue],
                      let signType = EVMBaseSignType(rawValue: rawSignType) else { return nil }
                methodContentType = .evmBase(
                    .signMessage(
                        from: from,
                        message: message.removingPercentEncoding ?? message,
                        signType: signType))
            case .sendTransaction:
                guard let from = param[QueryName.from.rawValue],
                      let to = param[QueryName.to.rawValue],
                      let value = param[QueryName.value.rawValue],
                      let dataString = param[QueryName.data.rawValue] else { return nil }
                methodContentType = .evmBase(
                    .sendTransaction(
                        transaction: EVMBaseTransaction(
                            to: to,
                            from: from,
                            value: BigUInt(value, radix: 16) ?? 0,
                            data: dataString.hexDecodedData)))
            }
        }
    }

}

extension ParsedMethod {

    init(
        appId: String,
        requestId: String,
        blockchain: Blockchain,
        methodContentType: GeneralMethodContentType
    ) {
        self.appId = appId
        self.requestId = requestId
        self.blockchain = blockchain
        self.methodContentType = methodContentType
    }

}
