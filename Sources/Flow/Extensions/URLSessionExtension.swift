//
//  URLSessionExtension.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/8/18.
//

import UIKit

extension URLSession {
    
    static let decoder = JSONDecoder()
    
    func dataDecode<Model: Decodable>(for request: URLRequest) async throws -> Model {
        let data = try await data(for: request)
        return try Self.decoder.decode(Model.self, from: data)
    }
    
    private func data(for request: URLRequest) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            dataTask(with: request) { data, _, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                } else if let data = data {
                    continuation.resume(with: .success(data))
                } else {
                    continuation.resume(with: .failure(BloctoSDKError.responseUnexpected))
                }
            }.resume()
        }
    }
    
}
