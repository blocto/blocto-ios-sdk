//
//  BloctoSDK.swift
//  Alamofire
//
//  Created by Andrew Wang on 2022/3/10.
//

import UIKit
import AuthenticationServices

public class BloctoSDK {
    
    public static let shared: BloctoSDK = BloctoSDK()

#if DEBUG
    let bloctoAssociatedDomain: String = "https://staging.blocto.app/"
#else
    let bloctoAssociatedDomain: String = "https://blocto.app/"
#endif
    let webBaseURLString: String = "https://sdk.blocto.app/"
    let requestPath: String = "sdk"
    let responsePath: String = "/blocto"
    let responseHost: String = "blocto"
    
    var requestBloctoBaseURLString: String {
        bloctoAssociatedDomain + requestPath
    }
    
    var webRequestBloctoBaseURLString: String {
        webBaseURLString + requestPath
    }
    
    var webCallbackURLScheme: String {
        "blocto"
    }
    
    var uuidToMethod: [UUID: Method] = [:]

    var appId: String = ""
    var window: UIWindow = UIWindow()
    var logging: Bool = true
    var urlOpening: URLOpening = UIApplication.shared
    var sessioningType: AuthenticationSessioning.Type = ASWebAuthenticationSession.self
    
    /// initialize Blocto SDK
    /// - Parameters:
    ///   - appId: Registed id in https://developers.blocto.app/
    ///   - window: PresentationContextProvider of web SDK authentication.
    ///   - logging: Enabling log message, default is true.
    ///   - urlOpening: Handling url which opened app, default is UIApplication.shared.
    ///   - sessioningType: Type that handles web SDK authentication session, default is ASWebAuthenticationSession.
    public func initialize(
        with appId: String,
        window: UIWindow,
        logging: Bool = true,
        urlOpening: URLOpening = UIApplication.shared,
        sessioningType: AuthenticationSessioning.Type = ASWebAuthenticationSession.self
    ) {
        self.appId = appId
        self.window = window
        self.logging = logging
        self.urlOpening = urlOpening
        self.sessioningType = sessioningType
    }
    
    public func `continue`(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else {
            log(message: "webpageURL not found.")
            return
        }
        methodResolve(expectHost: responseHost, url: url)
    }
    
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) {
        guard url.path == responsePath else {
            log(message: "url path should be \(responsePath) rather than \(url.path).")
            return
        }
        methodResolve(url: url)
    }

    public func send(method: Method) -> Void {
        do {
            try checkConfigration()
            guard let requestURL = try method.encodeToURL(baseURLString: requestBloctoBaseURLString) else {
                method.handleError(error: InternalError.encodeToURLFailed)
                return
            }
            uuidToMethod[method.id] = method
            urlOpening.open(
                requestURL,
                options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true],
                completionHandler: { [weak self] opened in
                    guard let self = self else { return }
                    if opened {
                        self.log(message: "open universal link successfully.")
                    } else {
                        self.log(message: "can't open universal link.")
                        self.routeToWebSDK(window: self.window, method: method)
                    }
                })
        } catch {
            method.handleError(error: error)
            routeToWebSDK(window: window, method: method)
        }
    }

    internal func checkConfigration() throws {
        guard appId.isEmpty == false else { throw InternalError.appIdNotSet }
    }
    
    internal func log(message: String) {
        guard logging else { return }
        print(message)
    }

    private func routeToWebSDK(
        window: UIWindow,
        method: Method
    ) {
        do {
            guard let requestURL = try method.encodeToURL(baseURLString: webRequestBloctoBaseURLString) else {
                method.handleError(error: InternalError.encodeToURLFailed)
                return
            }
            var session: AuthenticationSessioning?
            
            session = sessioningType.init(
                url: requestURL,
                callbackURLScheme: webCallbackURLScheme,
                completionHandler: { [weak self] callbackURL, error in
                    guard let self = self else { return }
                    if let error = error {
                        self.log(message: error.localizedDescription)
                    } else if let callbackURL = callbackURL {
                        self.methodResolve(expectHost: nil, url: callbackURL)
                    } else {
                        self.log(message: "callback URL not found.")
                    }
                    session = nil
                })
            
            session?.presentationContextProvider = window
            
            let startsSuccessfully = session?.start()
            if startsSuccessfully == false {
                method.handleError(error: InternalError.webSDKSessionFailed)
            }
        } catch {
            method.handleError(error: error)
        }
    }
    
    private func methodResolve(
        expectHost: String? = nil,
        url: URL
    ) {
        if let expectHost = expectHost {
            guard url.host == expectHost else {
                log(message: "\(url.host ?? "host is nil") should be \(expectHost)")
                return
            }
        }
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

}

extension UIWindow: ASWebAuthenticationPresentationContextProviding {

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self
    }

}
