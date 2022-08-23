#!/bin/sh

BUMPED_VERSION="$1"

sed -i '' -e 's/s.version          \= [^\;]*/s.version          = '"'$BUMPED_VERSION'"'/' ../BloctoSDK.podspec
sed -i '' -e 's/ss.dependency "BloctoSDK\/Core", "~> [^\;]*"/ss.dependency "BloctoSDK\/Core", "~> '"$BUMPED_VERSION"'"/' ../BloctoSDK.podspec
sed -i '' -e 's/return "[^\;]*"/return "'"$BUMPED_VERSION"'"/' ../Sources/Solana/SDKInfo.swift
