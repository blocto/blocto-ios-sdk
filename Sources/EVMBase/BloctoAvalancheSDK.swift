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
        get {
            if let avalancheSDK = objc_getAssociatedObject(self, &associateKey) as? BloctoAvalancheSDK {
                return avalancheSDK
            } else {
                let avalancheSDK = BloctoAvalancheSDK(base: self)
                objc_setAssociatedObject(self, &associateKey, avalancheSDK, .OBJC_ASSOCIATION_RETAIN)
                return avalancheSDK
            }
        }
    }

}

public class BloctoAvalancheSDK {

    private let base: BloctoSDK

    init(base: BloctoSDK) {
        self.base = base
    }

    /// To request Solana account address
    /// - Parameters:
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    ///   The successful result is address String for Solana.
    public func requestAccount(completion: @escaping (Result<String, Swift.Error>) -> Void) {
        let method = RequestAccountMethod(blockchain: .avalanche, callback: completion)
        base.send(method: method)
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
            callback: completion)
        base.send(method: method)
    }

}
