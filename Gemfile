
source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.13', '< 0.5'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'social-share-button'
gem 'exception_notification'
gem 'aws-sdk', '< 2.0'
gem 'slim'
gem 'slim-rails'
gem "less-rails"
gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'
gem "font-awesome-rails" 
gem 'quiet_assets', group: :development
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'progress_bar'
gem 'noty-rails'
# gem 'client_side_validations'
gem 'gibbon', git: 'git://github.com/amro/gibbon.git'



gem 'spree_editor', github: 'spree-contrib/spree_editor', branch: '3-1-stable'
#gem 'spree_promotion_tax', git: 'git://github.com/bluehandtalking/spree_promotion_tax.git', branch: '1-3-default_tax'


gem 'active_model_serializers', '~> 0.10.0'
# Use geokit gem to calculate distance
# gem 'geokit-rails', '2.0.1'
# gem 'geokit', '1.8.5'
gem 'asin'
gem 'sidekiq'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'therubyracer', platforms: :ruby

gem 'impressionist'

# gem 'import_products', :git => 'git://github.com/pkumarmis/spree-import-products.git', branch: '3-1-stable'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem "letter_opener"
gem "paperclip-ffmpeg", "~> 1.0.1"

#xlsx file format
gem 'axlsx', '~> 2.0', '>= 2.0.1'
gem 'axlsx_rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rspec-rails', '~> 3.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem "factory_girl_rails", "~> 4.0"
  gem 'simplecov', :require => false
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'capybara'
  gem "cucumber-websteps"
  gem 'zip-zip'
  gem 'selenium-webdriver', '2.52.0'
  gem 'byebug'
  gem 'hirb'
  gem "rails-erd"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

gem 'spree', '~> 3.1.0'
gem 'spree_auth_devise', '~> 3.1.0'
gem 'spree_gateway', '~> 3.1.0'

gem 'spree_print_invoice', github: 'spree-contrib/spree_print_invoice', branch: 'master'
gem 'spree_static_content', github: 'spree-contrib/spree_static_content', branch: '3-1-stable'
gem 'spree_braintree_vzero', github: 'spree-contrib/spree_braintree_vzero', branch: 'master'

gem 'rvm-capistrano'


group :development do
  gem 'capistrano', '2.15.5'
  gem 'capistrano-unicorn', :require => false
  gem 'thin'
  gem "rails-erd"
end

group :production do
	gem 'puma'
end

# group :assets do
#   gem 'jquery-ui-rails'
# end
