//
//  FlowDemoViewController.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/7/8.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa
import SnapKit
import BloctoSDK
import FlowSDK
import Cadence
import FCL_SDK

// swiftlint:disable type_body_length file_length
final class FlowDemoViewController: UIViewController {

    private var accountProofAppName = "This is demo app."
    // minimum 32-byte random nonce as a hex string.
    private var nonce = "75f8587e5bd5f9dcc9909d0dae1f0ac5814458b2ae129620502cb936fde7120a"

    var flowAPIClient: Client {
        if isProduction {
            return Client(network: Network.mainnet)
        } else {
            return Client(network: Network.testnet)
        }
    }

    private var bloctoApiBaseURLString: String {
        if isProduction {
            return "https://api.blocto.app"
        } else {
            return "https://api-staging.blocto.app"
        }
    }

    private var bloctoContract: String {
        if isProduction {
            return "0xdb6b70764af4ff68"
        } else {
            return "0x5b250a8a85b44a67"
        }
    }

    private var valueDappContract: String {
        if isProduction {
            return "0x8320311d63f3b336"
        } else {
            return "0x5a8143da8058740c"
        }
    }

    private lazy var bloctoFlowSDK = BloctoSDK.shared.flow
    private var userSignatures: [FlowCompositeSignature] = []

