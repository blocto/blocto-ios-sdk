import XCTest
import BloctoSDK

class AccountRequestTests: XCTestCase {
    
    var mockUIApplication: MockUIApplication!
    
    let appId: String = "64776cec-5953-4a58-8025-772f55a3917b"
    let appUniversalLinkBaseURLString: String = "https://c161-61-216-44-25.ngrok.io/"
    let webRedirectBaseURLString: String = "blocto://"
    
    override func setUp() {
        super.setUp()
        mockUIApplication = MockUIApplication()
    }
    
    func testOpenNativeAppWhenInstalled() {
        // Given:
        let requestId = UUID()
        var address: String?
        let expectedAddress: String = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        BloctoSDK.shared.initialize(
            with: appId,
            window: UIWindow(),
            logging: false,
            urlOpening: mockUIApplication)

        mockUIApplication.setup(opened: true)
        
        // When:
        let requestAccountMethod = RequestAccountMethod(
            id: requestId,
            blockchain: Blockchain.solana) { result in
                switch result {
                case let .success(receivedAddress):
                    address = receivedAddress
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        BloctoSDK.shared.send(method: requestAccountMethod)
        
        var components = URLComponents(string: appUniversalLinkBaseURLString)
        components?.path = "/blocto"
        components?.queryItems = [
            .init(name: "address", value: expectedAddress),
            .init(name: "request_id", value: requestId.uuidString)
        ]
        
        BloctoSDK.shared.application(
            UIApplication.shared,
            open: components!.url!,
            options: [:])
        
        // Then:
        XCTAssert(address == expectedAddress, "address should be \(expectedAddress) rather then \(address!)")
        
    }
    
    func testOpenWebSDK() {
        // Given:
        let requestId = UUID()
        var address: String?
        let expectedAddress: String = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        BloctoSDK.shared.initialize(
            with: appId,
            window: UIWindow(),
            logging: false,
            urlOpening: mockUIApplication,
            sessioningType: MockAuthenticationSession.self)

        mockUIApplication.setup(opened: false)
        
        var components = URLComponents(string: webRedirectBaseURLString)
        components?.queryItems = [
            .init(name: "address", value: expectedAddress),
            .init(name: "request_id", value: requestId.uuidString)
        ]
        MockAuthenticationSession.setCallbackURL(components!.url!)
        
        // When:
        let requestAccountMethod = RequestAccountMethod(
            id: requestId,
            blockchain: Blockchain.solana) { result in
                switch result {
                case let .success(receivedAddress):
                    address = receivedAddress
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        BloctoSDK.shared.send(method: requestAccountMethod)
        
        // Then:
        XCTAssert(address == expectedAddress, "address should be \(expectedAddress) rather then \(address!)")
    }

}
