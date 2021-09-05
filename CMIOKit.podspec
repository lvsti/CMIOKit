Pod::Spec.new do |spec|
  spec.name = "CMIOKit"
  spec.version = "1.0.0"
  spec.summary = "Swift wrapper around the CoreMediaIO C APIs"
  spec.description = <<-DESC
    CoreMediaIO (CMIO for short) is a neglected foster child in the macOS platform SDK
    for that its API is still a decades-old C interface that auto-translates miserably
    to Swift with all that unsafe pointer business going on. CMIOKit aims at offering
    a somewhat higher-level, developer-friendly API for these calls while making no
    simplifications or compromises on the data that can be accessed.
                   DESC
  spec.homepage = "https://github.com/lvsti/CMIOKit"
  spec.license = { :type => "MIT", :file => "LICENSE.txt" }
  spec.author = "Tamas Lustyik"
  spec.platform = :osx, "10.13"
  spec.swift_version = "4.2"
  spec.source = { :git => "https://github.com/lvsti/CMIOKit.git" }
  spec.source_files = "Sources/**/*.{h,swift}"
end
