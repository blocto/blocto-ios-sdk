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

let responsePath: String = "/blocto"
let responseScheme: String = "blocto"

func customScheme(appId: String) -> String {
    responseScheme + appId
}

public class BloctoSDK {

    public static let shared: BloctoSDK = BloctoSDK()

    var bloctoApiBaseURLString: String {
        switch environment {
        case .prod:
            return "https://api.blocto.app"
        case .dev:
            return "https://api-dev.blocto.app"
        }
    }

    private var bloctoAssociatedDomain: String {
        switch environment {
        case .prod:
            return "https://blocto.app/"
        case .dev:
            return "https://dev.blocto.app/"
        }
    }

    private var webBaseURLString: String {
        switch environment {
        case .prod:
            return "https://wallet.blocto.app/"
        case .dev:
            return "https://wallet-testnet.blocto.app/"
        }
    }

    private let requestPath: String = "sdk"

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

    private var getWindow: (() throws -> UIWindow)?

    var logging: Bool = true

    var environment: BloctoEnvironment = .prod

    var urlOpening: URLOpening = UIApplication.shared

    var sessioningType: AuthenticationSessioning.Type = ASWebAuthenticationSession.self

    /// initialize Blocto SDK
    /// - Parameters:
    ///   - appId: Registed id in https://developers.blocto.app/
    ///   - window: PresentationContextProvider of web SDK authentication.
    ///   - logging: Enabling log message, default is true.
    ///   - testnet: Determine which blockchain environment. e.g. testnet (Ethereum testnet, Solana devnet), mainnet (Ethereum mannet, Solana mainnet Beta)
    ///   - urlOpening: Handling url which opened app, default is UIApplication.shared, testing purpose.
    ///   - sessioningType: Type that handles web SDK authentication session, default is ASWebAuthenticationSession, testing purpose.
    public func initialize(
        with appId: String,
        getWindow: (() throws -> UIWindow)?,
        logging: Bool = true,
        environment: BloctoEnvironment = .prod,
        urlOpening: URLOpening = UIApplication.shared,
        sessioningType: AuthenticationSessioning.Type = ASWebAuthenticationSession.self
    ) {
        self.appId = appId
        self.getWindow = getWindow
        self.logging = logging
        self.environment = environment
        self.urlOpening = urlOpening
        self.sessioningType = sessioningType
    }

    /// To simply update blockchain network.
    /// - Parameter environment: Blocto Environment
    public func updateEnvironment(_ environment: BloctoEnvironment) {
        self.environment = environment
    }

    /// Entry of Universal Links
    /// - Parameter userActivity: the same userActivity from UIApplicationDelegate
    public func `continue`(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else {
            log(
                enable: logging,
                message: "webpageURL not found."
            )
            return
        }
        guard url.path == responsePath else {
            log(
                enable: logging,
                message: "url path should be \(responsePath) rather than \(url.path)."
            )
            return
        }
        log(
            enable: logging,
            message: "App get called by Universal Links: \(url)"
        )
        methodResolve(url: url)
    }

    /// Entry of custom scheme
    /// - Parameters:
    ///   - url: custom scheme URL
    public func application(
        open url: URL
    ) {
        if let scheme = url.scheme?.lowercased(),
           scheme.hasPrefix("blocto") || scheme.hasPrefix("blocto-dev") {
            log(
                enable: true,
                message: "❗️❗️Universal link should be implemented to prevent from potential attack."
            )
        }
        do {
            try checkConfigration()
            guard url.scheme == customScheme(appId: appId) else {
                log(
                    enable: logging,
                    message: "url scheme should be \(responseScheme) rather than \(String(describing: url.scheme))."
                )
                return
            }
            log(
                enable: logging,
                message: "App get called by custom scheme: \(url)"
            )
            methodResolve(url: url)
        } catch {
            log(
                enable: logging,
                message: "error: \(error) when opened by \(url)"
            )
        }
    }

