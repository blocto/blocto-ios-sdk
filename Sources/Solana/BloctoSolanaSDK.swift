//
//  BloctoSolanaSDK.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/15.
//

import Foundation

extension BloctoSDK {
    
    public var solana: BloctoSolanaSDK {
        BloctoSolanaSDK(base: self)
    }
    
}

public class BloctoSolanaSDK {
    
    private let base: BloctoSDK
    
    init(base: BloctoSDK) {
        self.base = base
    }
    
    public func requestAccount(completion: @escaping (Result<String, Swift.Error>) -> Void) {
        let method = RequestAccountMethod(blockchain: .solana, callback: completion)
        base.send(method: method)
    }
    
}
