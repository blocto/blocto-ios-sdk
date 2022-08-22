//
//  BloctoSolanaSDK.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/15.
//

import Foundation
import SolanaWeb3

private var associateKey: Void?

extension BloctoSDK {

    public var solana: BloctoSolanaSDK {
        if let solanaSDK = objc_getAssociatedObject(self, &associateKey) as? BloctoSolanaSDK {
            return solanaSDK
        } else {
            let solanaSDK = BloctoSolanaSDK(base: self)
            objc_setAssociatedObject(self, &associateKey, solanaSDK, .OBJC_ASSOCIATION_RETAIN)
            return solanaSDK
        }
    }

}

public class BloctoSolanaSDK {

    private let base: BloctoSDK
    private var appendTxMap: [String: [String: Data]] = [:]

    private var cluster: Cluster {
        if base.testnet {
            return .devnet
        } else {
            return .mainnetBeta
        }
    }

    private var walletProgramId: String {
        if base.testnet {
            return "Ckv4czD7qPmQvy2duKEa45WRp3ybD2XuaJzQAWrhAour"
        } else {
            return "JBn9VwAiqpizWieotzn6FjEXrBu4fDe2XFjiFqZwp8Am"
        }
    }

    init(base: BloctoSDK) {
        self.base = base
    }

    /// To request Solana account address
    /// - Parameters:
    ///   - completion: completion handler for this methods. Please note this completion might not be called in some circumstances. e.g. SDK version incompatible with Blocto Wallet app.
    ///   The successful result is address String for Solana.
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
        session: URLSessionProtocol = URLSession(configuration: .default),
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        addRecentBlockhashIfNeeded(
            transaction) { [weak self] result in
                guard let self = self else {
                    completion(.failure(BloctoSDKError.callbackSelfNotfound))
                    return
                }
                switch result {
                case let .success(transaction):
                    do {
                        if self.transactionNeedsConvert(transaction) {
                            self.convertToProgramWalletTransaction(
                                transaction,
                                solanaAddress: from,
                                session: session
                            ) { [weak self] result in
                                guard let self = self else {
                                    completion(.failure(BloctoSDKError.callbackSelfNotfound))
                                    return
                                }
                                switch result {
                                case let .success(transaction):
                                    self.signAndSendTransaction(
                                        uuid: uuid,
                                        from: from,
                                        transaction: transaction,
                                        completion: completion
                                    )
                                case let .failure(error):
                                    completion(.failure(error))
                                }
                            }
                        } else {
                            var mutateTransaction = transaction

                            let serializeMessage = try mutateTransaction.serializeMessage()

                            let shaString = serializeMessage.sha1().bloctoSDK.hexString
                            let appendTx = self.appendTxMap[shaString]

                            let publicKeySignaturePairs = transaction.signatures.reduce([String: String]()) { partialResult, signaturePubkeyPair in
                                var result = partialResult
                                result[signaturePubkeyPair.publicKey.description] = signaturePubkeyPair.signature?.bloctoSDK.hexString
                                return result
                            }

                            let method = SignAndSendSolanaTransactionMethod(
                                id: uuid,
                                blockchain: .solana,
                                from: from,
                                transactionInfo: SolanaTransactionInfo(
                                    message: serializeMessage.bloctoSDK.hexString,
                                    appendTx: appendTx,
                                    publicKeySignaturePairs: publicKeySignaturePairs
                                ),
                                isInvokeWrapped: true,
                                callback: completion
                            )
                            self.appendTxMap[shaString] = nil
                            self.base.send(method: method)
                        }
                    } catch {
                        completion(.failure(error))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    /// Convert normal Solana transaction to wallet program executable transaction
    /// - Parameters:
    ///   - transaction: Normal Solana transaction.
    ///   - solanaAddress: Solana address invoke this transaction
    ///   - completion: Completion handler for this methods.
    public func convertToProgramWalletTransaction(
        _ transaction: Transaction,
        solanaAddress: String,
        session: URLSessionProtocol = URLSession(configuration: .default),
        completion: @escaping (Result<Transaction, Swift.Error>) -> Void
    ) {
        addRecentBlockhashIfNeeded(transaction) { [weak self] result in
            guard let self = self else {
                completion(.failure(BloctoSDKError.callbackSelfNotfound))
                return
            }
            do {
                var transaction = try result.get()
                let serializeMessage = try transaction.serializeMessage()
                let request = try RequestBuilder.build(
                    baseURLString: self.base.bloctoApiBaseURLString,
                    path: "/solana/createRawTransaction",
                    method: .post,
                    bodyParam: [
                        "sol_address": solanaAddress,
                        "raw_tx": serializeMessage.bloctoSDK.hexString,
                    ]
                )
                session
                    .dataTask(with: request) { [weak self] data, _, error in
                        DispatchQueue.main.async {
                            do {
                                guard let self = self else {
                                    throw BloctoSDKError.callbackSelfNotfound
                                }
                                if let error = error {
                                    completion(.failure(error))
                                    return
                                } else if let data = data {
                                    let createTransactionResponse = try JSONDecoder().decode(SolanaCreateTransactionResponse.self, from: data)
                                    
                                    let message = try Message(data: createTransactionResponse.rawTx.bloctoSDK.hexDecodedData)
                                    var convertedTransaction = Transaction(message: message, signatures: [])
                                    
                                    let serializeMessage = try convertedTransaction.serializeMessage()
                                    let shaString = serializeMessage.sha1().bloctoSDK.hexString
                                    self.appendTxMap[shaString] = createTransactionResponse.appendTx
                                    completion(.success(convertedTransaction))
                                } else {
                                    completion(.failure(BloctoSDKError.invalidResponse))
                                }
                            } catch {
                                completion(.failure(error))
                            }
                        }
                    }.resume()
            } catch {
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
        let connection = Connection(cluster: cluster)
        connection.getLatestBlockhash(commitment: .confirmed) { result in
            switch result {
            case let .success(blockhashLastValidBlockHeightPair):
                var newTransaction = transaction
                newTransaction.recentBlockhash = blockhashLastValidBlockHeightPair.blockhash
                completion(.success(newTransaction))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func transactionNeedsConvert(_ transaction: Transaction) -> Bool {
        transaction.instructions.allSatisfy { TransactionInstruction in
            TransactionInstruction.programId.description != walletProgramId
        }
    }

}
