Pod::Spec.new do |s|
  s.name = 'SwiftDux'
  s.version = '1.1.5'
  s.summary = 'SwiftDux is a straightforward, thread-safe implementation of Redux in Swift.'
  s.homepage = 'https://github.com/jpeckner/SwiftDux'
  s.authors = { 'Justin Peckner' => 'pecknerj@gmail.com' }
  s.license = 'MIT'
  s.source = { 
    :git => 'https://github.com/jpeckner/SwiftDux.git', 
    :tag => 'v' + s.version.to_s 
  }
  
  s.ios.deployment_target = '11.0'
  s.source_files = 'SwiftDux/**/*.swift'
  s.swift_version = '5.0'
end