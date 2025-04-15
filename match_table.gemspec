# frozen_string_literal: true

require_relative "lib/match_table/version"

Gem::Specification.new do |spec|
  spec.name = "match_table"
  spec.version = MatchTable::VERSION
  spec.authors = ["Ryan Schlesinger"]
  spec.email = ["ryan@ryanschlesinger.com"]

  spec.summary = "Adds a `match_table` matcher for your Capybara system specs."
  spec.description = "Capybara's built-in table matchers leave a lot to be desired. `match_table` is a matcher that allows you to match tables in your system specs with a lot more flexibility and much improved failure messages."
  spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec-expectations", "~> 3"
  spec.add_dependency "capybara", "~> 3"
end
