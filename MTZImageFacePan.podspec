Pod::Spec.new do |s|
  s.name             = "MTZImageFacePan"
  s.version          = "0.1.0"
  s.summary          = "MTZImageFacePan - Show all faces in an ImageView."

  s.description      = <<-DESC
                        Make sure all faces are showing when filling an ImageView with an image
                       DESC

  s.homepage         = "https://github.com/MichaelTzach/MTZImageFacePan"
  s.license          = 'MIT'
  s.author           = { "Michael Tzach" => "michael.tzach@jivesoftware.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/MTZImageFacePan.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'MTZImageFacePan' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
