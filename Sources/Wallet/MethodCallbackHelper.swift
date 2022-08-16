//
//  MethodCallbackHelper.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/11.
//

import Foundation

public enum MethodCallbackHelper {

    public static func sendBack(
        urlOpening: URLOpening,
        routingInfo: RoutingInfo,
        completion: @escaping (_ opened: Bool) -> Void
    ) {
        guard routingInfo.baseURLString.isEmpty == false else {
            completion(false)
            return
        }
        var components = URLComponents(string: routingInfo.baseURLString)
        components?.path = responsePath
        var items = queryItems(from: routingInfo.methodContentType)
        items.append(.init(name: .requestId, value: routingInfo.requestId))
        components?.queryItems = items
        guard let components = components else {
            log(
                enable: true,
                message: "components not found."
            )
            completion(false)
            return
        }
        guard let openURL = components.url else {
            log(
                enable: true,
                message: "components's url not found."
            )
            completion(false)
            return
        }
        urlOpening.open(
            openURL,
            options: [.universalLinksOnly: true]
        ) { opened in
            if opened {
                completion(true)
            } else {
                openWithCustomScheme(
                    urlOpening: urlOpening,
                    appId: routingInfo.appId,
                    urlComponents: components,
                    completion: completion
                )
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
        components.host = ""
        components.path = ""
        guard let openURL = components.url else {
            log(
                enable: true,
                message: "components's url not found."
            )
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
                    message: "opened with custom scheme \(openURL)."
                )
                completion(true)
                return
            } else {
                log(
                    enable: true,
                    message: "can't open with custom scheme \(openURL)."
                )
                completion(false)
                return
            }
        }
    }

    static func queryItems(from methodContentType: CallbackMethodContentType) -> [URLQueryItem] {
        switch methodContentType {
        case let .requestAccount(address):
            return [
                .init(name: .address, value: address),
            ]
        case let .signMessage(signature):
            return [
                .init(name: .signature, value: signature),
            ]
        case let .signAndSendTransaction(txHash):
            return [
                .init(name: .txHash, value: txHash),
            ]
        case let .authanticate(address, accountProof):
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: .address, value: address)
            ]
            if accountProof.isEmpty == false {
                let accountProofItems = accountProof.enumerated().flatMap {
                    [
                        URLQueryItem(
                            name: QueryName.accountProof.rawValue + "[\(String($0))]" + "[\(QueryName.address.rawValue)]",
                            value: $1.address
                        ),
                        URLQueryItem(
                            name: QueryName.accountProof.rawValue + "[\(String($0))]" + "[\(QueryName.keyId.rawValue)]",
                            value: String($1.keyId)
                        ),
                        URLQueryItem(
                            name: QueryName.accountProof.rawValue + "[\(String($0))]" + "[\(QueryName.signature.rawValue)]",
                            value: $1.signature
                        ),
                    ]
                }
                queryItems.append(contentsOf: accountProofItems)
            }
            return queryItems
        case let .flowSignMessage(signatures):
            let queryItems: [URLQueryItem] = signatures.enumerated().flatMap {
                [
                    URLQueryItem(
                        name: QueryName.userSignature.rawValue + "[\(String($0))]" + "[\(QueryName.address.rawValue)]",
                        value: $1.address
                    ),
                    URLQueryItem(
                        name: QueryName.userSignature.rawValue + "[\(String($0))]" + "[\(QueryName.keyId.rawValue)]",
                        value: String($1.keyId)
                    ),
                    URLQueryItem(
                        name: QueryName.userSignature.rawValue + "[\(String($0))]" + "[\(QueryName.signature.rawValue)]",
                        value: $1.signature
                    ),
                ]
            }
            return queryItems
        case let .error(error):
            return [
                .init(name: .error, value: error.rawValue),
            ]
        }
    }

}
