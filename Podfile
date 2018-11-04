source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

target 'SwordsExpress' do
    platform :ios, '10.3'
    pod 'Whisper', :git => 'https://github.com/treatwell-marius/Whisper.git', :branch => 'feature/iphone-x-fixes'
    pod 'SwiftyJSON'
    pod 'RevealingSplashView'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'Crashlytics'

    target 'SwordsExpressTests' do
	inherit! :search_paths
	pod 'Firebase'
    end
end
