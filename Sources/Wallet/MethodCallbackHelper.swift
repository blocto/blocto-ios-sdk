//
//  MethodCallbackHelper.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/11.
//

import Foundation

public class MethodCallbackHelper {

    static public func sendBack(
        urlOpening: URLOpening,
        requestId: String,
        methodContentType: CallbackMethodContentType,
        baseURLString: String,
        completion: @escaping (_ opened: Bool) -> Void
    ) {
        guard baseURLString.isEmpty == false else {
            completion(false)
            return
        }
        var components = URLComponents(string: baseURLString)
        components?.path = responsePath
        components?.queryItems = [
            .init(name: .requestId, value: requestId)
        ]
        components?.queryItems?.append(contentsOf: queryItems(from: methodContentType))
        guard let components = components else {
            log(
                enable: true,
                message: "components not found.")
            completion(false)
            return
        }
        guard let openURL = components.url else {
            log(
                enable: true,
                message: "components's url not found.")
            completion(false)
            return
        }
        urlOpening.open(
            openURL,
            options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true]
        ) { opened in
            completion(opened)
        }
    }

    static func queryItems(from methodContentType: CallbackMethodContentType) -> [URLQueryItem] {
        switch methodContentType {
            case let .requestAccount(address):
                return [
                    .init(name: .address, value: address)
                ]
            case let .signMessage(signature):
                return [
                    .init(name: .signature, value: signature)
                ]
            case let .signAndSendTransaction(txHash):
                return [
                    .init(name: .txHash, value: txHash)
                ]
        }
    }

}
