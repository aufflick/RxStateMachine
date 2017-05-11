Pod::Spec.new do |spec|
  spec.name         = 'RxStateMachine'
  spec.version      = '0.1.0'
  spec.ios.deployment_target  = '8.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/aufflick/RxStateMachine'
  spec.authors      = { 'Mark Aufflick' => 'mark@aufflick.com' }
  spec.summary      = 'Simple way to interface a SwiftyStateMachine with RxSwift'
  spec.source       = { :git => 'https://github.com/aufflick/RxStateMachine.git', :tag => "v#{spec.version}" }
  spec.source_files = 'RxStateMachine/*.{swift}'
  spec.dependency 'RxSwift'
  spec.dependency 'SwiftyStateMachine'
end
