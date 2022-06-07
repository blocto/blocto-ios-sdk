//
//  EVMBaseDemoViewController.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/5/11.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa
import SnapKit
import BloctoSDK
import web3
import BigInt
import EthereumSignTypedDataUtil

// swiftlint:disable type_body_length file_length
final class EVMBaseDemoViewController: UIViewController {

    private var userWalletAddress: String?

    private lazy var bloctoEthereumSDK = BloctoSDK.shared.ethereum

    private var selectedBlockchain: EVMBase = .ethereum
    private var selectedSigningType: EVMBaseSignType = .sign

    private lazy var rpcClient = selectedBlockchain.rpcClient

    private let blockchainSelections: [EVMBase] = EVMBase.allCases
    private let signingSelections: [EVMBaseSignType] = EVMBaseSignType.allCases

    private var signingTextViewHeightContraint: Constraint?

    private lazy var networkSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["testnet", "mainnet"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = .blue
        }
        return segmentedControl
    }()

    private lazy var blockchainSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: blockchainSelections.map { $0.displayString })
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = .blue
        }
        return segmentedControl
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white

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

        view.addSubview(separator1)

        view.addSubview(signingTitleLabel)
        view.addSubview(signingSegmentedControl)
        view.addSubview(signingTypeDataSegmentedControl)
        view.addSubview(expandSignTextButton)
        view.addSubview(signingTextView)
        view.addSubview(signingResultLabel)
        view.addSubview(signingVerifyButton)
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
        view.addSubview(getValueResultLabel)

        view.addSubview(separator4)

        view.addSubview(sendValueTxTitleLabel)
        view.addSubview(valueTxInputTextField)
        view.addSubview(sendValueTxButton)
        view.addSubview(sendValueTxResultLabel)
        view.addSubview(sendValueTxExplorerButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        requestAccountButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(50)
            $0.leading.equalToSuperview().inset(20)
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

        signingSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(signingTitleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        signingTypeDataSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(signingSegmentedControl.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        expandSignTextButton.snp.makeConstraints {
            $0.top.equalTo(signingTypeDataSegmentedControl.snp.bottom).offset(20)
            $0.height.equalTo(30)
        }

        signingTextView.snp.makeConstraints {
            $0.top.equalTo(expandSignTextButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.trailing.equalTo(expandSignTextButton)
            signingTextViewHeightContraint = $0.height.equalTo(70).constraint
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

        setValueButton.snp.makeConstraints {
            $0.top.equalTo(nomalTxInputTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        setValueResultLabel.snp.makeConstraints {
            $0.top.equalTo(setValueButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        setValueExplorerButton.snp.makeConstraints {
            $0.centerY.equalTo(setValueResultLabel)
            $0.size.equalTo(40)
            $0.leading.equalTo(setValueResultLabel.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        separator3.snp.makeConstraints {
            $0.top.equalTo(setValueResultLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        getValueTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separator3.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        getValueButton.snp.makeConstraints {
            $0.top.equalTo(getValueTitleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        getValueResultLabel.snp.makeConstraints {
            $0.top.equalTo(getValueButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        separator4.snp.makeConstraints {
            $0.top.equalTo(getValueResultLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        sendValueTxTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separator4.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        valueTxInputTextField.snp.makeConstraints {
            $0.top.equalTo(sendValueTxTitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(35)
        }

        sendValueTxButton.snp.makeConstraints {
            $0.top.equalTo(valueTxInputTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        sendValueTxResultLabel.snp.makeConstraints {
            $0.top.equalTo(sendValueTxButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
        }

        sendValueTxExplorerButton.snp.makeConstraints {
            $0.centerY.equalTo(sendValueTxResultLabel)
            $0.size.equalTo(40)
            $0.leading.equalTo(sendValueTxResultLabel.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().inset(20)
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
        indicator: requestAccountLoadingIndicator)

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

    private lazy var separator1 = createSeparator()

    private lazy var signingTitleLabel: UILabel = createLabel(text: "Signing")

    private lazy var signingSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(
            items: signingSelections.prefix(2)
                .map { $0.displayTitle })
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = .blue
        }
        return segmentedControl
    }()

    private lazy var signingTypeDataSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(
            items: signingSelections.dropFirst(2)
                .map { $0.displayTitle })
        segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = .blue
        }
        return segmentedControl
    }()

    private lazy var expandSignTextButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("expand text", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.backgroundColor = .gray
        button.contentEdgeInsets = .init(top: 12, left: 10, bottom: 12, right: 10)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()

    private lazy var signingTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .black
        textView.backgroundColor = .lightGray
        textView.text = selectedSigningType.defaultText
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
        indicator: signingLoadingIndicator)

    private lazy var signingLoadingIndicator = createLoadingIndicator()

    private lazy var separator2 = createSeparator()

    private lazy var setValueTitleLabel: UILabel = createLabel(text: "Set a Value")

    private lazy var nomalTxInputTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.backgroundColor = .lightGray
        textField.text = "5566"
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
        indicator: setValueLoadingIndicator)

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

    private lazy var getValueTitleLabel: UILabel = createLabel(text: "Get a Value from Account's Data")

    private lazy var getValueButton: UIButton = createButton(
        text: "Get Value",
        indicator: getValueLoadingIndicator)

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

    private lazy var sendValueTxTitleLabel: UILabel = createLabel(text: "Send transaction with native coin value")

    private lazy var valueTxInputTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.backgroundColor = .lightGray
        textField.text = "100"
        textField.returnKeyType = .done
        textField.delegate = self
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.layer.cornerRadius = 5
        textField.clipsToBounds = true
        let leftView = UIView()

        leftView.snp.makeConstraints {
            $0.size.equalTo(10)
        }

        let rightView = UILabel()
        rightView.text = "wei   "

        textField.leftView = leftView
        textField.rightView = rightView
        return textField
    }()

    private lazy var sendValueTxButton: UIButton = createButton(
        text: "Send Tx with value",
        indicator: sendValueTxLoadingIndicator)

    private lazy var sendValueTxLoadingIndicator = createLoadingIndicator()

    private lazy var sendValueTxResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private lazy var sendValueTxExplorerButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "ic28Earth"), for: .normal)
        button.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        button.isHidden = true
        return button
    }()

    private lazy var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBinding()
        title = "EVM Base"
    }

    private func setupViews() {
        view.backgroundColor = .white

        view.addSubview(networkSegmentedControl)
        view.addSubview(blockchainSegmentedControl)
        view.addSubview(scrollView)

        networkSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        blockchainSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(networkSegmentedControl.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(blockchainSegmentedControl.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.width.equalTo(view)
        }
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    private func setupBinding() {
        _ = networkSegmentedControl.rx.value.changed
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                guard let window = self.view.window else { return }
                self.resetRequestAccountStatus()
                self.resetSetValueStatus()
                self.resetGetValueStatus()
                self.resetValueTxStatus()
                switch index {
                case 0:
                    isProduction = false
                case 1:
                    isProduction = true
                default:
                    break
                }
                if #available(iOS 13.0, *) {
                    BloctoSDK.shared.initialize(
                        with: bloctoSDKAppId,
                        window: window,
                        logging: true,
                        testnet: !isProduction)
                } else {
                    BloctoSDK.shared.initialize(
                        with: bloctoSDKAppId,
                        logging: true,
                        testnet: !isProduction)
                }
            })

        _ = blockchainSegmentedControl.rx.value.changed
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.resetRequestAccountStatus()
                self.resetSetValueStatus()
                self.resetGetValueStatus()
                self.resetValueTxStatus()
                self.selectedBlockchain = self.blockchainSelections[index]
                self.rpcClient = self.selectedBlockchain.rpcClient
            })

        _ = signingSegmentedControl.rx.value.changed
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.resetSignStatus()
                self.signingTypeDataSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
                self.selectedSigningType = self.signingSelections[index]
                self.signingTextView.text = self.selectedSigningType.defaultText
            })

        _ = signingTypeDataSegmentedControl.rx.value.changed
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.resetSignStatus()
                self.signingSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
                self.selectedSigningType = Array(self.signingSelections.dropFirst(2))[index]
                self.signingTextView.text = self.selectedSigningType.defaultText
            })

        _ = requestAccountButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.resetRequestAccountStatus()

                self.selectedBlockchain.sdkProvider.requestAccount { [weak self] result in
                    switch result {
                    case .success(let address):
                        self?.userWalletAddress = address
                        self?.requestAccountResultLabel.text = address
                        self?.requestAccountCopyButton.isHidden = false
                        self?.requestAccountExplorerButton.isHidden = false
                    case .failure(let error):
                        self?.handleRequestAccountError(error)
                    }
                }
            })

        _ = requestAccountCopyButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
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
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let address = self.requestAccountResultLabel.text else { return }
                self.routeToExplorer(with: .address(address))
            })

        _ = expandSignTextButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.expandSignTextButton.isSelected {
                    self.expandSignTextButton.isSelected = false
                    self.expandSignTextButton.backgroundColor = .gray
                    let text = self.signingTextView.text
                    self.signingTextView.text = ""
                    self.signingTextView.isScrollEnabled = true
                    self.signingTextView.text = text
                    self.signingTextViewHeightContraint?.isActive = true
                } else {
                    self.expandSignTextButton.isSelected = true
                    self.expandSignTextButton.backgroundColor = .blue
                    let text = self.signingTextView.text
                    self.signingTextView.text = ""
                    self.signingTextView.isScrollEnabled = false
                    self.signingTextView.text = text
                    self.signingTextViewHeightContraint?.isActive = false
                }
            })

        _ = signButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.signMessage()
            })

        _ = signingVerifyButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.verifySignature()
            })

        _ = setValueButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
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
                scheduler: MainScheduler.instance)
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
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.resetGetValueStatus()
                self.getValueLoadingIndicator.startAnimating()
                self.getValue()
            })

        _ = sendValueTxButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.resetValueTxStatus()
                self.sendValueTxLoadingIndicator.startAnimating()
                self.sendTransactionWithValue()
            })

        _ = sendValueTxExplorerButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let hash = self.sendValueTxResultLabel.text else { return }
                self.routeToExplorer(with: .txhash(hash))
            })
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
    }

    private func resetSignStatus() {
        signingResultLabel.text = nil
        signingResultLabel.textColor = .black
        signingVerifyButton.isHidden = true
        signingLoadingIndicator.stopAnimating()
    }

    private func resetSignVerifyStatus() {
        signingVerifyingIndicator.stopAnimating()
    }

    private func resetSetValueStatus() {
        setValueResultLabel.text = nil
        setValueResultLabel.textColor = .black
        setValueLoadingIndicator.stopAnimating()
        setValueExplorerButton.isHidden = true
    }

    private func resetGetValueStatus() {
        getValueResultLabel.text = nil
        getValueResultLabel.textColor = .black
        getValueLoadingIndicator.stopAnimating()
    }

    private func resetValueTxStatus() {
        sendValueTxResultLabel.text = nil
        sendValueTxResultLabel.textColor = .black
        sendValueTxLoadingIndicator.stopAnimating()
    }

    private func signMessage() {
        guard let userWalletAddress = userWalletAddress else {
            handleSignError(Error.message("User address not found. Please request account first."))
            return
        }
        guard let message = signingTextView.text else {
            handleSignError(Error.message("message not found."))
            return
        }
        selectedBlockchain.sdkProvider.signMessage(
            from: userWalletAddress,
            message: message,
            signType: selectedSigningType) { [weak self] result in
                guard let self = self else { return }
                self.resetSignStatus()
                switch result {
                case let .success(signature):
                    self.signingResultLabel.text = signature
                    self.signingVerifyButton.isHidden = false
                case let .failure(error):
                    self.handleSignError(error)
                }
            }
    }

    private func verifySignature() {
        guard let userWalletAddress = userWalletAddress else {
            handleSignError(Error.message("User address not found. Please request account first."))
            return
        }
        guard let message = signingTextView.text else {
            handleSignError(Error.message("signature not found."))
            return
        }
        guard let signature = signingResultLabel.text?.bloctoSDK.drop0x else {
            handleSignError(Error.message("signature not found."))
            return
        }
        signingVerifyingIndicator.startAnimating()

        let data: Data
        switch selectedSigningType {
        case .sign:
            data = Data(ethMessage: message)
        case .personalSign:
            data = Data(message.utf8)
        case .typedSignV3,
                .typedSignV4,
                .typedSign:
            do {
                let typedData = try JSONDecoder().decode(EIP712TypedData.self, from: Data(message.utf8))
                let signableHash: Data
                if case .typedSignV3 = selectedSigningType {
                    signableHash = try typedData.signableHash(version: .v3)
                } else {
                    signableHash = try typedData.signableHash(version: .v4)
                }
                data = signableHash
            } catch {
                signingVerifyButton.setImage(UIImage(named: "error"), for: .normal)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.signingVerifyButton.setImage(UIImage(named: "icExamination"), for: .normal)
                }
                return
            }
        }

        let verifySignatureABIFunction = ERC1271ABIFunction(
            hash: data.sha3(.keccak256),
            signature: signature.bloctoSDK.hexDecodedData,
            contract: EthereumAddress(userWalletAddress))

        verifySignatureABIFunction.call(
            withClient: rpcClient,
            responseType: ERC1271ABIFunction.Response.self) { [weak self] error, response in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let error = error {
                        debugPrint(error)
                        self.signingVerifyButton.setImage(UIImage(named: "error"), for: .normal)
                    } else {
                        self.resetSignVerifyStatus()
                        if let value = response?.value,
                           value.bloctoSDK.hexStringWith0xPrefix == ERC1271ABIFunction.Response.erc1271ValidSignature {
                            self.signingVerifyButton.setImage(UIImage(named: "icon20Selected"), for: .normal)
                        } else {
                            self.signingVerifyButton.setImage(UIImage(named: "error"), for: .normal)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.signingVerifyButton.setImage(UIImage(named: "icExamination"), for: .normal)
                    }
                }
            }
    }

    private func sendTransaction() {
        guard let userWalletAddress = userWalletAddress else {
            handleSetValueError(Error.message("User address not found. Please request account first."))
            return
        }
        guard let inputValue = nomalTxInputTextField.text,
              inputValue.isEmpty == false,
              let value = BigUInt(inputValue) else {
                  handleSetValueError(Error.message("Input not found."))
                  return
              }
        let setValueABIFunction = SetValueABIFunction(value: value)

        do {
            let functionData = try setValueABIFunction.functionData()

            let evmBaseTransaction = EVMBaseTransaction(
                to: selectedBlockchain.dappAddress,
                from: userWalletAddress,
                value: "0",
                data: functionData)
            selectedBlockchain.sdkProvider.sendTransaction(
                transaction: evmBaseTransaction
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
            debugPrint(error)
        }
    }

    private func getValue() {
        let getValueABIFunction = GetValueABIFunction(
            contract: EthereumAddress(selectedBlockchain.dappAddress),
            from: nil,
            gasPrice: nil,
            gasLimit: nil)

        getValueABIFunction.call(
            withClient: rpcClient,
            responseType: GetValueABIFunction.Response.self) { [weak self] error, response in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.resetGetValueStatus()
                    if let error = error {
                        debugPrint(error)
                        self.handleGetValueError(error)
                    } else {
                        self.getValueResultLabel.text = response?.value.description
                    }
                }
            }
    }

    private func sendTransactionWithValue() {
        guard let userWalletAddress = userWalletAddress else {
            handleValueTxError(Error.message("User address not found. Please request account first."))
            return
        }
        guard let inputValue = valueTxInputTextField.text,
              inputValue.isEmpty == false,
              let value = BigUInt(inputValue) else {
                  handleValueTxError(Error.message("Input not found."))
                  return
              }
        let donateABIFunction = DonateABIFunction(message: "lalala")

        do {
            let functionData = try donateABIFunction.functionData()

            let evmBaseTransaction = EVMBaseTransaction(
                to: selectedBlockchain.dappAddress,
                from: userWalletAddress,
                value: value,
                data: functionData)
            selectedBlockchain.sdkProvider.sendTransaction(
                transaction: evmBaseTransaction
            ) { [weak self] result in
                guard let self = self else { return }
                self.resetValueTxStatus()
                switch result {
                case let .success(txHsh):
                    self.sendValueTxResultLabel.text = txHsh
                    self.sendValueTxExplorerButton.isHidden = false
                case let .failure(error):
                    self.handleValueTxError(error)
                }
            }
        } catch {
            debugPrint(error)
        }
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

    private func handleGetValueError(_ error: Swift.Error) {
        getValueResultLabel.text = error.localizedDescription
        getValueResultLabel.textColor = .red
        getValueLoadingIndicator.stopAnimating()
    }

    private func handleValueTxError(_ error: Swift.Error) {
        handleGeneralError(label: sendValueTxResultLabel, error: error)
        sendValueTxLoadingIndicator.stopAnimating()
    }

    private func handleGeneralError(label: UILabel, error: Swift.Error) {
        if let error = error as? BloctoSDKError {
            switch error {
            case .appIdNotSet:
                label.text = "app id not set."
            case .userRejected:
                label.text = "user rejected."
            case .forbiddenBlockchain:
                label.text = "Forbidden blockchain. You should check blockchain selection on Blocto developer dashboard."
            case .invalidResponse:
                label.text = "invalid response."
            case .userNotMatch:
                label.text = "user not matched."
            case .ethSignInvalidHexString:
                label.text = "input text should be hex string with 0x prefix."
            case .userCancel:
                label.text = "user canceled."
            case .redirectURLNotFound:
                label.text = "redirect url not found."
            case .sessionError(let code):
                label.text = "ASWebAuthenticationSessionError \(code)"
            case .other(let code):
                label.text = code
            }
        } else if let error = error as? Error {
            label.text = error.message
        } else {
            debugPrint(error)
            label.text = error.localizedDescription
        }
        label.textColor = .red
    }

    private func routeToExplorer(with type: ExplorerURLType) {
        guard let url = selectedBlockchain.explorerURL(type: type) else { return }
        let safariVC = SFSafariViewController(url: url)
        if #available(iOS 13.0, *) {
            safariVC.modalPresentationStyle = .automatic
        } else {
            safariVC.modalPresentationStyle = .overCurrentContext
        }
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
    }

}

extension EVMBaseDemoViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension EVMBaseDemoViewController: SFSafariViewControllerDelegate {}

extension EVMBaseDemoViewController {

    enum Error: Swift.Error {
        case message(String)

        var message: String {
            switch self {
            case let .message(message):
                return message
            }
        }
    }

}
