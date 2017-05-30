
Pod::Spec.new do |s|

  s.platform = :ios
  s.ios.deployment_target = '10.0'

  s.name         = "PodNetwork"
  s.version      = "1.0.28"
  s.summary      = "PodNetwork classes"
  s.description  = <<-DESC
  A bunch of classes i have found useful for PodNetwork
                   DESC

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Etienne Goulet-Lang" => "" }
  s.source       = { :git => "https://github.com/egouletlang/PodNetwork.git", :tag => "#{s.version}" }

  s.homepage = "https://github.com/egouletlang/PodNetwork"

  s.source_files  = "PodNetwork", "PodNetwork/**/*.{h,m}", "PodNetwork/**/*.{swift}"
  s.exclude_files = "Classes/Exclude"

  s.dependency 'BaseUtils'

end

