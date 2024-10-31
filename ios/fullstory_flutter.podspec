#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fullstory_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fullstory_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Fullstory for Flutter Mobile Apps'
  s.description      = <<-DESC
Fullstory for Flutter Mobile Apps.
                       DESC
  s.homepage         = 'https://www.fullstory.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Fullstory, Inc.' => 'mobile-support@fullstory.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FullStory', '~> 1.54'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'fullstory_flutter_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
