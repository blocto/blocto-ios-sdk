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
        .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMinor(from: "5.2.0")),
        .package(url: "https://github.com/portto/solana-web3.swift", .upToNextMinor(from: "0.0.4")),
        .package(url: "https://github.com/portto/flow-swift-sdk.git", .upToNextMajor(from: "0.4.0")),
    ],
    targets: [
        .target(
            name: "BloctoSDK",
            dependencies: [
                "BigInt",
                .product(name: "SolanaWeb3", package: "solana-web3.swift"),
                .product(name: "FlowSDK", package: "flow-swift-sdk"),
            ],
            path: "Sources"
        ),
    ]
)
