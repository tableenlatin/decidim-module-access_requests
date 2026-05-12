# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/access_requests/version"

DECIDIM_VERSION = Decidim::AccessRequests.decidim_version

gem "decidim", DECIDIM_VERSION
gem "decidim-access_requests", path: "."

gem "bootsnap", "~> 1.23"
gem "puma", ">= 6.3.1"

group :development, :test do
  gem "brakeman", "~> 8.0"
  gem "byebug", "~> 13.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "parallel_tests", "~> 5.6"
  gem "rubocop-faker"
  gem "rubocop-performance", "~> 1.25"
end

group :development do
  gem "faker", "~> 3.1"
  gem "letter_opener_web", "~> 3.0"
  gem "listen", "~> 3.10"
  gem "web-console", "~> 4.3"
end
