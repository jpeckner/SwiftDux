Pod::Spec.new do |s|
  s.name = 'SwiftDux'
  s.version = '1.0.2'
  s.license = 'MIT'
  s.summary = 'SwiftDux is a straightforward, thread-safe implementation of Redux in Swift.'
  s.homepage = 'https://github.com/jpeckner/SwiftDux'
  s.authors = { 'Justin Peckner' => 'pecknerj@gmail.com' }
  s.source = { :git => 'https://github.com/jpeckner/SwiftDux.git', :tag => '1.0.2' }

  s.ios.deployment_target = '11.0'
  s.source_files = 'SwiftDux/**/*.swift'
  s.swift_version = '5.0'
end