//
//  SolanaDemoViewController.swift
//  BloctoSDK
//
//  Created by scottphc on 01/12/2022.
//  Copyright (c) 2022 scottphc. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa
import SnapKit
import BloctoSDK
import SolanaWeb3

// swiftlint:disable type_body_length
final class SolanaDemoViewController: UIViewController {

    private var userWalletAddress: String?
    private var dappAddress: String {
        isProduction
        ? "EajAHVxAVvf4yNUu37ZEh8QS7Lk5bw9yahTGiTSL1Rwt"
        : "4AXy5YYCXpMapaVuzKkz25kVHzrdLDgKN3TiQvtf1Eu8"
    }
    private var programId: String {
        isProduction
        ? "EN2Ln23fzm4qag1mHfx7FDJwDJog5u4SDgqRY256ZgFt"
        : "G4YkbRN4nFQGEUg4SXzPsrManWzuk8bNq9JaMhXepnZ6"
    }
    private var cluster: Cluster {
        isProduction
        ? .mainnetBeta
        : .devnet
    }

    private lazy var bloctoSolanaSDK = BloctoSDK.shared.solana

    private lazy var networkSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["devnet", "mainnet-beta"])
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

        view.addSubview(setValueTitleLabel)
        view.addSubview(inputTextField)
        view.addSubview(setValueButton)
        view.addSubview(setValueResultLabel)
        view.addSubview(setValueExplorerButton)

        view.addSubview(separator2)

        view.addSubview(getValueTitleLabel)
        view.addSubview(getValueButton)
        view.addSubview(getValueResultLabel)

        view.addSubview(separator3)

        view.addSubview(partialSignTxTitleLabel)
        view.addSubview(partialSignTxButton)
        view.addSubview(partialSignTxResultLabel)
        view.addSubview(partialSignTxExplorerButton)

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

        setValueTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separator1.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        inputTextField.snp.makeConstraints {
            $0.top.equalTo(setValueTitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(35)
        }

        setValueButton.snp.makeConstraints {
            $0.top.equalTo(inputTextField.snp.bottom).offset(20)
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

        separator2.snp.makeConstraints {
            $0.top.equalTo(setValueResultLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        getValueTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separator2.snp.bottom).offset(20)
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

        separator3.snp.makeConstraints {
            $0.top.equalTo(getValueResultLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        partialSignTxTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separator3.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        partialSignTxButton.snp.makeConstraints {
            $0.top.equalTo(partialSignTxTitleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        partialSignTxResultLabel.snp.makeConstraints {
            $0.top.equalTo(partialSignTxButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
        }

        partialSignTxExplorerButton.snp.makeConstraints {
            $0.centerY.equalTo(partialSignTxResultLabel)
            $0.size.equalTo(40)
            $0.leading.equalTo(partialSignTxResultLabel.snp.trailing).offset(20)
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

    private lazy var setValueTitleLabel: UILabel = createLabel(text: "Set a Value")

    private lazy var inputTextField: UITextField = {
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

    private lazy var separator2 = createSeparator()

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

    private lazy var separator3 = createSeparator()

    private lazy var partialSignTxTitleLabel: UILabel = createLabel(text: "Create Account/Send Transaction (partialSign)")

    private lazy var partialSignTxButton: UIButton = createButton(
        text: "Send partial sign tx",
        indicator: partialSignTxLoadingIndicator)

    private lazy var partialSignTxLoadingIndicator = createLoadingIndicator()

    private lazy var partialSignTxResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private lazy var partialSignTxExplorerButton: UIButton = {
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
        title = "Solana"
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
                self.resetSetValueStatus()
                self.resetGetValueStatus()
                self.resetPartialSignTxStatus()
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

        _ = requestAccountButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.resetRequestAccountStatus()
                self.bloctoSolanaSDK.requestAccount { [weak self] result in
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

        _ = partialSignTxButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.resetPartialSignTxStatus()
                self.partialSignTxLoadingIndicator.startAnimating()
                self.partialSign()
            })

        _ = partialSignTxExplorerButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let hash = self.partialSignTxResultLabel.text else { return }
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

    private func resetPartialSignTxStatus() {
        partialSignTxResultLabel.text = nil
        partialSignTxResultLabel.textColor = .black
        partialSignTxLoadingIndicator.stopAnimating()
        partialSignTxExplorerButton.isHidden = true
    }

    private func sendTransaction() {
        guard let userWalletAddress = userWalletAddress else {
            handleSetValueError(Error.message("User address not found. Please request account first."))
            return
        }
        guard let dappPublicKey = try? PublicKey(dappAddress) else {
            return
        }
        guard let userWalletPublicKey = try? PublicKey(userWalletAddress) else {
            return
        }
        guard let programId = try? PublicKey(programId) else {
            return
        }
        guard let inputValue = inputTextField.text,
              inputValue.isEmpty == false,
              let value = UInt32(inputValue) else {
                  handleSetValueError(Error.message("Input not found."))
                  return
              }

        var transaction = Transaction()
        do {
            let setValueInstruction = try createSetValueInstruction(
                dappPublicKey: dappPublicKey,
                userWalletPublicKey: userWalletPublicKey,
                programId: programId,
                value: value)
            transaction.add(setValueInstruction)
        } catch {
            handleSetValueError(Error.message("Create set value instruction failed."))
            return
        }
        transaction.feePayer = userWalletPublicKey

        bloctoSolanaSDK.signAndSendTransaction(
            from: userWalletAddress,
            transaction: transaction) { [weak self] result in
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
    }

    private func getValue() {
        guard let dappPublicKey = try? PublicKey(dappAddress) else {
            return
        }

        let connetion = Connection(cluster: cluster)
        connetion.getAccountInfo(
            publicKey: dappPublicKey) { [weak self] (result: Result<AccountInfo<ValueAccountData>?, Connection.Error>) in
                guard let self = self else { return }
                self.resetGetValueStatus()
                switch result {
                case let .success(valueAccount):
                    guard let data = valueAccount?.data else {
                        self.handleGetValueError(Error.message("data not found."))
                        return
                    }
                    self.getValueResultLabel.text = "\(data.value)"
                case let .failure(error):
                    debugPrint(error)
                    self.handleGetValueError(error)
                }
            }
    }

    private func partialSign() {
        guard let userWalletAddress = userWalletAddress else {
            handlePartialSignTxError(Error.message("User address not found. Please request account first."))
            return
        }
        guard let dappPublicKey = try? PublicKey(dappAddress) else {
            return
        }
        guard let userWalletPublicKey = try? PublicKey(userWalletAddress) else {
            return
        }
        guard let programId = try? PublicKey(programId) else {
            return
        }
        guard let inputValue = inputTextField.text,
              inputValue.isEmpty == false,
              let value = UInt32(inputValue) else {
                  handlePartialSignTxError(Error.message("Input not found."))
                  return
              }

        var transaction = Transaction()
        transaction.feePayer = userWalletPublicKey

        let connetion = Connection(cluster: .devnet)
        connetion.getMinimumBalanceForRentExemption(
            dataLength: 10) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(minBalance):
                    do {
                        let newAccount = try Account()
                        let createAccountInstruction = try SystemProgram.createAccount(
                            fromPublicKey: userWalletPublicKey,
                            newAccountPublicKey: newAccount.publicKey,
                            lamports: minBalance,
                            space: 10,
                            programId: programId)
                        transaction.add(createAccountInstruction)

                        let setValueInstruction = try self.createSetValueInstruction(
                            dappPublicKey: dappPublicKey,
                            userWalletPublicKey: userWalletPublicKey,
                            programId: programId,
                            value: value)
                        transaction.add(setValueInstruction)

                        self.bloctoSolanaSDK.convertToProgramWalletTransaction(
                            transaction,
                            solanaAddress: userWalletAddress) { [weak self] result in
                                guard let self = self else { return }
                                switch result {
                                case let .success(transaction):
                                    do {
                                        var newTransaction = transaction
                                        try newTransaction.partialSign(signers: [newAccount])

                                        self.bloctoSolanaSDK.signAndSendTransaction(
                                            from: userWalletAddress,
                                            transaction: newTransaction) { [weak self] result in
                                                guard let self = self else { return }
                                                self.resetPartialSignTxStatus()
                                                switch result {
                                                case let .success(txHash):
                                                    self.partialSignTxResultLabel.text = txHash
                                                    self.partialSignTxExplorerButton.isHidden = false
                                                case let .failure(error):
                                                    self.handlePartialSignTxError(error)
                                                }
                                            }
                                    } catch {
                                        self.handlePartialSignTxError(error)
                                    }
                                case let .failure(error):
                                    self.handlePartialSignTxError(error)
                                }
                            }
                    } catch {
                        self.handlePartialSignTxError(error)
                    }
                case let .failure(error):
                    self.handlePartialSignTxError(error)
                }
            }
    }

    private func createSetValueInstruction(
        dappPublicKey: PublicKey,
        userWalletPublicKey: PublicKey,
        programId: PublicKey,
        value: UInt32
    ) throws -> TransactionInstruction {
        let valueAccountData = ValueAccountData(
            instruction: 0,
            value: value)
        guard let data = try? valueAccountData.serialize() else {
            throw Error.message("valueAccountData serialize failed.")
        }
        let transactionInstruction = TransactionInstruction(
            keys: [
                AccountMeta(
                    publicKey: dappPublicKey,
                    isSigner: false,
                    isWritable: true),
                AccountMeta(
                    publicKey: userWalletPublicKey,
                    isSigner: false,
                    isWritable: true)
            ],
            programId: programId,
            data: data)
        return transactionInstruction
    }

    private func handleRequestAccountError(_ error: Swift.Error) {
        handleGeneralError(label: requestAccountResultLabel, error: error)
        requestAccountLoadingIndicator.stopAnimating()
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

    private func handlePartialSignTxError(_ error: Swift.Error) {
        handleGeneralError(label: partialSignTxResultLabel, error: error)
        partialSignTxLoadingIndicator.stopAnimating()
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

    enum ExplorerURLType {
        case txhash(String)
        case address(String)

        func url() -> URL? {
            switch self {
            case let .txhash(hash):
                return isProduction
                ? URL(string: "https://explorer.solana.com/tx/\(hash)")
                : URL(string: "https://explorer.solana.com/tx/\(hash)?cluster=devnet")
            case let .address(address):
                return isProduction
                ? URL(string: "https://explorer.solana.com/address/\(address)")
                : URL(string: "https://explorer.solana.com/address/\(address)?cluster=devnet")
            }
        }
    }

    private func routeToExplorer(with type: ExplorerURLType) {
        guard let url = type.url() else { return }
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

extension SolanaDemoViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension SolanaDemoViewController: SFSafariViewControllerDelegate {}

extension SolanaDemoViewController {

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
