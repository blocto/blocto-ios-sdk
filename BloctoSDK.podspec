Pod::Spec.new do |s|
  s.name             = 'BloctoSDK'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BloctoSDK.'

  s.description      = <<-DESC
                       Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/portto/blocto-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dawson' => 'dawson@portto.com', 'Scott' => 'scott@portto.com' }
  s.source           = { :git => 'https://github.com/portto/blocto-ios-sdk.git', :tag => s.version.to_s }
  s.default_subspec = "Core"
  s.social_media_url = 'https://twitter.com/BloctoApp'

  s.ios.deployment_target = '12.0'

  s.subspec "Core" do |ss|
      ss.source_files  = "Sources/Core/**/*"
      ss.framework  = "Foundation"
      ss.dependency "SolanaWeb3"
  end
  
  s.subspec "Solana" do |ss|
      ss.source_files = "Sources/Solana/**/*"
      ss.dependency "BloctoSDK/Core"
      ss.dependency "RxSwift", "~> 6.0"
  end
  
  s.subspec "Wallet" do |ss|
    ss.source_files = "Sources/Wallet/**/*"
    ss.dependency "BloctoSDK/Core"
  end

end
