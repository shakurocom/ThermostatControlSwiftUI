# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'

target 'ThermostatControlSwiftUI' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ThermostatControlSwiftUI

pod 'lottie-ios', '4.4.0'
pod 'SwiftLint', '0.54.0'
pod 'Shakuro.CommonTypes', '1.1.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
