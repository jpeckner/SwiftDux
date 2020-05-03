Pod::Spec.new do |s|
  s.name = 'SwiftDuxExtensions'
  s.version = '1.1.0'
  s.license = 'MIT'
  s.summary = 'Generic components that complement the core SwiftDux package.'
  s.homepage = 'https://github.com/jpeckner/SwiftDux'
  s.authors = { 'Justin Peckner' => 'pecknerj@gmail.com' }
  s.source = { :git => 'https://github.com/jpeckner/SwiftDux.git', :tag => '1.1.0' }

  s.ios.deployment_target = '11.0'
  s.source_files = 'SwiftDuxExtensions/**/*.swift'
  s.swift_version = '5.0'
end