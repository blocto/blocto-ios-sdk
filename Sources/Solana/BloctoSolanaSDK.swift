//
//  BloctoSolanaSDK.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/15.
//

import Foundation
import SolanaWeb3

extension BloctoSDK {

    public var solana: BloctoSolanaSDK {
        BloctoSolanaSDK(base: self)
    }

}

public class BloctoSolanaSDK {

    private let base: BloctoSDK
    private let apiProvider: ApiProvider?
    private var appendTxMap: [String: [String: Data]] = [:]

    init(
        base: BloctoSDK,
        apiProvider: ApiProvider? = ApiProvider()
    ) {
        self.base = base
        self.apiProvider = apiProvider
    }

    public func requestAccount(completion: @escaping (Result<String, Swift.Error>) -> Void) {
        let method = RequestAccountMethod(blockchain: .solana, callback: completion)
        base.send(method: method)
    }

    /// To sign transaction and then send transaction
    /// - Parameters:
    ///   - uuid: The id to identify this request, you can pass your owned uuid here.
    ///   - from: from which solana account address.
    ///   - transaction: Solana Transaction structure from Web3.
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    ///   The successful result is Tx hash of Solana.
    public func signAndSendTransaction(
        uuid: UUID = UUID(),
        from: String,
        transaction: Transaction,
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        addRecentBlockhashIfNeeded(
            transaction) { [weak self] result in
                guard let self = self else {
                    completion(.failure(Error.callbackSelfNotfound))
                    return
                }
                switch result {
                    case .success(let transaction):
                        do {
                            if self.transactionNeedsConvert(transaction) {
                                guard let apiProvider = self.apiProvider else {
                                    log(
                                        enable: self.base.logging,
                                        message: "This transaction needs to convert to wallet program executable one, please provide a api provider to proceed.")
                                    throw Error.apiProviderNotFound
                                }
                                self.convertToProgramWalletTransaction(
                                    transaction,
                                    solanaAddress: from,
                                    apiProvider: apiProvider) { [weak self] result in
                                        guard let self = self else {
                                            completion(.failure(Error.callbackSelfNotfound))
                                            return
                                        }
                                        switch result {
                                            case .success(let transaction):
                                                self.signAndSendTransaction(
                                                    uuid: uuid,
                                                    from: from,
                                                    transaction: transaction,
                                                    completion: completion)
                                            case .failure(let error):
                                                completion(.failure(error))
                                        }
                                    }
                            } else {
                                var mutateTransaction = transaction

                                let serializeMessage = try mutateTransaction.serializeMessage()

                                let shaString = serializeMessage.sha1().hexString
                                let appendTx = self.appendTxMap[shaString]

                                let publicKeySignaturePairs = transaction.signatures.reduce([String: String]()) { partialResult, signaturePubkeyPair in
                                    var result = partialResult
                                    result[signaturePubkeyPair.publicKey.description] = signaturePubkeyPair.signature?.hexString
                                    return result
                                }

                                let method = SignAndSendSolanaTransactionMethod(
                                    id: uuid,
                                    blockchain: .solana,
                                    from: from,
                                    transactionInfo: SolanaTransactionInfo(
                                        message: serializeMessage.hexString,
                                        appendTx: appendTx,
                                        publicKeySignaturePairs: publicKeySignaturePairs),
                                    isInvokeWrapped: true,
                                    callback: completion)
                                self.appendTxMap[shaString] = nil
                                self.base.send(method: method)
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
    }

    func addRecentBlockhashIfNeeded(
        _ transaction: Transaction,
        completion: @escaping (Result<Transaction, Swift.Error>) -> Void
    ) {
        guard transaction.recentBlockhash == nil else {
            completion(.success(transaction))
            return
        }
        let connection = Connection(endpointURL: AppConstants.solanaRPCEndpoint)
        connection.getLatestBlockhash(commitment: .confirmed) { result in
            switch result {
                case .success(let blockhashLastValidBlockHeightPair):
                    var newTransaction = transaction
                    newTransaction.recentBlockhash = blockhashLastValidBlockHeightPair.blockhash
                    completion(.success(newTransaction))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    func transactionNeedsConvert(_ transaction: Transaction) -> Bool {
        transaction.instructions.allSatisfy { TransactionInstruction in
            TransactionInstruction.programId.description != AppConstants.walletProgramIds
        }
    }

    func convertToProgramWalletTransaction(
        _ transaction: Transaction,
        solanaAddress: String,
        apiProvider: ApiProvider,
        completion: @escaping (Result<Transaction, Swift.Error>) -> Void
    ) {
        do {
            var transaction = transaction
            let serializeMessage = try transaction.serializeMessage()
            let request = ConvertTransactionRequest(
                solanaAddress: solanaAddress,
                message: serializeMessage.hexString)
            _ = apiProvider.request(request) { [weak self] result in
                switch result {
                    case let .success(response):
                        do {
                            let createTransactionResponse = try JSONDecoder().decode(SolanaCreateTransactionResponse.self, from: response.data)

                            let message = try Message(data: createTransactionResponse.rawTx.hexDecodedData)
                            let convertedTransaction = Transaction(message: message, signatures: [])
                            let data = createTransactionResponse.rawTx.hexDecodedData.sha1()
                            self?.appendTxMap[data.hexString] = createTransactionResponse.appendTx
                            completion(.success(convertedTransaction))
                        } catch {
                            completion(.failure(error))
                        }
                    case let .failure(error):
                        completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

}
