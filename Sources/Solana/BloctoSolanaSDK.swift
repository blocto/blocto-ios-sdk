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

    var sessionId: String?
    private let base: BloctoSDK
    private var appendTxMap: [String: [String: Data]] = [:]

    private var cluster: Cluster {
        switch base.environment {
        case .dev:
            return .devnet
        case .prod:
            return .mainnetBeta
        }
    }

    private var walletProgramId: String {
        switch base.environment {
        case .dev:
            return "Ckv4czD7qPmQvy2duKEa45WRp3ybD2XuaJzQAWrhAour"
        case .prod:
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
        let method = RequestAccountMethod(
            blockchain: .solana,
            callback: { [weak self] result in
                switch result {
                case let .success((address, sessionId)):
                    self?.sessionId = sessionId
                    completion(.success(address))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        )
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
        session: URLSessionProtocol = URLSession.shared,
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
                        let txConverted = self.transactionIsConverted(transaction)
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
                            sessionId: self.sessionId,
                            blockchain: .solana,
                            from: from,
                            transactionInfo: SolanaTransactionInfo(
                                message: serializeMessage.bloctoSDK.hexString,
                                appendTx: appendTx,
                                publicKeySignaturePairs: publicKeySignaturePairs
                            ),
                            isInvokeWrapped: txConverted,
                            session: session,
                            callback: completion
                        )
                        self.appendTxMap[shaString] = nil
                        if Thread.isMainThread {
                            self.base.send(method: method)
                        } else {
                            DispatchQueue.main.async {
                                self.base.send(method: method)
                            }
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
        session: URLSessionProtocol = URLSession.shared,
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
                let transactionInfo = TransactionInfo(
                    solAddress: solanaAddress,
                    rawTx: serializeMessage.bloctoSDK.hexString
                )
                let request = try RequestBuilder.build(
                    baseURLString: self.base.bloctoApiBaseURLString,
                    path: "/solana/createRawTransaction",
                    method: .post,
                    bodyParam: transactionInfo
                )
                Task {
                    do {
                        let createTransactionResponse: SolanaCreateTransactionResponse = try await session.asyncDataTask(with: request)
                        let message = try Message(data: createTransactionResponse.rawTx.bloctoSDK.hexDecodedData)
                        var convertedTransaction = Transaction(message: message, signatures: [])

                        let serializeMessage = try convertedTransaction.serializeMessage()
                        let shaString = serializeMessage.sha1().bloctoSDK.hexString
                        self.appendTxMap[shaString] = createTransactionResponse.appendTx
                        completion(.success(convertedTransaction))
                    } catch {
                        completion(.failure(error))
                    }
                }
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

    func transactionIsConverted(_ transaction: Transaction) -> Bool {
        transaction.instructions.contains(where: { $0.programId.description == walletProgramId })
    }

}

extension BloctoSolanaSDK {

    struct TransactionInfo: Encodable {
        let solAddress: String
        let rawTx: String

        enum CodingKeys: String, CodingKey {
            case solAddress = "sol_address"
            case rawTx = "raw_tx"
        }
    }

}
