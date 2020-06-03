source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

gem 'sassc-rails'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0'

# Use Puma as the app server
gem 'puma', '~> 3.11'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Pry tools
  gem 'pry-rails', '~> 0.3.9'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Clockwork
gem 'clockwork', '~> 2.0', '>= 2.0.4'

# Sidekiq
gem 'sidekiq', '~> 6.0', '>= 6.0.7'

# Linting
gem 'rubocop'
gem 'mocha', '~> 0.14.0'

# Postgres
gem 'pg'
gem 'pg_search', '< 1.0'
gem "pgrel", "~>0.1"

# HTTP
gem 'httparty'

# oAuth
gem 'oauth2'

# Deletion persistance
gem "paranoia", "~> 2.2"
