# BloctoSDK

[![CI Status](https://dl.circleci.com/status-badge/img/gh/portto/blocto-ios-sdk/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/portto/blocto-ios-sdk/tree/main)
[![Version](https://img.shields.io/cocoapods/v/BloctoSDK.svg?style=flat)](https://cocoapods.org/pods/BloctoSDK)
[![License](https://img.shields.io/cocoapods/l/BloctoSDK.svg?style=flat)](https://cocoapods.org/pods/BloctoSDK)
[![Platform](https://img.shields.io/cocoapods/p/BloctoSDK.svg?style=flat)](https://cocoapods.org/pods/BloctoSDK)

## Example

To run the example project, clone the repo, and run 
```
bundle install
bundle exec pod install
```
or (if Bundler not installed) 
```
pod install
```
from the Example directory first.

## Installation

### CocoaPods

BloctoSDK is available through [CocoaPods](https://cocoapods.org). You can only include specific subspec to install, simply add the following line to your Podfile:

```ruby
pod 'BloctoSDK', '~> 0.5.0'

# or 

pod 'BloctoSDK/Solana', '~> 0.5.0'

# or

pod 'BloctoSDK/EVMBase', '~> 0.5.0'

# or

pod 'BloctoSDK/Flow', '~> 0.5.0'
```

### Swift Package Manager


```swift
.package(url: "https://github.com/portto/blocto-ios-sdk.git", .upToNextMinor(from: "0.5.0"))
```

and then specify `"BloctoSDK"` as a dependency of the Target in which you wish to use.
Here's an example `PackageDescription`:

```swift
// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/portto/blocto-ios-sdk.git", .upToNextMinor(from: "0.5.0"))
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: [
                .product(name: "BloctoSDK", package: "blocto-ios-sdk"),
            ]
        )
    ]
)
```

## Usage
Currently support 
 * Solana SDK
 * EVMBase SDK (Ethereum, Avalanche, BSC, Polygon)
 * Flow SDK

For further instructions please refer to [Blocto Docs](https://docs.blocto.app/blocto-ios-sdk/overview)

## Author

Dawson, dawson@portto.com, Scott, scott@portto.com

## License

BloctoSDK is available under the MIT license. See the LICENSE file for more info.
