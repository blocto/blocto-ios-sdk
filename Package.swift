// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BloctoSDK",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "BloctoSDK",
            targets: ["BloctoSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMinor(from: "14.0.0")),
        .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/portto/solana-web3.swift", .upToNextMinor(from: "0.0.4")),
    ],
    targets: [
        .target(
            name: "BloctoSDK",
            dependencies: [
                "BigInt",
                "Moya",
                .product(name: "SolanaWeb3", package: "solana-web3.swift"),
            ],
            path: "Sources"
        ),
    ]
)
