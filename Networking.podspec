Pod::Spec.new do |s|
  s.name = "Networking"
  s.version = "0.0.1"
  s.summary = "A super lightweight URLSession wrapper"

  s.homepage = "https://github.com/Jimmy-Lee/Networking"

  s.license = { :type => "MIT", :file => "LICENSE" }

  s.authors = { "Jimmy-Lee" => "jimmylevelup@gmail.com" }

  s.swift_version = "5.0"

  s.ios.deployment_target = "13.0"
  s.tvos.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"
  s.watchos.deployment_target = "6.0"

  s.source = { :git => "https://github.com/Jimmy-Lee/Networking.git", :tag => s.version}

  s.source_files  = ["Sources/*.swift", "Sources/Networking.h"]
  s.public_header_files = ["Sources/Networking.h"]

  s.requires_arc = true
  s.frameworks = "Combine"
end
