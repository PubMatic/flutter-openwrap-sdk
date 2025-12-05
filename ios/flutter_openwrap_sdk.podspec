#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_openwrap_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_openwrap_sdk'
  s.version          = '1.0.0'
  s.summary          = 'OpenWrap SDK Flutter plugin.'
  s.description      = <<-DESC
  OpenWrap SDK Flutter plugin.
                       DESC
  s.homepage         = 'https://git.pubmatic.com/PubMatic/flutter-openwrap-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'PubMatic' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'OpenWrapSDK','~> 4.10.0'
  s.static_framework = true
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
