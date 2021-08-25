Pod::Spec.new do |s|
  s.name             = 'ConnectAd_ObjC'
  s.version          = '1.1.12'
  s.summary          = 'ConnectAd_ObjC for iOS.'
  s.description      = 'This pod is used for integrating ConnectAd_ObjC in Objective-C iOS projects.'
  
  s.homepage         = 'https://github.com/connectedinteractive/connectedadsdk_objc'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'connsdkimpl' => 'sdkimpl@gmail.com' }
  s.source           = { :git => 'https://github.com/connectedinteractive/connectedadsdk_objc.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '9.0'
  
  s.source_files = 'ConnectAd_ObjC/**/*.{h,m}'
  s.exclude_files = 'ConnectAd_ObjC/**/*.plist'
  s.resource_bundles = {
    'ConnectAd_ObjC' => ['ConnectAd_ObjC/Assets/*.png']
  }
  
  s.pod_target_xcconfig = {
    'ARCHS[sdk=iphonesimulator*]' => '$(ARCHS_STANDARD_64_BIT)'
  }
  
  s.user_target_xcconfig = {
    'ARCHS[sdk=iphonesimulator*]' => '$(ARCHS_STANDARD_64_BIT)',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
  
  
  s.static_framework = true
  
  s.dependencies = { "mopub-ios-sdk/Core": "~> 5.12.1", "Google-Mobile-Ads-SDK": "~> 8.5.0" }
end
