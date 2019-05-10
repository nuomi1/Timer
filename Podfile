platform :ios, "11"
use_frameworks!

target "Timer" do
  pod "BarcodeScanner"
  pod "Eureka"
  pod "FlexLayout"
  pod "MJRefresh"
  pod "R.swift"
  pod "Reusable"
  pod "Reveal-SDK", :configurations => ["Debug"]
  pod "RxCocoa"
  pod "RxSwift"
  pod "SVProgressHUD"
  pod "SnapKit"
  pod "SwiftIcons"
  pod "SwifterSwift"
  pod "SwiftyUserDefaults"
  pod "Then"
  pod "WCDB.swift"
  pod "WoodPeckeriOS", :configurations => ["Debug"]
end

post_install do |installer|

  swift_4_0 = [
    'BarcodeScanner',
  ]

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if swift_4_0.include? target.name
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end
end
