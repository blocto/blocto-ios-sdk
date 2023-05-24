#!/bin/sh

if pod spec lint ./BloctoSDK.podspec
then 
    echo "lint suceess"
else
    echo "failed"
    exit 0
fi

BUMPED_VERSION="$1"

sed -i '' -e 's/s.version          \= [^\;]*/s.version          = '"'$BUMPED_VERSION'"'/' BloctoSDK.podspec
sed -i '' -e 's/ss.dependency "BloctoSDK\/Core", "~> [^\;]*"/ss.dependency "BloctoSDK\/Core", "~> '"$BUMPED_VERSION"'"/' BloctoSDK.podspec
sed -i '' -e 's/return "[^\;]*"/return "'"$BUMPED_VERSION"'"/' Sources/Solana/SDKInfo.swift

# docs
sed -i '' -e 's/, '\''~> [^\;]*'\''/, '\''~> '$BUMPED_VERSION''\''/' README.md
sed -i '' -e 's/.package(url: "https:\/\/github.com\/portto\/blocto-ios-sdk.git", .upToNextMinor(from: [^\;]*))/.package(url: "https:\/\/github.com\/portto\/blocto-ios-sdk.git", .upToNextMinor(from: "'$BUMPED_VERSION'"))/' README.md

# commit all changes
git add BloctoSDK.podspec README.md Sources/Solana/SDKInfo.swift
git commit -m "Bump version"
git push origin main

# add tag and push to remote
git tag $BUMPED_VERSION
git push origin $BUMPED_VERSION

# publish cocoapods
pod trunk push BloctoSDK.podspec --allow-warnings