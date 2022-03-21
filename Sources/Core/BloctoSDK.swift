//
//  BloctoSDK.swift
//  Alamofire
//
//  Created by Andrew Wang on 2022/3/10.
//

import UIKit

public class BloctoSDK {
    
    public static let shared: BloctoSDK = BloctoSDK()

#if DEBUG
    let bloctoAssociatedDomainWithPath: String = "https://staging.blocto.app/"
#else
    let bloctoAssociatedDomainWithPath: String = "https://blocto.app/"
#endif
    let requestPath: String = "sdk"
    let responseHost: String = "blocto"
    
    var requestBloctoAssociatedDomainWithPath: String {
        bloctoAssociatedDomainWithPath + requestPath
    }
    
    var appId: String = ""
    var logging: Bool = true
    var uuidToMethod: [UUID: Method] = [:]

    public func initialize(with appId: String, logging: Bool = true) {
        self.appId = appId
        self.logging = logging
    }
    
    public func `continue`(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else {
            log(message: "webpageURL not found.")
            return
        }
        resolve(url: url)
    }
    
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) {
        resolve(url: url)
    }

    public func send(method: Method) -> Void {
        do {
            try checkConfigration()
            guard let requestURL = try method.encodeToURL(domainWithPath: requestBloctoAssociatedDomainWithPath) else {
                method.handleError(error: InternalError.encodeToURLFailed)
                return
            }
            uuidToMethod[method.id] = method
            UIApplication.shared.open(
                requestURL,
                options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true],
                completionHandler: { [weak self] opened in
                    if opened {
                        self?.log(message: "open universal link successfully.")
                    } else {
                        self?.log(message: "can't open universal link.")
                    }
                })
        } catch {
            method.handleError(error: error)
        }
    }

    internal func checkConfigration() throws {
        guard appId.isEmpty == false else { throw InternalError.appIdNotSet }
    }
    
    internal func log(message: String) {
        guard logging else { return }
        print(message)
    }

    private func resolve(url: URL) {
        guard url.host == responseHost else { return }
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            log(message: "urlComponents not found.")
            return
        }
        guard let uuid = urlComponents.getRequestId() else {
            log(message: "\(QueryName.requestId.rawValue) not found.")
            return
        }
        guard let method = uuidToMethod[uuid] else {
            log(message: "\(QueryName.method.rawValue) not found.")
            return
        }
        method.resolve(components: urlComponents)
    }

    private func routeToWebSDK(requstURL: URL) {
        // TODO: routeToWebSDK
    }

}
