Pod::Spec.new do |s|
  s.name         = "MBPullDownController"
  s.version      = "1.0"
  s.summary      = "MBPullDownController, an iOS container view controller for pullable scroll view interfaces."
  s.homepage     = "https://github.com/matej/MBPullDownController"
  s.license      = 'MIT'
  s.author       = { "Matej Bukovinski" => "matej@bukovinski.com" }
  s.source       = { :git => "https://github.com/matej/MBPullDownController.git" }
  s.platform     = :ios, '5.0'
  s.source_files = 'MBPullDownController/*.{h,m}'
  s.framework  = 'QuartzCore'
  s.requires_arc = true
end
