#
# Be sure to run `pod lib lint Tremolo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Tremolo'
  s.version          = '1.0.1'
  s.summary          = 'An iOS Networking framework for handling recoverable network calls.'
  s.swift_versions   = ['5.0', '5.1', '5.2']

  s.description      = <<-DESC
A good software must provide best possible user experience that technology can provide. With that mind state, Tremolo aims make recoverable network api errors easier to handle, such as invalid or expired session, logged out users, etc.
                       DESC

  s.homepage         = 'https://github.com/ismailbozk/Tremolo'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ismailbozk' => 'ismailbozk@gmail.com' }
  s.source           = { :git => 'https://github.com/ismailbozk/Tremolo.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Tremolo/Classes/**/*'

end
