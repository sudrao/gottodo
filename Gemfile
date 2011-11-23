source 'http://rubygems.org'

gem 'rails', '3.1.0'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem 'redis'
gem 'evernote'
gem 'oauth'
gem 'haml-rails'
gem 'ohm'
gem 'mongoid', '~> 2.3'
gem 'bson_ext', '~> 1.4'
gem 'bcrypt-ruby'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test, :development do
  gem 'rspec-rails'
  gem 'cucumber-rails'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'capybara'
end

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'growl_notify'
  gem 'spork', "~> 0.9.0.rc"
  gem 'guard-spork'
end