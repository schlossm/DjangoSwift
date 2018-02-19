Pod::Spec.new do |s|

  s.name         = "RESTSwift"
  s.version      = "1.0"
  s.summary      = "An extendable, robust, and easy-to-use framework for communicating with RESTful endpoints."

  s.description  = <<-DESC
		An extendable, robust, and easy-to-use framework for communicating with RESTful endpoints.
                   DESC

  s.homepage     = "https://github.com/schlossm/RESTSwift"

  s.license      = { :type => 'MIT', :file => 'MIT.txt' }

  s.author       = { "Michael Schloss" => "mschloss11@gmail.com" }

  #  When using multiple platforms
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "10.0"

  s.swift_version = "4.0"

  s.source       = { :git => "https://github.com/schlossm/RESTSwift.git", :tag => "#{s.version}" }

  s.source_files  = "Common", "Common/**/**/*.swift"

end
