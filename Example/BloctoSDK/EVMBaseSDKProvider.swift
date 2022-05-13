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

    func sendTransaction(
        uuid: UUID,
        blockchain: Blockchain,
        transaction: EVMBaseTransaction,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    )

}

extension EVMBaseSDKProvider {

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

extension BloctoEthereumSDK: EVMBaseSDKProvider {}

extension BloctoBSCSDK: EVMBaseSDKProvider {}

extension BloctoPolygonSDK: EVMBaseSDKProvider {}

extension BloctoAvalancheSDK: EVMBaseSDKProvider {}
