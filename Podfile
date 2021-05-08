# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'GroceryShopping' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Table View Animations
  pod 'ViewAnimator', '2.7.1'
  
  # Authentication
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'
  
  # Regular Animations
  pod 'lottie-ios'
  
  # Store and Item Storing
  pod 'Firebase/Database'

end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
  end
 end
end
