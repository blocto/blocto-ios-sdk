//
//  URLComponents.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/7/7.
//

import Foundation

extension URLComponents {

    func getSignatures(type: FlowSignatureType) -> [FlowCompositeSignature] {
        let keyword: String
        switch type {
        case .accountProof:
            keyword = QueryName.accountProof.rawValue
        case .userSignature:
            keyword = QueryName.userSignature.rawValue
        }
        let items = queryItems?.filter { $0.name.contains(keyword) } ?? []
        let dic = items.reduce([String: String]()) {
            var result = $0
            result[$1.name.removingPercentEncoding ?? $1.name] = $1.value
            return result
        }
        precondition(items.count % 3 == 0, "AcountProof query item should be multiple of 3.")
        let signatureCount = items.count / 3
        if signatureCount > 0 {
            var result: [FlowCompositeSignature] = []
            for index in 0 ... (signatureCount - 1) {
                if let address = dic[keyword + "[\(index)]" + "[\(QueryName.address.rawValue)]"],
                   let keyIdString = dic[keyword + "[\(index)]" + "[\(QueryName.keyId.rawValue)]"],
                   let keyId = Int(keyIdString),
                   let signature = dic[keyword + "[\(index)]" + "[\(QueryName.signature.rawValue)]"] {
                    result.append(
                        FlowCompositeSignature(
                            address: address,
                            keyId: keyId,
                            signature: signature
                        )
                    )
                }
            }
            precondition(result.count == signatureCount, "AcountProof query item should be multiple of 3.")
            return result
        } else {
            return []
        }
    }

}
