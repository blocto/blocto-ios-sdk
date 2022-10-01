//
//  BloctoAvalancheSDK.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/5/13.
//

import Foundation

private var associateKey: Void?

extension BloctoSDK {

    public var avalanche: BloctoAvalancheSDK {
        if let avalancheSDK = objc_getAssociatedObject(self, &associateKey) as? BloctoAvalancheSDK {
            return avalancheSDK
        } else {
            let avalancheSDK = BloctoAvalancheSDK(base: self)
            objc_setAssociatedObject(self, &associateKey, avalancheSDK, .OBJC_ASSOCIATION_RETAIN)
            return avalancheSDK
        }
    }

}

public class BloctoAvalancheSDK {

    private let base: BloctoSDK

    init(base: BloctoSDK) {
        self.base = base
    }

    /// To request Avalanche account address
    /// - Parameters:
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    ///   The successful result is address String for Avalanche.
    public func requestAccount(completion: @escaping (Result<String, Swift.Error>) -> Void) {
        let method = RequestAccountMethod(blockchain: .avalanche, callback: completion)
        #if canImport(UIKit)
        base.send(method: method)
        #endif
    }

    /// To sign message
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
        signType: EVMBaseSignType,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        let method = SignEVMBaseMessageMethod(
            id: uuid,
            from: from,
            message: message,
            signType: signType,
            blockchain: .avalanche,
            callback: completion
        )
        #if canImport(UIKit)
        base.send(method: method)
        #endif
    }

    /// To sign transaction and then send transaction
    /// - Parameters:
    ///   - uuid: The id to identify this request, you can pass your owned uuid here.
    ///   - transaction: Custom type EVMBaseTransaction.
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    ///   The successful result is Tx hash of Avalanche.
    public func sendTransaction(
        uuid: UUID = UUID(),
        transaction: EVMBaseTransaction,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        let method = SendEVMBasedTransactionMethod(
            id: uuid,
            blockchain: .avalanche,
            transaction: transaction,
            callback: completion
        )
        #if canImport(UIKit)
        base.send(method: method)
        #endif
    }

}
