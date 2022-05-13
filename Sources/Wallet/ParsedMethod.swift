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
    public let methodContentType: MethodContentType

    public init?(param: [String: String]) {
        guard let appId = param[QueryName.appId.rawValue] else { return nil }
        self.appId = appId

        guard let requestId = param[QueryName.requestId.rawValue] else { return nil }
        self.requestId = requestId

        guard let rawBlockchain = param[QueryName.blockchain.rawValue],
              let blockchain = Blockchain(rawValue: rawBlockchain) else { return nil }
        self.blockchain = blockchain

        guard let rawMethod = param[QueryName.method.rawValue],
              let method = MethodType(rawValue: rawMethod) else { return nil }
        switch method {
        case .requestAccount:
            self.methodContentType = .requestAccount
        case .signMessage:
            guard let from = param[QueryName.from.rawValue],
                  let message = param[QueryName.message.rawValue],
                  let rawSignType = param[QueryName.signType.rawValue],
                  let signType = SignType(rawValue: rawSignType) else { return nil }
            self.methodContentType = .signMessage(
                from: from,
                message: message,
                signType: signType)
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

            self.methodContentType = .signAndSendTransaction(
                from: from,
                isInvokeWrapped: isInvokeWrapped,
                transactionInfo: SolanaTransactionInfo(
                    message: message,
                    appendTx: appendTx,
                    publicKeySignaturePairs: publicKeySignaturePairs))
        case .sendTransaction:
            guard let from = param[QueryName.from.rawValue],
                  let to = param[QueryName.to.rawValue],
                  let value = param[QueryName.value.rawValue],
                  let dataString = param[QueryName.data.rawValue] else { return nil }
            self.methodContentType = .sendTransaction(
                transaction: EVMBaseTransaction(
                    to: to,
                    from: from,
                    value: BigUInt(value, radix: 16) ?? 0,
                    data: dataString.hexDecodedData))
        }
    }

}

extension ParsedMethod {

    init(
        appId: String,
        requestId: String,
        blockchain: Blockchain,
        methodContentType: MethodContentType
    ) {
        self.appId = appId
        self.requestId = requestId
        self.blockchain = blockchain
        self.methodContentType = methodContentType
    }

}
