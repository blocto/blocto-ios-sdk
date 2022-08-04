//
//  BloctoFlowSDK.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/7/7.
//

import Foundation
import FlowSDK
import Cadence

private var associateKey: Void?

extension BloctoSDK {

    public var flow: BloctoFlowSDK {
        if let flowSDK = objc_getAssociatedObject(self, &associateKey) as? BloctoFlowSDK {
            return flowSDK
        } else {
            let flowSDK = BloctoFlowSDK(base: self)
            objc_setAssociatedObject(self, &associateKey, flowSDK, .OBJC_ASSOCIATION_RETAIN)
            return flowSDK
        }
    }

}

public class BloctoFlowSDK {

    private let base: BloctoSDK

    init(base: BloctoSDK) {
        self.base = base
    }

    /// Ask for User's authantication to request Flow account address
    /// - Parameters:
    ///   - id: The id to identify this request, you can pass your owned uuid here.
    ///   - accountProofData: accountProofData to be sign along with authantication
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    /// - Completion: The successful result is a tuple of address String with accountProof for Flow.
    public func authanticate(
        id: UUID = UUID(),
        accountProofData: FlowAccountProofData?,
        completion: @escaping (Result<(address: String, accountProof: [FlowCompositeSignature]), Swift.Error>) -> Void
    ) {
        let method = AuthenticateMethod(
            id: id,
            accountProofData: accountProofData,
            callback: completion
        )
        base.send(method: method)
    }

    /// To sign Flow message
    /// - Parameters:
    ///   - uuid: The id to identify this request, you can pass your owned uuid here.
    ///   - from: send from which address.
    ///   - message: message needs to be sign in String format.
    ///   - signType: pre-defined signType in BloctoSDK/EVMBase
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    public func signMessage(
        uuid: UUID = UUID(),
        from: String,
        message: String,
        completion: @escaping (Result<[FlowCompositeSignature], Swift.Error>) -> Void
    ) {
        let method = SignFlowMessageMethod(
            id: uuid,
            from: from,
            message: message,
            callback: completion
        )
        base.send(method: method)
    }

    /// To sign Flow transaction and then send transaction.
    /// - Parameters:
    ///   - uuid: The id to identify this request, you can pass your owned uuid here.
    ///   - from: Send from which address.
    ///   - transaction: Pre-defined Flow Transaction.
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    ///   The successful result is Tx hash of Flow.
    public func sendTransaction(
        uuid: UUID = UUID(),
        from: Cadence.Address,
        transaction: Transaction,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        guard let scriptString = String(data: transaction.script, encoding: .utf8) else {
            completion(.failure(InternalError.flowScriptInvalid))
            return
        }
        var message = DomainTag.transaction.rightPaddedData
        message.append(transaction.payloadMessage())
        let payloadHash = message.sha3(.sha256).bloctoSDK.hexString
        let transactionInfo = FlowTransactionInfo(
            script: scriptString,
            arguments: transaction.arguments.map(\.bloctoSDK.hexString),
            rawPayload: transaction.payloadMessage().bloctoSDK.hexString,
            hash: payloadHash,
            address: from.hexStringWithPrefix,
            gasLimit: transaction.gasLimit
        )
        let method = SendFlowTransactionMethod(
            id: uuid,
            from: from,
            transactionInfo: transactionInfo,
            callback: completion
        )
        base.send(method: method)
    }

}
