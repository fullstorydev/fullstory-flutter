#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fullstory_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fullstory_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Fullstory support for Flutter on iOS.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'fullstory_flutter/Sources/fullstory_flutter/**/*.swift'
  s.dependency 'Flutter'
  # The Flutter capture bridge is released and tested in lockstep with the
  # native SDK. Update this exact pin and Package.swift together.
  s.dependency 'FullStory', '1.72.1'
  s.platform = :ios, '13.0'
  s.static_framework = true
  s.vendored_frameworks = 'fullstory_flutter/shared_flutter.xcframework'
  s.user_target_xcconfig = {
    # Prevents stripping of all symbols, keeps dynamic symbols.
    'STRIP_STYLE' => 'non-global',
    # Disables stripping of unused code.
    'DEAD_CODE_STRIPPING' => 'NO'
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'fullstory_flutter_privacy' => ['fullstory_flutter/Sources/fullstory_flutter/Resources/PrivacyInfo.xcprivacy']}
end
