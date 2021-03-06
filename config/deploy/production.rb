# Settings for staging server
server '34.203.36.151', :app, :web, :db, :primary => true
# server '54.202.62.141', :user => 'w3villa', :roles => %w{web app db}
set :rails_env, 'production'

set :use_sudo, false
set :deploy_via, :remote_cache
set :user, 'deploy'
set :rvm_ruby_version, 'ruby-2.1.0'
set :deploy_to, "/home/#{user}/#{application}"
set :branch, `git rev-parse --abbrev-ref HEAD`.chomp