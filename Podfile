source 'https://github.com/tourmalinelabs/iOSTLKitSDK.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'

use_frameworks!
inhibit_all_warnings!

target 'TLKitExample' do
  pod 'TLKit'
  pod 'SVProgressHUD'
end

################################################################################

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end

################################################################################
