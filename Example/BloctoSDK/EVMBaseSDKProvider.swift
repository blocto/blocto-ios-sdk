//
//  RequestAccounting.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/5/13.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import BloctoSDK

protocol EVMBaseSDKProvider {

    func requestAccount(
        uuid: UUID,
        blockchain: Blockchain,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    )

    func signMessage(
        uuid: UUID,
        blockchain: Blockchain,
        from: String,
        message: String,
        signType: EVMBaseSignType,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    )

    func sendTransaction(
        uuid: UUID,
        blockchain: Blockchain,
        transaction: EVMBaseTransaction,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    )

}

extension EVMBaseSDKProvider {

    func signMessage(
        blockchain: Blockchain,
        from: String,
        message: String,
        signType: EVMBaseSignType,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        signMessage(
            uuid: UUID(),
            blockchain: blockchain,
            from: from,
            message: message,
            signType: signType,
            completion: completion)
    }

    func sendTransaction(
        blockchain: Blockchain,
        transaction: EVMBaseTransaction,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        sendTransaction(
            uuid: UUID(),
            blockchain: blockchain,
            transaction: transaction,
            completion: completion)
    }

}

extension BloctoEVMSDK: EVMBaseSDKProvider {}
