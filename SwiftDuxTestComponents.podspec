Pod::Spec.new do |s|
  s.name = 'SwiftDuxTestComponents'
  s.version = '1.1.0'
  s.license = 'MIT'
  s.summary = 'Test components for SwiftDux framework.'
  s.homepage = 'https://github.com/jpeckner/SwiftDux'
  s.authors = { 'Justin Peckner' => 'pecknerj@gmail.com' }
  s.source = { :git => 'https://github.com/jpeckner/SwiftDux.git', :tag => '1.1.0' }

  s.ios.deployment_target = '11.0'
  s.source_files = 'SwiftDuxTestComponents/**/*.swift'
  s.swift_version = '5.0'
  
  s.frameworks = 'XCTest'
  s.dependency 'SwiftDux', '~> 1.0.0'
end