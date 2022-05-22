//
//  RequestAccounting.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/5/13.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import BloctoSDK

protocol EVMBaseSDKProvider {

    func requestAccount(completion: @escaping (Result<String, Swift.Error>) -> Void)

    func signMessage(
        uuid: UUID,
        from: String,
        message: String,
        signType: EVMBaseSignType,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    )

    func sendTransaction(
        uuid: UUID,
        transaction: EVMBaseTransaction,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    )

}

extension EVMBaseSDKProvider {

    func signMessage(
        from: String,
        message: String,
        signType: EVMBaseSignType,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        signMessage(
            uuid: UUID(),
            from: from,
            message: message,
            signType: signType,
            completion: completion)
    }

    func sendTransaction(
        transaction: EVMBaseTransaction,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        sendTransaction(
            uuid: UUID(),
            transaction: transaction,
            completion: completion)
    }

}

extension BloctoEthereumSDK: EVMBaseSDKProvider {}

extension BloctoBSCSDK: EVMBaseSDKProvider {}

extension BloctoPolygonSDK: EVMBaseSDKProvider {}

extension BloctoAvalancheSDK: EVMBaseSDKProvider {}
