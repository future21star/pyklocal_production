# Settings for staging server
server '54.202.62.141', :app, :web, :db, :primary => true
set :rails_env, 'production'

set :use_sudo, false
set :deploy_via, :remote_cache
set :user, 'pyklocal'
set :rvm_ruby_version, 'ruby-2.1.0'
set :deploy_to, "/home/#{user}/#{application}"
set :branch, `git rev-parse --abbrev-ref HEAD`.chomp
