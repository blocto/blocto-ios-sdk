//
//  SolanaCreateTransactionResponse.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/15.
//

import Foundation

struct SolanaCreateTransactionResponse: Decodable {

    let rawTx: String
    let appendTx: [String: Data]?

    private enum CodingKeys: String, CodingKey {
        case rawTx = "raw_tx"
        case extraData = "extra_data"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rawTx = try container.decode(String.self, forKey: .rawTx)

        let extraData = try container.decodeIfPresent(ExtraData.self, forKey: .extraData)
        self.appendTx = extraData?.appendTx
    }
}

private struct ExtraData: Decodable {

    let appendTx: [String: Data]?

    private enum CodingKeys: String, CodingKey {
        case appendTx = "append_tx"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.appendTx = try? container.decodeStringDataDictionary(forKey: .appendTx)
    }
}
