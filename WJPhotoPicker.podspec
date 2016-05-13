
Pod::Spec.new do |s|
  s.name         = "WJPhotoPicker"
  s.version      = "1.0.0"
  s.summary      = "A simple and easy to use photo picker."

  s.author       = { "zwj" => "niuszeng@sina.com" }
  s.homepage     = "https://github.com/ZengWeiJun/WJPhotoPicker"
  s.license      = "MIT"
  s.platform     = :ios
  s.ios.deployment_target = "5.0"
  s.source       = { :git => "https://github.com/ZengWeiJun/WJPhotoPicker.git", :tag => s.version }
s.source_files  = "WJPhotoPicker", "WJPhotoPicker/*.{h,m}"
#s.resources = "WJPhotoAssets.bundle/*.png"
s.framework  = "UIKit"
s.requires_arc = true
s.dependency 'SDWebImage'

end
