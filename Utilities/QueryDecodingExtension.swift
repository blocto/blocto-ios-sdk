//
//  QueryDecodingExtension.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/8/2.
//

import Foundation

public extension QueryDecoding {

    static func decodeFlowTransactionInfo(param: [String: String]) throws -> FlowTransactionInfo {
        
        let dic: [String: String] = decodeDictionary(
            param: param,
            queryName: .flowTransactionInfo
        )
        
        guard let script = dic[QueryName.script.rawValue],
              let arguments = dic[QueryName.arguments.rawValue],
              let rawPayload = dic[QueryName.rawPayload.rawValue],
              let hash = dic[QueryName.payloadHash.rawValue],
              let address = dic[QueryName.address.rawValue],
              let title = dic[QueryName.appTitle.rawValue],
              let imageURLString = dic[QueryName.appImageURLString.rawValue],
              let urlString = dic[QueryName.appSiteURLString.rawValue] else {
            
        }
        
        FlowTransactionInfo(
            script: dic[""],
            arguments: <#T##[String]#>,
            rawPayload: <#T##String#>,
            hash: <#T##String#>,
            address: <#T##String#>,
            title: <#T##String#>,
            imageURLString: <#T##String#>,
            urlString: <#T##String?#>
        )
    }

}
