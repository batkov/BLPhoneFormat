#
# Be sure to run `pod lib lint BLPhoneFormat.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BLPhoneFormat"
  s.version          = "0.3.2"
  s.summary          = "Simple iOS Phone Number formatter Pod."
  s.description      = <<-DESC
                       Inspired by RMPhoneFormat and Telegram App phone formatting behavior.
                       Only few methods to detect which country code is entered and format phone number.
                       Also list of Countries with phone codes included.
                       DESC
  s.homepage         = "https://github.com/batkov/BLPhoneFormat"
  s.license          = 'MIT'
  s.author           = { "Hariton Batkov" => "batkov@i.ua" }
  s.source           = { :git => "https://github.com/batkov/BLPhoneFormat.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/batkov111'
  s.screenshots     = "https://github.com/batkov/BLPhoneFormat/blob/master/Screenshots/BLPhoneFormat.gif"
  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BLPhoneFormat' => ['Pod/Assets/**/*']
  }

end
