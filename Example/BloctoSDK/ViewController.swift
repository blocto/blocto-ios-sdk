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

    private var solanaBloctoSDK = BloctoSDK.shared.solana

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
        view.addSubview(accountTextLabel)

        view.addSubview(separator1)

        view.addSubview(setValueTitleLabel)
        view.addSubview(inputTextField)
        view.addSubview(setValueButton)
        view.addSubview(setValueResultLabel)
        view.addSubview(errorLabel)

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

        accountTextLabel.snp.makeConstraints {
            $0.top.equalTo(requestAccountButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        separator1.snp.makeConstraints {
            $0.top.equalTo(accountTextLabel.snp.bottom).offset(20)
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

        errorLabel.snp.makeConstraints {
            $0.top.equalTo(setValueResultLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        separator2.snp.makeConstraints {
            $0.top.equalTo(errorLabel.snp.bottom).offset(20)
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

    private var requestAccountButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("request account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        return button
    }()

    private lazy var accountTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var separator1 = createSeparator()

    private lazy var setValueTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Set a Value"
        return label
    }()

    private var inputTextField: UITextField = {
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

    private lazy var setValueButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Send transaction", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)

        button.addSubview(loadingIndicator)

        loadingIndicator.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        return button
    }()

    private lazy var setValueResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .red
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
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

    private var getValueButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Get Value", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        return button
    }()

    private lazy var getValueResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()

    private lazy var separator3 = createSeparator()

    private lazy var partialSignTxTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Create Account/Send Transaction (partialSign)"
        return label
    }()

    private var partialSignTxButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Send partial sign tx", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        return button
    }()

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
                self?.solanaBloctoSDK.requestAccount { [weak self] result in
                    switch result {
                        case .success(let address):
                            self?.userWalletAddress = address
                            self?.accountTextLabel.text = address
                        case .failure(let error):
                            self?.handleError(error)
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
                self.loadingIndicator.startAnimating()
                self.setValueButton.isEnabled = false
                self.errorLabel.text = nil
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
                self.resetSendButton()
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

    private func resetSendButton() {
        errorLabel.text = nil
        setValueButton.isEnabled = true
        loadingIndicator.stopAnimating()
    }

    private func sendTransaction() {
        guard let userWalletAddress = userWalletAddress else {
            resetSendButton()
            return
        }
        guard let dappPublicKey = try? PublicKey(dappAddress) else {
            resetSendButton()
            return
        }
        guard let userWalletPublicKey = try? PublicKey(userWalletAddress) else {
            resetSendButton()
            return
        }
        guard let programId = try? PublicKey(programId) else {
            resetSendButton()
            return
        }
        guard let inputValue = inputTextField.text,
              inputValue.isEmpty == false,
              let value = UInt32(inputValue) else {
                  resetSendButton()
                  return
              }
        let valueAccountData = ValueAccountData(
            instruction: 0,
            value: value)
        guard let data = try? valueAccountData.serialize() else {
            resetSendButton()
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

        solanaBloctoSDK.signAndSendTransaction(
            from: userWalletAddress,
            transaction: transaction) { [weak self] result in
                self?.resetSendButton()
                switch result {
                    case let .success(txHsh):
                        self?.setValueResultLabel.text = txHsh
                    case let .failure(error):
                        self?.handleError(error)
                }
            }
    }

    private func handleError(_ error: Swift.Error) {
        if let error = error as? QueryError {
            switch error {
                case .userRejected:
                    errorLabel.text = "user rejected."
                case .forbiddenBlockchain:
                    errorLabel.text = "Forbidden blockchain. You should check blockchain selection on Blocto developer dashboard."
                case .invalidResponse:
                    errorLabel.text = "invalid response."
                case .userNotMatch:
                    errorLabel.text = "user not matched."
                case .other(let code):
                    errorLabel.text = code
            }
        } else {
            errorLabel.text = error.localizedDescription
        }
    }

}

struct ValueAccountData: BufferLayout {
    let instruction: UInt8
    let value: UInt32
}
