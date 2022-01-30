Pod::Spec.new do |s|
  s.name = 'SwiftDuxTestComponents'
  s.module_name = 'SwiftDuxTestComponents'
  s.version = '1.1.4'
  s.summary = 'Test components for SwiftDux framework.'
  s.homepage = 'https://github.com/jpeckner/SwiftDux'
  s.authors = { 'Justin Peckner' => 'pecknerj@gmail.com' }
  s.license = 'MIT'
  s.source = {
    :git => 'https://github.com/jpeckner/SwiftDux.git',
    :tag => 'v' + s.version.to_s
  }

  s.ios.deployment_target = '11.0'
  s.source_files = 'SwiftDuxTestComponents/**/*.swift'
  s.swift_version = '5.0'
  s.frameworks = 'XCTest'
  
  s.dependency 'SwiftDux', '' + s.version.to_s
end