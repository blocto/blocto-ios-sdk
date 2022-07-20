Pod::Spec.new do |s|
  s.name             = 'BloctoSDK'
  s.version          = '0.2.2'
  s.summary          = 'A SDK to interact with Blockchain through Blocto Wallet App.'

  s.homepage         = 'https://github.com/portto/blocto-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dawson' => 'dawson@portto.com', 'Scott' => 'scott@portto.com' }
  s.source           = { :git => 'https://github.com/portto/blocto-ios-sdk.git', :tag => s.version.to_s }
  s.default_subspec = "Core"
  s.social_media_url = 'https://twitter.com/BloctoApp'

  s.swift_version = '5.0.0'
  s.ios.deployment_target = '13.0'

  s.subspec "Core" do |ss|
      ss.source_files  = "Sources/Core/**/*"
      ss.framework  = "Foundation"
  end
  
  s.subspec "Solana" do |ss|
      ss.source_files = "Sources/Solana/**/*"
      ss.dependency "BloctoSDK/Core"
      ss.dependency "SolanaWeb3", "~> 0.0.4"
      ss.dependency "Moya", "~> 14.0.0"
  end
  
  s.subspec "EVMBase" do |ss|
      ss.source_files = "Sources/EVMBase/**/*"
      ss.dependency "BloctoSDK/Core"
      ss.dependency "BigInt", "~> 5.0"
  end
  
  s.subspec "Flow" do |ss|
      ss.source_files = "Sources/Flow/**/*"
      ss.dependency "BloctoSDK/Core"
  end
  
  s.subspec "Wallet" do |ss|
      ss.source_files = "Sources/Wallet/*",
      "Sources/Solana/Models/SolanaMethodType.swift",
      "Sources/Solana/Models/SolanaMethodContentType.swift",
      "Sources/Solana/Models/SolanaTransactionInfo.swift",
      "Sources/EVMBase/Models/EVMBaseMethodType.swift",
      "Sources/EVMBase/Models/EVMBaseMethodContentType.swift",
      "Sources/EVMBase/Models/EVMBaseTransaction.swift",
      "Sources/EVMBase/Models/SignType.swift",
      "Sources/Flow/Models/FlowMethodType.swift",
      "Sources/Flow/Models/FlowMethodContentType.swift",
      "Sources/Flow/Models/CompositeSignature.swift",
      "Sources/Flow/Models/AccountProofData.swift",
      "Sources/Flow/Models/FlowSignatureType.swift"
      ss.dependency "BloctoSDK/Core", "~> 0.2.0"
      ss.dependency "BigInt", "~> 5.0"
  end

end
