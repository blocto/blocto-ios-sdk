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

    private var textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.backgroundColor = .systemGray
        textField.text = "5566"
        return textField
    }()

    private var sendButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("send transaction", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }()

    private lazy var txLabel: UILabel = {
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

    private lazy var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBinding()
    }

    private func setupViews() {
        view.backgroundColor = .white

        view.addSubview(requestAccountButton)
        view.addSubview(accountTextLabel)
        view.addSubview(textField)
        view.addSubview(sendButton)
        view.addSubview(txLabel)
        view.addSubview(errorLabel)

        requestAccountButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
        }

        accountTextLabel.snp.makeConstraints {
            $0.top.equalTo(requestAccountButton.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(accountTextLabel.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
        }

        sendButton.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
        }

        txLabel.snp.makeConstraints {
            $0.top.equalTo(sendButton.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
        }

        errorLabel.snp.makeConstraints {
            $0.top.equalTo(txLabel.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
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
                BloctoSDK.shared.solana.requestAccount { [weak self] result in
                    switch result {
                        case .success(let address):
                            self?.userWalletAddress = address
                            self?.accountTextLabel.text = address
                        case .failure(let error):
                            if let error = error as? QueryError {
                                self?.handleError(error)
                            }
                    }
                }
            })

        _ = sendButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.sendTransaction()
            })
    }

    var solanaBloctoSDK = BloctoSDK.shared.solana

    private func sendTransaction() {
        guard let userWalletAddress = userWalletAddress else { return }
        guard let dappPublicKey = try? PublicKey(dappAddress) else { return }
        guard let userWalletPublicKey = try? PublicKey(userWalletAddress) else { return }
        guard let programId = try? PublicKey(programId) else { return }
        guard let inputValue = textField.text,
            inputValue.isEmpty == false else { return }
        let valueAccountData = ValueAccountData(
            instruction: 0,
            value: inputValue)
        guard let data = try? valueAccountData.serialize() else { return }
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
                switch result {
                    case let .success(txHsh):
                        self?.txLabel.text = txHsh
                    case let .failure(error):
                        self?.handleError(.other(code: error.localizedDescription))
                }
            }
    }

    private func handleError(_ error: QueryError) {
        switch error {
            case .userRejected:
                errorLabel.text = "user rejected."
            case .forbiddenBlockchain:
                errorLabel.text = "Forbidden blockchain. You should check blockchain selection on Blocto developer dashboard."
            case .invalidResponse:
                errorLabel.text = "invalid response"
            case .other(let code):
                errorLabel.text = code
        }
    }

}

struct ValueAccountData: BufferLayout {
    let instruction: Int
    let value: String
}
