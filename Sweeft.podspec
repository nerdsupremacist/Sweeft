Pod::Spec.new do |s|
  s.name             = 'Sweeft'
  s.version          = '0.14.3'
  s.summary          = 'Swift but a bit Sweeter - More Syntactic Sugar for Swift'

  s.description      = "A collection of different operators and extensions that make writing in Swift a bit sweeter."

  s.homepage         = 'https://github.com/mathiasquintero/Sweeft'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mathias Quintero' => 'mathias.quintero@tum.de' }
  s.source           = { :git => 'https://github.com/mathiasquintero/Sweeft.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sifrinoimperial'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.2' }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'

  s.source_files = 'Sources/Sweeft/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = ['Foundation', 'Security']
  # s.dependency 'AFNetworking', '~> 2.3'
end
