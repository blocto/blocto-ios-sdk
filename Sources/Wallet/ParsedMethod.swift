//
//  ParsedMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/29.
//

import Foundation
import BigInt
import FlowSDK

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
                self.methodContentType = .solana(SolanaMethodContentType.requestAccount)
            case .signAndSendTransaction:
                guard let from = param[QueryName.from.rawValue],
                      let message = param[QueryName.message.rawValue],
                      let isInvokeWrappedString = param[QueryName.isInvokeWrapped.rawValue],
                      let isInvokeWrapped = Bool(isInvokeWrappedString) else { return nil }

                let appendTx: [String: Data] = QueryDecoding.decodeDictionary(
                    param: param,
                    queryName: .appendTx
                )

                let publicKeySignaturePairs: [String: String] = QueryDecoding.decodeDictionary(
                    param: param,
                    queryName: .publicKeySignaturePairs
                )

                self.methodContentType = .solana(
                    SolanaMethodContentType.signAndSendTransaction(
                        from: from,
                        isInvokeWrapped: isInvokeWrapped,
                        transactionInfo: .init(
                            message: message,
                            appendTx: appendTx,
                            publicKeySignaturePairs: publicKeySignaturePairs
                        )
                    ))
            }
        case .ethereum,
             .binanceSmartChain,
             .polygon,
             .avalanche:
            guard let methodType = EVMBaseMethodType(rawValue: rawMethod) else { return nil }
            switch methodType {
            case .requestAccount:
                self.methodContentType = .evmBase(.requestAccount)
            case .signMessage:
                guard let from = param[QueryName.from.rawValue],
                      let message = param[QueryName.message.rawValue],
                      let rawSignType = param[QueryName.signType.rawValue],
                      let signType = EVMBaseSignType(rawValue: rawSignType) else { return nil }
                let removingPercentEncodingString = message.removingPercentEncoding ?? message
                let messageString = removingPercentEncodingString.bloctoSDK.hexConvertToString()
                self.methodContentType = .evmBase(
                    .signMessage(
                        from: from,
                        message: messageString,
                        signType: signType
                    ))
            case .sendTransaction:
                guard let from = param[QueryName.from.rawValue],
                      let to = param[QueryName.to.rawValue],
                      let value = param[QueryName.value.rawValue],
                      let dataString = param[QueryName.data.rawValue] else { return nil }
                self.methodContentType = .evmBase(
                    .sendTransaction(
                        transaction: EVMBaseTransaction(
                            to: to,
                            from: from,
                            value: BigUInt(value.bloctoSDK.drop0x, radix: 16) ?? 0,
                            data: dataString
                                .bloctoSDK.drop0x
                                .bloctoSDK.hexDecodedData
                        )))
            }
        case .flow:
            guard let methodType = FlowMethodType(rawValue: rawMethod) else { return nil }
            switch methodType {
            case .requestAccount:
                self.methodContentType = .flow(
                    .authenticate(
                        accountProofData: nil
                    )
                )
            case .authenticate:
                var accountProofData: FlowAccountProofData?
                if let accountProofAppId = param[QueryName.flowAppId.rawValue],
                   let nonce = param[QueryName.flowNonce.rawValue] {
                    accountProofData = FlowAccountProofData(
                        appId: accountProofAppId.removingPercentEncoding ?? accountProofAppId,
                        nonce: nonce
                    )
                }

                self.methodContentType = .flow(
                    .authenticate(
                        accountProofData: accountProofData
                    )
                )
            case .userSignature:
                guard let from = param[QueryName.from.rawValue],
                      let message = param[QueryName.message.rawValue] else { return nil }
                let removingPercentEncodingString = message.removingPercentEncoding ?? message

                self.methodContentType = .flow(
                    .userSignature(from: from, message: removingPercentEncodingString)
                )
            case .sendTransaction:
                guard let from = param[QueryName.from.rawValue],
                      let transactionDataHex = param[QueryName.flowTransaction.rawValue] else { return nil }

                guard let transaction = try? Transaction(rlpData: transactionDataHex.bloctoSDK.hexDecodedData) else {
                    return nil
                }

                self.methodContentType = .flow(
                    .sendTransaction(from: from, transaction: transaction)
                )
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
