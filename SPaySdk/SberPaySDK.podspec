Pod::Spec.new do |s|
  s.name         = "SberPaySDK"
  s.module_name  = "SberPaySDK"
  s.version      = "0.0.1"
  s.summary      = "SberPaySDK sdk for iOS and OS X"
  s.description  = <<-DESC
                   Some desc
                   DESC
  s.homepage     = ""
  s.license      = { :type => 'MIT' }
  s.author       = { "AlexIpatov" => "alexanderIpatov1997@gmail.com" }
  s.ios.deployment_target = '12.0'
  s.requires_arc = true
  s.source = {
    :git => "",
    :tag => 'v0.0.1',
    :submodules => true
  }

  s.swift_version = "5"
  s.pod_target_xcconfig = {
      'SWIFT_VERSION' => '5.0'
  }
  s.source_files  = "Sources/**/*.swift", "Sources/*.swift"
  s.dependency "Dynatrace/lib", "~> 8.237"
end