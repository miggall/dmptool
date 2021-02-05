# frozen_string_literal: true

# set vars from ENV
set :application,      ENV['CAPISTRANO_APP']  || 'DMPTool'
set :user,             ENV['USER']            || 'dmp'
set :deploy_to,        ENV['DEPLOY_TO']       || '/dmp/apps/dmptool'
set :rails_env,        ENV['RAILS_ENV']       || 'production'
set :repo_url,         ENV['REPO_URL']        || 'https://github.com/cdluc3/dmptool.git'
set :branch,           ENV['BRANCH']          || 'master'
set :config_branch,    ENV['CONFIG_BRANCH']   || "uc3-dmpx2-prd"
#ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp unless ENV["BRANCH"]

set :share_to,         "#{fetch(:deploy_to)}/shared"
set :default_env,      { path: "$PATH" }
puts "default_env:"
puts fetch(:default_env).to_s
puts "deploy_path: #{deploy_path}"

# Gets the current Git tag and revision
set :version_number, `git describe --tags`
# Default environments to skip
set :bundle_without, %w[puma pgsql thin rollbar test].join(" ")

# Define the location of the private configuration repo
set :config_repo, "git@github.com:cdlib/dmptool_config.git"

# Default value for :linked_files is []
append :linked_files,
       ".env",
       "config/credentials.yml.enc",
       "config/master.key",
       "public/tinymce/tinymce.css"

# Default value for linked_dirs is []
append :linked_dirs,
       "log",
       "tmp/pids",
       "tmp/cache",
       "tmp/sockets",
       "public"

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  #before :deploy, "config:install_shared_dir"
  after :deploy, "git:version"
  after :deploy, "cleanup:remove_example_configs"
  #after :deploy, "cleanup:restart_passenger"
end

namespace :config do
  desc "Setup up the config repo as the shared directory"
  task :install_shared_dir do
    on roles(:app), wait: 1 do
      # rubocop:disable Layout/LineLength
      execute "if [ ! -d '#{deploy_path}/shared/' ]; then cd #{deploy_path}/ && git clone #{fetch :config_repo} shared; fi"
      execute "cd #{deploy_path}/shared/ && git checkout #{fetch :config_branch} && git pull origin #{fetch :config_branch}"
      # rubocop:enable Layout/LineLength
    end
  end
end

namespace :git do
  desc "Add the version file so that we can display the git version in the footer"
  task :version do
    on roles(:app), wait: 1 do
      execute "touch #{release_path}/.version"
      execute "echo '#{fetch :version_number}' >> #{release_path}/.version"
    end
  end
end

namespace :cleanup do
  desc "Remove all of the example config files"
  task :remove_example_configs do
    on roles(:app), wait: 1 do
      execute "rm -f #{release_path}/config/*.yml.sample"
      execute "rm -f #{release_path}/config/initializers/*.rb.example"
    end
  end

  #desc "Restart Phusion Passenger"
  #task :restart_passenger do
  #  on roles(:app), wait: 5 do
  #    execute "cd /apps/dmp/init.d && ./passenger stop"
  #    execute "cd /apps/dmp/init.d && ./passenger start"
  #  end
  #end

  #after :restart_passenger, :clear_cache do
  #  on roles(:web), in: :groups, limit: 3, wait: 10 do
  #  end
  #end
end
