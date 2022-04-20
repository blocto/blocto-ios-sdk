//
//  RoutingInfo.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/20.
//

import Foundation

public struct RoutingInfo {

    public let appId: String

    public let requestId: String

    public let methodContentType: CallbackMethodContentType

    public let baseURLString: String
    
    public init(
        appId: String,
        requestId: String,
        methodContentType: CallbackMethodContentType,
        baseURLString: String
    ) {
        self.appId = appId
        self.requestId = requestId
        self.methodContentType = methodContentType
        self.baseURLString = baseURLString
    }

}
