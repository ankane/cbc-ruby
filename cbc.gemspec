require_relative "lib/cbc/version"

Gem::Specification.new do |spec|
  spec.name          = "cbc"
  spec.version       = Cbc::VERSION
  spec.summary       = "Mixed-integer programming for Ruby"
  spec.homepage      = "https://github.com/ankane/cbc-ruby"
  spec.license       = "EPL-2.0"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "fiddle"
end
