//
//  Request.swift
//  BloctoSDK
//
//  Created by Scott on 2022/1/20.
//

import Foundation

protocol Method {
    associatedtype Response

    typealias Callback = ((Result<Response, Error>) -> Void)

    var id: String { get }
    var callback: Callback { get }
}

struct GetAccountMethod: Method {

    typealias Response = String

    let id: String
    let callback: Callback

    let blockchain: Blockchain

    init(id: String = UUID().uuidString, callback: @escaping Callback, blockchain: Blockchain) {
        self.id = id
        self.callback = callback
        self.blockchain = blockchain
    }
}
