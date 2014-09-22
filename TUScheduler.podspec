Pod::Spec.new do |s|
  s.name         = 'TUScheduler'
  s.version      = '0.0.1'
  s.homepage     = 'https://github.com/tuenti/TUScheduler'
  s.summary      = 'Schedulers help you testing your asynchronous code, and decouples your code from the underlying concurrency API.'
  s.authors      = { 'Tuenti Technologies S.L.' => 'https://twitter.com/TuentiEng' }
  s.source       = { :git => 'https://github.com/tuenti/TUScheduler.git', :tag => 'v0.0.1' }
  s.source_files = 'TUScheduler/Source/**/*.{h,m}'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.requires_arc = true

  s.subspec 'AsyncTestSentinel' do |sentinel|
    sentinel.source_files = 'TUScheduler/Tests/AsyncTestSentinel/*.{h,m}'
  end
end
