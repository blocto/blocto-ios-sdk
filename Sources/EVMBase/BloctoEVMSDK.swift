//
//  BloctoEVMSDK.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2023/5/9.
//

import Foundation

private var associateKey: Void?

extension BloctoSDK {

    public var evm: BloctoEVMSDK {
        if let evmSDK = objc_getAssociatedObject(self, &associateKey) as? BloctoEVMSDK {
            return evmSDK
        } else {
            let evmSDK = BloctoEVMSDK(base: self)
            objc_setAssociatedObject(self, &associateKey, evmSDK, .OBJC_ASSOCIATION_RETAIN)
            return evmSDK
        }
    }

}

public class BloctoEVMSDK {

    private let base: BloctoSDK
    private var sessionId: String?

    init(base: BloctoSDK) {
        self.base = base
    }

    /// To request EVM base blockchain account address
    /// - Parameters:
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    ///   The successful result is address String for Ethereum.
    public func requestAccount(
        uuid: UUID = UUID(),
        blockchain: Blockchain,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        let method = RequestAccountMethod(
            id: uuid,
            blockchain: blockchain,
            callback: { [weak self] result in
                switch result {
                case let .success((address, sessionId)):
                    self?.sessionId = sessionId
                    completion(.success(address))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        )
        base.send(method: method)
    }

    /// To sign a message
    /// - Parameters:
    ///   - uuid: The id to identify this request, you can pass your owned uuid here.
    ///   - blockchain: Blockchain used to sign message.
    ///   - from: send from which address.
    ///   - message: message needs to be sign in String format.
    ///   - signType: pre-defined signTypes in BloctoSDK/EVMBase
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    public func signMessage(
        uuid: UUID = UUID(),
        blockchain: Blockchain,
        from: String,
        message: String,
        signType: EVMBaseSignType,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        let method = SignEVMBaseMessageMethod(
            id: uuid,
            sessionId: sessionId,
            from: from,
            message: message,
            signType: signType,
            blockchain: blockchain,
            callback: completion
        )
        base.send(method: method)
    }

    /// To sign a transaction and then send a transaction
    /// - Parameters:
    ///   - uuid: The id to identify this request, you can pass your owned uuid here.
    ///   - transaction: Custom type EVMBaseTransaction.
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    ///   The successful result is Tx hash of Ethereum.
    public func sendTransaction(
        uuid: UUID = UUID(),
        blockchain: Blockchain,
        transaction: EVMBaseTransaction,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        let method = SendEVMBasedTransactionMethod(
            id: uuid,
            sessionId: sessionId,
            blockchain: blockchain,
            transaction: transaction,
            callback: completion
        )
        base.send(method: method)
    }

}
