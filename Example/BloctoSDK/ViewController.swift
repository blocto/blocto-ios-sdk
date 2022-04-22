//
//  ViewController.swift
//  BloctoSDK
//
//  Created by scottphc on 01/12/2022.
//  Copyright (c) 2022 scottphc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import BloctoSDK
import SolanaWeb3

final class ViewController: UIViewController {

    private var userWalletAddress: String?
    private let dappAddress: String = "4AXy5YYCXpMapaVuzKkz25kVHzrdLDgKN3TiQvtf1Eu8"
    private let programId: String = "G4YkbRN4nFQGEUg4SXzPsrManWzuk8bNq9JaMhXepnZ6"

    private lazy var bloctoSolanaSDK = BloctoSDK.shared.solana

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

        view.addSubview(separator1)

        view.addSubview(setValueTitleLabel)
        view.addSubview(inputTextField)
        view.addSubview(setValueButton)
        view.addSubview(setValueResultLabel)

        view.addSubview(separator2)

        view.addSubview(getValueTitleLabel)
        view.addSubview(getValueButton)
        view.addSubview(getValueResultLabel)

        view.addSubview(separator3)

        view.addSubview(partialSignTxTitleLabel)
        view.addSubview(partialSignTxButton)
        view.addSubview(partialSignTxResultLabel)

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
            $0.leading.trailing.equalToSuperview().inset(20)
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
            $0.leading.trailing.equalToSuperview().inset(20)
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
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
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

    private lazy var separator1 = createSeparator()

    private lazy var setValueTitleLabel: UILabel = createLabel(text: "Set a Value")

    private lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.backgroundColor = .lightGray
        textField.text = "5566"
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

    private lazy var separator2 = createSeparator()

