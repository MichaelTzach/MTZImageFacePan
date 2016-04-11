Pod::Spec.new do |s|

s.name              = 'MTZImageFacePan'
s.version           = '0.1.0'
s.summary           = 'ImageFilesPicker'
s.homepage          = 'https://github.com/MichaelTzach/MTZImageFacePan'
s.ios.deployment_target = '7.0'
s.platform = :ios, '7.0'
s.license           = {
:type => 'MIT',
:file => 'LICENSE'
}
s.author            = {
'YOURNAME' => 'Michael'
}
s.source            = {
:git => 'https://github.com/MichaelTzach/MTZImageFacePan.git',
}
s.framework = "UIKit"
s.source_files = 'Pod/Classes/**/*'
s.requires_arc      = true

end