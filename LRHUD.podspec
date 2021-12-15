
Pod::Spec.new do |s|
  s.name         = "LRHUD"
  s.version      = "1.0.0"
  s.summary      = "LRHUD"
  s.description  = "LRHUD"
  s.homepage     = "https://github.com/karlcool/LRHUD.git"
  s.license      = "MIT"
  s.author       = { "yanzhi.liu" => "karlcool.l@qq.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/karlcool/LRHUD.git", :tag => "#{s.version}" }
  s.source_files        = 'LRHUD/Class/*.swift'
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
end