    private lazy var getValueTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Get a Value from Account's Data"
        return label
    }()

    private lazy var getValueButton: UIButton = createButton(
        text: "Get Value",
        indicator: getValueLoadingIndicator)
    
    private lazy var getValueLoadingIndicator = createLoadingIndicator()

    private lazy var getValueResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
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
        return label
    }()

    private lazy var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBinding()
    }

    private func setupViews() {
        view.backgroundColor = .white

        view.addSubview(scrollView)

        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.width.equalTo(view)
        }
    }

    private func setupBinding() {
        _ = requestAccountButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.resetRequestAccountStatus()
                self?.bloctoSolanaSDK.requestAccount { [weak self] result in
                    switch result {
                        case .success(let address):
                            self?.userWalletAddress = address
                            self?.requestAccountResultLabel.text = address
                        case .failure(let error):
                            self?.handleSetValueError(error)
                    }
                }
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
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private func createButton(text: String, indicator: UIActivityIndicatorView) -> UIButton {
        let button: UIButton = UIButton()
        button.setTitle("Send transaction", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = .init(top: 12, left: 35, bottom: 12, right: 35)
        
        button.addSubview(indicator)
        
        indicator.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
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
    }
    
    private func resetSetValueStatus() {
        setValueResultLabel.text = nil
        setValueResultLabel.textColor = .black
        setValueLoadingIndicator.stopAnimating()
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
        let valueAccountData = ValueAccountData(
            instruction: 0,
            value: value)
        guard let data = try? valueAccountData.serialize() else {
            return
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
        var transaction = Transaction()
        transaction.add(transactionInstruction)
        transaction.feePayer = userWalletPublicKey

        bloctoSolanaSDK.signAndSendTransaction(
            from: userWalletAddress,
            transaction: transaction) { [weak self] result in
                switch result {
                    case let .success(txHsh):
                        self?.setValueResultLabel.text = txHsh
                    case let .failure(error):
                        self?.handleSetValueError(error)
                }
            }
    }
    
    private func getValue() {
        guard let dappPublicKey = try? PublicKey(dappAddress) else {
            return
        }
        
        let connetion = Connection(endpointURL: AppConsts.solanaRPCEndpoint)
        connetion.getAccountInfo(
            publicKey: dappPublicKey) { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case let .success(accountInfo):
                        guard let data = accountInfo?.data else {
                            self.handleGetValueError(Error.message("data not found."))
                        }
                        var pointer = 0
                        do {
                            let valueAccountData = try ValueAccountData(buffer: data, pointer: &pointer)
                            self.getValueResultLabel.text = "\(valueAccountData.value)"
                        } catch {
                            self.handleGetValueError(error)
                        }
                    case let .failure(error):
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
        let valueAccountData = ValueAccountData(
            instruction: 0,
            value: value)
        guard let data = try? valueAccountData.serialize() else {
            return
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
        var transaction = Transaction()
        transaction.add(transactionInstruction)
        transaction.feePayer = userWalletPublicKey
        
        let connetion = Connection(endpointURL: AppConsts.solanaRPCEndpoint)
        connetion.getMinimumBalanceForRentExemption(
            dataLength: 10) { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case let .success(minBalance):
                        do {
                            var newAccount = try Account()
                            let createAccountInstruction = try SystemProgram.createAccount(
                                fromPublicKey: userWalletPublicKey,
                                newAccountPublicKey: newAccount.publicKey,
                                lamports: minBalance,
                                space: 10,
                                programId: programId)
                            transaction.add(createAccountInstruction)
                            
                            self.bloctoSolanaSDK.convertToProgramWalletTransaction(
                                transaction,
                                solanaAddress: userWalletAddress) { [weak self] result in
                                    guard let self = self else { return }
                                    switch result {
                                        case let .success(transaction):
                                            var newTransaction = transaction
                                            newTransaction.partialSign(signers: [newAccount])
                                            
                                            self.bloctoSolanaSDK.signAndSendTransaction(
                                                from: userWalletAddress,
                                                transaction: newTransaction) { [weak self] result in
                                                    guard let self = self else { return }
                                                    switch result {
                                                        case let .success(txHash):
                                                            self.partialSignTxResultLabel.text = txHash
                                                        case let .failure(error):
                                                            self.handlePartialSignTxError(error)
                                                    }
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
    
    private func handleRequestAccountError(_ error: Swift.Error) {
        if let error = error as? QueryError {
            switch error {
                case .userRejected:
                    requestAccountResultLabel.text = "user rejected."
                case .forbiddenBlockchain:
                    requestAccountResultLabel.text = "Forbidden blockchain. You should check blockchain selection on Blocto developer dashboard."
                case .invalidResponse:
                    requestAccountResultLabel.text = "invalid response."
                case .userNotMatch:
                    requestAccountResultLabel.text = "user not matched."
                case .other(let code):
                    requestAccountResultLabel.text = code
            }
        } else if let error = error as? Error {
            requestAccountResultLabel.text = error.message
        } else {
            requestAccountResultLabel.text = error.localizedDescription
        }
        requestAccountResultLabel.textColor = .red
        requestAccountLoadingIndicator.stopAnimating()
    }

    private func handleSetValueError(_ error: Swift.Error) {
        if let error = error as? QueryError {
            switch error {
                case .userRejected:
                    setValueResultLabel.text = "user rejected."
                case .forbiddenBlockchain:
                    setValueResultLabel.text = "Forbidden blockchain. You should check blockchain selection on Blocto developer dashboard."
                case .invalidResponse:
                    setValueResultLabel.text = "invalid response."
                case .userNotMatch:
                    setValueResultLabel.text = "user not matched."
                case .other(let code):
                    setValueResultLabel.text = code
            }
        } else if let error = error as? Error {
            setValueResultLabel.text = error.message
        } else {
            setValueResultLabel.text = error.localizedDescription
        }
        setValueResultLabel.textColor = .red
        setValueLoadingIndicator.stopAnimating()
    }
    
    private func handleGetValueError(_ error: Swift.Error) {
        getValueResultLabel.text = error.localizedDescription
        getValueResultLabel.textColor = .red
        getValueLoadingIndicator.stopAnimating()
    }
    
    private func handlePartialSignTxError(_ error: Swift.Error) {
        if let error = error as? QueryError {
            switch error {
                case .userRejected:
                    partialSignTxResultLabel.text = "user rejected."
                case .forbiddenBlockchain:
                    partialSignTxResultLabel.text = "Forbidden blockchain. You should check blockchain selection on Blocto developer dashboard."
                case .invalidResponse:
                    partialSignTxResultLabel.text = "invalid response."
                case .userNotMatch:
                    partialSignTxResultLabel.text = "user not matched."
                case .other(let code):
                    partialSignTxResultLabel.text = code
            }
        } else if let error = error as? Error {
            partialSignTxResultLabel.text = error.message
        } else {
            partialSignTxResultLabel.text = error.localizedDescription
        }
        partialSignTxResultLabel.textColor = .red
        partialSignTxLoadingIndicator.stopAnimating()
    }

}

extension ViewController {
    
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
