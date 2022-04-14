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
        appId: String,
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
        components?.queryItems = queryItems(from: methodContentType)
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
            if opened {
                completion(true)
            } else {
                openWithCustomScheme(
                    urlOpening: urlOpening,
                    appId: appId,
                    urlComponents: components,
                    completion: completion)
            }
        }
    }
    
    static func openWithCustomScheme(
        urlOpening: URLOpening,
        appId: String,
        urlComponents: URLComponents,
        completion: @escaping (_ opened: Bool) -> Void
    ) {
        var components = urlComponents
        components.scheme = customScheme(appId: appId)
        components.host = nil
        components.path = ""
        guard let openURL = components.url else {
            log(
                enable: true,
                message: "components's url not found.")
            completion(false)
            return
        }
        urlOpening.open(
            openURL,
            options: [:]
        ) { opened in
            if opened {
                log(
                    enable: true,
                    message: "opened with custom scheme \(openURL).")
                completion(true)
                return
            } else {
                log(
                    enable: true,
                    message: "can't open with custom scheme \(openURL).")
                completion(false)
                return
            }
        }
    }

    static func queryItems(from methodContentType: CallbackMethodContentType) -> [URLQueryItem] {
        switch methodContentType {
            case let .requestAccount(requestId, address):
                return [
                    .init(name: .requestId, value: requestId),
                    .init(name: .address, value: address)
                ]
            case let .signMessage(requestId, signature):
                return [
                    .init(name: .requestId, value: requestId),
                    .init(name: .signature, value: signature)
                ]
            case let .signAndSendTransaction(requestId, txHash):
                return [
                    .init(name: .requestId, value: requestId),
                    .init(name: .txHash, value: txHash)
                ]
            case let .error(requestId, error):
                return [
                    .init(name: .requestId, value: requestId),
                    .init(name: .error, value: error.rawValue)
                ]
        }
    }

}
