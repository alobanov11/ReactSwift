Pod::Spec.new do |s|
  s.name             = 'ReactSwift'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ReactSwift.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/alobanov11/ReactSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anton Lobanov' => 'alobanov11@gmail.com' }
  s.source           = { :git => 'https://github.com/alobanov11/ReactSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/**/*.{swift}'
end