    private lazy var networkSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["devnet", "mainnet-beta"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.selectedSegmentTintColor = .blue
        return segmentedControl
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.contentInset.bottom = 350

        scrollView.addSubview(contentView)

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()

        view.addSubview(titleLabel)

        view.addSubview(requestAccountButton)
        view.addSubview(requestAccountResultLabel)
        view.addSubview(requestAccountCopyButton)
        view.addSubview(requestAccountExplorerButton)
        view.addSubview(accountProofVerifyButton)

        view.addSubview(separator1)

        view.addSubview(signingTitleLabel)
        view.addSubview(signingTextView)
        view.addSubview(signingResultLabel)
        view.addSubview(signingVerifyButton)
        view.addSubview(signingVerifyingIndicator)
        view.addSubview(signButton)
        view.addSubview(signingLoadingIndicator)

        view.addSubview(separator2)

        view.addSubview(setValueTitleLabel)
        view.addSubview(nomalTxInputTextField)
        view.addSubview(setValueButton)
        view.addSubview(setValueResultLabel)
        view.addSubview(setValueExplorerButton)

        view.addSubview(separator3)

        view.addSubview(getValueTitleLabel)
        view.addSubview(getValueButton)
        view.addSubview(getValueLoadingIndicator)
        view.addSubview(getValueResultLabel)

        view.addSubview(separator4)

        view.addSubview(lookupTitleLabel)
        view.addSubview(txIdInputTextField)
        view.addSubview(lookupResultLabel)
        view.addSubview(lookupLoadingIndicator)
        view.addSubview(lookupButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        requestAccountButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(50)
            $0.leading.equalToSuperview().inset(20)
        }

        accountProofVerifyButton.snp.makeConstraints {
            $0.leading.equalTo(requestAccountButton.snp.trailing).offset(20)
            $0.size.equalTo(40)
            $0.centerY.equalTo(requestAccountButton)
            $0.trailing.equalToSuperview().inset(20)
        }

        requestAccountResultLabel.snp.makeConstraints {
            $0.top.equalTo(requestAccountButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        requestAccountCopyButton.snp.makeConstraints {
            $0.centerY.equalTo(requestAccountResultLabel)
            $0.size.equalTo(40)
            $0.leading.equalTo(requestAccountResultLabel.snp.trailing).offset(20)
        }

        requestAccountExplorerButton.snp.makeConstraints {
            $0.centerY.equalTo(requestAccountCopyButton)
            $0.size.equalTo(40)
            $0.leading.equalTo(requestAccountCopyButton.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        separator1.snp.makeConstraints {
            $0.top.equalTo(requestAccountResultLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        signingTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separator1.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        signingTextView.snp.makeConstraints {
            $0.top.equalTo(signingTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }

        signingResultLabel.snp.makeConstraints {
            $0.top.equalTo(signingTextView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        signingVerifyButton.snp.makeConstraints {
            $0.leading.equalTo(signingResultLabel.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(signingResultLabel)
            $0.size.equalTo(40)
        }

        signButton.snp.makeConstraints {
            $0.top.equalTo(signingResultLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        separator2.snp.makeConstraints {
            $0.top.equalTo(signButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        setValueTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separator2.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        nomalTxInputTextField.snp.makeConstraints {
            $0.top.equalTo(setValueTitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(35)
        }

        setValueResultLabel.snp.makeConstraints {
            $0.top.equalTo(nomalTxInputTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        setValueExplorerButton.snp.makeConstraints {
            $0.centerY.equalTo(setValueResultLabel)
            $0.size.equalTo(40)
            $0.leading.equalTo(setValueResultLabel.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        setValueButton.snp.makeConstraints {
            $0.top.equalTo(setValueResultLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        separator3.snp.makeConstraints {
            $0.top.equalTo(setValueButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        getValueTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separator3.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        getValueResultLabel.snp.makeConstraints {
            $0.top.equalTo(getValueTitleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        getValueButton.snp.makeConstraints {
            $0.top.equalTo(getValueResultLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        separator4.snp.makeConstraints {
            $0.top.equalTo(getValueButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        lookupTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separator4.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        txIdInputTextField.snp.makeConstraints {
            $0.top.equalTo(lookupTitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(35)
        }

        lookupResultLabel.snp.makeConstraints {
            $0.top.equalTo(txIdInputTextField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        lookupButton.snp.makeConstraints {
            $0.top.equalTo(lookupResultLabel.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 35, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Value dApp"
        return label
    }()

    private lazy var requestAccountButton: UIButton = createButton(
        text: "Request account",
        indicator: requestAccountLoadingIndicator
    )

    private lazy var requestAccountLoadingIndicator = createLoadingIndicator()

    private lazy var requestAccountResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var requestAccountCopyButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "ic28Copy"), for: .normal)
        button.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        button.isHidden = true
        return button
    }()

    private lazy var requestAccountExplorerButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "ic28Earth"), for: .normal)
        button.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        button.isHidden = true
        return button
    }()

    private lazy var accountProofVerifyButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "icExamination"), for: .normal)
        button.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        button.isHidden = true
        button.addSubview(accountProofVerifyingIndicator)
        accountProofVerifyingIndicator.color = .gray
        accountProofVerifyingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        return button
    }()

    private lazy var accountProofVerifyingIndicator = createLoadingIndicator()

    private lazy var separator1 = createSeparator()

    private lazy var signingTitleLabel: UILabel = createLabel(text: "Signing")

    private lazy var signingTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .black
        textView.backgroundColor = .lightGray
        textView.text = "user input any message"
        textView.returnKeyType = .done
        textView.layer.cornerRadius = 5
        textView.clipsToBounds = true
        return textView
    }()

    private lazy var signingResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var signingVerifyButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "icExamination"), for: .normal)
        button.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        button.isHidden = true
        button.addSubview(signingVerifyingIndicator)
        signingVerifyingIndicator.color = .gray
        signingVerifyingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        return button
    }()

    private lazy var signingVerifyingIndicator = createLoadingIndicator()

    private lazy var signButton: UIButton = createButton(
        text: "Sign",
        indicator: signingLoadingIndicator
    )

    private lazy var signingLoadingIndicator = createLoadingIndicator()

    private lazy var separator2 = createSeparator()

    private lazy var setValueTitleLabel: UILabel = createLabel(text: "Set a Value")

    private lazy var nomalTxInputTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.backgroundColor = .lightGray
        textField.placeholder = "input value"
        textField.returnKeyType = .done
        textField.delegate = self
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 5
        textField.clipsToBounds = true
        let leftView = UIView()
        leftView.snp.makeConstraints {
            $0.size.equalTo(10)
        }
        textField.leftView = leftView
        return textField
    }()

    private lazy var setValueButton: UIButton = createButton(
        text: "Send transaction",
        indicator: setValueLoadingIndicator
    )

    private lazy var setValueLoadingIndicator = createLoadingIndicator()

    private lazy var setValueResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var setValueExplorerButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "ic28Earth"), for: .normal)
        button.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        button.isHidden = true
        return button
    }()

    private lazy var separator3 = createSeparator()

    private lazy var getValueTitleLabel: UILabel = createLabel(text: "Get a Value from Value Dapp")

    private lazy var getValueButton: UIButton = createButton(
        text: "Get Value",
        indicator: getValueLoadingIndicator
    )

    private lazy var getValueLoadingIndicator = createLoadingIndicator()

    private lazy var getValueResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private lazy var separator4 = createSeparator()

    private lazy var lookupTitleLabel: UILabel = createLabel(text: "Look up tx")

    private lazy var txIdInputTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.backgroundColor = .lightGray
        textField.placeholder = "tx id"
        textField.returnKeyType = .done
        textField.delegate = self
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 5
        textField.clipsToBounds = true
        let leftView = UIView()
        leftView.snp.makeConstraints {
            $0.size.equalTo(10)
        }
        textField.leftView = leftView
        return textField
    }()

    private lazy var lookupResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var lookupLoadingIndicator = createLoadingIndicator()

    private lazy var lookupButton: UIButton = createButton(
        text: "Look up",
        indicator: lookupLoadingIndicator
    )

    private lazy var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFCL()
        setupViews()
        setupBinding()
        title = "Flow"
    }

    private func setupFCL() {
        do {
            let bloctoWalletProvider = try BloctoWalletProvider(
                bloctoAppIdentifier: bloctoSDKAppId,
                window: nil,
                testnet: !isProduction
            )
            if isProduction {
                fcl.config
                    .put(.network(.mainnet))
                    .put(.supportedWalletProviders([bloctoWalletProvider]))
            } else {
                fcl.config
                    .put(.network(.testnet))
                    .put(.supportedWalletProviders([bloctoWalletProvider]))
            }
        } catch {
            debugPrint(error)
        }
    }

    private func setupViews() {
        view.backgroundColor = .white

        view.addSubview(networkSegmentedControl)
        view.addSubview(scrollView)

        networkSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(networkSegmentedControl.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.width.equalTo(view)
        }
    }

    private func setupBinding() {
        _ = networkSegmentedControl.rx.value.changed
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                guard let window = self.view.window else { return }
                self.resetRequestAccountStatus()
                self.resetSignStatus()
                switch index {
                case 0:
                    isProduction = false
                case 1:
                    isProduction = true
                default:
                    break
                }
                BloctoSDK.shared.initialize(
                    with: bloctoSDKAppId,
                    getWindow: { window },
                    logging: true,
                    testnet: !isProduction
                )
                self.setupFCL()
            })

        _ = requestAccountButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.resetRequestAccountStatus()

                /// 1. request account only
                /*
                 let requestAccountMethod = RequestAccountMethod(
                     blockchain: .flow) { result in
                         switch result {
                         case let .success(address):
                             let userAddress = address
                             // receive userAddress here
                         case let .failure(error):
                             debugPrint(error)
                         }
                     }
                 BloctoSDK.shared.send(method: requestAccountMethod)
                 */

                /// 2. Authanticate like FCL
                let accountProofData = FCLAccountProofData(
                    appId: self.accountProofAppName,
                    nonce: self.nonce
                )
                Task {
                    do {
                        let address = try await fcl.authanticate(accountProofData: accountProofData)
                        self.requestAccountResultLabel.text = address.hexStringWithPrefix
                        let hasAccountProof = fcl.currentUser?.accountProof != nil
                        self.accountProofVerifyButton.isHidden = !hasAccountProof
                        self.requestAccountCopyButton.isHidden = !hasAccountProof
                        self.requestAccountExplorerButton.isHidden = !hasAccountProof
                    } catch {
                        self.handleRequestAccountError(error)
                    }
                }
            })

        _ = accountProofVerifyButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.verifyAccountProof()
            })

        _ = requestAccountCopyButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let address = self.requestAccountResultLabel.text else { return }
                UIPasteboard.general.string = address
                self.requestAccountCopyButton.setImage(UIImage(named: "icon20Selected"), for: .normal)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.requestAccountCopyButton.setImage(UIImage(named: "ic28Copy"), for: .normal)
                }
            })

        _ = requestAccountExplorerButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let address = self.requestAccountResultLabel.text else { return }
                self.routeToExplorer(with: .address(address))
            })

        _ = signButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.signMessage()
            })

        _ = signingVerifyButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.verifySignature()
            })

        _ = setValueButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.resetSetValueStatus()
                self.setValueLoadingIndicator.startAnimating()
                self.sendTransaction()
            })

        _ = setValueExplorerButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let hash = self.setValueResultLabel.text else { return }
                self.routeToExplorer(with: .txhash(hash))
            })

        _ = getValueButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.getValue()
            })

        _ = lookupButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let hash = self.txIdInputTextField.text else { return }
                self.lookup(txHash: hash)
            })
    }

    private func verifyAccountProof() {

        guard let accountProof = fcl.currentUser?.accountProof else {
            handleRequestAccountError(Error.message("no account proof."))
            return
        }

        accountProofVerifyingIndicator.startAnimating()

        Task {
            do {
                let valid = try await AppUtilities.verifyAccountProof(
                    appIdentifier: accountProofAppName,
                    accountProofData: accountProof,
                    fclCryptoContract: Address(hexString: bloctoContract)
                )
                accountProofVerifyingIndicator.stopAnimating()
                if valid {
                    accountProofVerifyButton.setImage(UIImage(named: "icon20Selected"), for: .normal)
                    try await Task.sleep(seconds: 3)
                    accountProofVerifyButton.setImage(UIImage(named: "icExamination"), for: .normal)
                } else {
                    accountProofVerifyButton.setImage(UIImage(named: "error"), for: .normal)
                    try await Task.sleep(seconds: 3)
                    accountProofVerifyButton.setImage(UIImage(named: "icExamination"), for: .normal)
                }
            } catch {
                accountProofVerifyingIndicator.stopAnimating()
                accountProofVerifyButton.setImage(UIImage(named: "error"), for: .normal)
                debugPrint(error)
            }
        }
    }

    private func signMessage() {
        guard let userWalletAddress = fcl.currentUser?.address.hexStringWithPrefix else {
            handleSignError(Error.message("User address not found. Please request account first."))
            return
        }
        guard let message = signingTextView.text else {
            handleSignError(Error.message("message not found."))
            return
        }
        bloctoFlowSDK.signMessage(
            from: userWalletAddress,
            message: message
        ) { [weak self] result in
            guard let self = self else { return }
            self.resetSignStatus()
            switch result {
            case let .success(signatures):
                self.userSignatures = signatures
                self.signingResultLabel.text = signatures.map(\.signature).joined(separator: "\n")
                self.signingVerifyButton.isHidden = false
            case let .failure(error):
                self.handleSignError(error)
            }
        }
    }

    private func verifySignature() {
        guard let message = signingTextView.text else {
            handleSignError(Error.message("signature not found."))
            return
        }

        signingVerifyingIndicator.startAnimating()

        let sigs = userSignatures.map {
            FCLCompositeSignature(
                address: $0.address,
                keyId: $0.keyId,
                signature: $0.signature
            )
        }

        Task {
            do {
                let valid = try await AppUtilities.verifyUserSignatures(
                    message: Data(message.utf8).bloctoSDK.hexString,
                    signatures: sigs,
                    fclCryptoContract: Address(hexString: bloctoContract)
                )
                signingVerifyingIndicator.stopAnimating()
                if valid {
                    signingVerifyButton.setImage(UIImage(named: "icon20Selected"), for: .normal)
                    try await Task.sleep(seconds: 3)
                    signingVerifyButton.setImage(UIImage(named: "icExamination"), for: .normal)
                } else {
                    signingVerifyButton.setImage(UIImage(named: "error"), for: .normal)
                    try await Task.sleep(seconds: 3)
                    signingVerifyButton.setImage(UIImage(named: "icExamination"), for: .normal)
                }
            } catch {
                signingVerifyingIndicator.stopAnimating()
                signingVerifyButton.setImage(UIImage(named: "error"), for: .normal)
                debugPrint(error)
            }
        }
    }

    private func sendTransaction() {
        guard let userWalletAddress = fcl.currentUser?.address else {
            handleSetValueError(Error.message("User address not found. Please request account first."))
            return
        }
        guard let inputValue = nomalTxInputTextField.text,
              inputValue.isEmpty == false,
              let input = Decimal(string: inputValue) else {
            handleSetValueError(Error.message("Input not found."))
            return
        }

        Task { @MainActor in
            do {
                guard let account = try await flowAPIClient.getAccountAtLatestBlock(address: userWalletAddress) else {
                    handleSetValueError(Error.message("Account not found."))
                    return
                }

                guard let block = try await flowAPIClient.getLatestBlock(isSealed: true) else {
                    handleSetValueError(Error.message("Latest block not found."))
                    return
                }

                let scriptString = """
                import ValueDapp from \(valueDappContract)

                transaction(value: UFix64) {
                    prepare(authorizer: AuthAccount) {
                        ValueDapp.setValue(value)
                    }
                }
                """
                let script = Data(scriptString.utf8)

                let argument = Cadence.Argument(.ufix64(input))

                guard let cosignerKey = account.keys
                    .first(where: { $0.weight == 999 && $0.revoked == false }) else {
                    throw FCLError.keyNotFound
                }

                let proposalKey = Transaction.ProposalKey(
                    address: userWalletAddress,
                    keyIndex: cosignerKey.index,
                    sequenceNumber: cosignerKey.sequenceNumber
                )

                let payer = try await bloctoFlowSDK.getFeePayerAddress(isTestnet: !isProduction)

                let transaction = try Transaction(
                    script: script,
                    arguments: [argument],
                    referenceBlockId: block.blockHeader.id,
                    gasLimit: 100,
                    proposalKey: proposalKey,
                    payer: payer,
                    authorizers: [userWalletAddress]
                )

                bloctoFlowSDK.sendTransaction(
                    from: userWalletAddress,
                    transaction: transaction
                ) { [weak self] result in
                    guard let self = self else { return }
                    self.resetSetValueStatus()
                    switch result {
                    case let .success(txHsh):
                        self.setValueResultLabel.text = txHsh
                        self.setValueExplorerButton.isHidden = false
                    case let .failure(error):
                        self.handleSetValueError(error)
                    }
                }

            } catch {
                handleSetValueError(Error.message("Account not found."))
            }
        }
    }

    private func getValue() {
        let script = """
        import ValueDapp from \(valueDappContract)

        pub fun main(): UFix64 {
            return ValueDapp.value
        }
        """

        Task {
            let argument = try await flowAPIClient.executeScriptAtLatestBlock(script: Data(script.utf8))
            getValueResultLabel.text = argument.value.description
        }
    }

    private func lookup(txHash: String) {
        lookupLoadingIndicator.startAnimating()
        lookupResultLabel.text = nil

        Task {
            do {
                let result = try await fcl.getTransactionStatus(transactionId: txHash)
                lookupLoadingIndicator.stopAnimating()
                let displayString = "status: \(String(describing: result.status ?? .unknown))\nerror message: \(result.errorMessage ?? "no error")"
                lookupResultLabel.text = displayString
                debugPrint(result)
            } catch {
                lookupLoadingIndicator.stopAnimating()
                lookupResultLabel.text = error.localizedDescription
            }
        }
    }

    private func createSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = .gray
        view.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        return view
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = text
        label.textColor = .black
        label.textAlignment = .left
        return label
    }

    private func createButton(text: String, indicator: UIActivityIndicatorView) -> UIButton {
        let button: UIButton = UIButton()
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = .init(top: 12, left: 35, bottom: 12, right: 35)

        button.addSubview(indicator)

        indicator.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }
        return button
    }

    private func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }

    private func resetRequestAccountStatus() {
        requestAccountResultLabel.text = nil
        requestAccountResultLabel.textColor = .black
        requestAccountLoadingIndicator.stopAnimating()
        requestAccountCopyButton.isHidden = true
        requestAccountExplorerButton.isHidden = true
        accountProofVerifyButton.isHidden = true
    }

    private func resetSignStatus() {
        signingResultLabel.text = nil
        signingResultLabel.textColor = .black
        signingVerifyButton.isHidden = true
        signingLoadingIndicator.stopAnimating()
    }

    private func resetSetValueStatus() {
        setValueResultLabel.text = nil
        setValueResultLabel.textColor = .black
        setValueLoadingIndicator.stopAnimating()
        setValueExplorerButton.isHidden = true
    }

    private func handleRequestAccountError(_ error: Swift.Error) {
        handleGeneralError(label: requestAccountResultLabel, error: error)
        requestAccountLoadingIndicator.stopAnimating()
    }

    private func handleSignError(_ error: Swift.Error) {
        handleGeneralError(label: signingResultLabel, error: error)
        signingLoadingIndicator.stopAnimating()
    }

    private func handleSetValueError(_ error: Swift.Error) {
        handleGeneralError(label: setValueResultLabel, error: error)
        setValueLoadingIndicator.stopAnimating()
    }

    private func handleGeneralError(label: UILabel, error: Swift.Error) {
        ErrorHandler.handleGeneralError(label: label, error: error)
    }

    enum ExplorerURLType {
        case txhash(String)
        case address(String)

        func url() -> URL? {
            switch self {
            case let .txhash(hash):
                return isProduction
                    ? URL(string: "https://flowscan.org/transaction/\(hash)")
                    : URL(string: "https://testnet.flowscan.org/transaction/\(hash)")
            case let .address(address):
                return isProduction
                    ? URL(string: "https://flowscan.org/account/\(address)")
                    : URL(string: "https://testnet.flowscan.org/account/\(address)")
            }
        }
    }

    private func routeToExplorer(with type: ExplorerURLType) {
        guard let url = type.url() else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
    }

}

// MARK: UITextFieldDelegate

extension FlowDemoViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

// MARK: SFSafariViewControllerDelegate

extension FlowDemoViewController: SFSafariViewControllerDelegate {}

extension FlowDemoViewController {

    enum Error: Swift.Error, ErrorMessaging {
        case message(String)

        var message: String {
            switch self {
            case let .message(message):
                return message
            }
        }
    }

}
