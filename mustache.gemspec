$LOAD_PATH.unshift 'lib'
require 'mustache/version'

Gem::Specification.new do |s|
  s.name              = "mustache-prime-edition"
  s.version           = Mustache::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           =
        "Mustache Prime Edition is an extension of mustache for increased integration with Prime. Mustache is a framework-agnostic way to render logic-free views. Mustache Prime Edition is based on Mustache version 0.11.2."
  s.homepage          = "http://github.com/daugaard/mustache"
  s.email             = "sbd@ipvision.dk"
  s.authors           = [ "Søren Blond Daugaard", "Chris Wanstrath" ]
  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("man/**/*")
  s.files            += Dir.glob("test/**/*")
  s.executables       = %w( mustache )
  s.description       = <<desc
Inspired by ctemplate, Mustache is a framework-agnostic way to render
logic-free views.

As ctemplates says, "It emphasizes separating logic from presentation:
it is impossible to embed application logic in this template
language.

Think of Mustache as a replacement for your views. Instead of views
consisting of ERB or HAML with random helpers and arbitrary logic,
your views are broken into two parts: a Ruby class and an HTML
template.
desc
end
