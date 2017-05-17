require 'bundler/capistrano'
require 'rvm/capistrano'
# require 'whenever/capistrano'
require 'capistrano/ext/multistage'
# require 'capistrano-unicorn'

# Whenever setup for application
set(:whenever_command) { "RAILS_ENV=#{rails_env} bundle exec whenever" }
set :whenever_environment, defer { 'production' }


# Application configuration
set :application, 'pyklocal'
set :repository,  'git@github.com:/pyklocal/pyklocal.git'
set :branch, 'master'
set :scm, :git

# Server-side system wide settings
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# Application stages configuration
set :stages, %w(production-frontend production-production production)
set :default_stage, 'production'


# Unicorn environment configuration
set(:unicorn_env) { rails_env }

# Deploy configuration (Unicorn, nginx)
after 'deploy', 'deploy:cleanup'

namespace :deploy do

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end

  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/public/spree #{release_path}/public/spree"
  end

  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
    task :check_revision, roles: :web do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  # before "deploy", "deploy:check_revision"

  namespace :figaro do
    desc "SCP transfer figaro configuration to the shared folder"
    task :setup do
      transfer :up, "config/application.yml", "#{shared_path}/application.yml", :via => :scp
    end

    desc "Symlink application.yml to the release path"
    task :symlink do
      run "ln -sf #{shared_path}/application.yml #{release_path}/config/application.yml"
    end
  end

  after  "deploy:started", "figaro:setup"
  after "deploy:symlink:release", "figaro:symlink"
  desc "Restart the application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec pumactl -S #{current_path}/tmp/pids/puma-production.state restart"
  end

  desc <<-DESC
    Clean up any assets that haven't been deployed for more than :expire_assets_after seconds.
    Default time to keep old assets is one week. Set the :expire_assets_after variable
    to change the assets expiry time. Assets will only be deleted if they are not required by
    an existing release.
  DESC
  
  task :clean_expired, :roles => lambda { assets_role }, :except => { :no_release => true } do
    # Fetch all assets_manifest contents.
    manifests_output = capture <<-CMD.compact
      for manifest in #{releases_path.shellescape}/*/assets_manifest.*; do
        cat -- "$manifest" 2> /dev/null && printf ':::' || true;
      done
    CMD
    manifests = manifests_output.split(':::')

    if manifests.empty?
      logger.info "No manifests in #{releases_path}/*/assets_manifest.*"
    else
      logger.info "Fetched #{manifests.count} manifests from #{releases_path}/*/assets_manifest.*"
      current_assets = Set.new
      manifests.each do |content|
        current_assets += parse_manifest(content)
      end
      current_assets += [File.basename(shared_manifest_path), "sources_manifest.yml"]

      # Write the list of required assets to server.
      logger.info "Writing required assets to #{deploy_to}/REQUIRED_ASSETS..."
      escaped_assets = current_assets.sort.join("\n").gsub("\"", "\\\"") << "\n"
      put escaped_assets, "#{deploy_to}/REQUIRED_ASSETS", :via => :scp

      # Finds all files older than X minutes, then removes them if they are not referenced
      # in REQUIRED_ASSETS.
      expire_after_mins = (expire_assets_after.to_f / 60.0).to_i
      logger.info "Removing assets that haven't been deployed for #{expire_after_mins} minutes..."
      # LC_COLLATE=C tells the `sort` and `comm` commands to sort files in byte order.
      run <<-CMD.compact
        cd -- #{deploy_to.shellescape}/ &&
        LC_COLLATE=C sort REQUIRED_ASSETS -o REQUIRED_ASSETS &&
        cd -- #{shared_path.shellescape}/#{shared_assets_prefix}/ &&
        for f in $(
          find * -mmin +#{expire_after_mins.to_s.shellescape} -type f | LC_COLLATE=C sort |
          LC_COLLATE=C comm -23 -- - #{deploy_to.shellescape}/REQUIRED_ASSETS
        ); do
          echo "Removing unneeded asset: $f";
          rm -f -- "$f";
        done;
        rm -f -- #{deploy_to.shellescape}/REQUIRED_ASSETS
      CMD
    end
  end

end