    /// Send pre-defined method
    /// - Parameters:
    ///   - method: Any method which conform to Method protocol
    ///   - fallbackToWebSDK: Whether to fallback to WebSDK if native Blocto app not install.
    public func send(
        method: Method,
        fallbackToWebSDK: Bool = true
    ) {
        let send = { [weak self] in
            guard let self = self else {
                method.handleError(error: BloctoSDKError.callbackSelfNotfound)
                return
            }
            do {
                try self.checkConfigration()
                guard let requestURL = try method.encodeToURL(
                    appId: self.appId,
                    baseURLString: self.requestBloctoBaseURLString
                ) else {
                    method.handleError(error: BloctoSDKError.encodeToURLFailed)
                    return
                }
                self.uuidToMethod[method.id] = method
                self.urlOpening.open(
                    requestURL,
                    options: [.universalLinksOnly: true],
                    completionHandler: { [weak self] opened in
                        guard let self = self else { return }
                        if opened {
                            log(
                                enable: self.logging,
                                message: "open universal link \(requestURL) successfully."
                            )
                        } else {
                            log(
                                enable: self.logging,
                                message: "can't open universal link \(requestURL)."
                            )
                            if fallbackToWebSDK {
                                do {
                                    self.routeToWebSDK(window: try self.getWindow?(), method: method)
                                } catch {
                                    log(
                                        enable: self.logging,
                                        message: "Window not found."
                                    )
                                }
                            } else {
                                log(
                                    enable: self.logging,
                                    message: "Not fallback to WebSDK for \(method.type)."
                                )
                            }
                        }
                    }
                )
            } catch {
                method.handleError(error: error)
                do {
                    self.routeToWebSDK(window: try self.getWindow?(), method: method)
                } catch {
                    log(
                        enable: self.logging,
                        message: "Window not found."
                    )
                }
            }
        }
        if Thread.isMainThread {
            send()
        } else {
            DispatchQueue.main.async {
                send()
            }
        }
    }

    private func checkConfigration() throws {
        guard appId.isEmpty == false else { throw BloctoSDKError.appIdNotSet }
    }

    private func routeToWebSDK(
        window: UIWindow? = nil,
        method: Method
    ) {
        do {
            guard let requestURL = try method.encodeToURL(
                appId: appId,
                baseURLString: webRequestBloctoBaseURLString
            ) else {
                method.handleError(error: BloctoSDKError.encodeToURLFailed)
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
                            message: error.localizedDescription
                        )
                        if let error = error as? ASWebAuthenticationSessionError {
                            if error.code == ASWebAuthenticationSessionError.Code.canceledLogin {
                                method.handleError(error: BloctoSDKError.userCancel)
                            } else {
                                method.handleError(error: BloctoSDKError.sessionError(code: error.code.rawValue))
                            }
                        }
                    } else if let callbackURL = callbackURL {
                        self.methodResolve(expectHost: nil, url: callbackURL)
                    } else {
                        log(
                            enable: self.logging,
                            message: "callback URL not found."
                        )
                        method.handleError(error: BloctoSDKError.redirectURLNotFound)
                    }
                    session = nil
                }
            )

            session?.presentationContextProvider = window

            log(
                enable: logging,
                message: "About to route to Web SDK \(requestURL)."
            )
            let startsSuccessfully = session?.start()
            if startsSuccessfully == false {
                method.handleError(error: BloctoSDKError.webSDKSessionFailed)
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
                    message: "\(url.host ?? "host is nil") should be \(expectHost)"
                )
                return
            }
        }
        guard let urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else {
            log(
                enable: logging,
                message: "urlComponents not found."
            )
            return
        }
        guard let uuid = urlComponents.getRequestId() else {
            log(
                enable: logging,
                message: "\(QueryName.requestId.rawValue) not found."
            )
            return
        }
        guard let method = uuidToMethod[uuid] else {
            log(
                enable: logging,
                message: "\(QueryName.method.rawValue) not found."
            )
            return
        }
        method.resolve(components: urlComponents, logging: logging)
    }

}
