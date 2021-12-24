Pod::Spec.new do |s|
  s.name = 'SwiftDux'
  s.module_name = 'SwiftDux'
  s.version = '1.1.2'
  s.license = 'MIT'
  s.summary = 'SwiftDux is a straightforward, thread-safe implementation of Redux in Swift.'
  s.homepage = 'https://github.com/jpeckner/SwiftDux'
  s.authors = { 'Justin Peckner' => 'pecknerj@gmail.com' }
  s.source = { :git => 'https://github.com/jpeckner/SwiftDux.git', :tag => 'v1.1.2' }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files = 'SwiftDux/**/*.swift'
end