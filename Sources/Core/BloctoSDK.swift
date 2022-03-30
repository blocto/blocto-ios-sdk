//
//  BloctoSDK.swift
//  Alamofire
//
//  Created by Andrew Wang on 2022/3/10.
//

import UIKit
import AuthenticationServices

func log(enable: Bool, message: String) {
    guard enable else { return }
    print("BloctoSDK: " + message)
}

public class BloctoSDK {

    public static let shared: BloctoSDK = BloctoSDK()

#if DEBUG
    private let bloctoAssociatedDomain: String = "https://staging.blocto.app/"
#else
    private let bloctoAssociatedDomain: String = "https://blocto.app/"
#endif
    private let webBaseURLString: String = "https://wallet.blocto.app/sdk"
    private let requestPath: String = "sdk"
    private let responsePath: String = "/blocto"
    private let responseHost: String = "blocto"

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
            log(
                enable: logging,
                message: "webpageURL not found.")
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
            log(
                enable: logging,
                message: "url path should be \(responsePath) rather than \(url.path).")
            return
        }
        methodResolve(url: url)
    }

    public func send(method: Method) {
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
                        log(
                            enable: self.logging,
                            message: "open universal link successfully.")
                    } else {
                        log(
                            enable: self.logging,
                            message: "can't open universal link.")
                        self.routeToWebSDK(window: self.window, method: method)
                    }
                })
        } catch {
            method.handleError(error: error)
            routeToWebSDK(window: window, method: method)
        }
    }

    private func checkConfigration() throws {
        guard appId.isEmpty == false else { throw InternalError.appIdNotSet }
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
                        log(
                            enable: self.logging,
                            message: error.localizedDescription)
                    } else if let callbackURL = callbackURL {
                        self.methodResolve(expectHost: nil, url: callbackURL)
                    } else {
                        log(
                            enable: self.logging,
                            message: "callback URL not found.")
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
                log(
                    enable: logging,
                    message: "\(url.host ?? "host is nil") should be \(expectHost)")
                return
            }
        }
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            log(
                enable: logging,
                message: "urlComponents not found.")
            return
        }
        guard let uuid = urlComponents.getRequestId() else {
            log(
                enable: logging,
                message: "\(QueryName.requestId.rawValue) not found.")
            return
        }
        guard let method = uuidToMethod[uuid] else {
            log(
                enable: logging,
                message: "\(QueryName.method.rawValue) not found.")
            return
        }
        method.resolve(components: urlComponents, logging: logging)
    }

}
