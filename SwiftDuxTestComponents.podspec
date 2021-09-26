Pod::Spec.new do |s|
  s.name = 'SwiftDuxTestComponents'
  s.module_name = 'SwiftDuxTestComponents'
  s.version = '1.1.1'
  s.license = 'MIT'
  s.summary = 'Test components for SwiftDux framework.'
  s.homepage = 'https://github.com/jpeckner/SwiftDux'
  s.authors = { 'Justin Peckner' => 'pecknerj@gmail.com' }
  s.source = { :git => 'https://github.com/jpeckner/SwiftDux.git', :tag => 'v1.1.1' }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.frameworks = 'XCTest'
  s.source_files = 'SwiftDuxTestComponents/**/*.swift'
  s.dependency 'SwiftDux', '1.1.1'
  s.dependency 'SwiftDuxExtensions', '1.1.1'
end