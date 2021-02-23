# frozen_string_literal: true

# set vars from ENV
set :application,      ENV['CAPISTRANO_APP']  || 'DMPTool'
set :user,             ENV['USER']            || 'dmp'
set :deploy_to,        ENV['DEPLOY_TO']       || '/dmp/apps/dmptool'
set :rails_env,        ENV['RAILS_ENV']       || 'production'
set :repo_url,         ENV['REPO_URL']        || 'https://github.com/cdluc3/dmptool.git'
set :branch,           ENV['BRANCH']          || 'master'

set :share_to,         "#{fetch(:deploy_to)}/shared"
set :default_env,      { path: "$PATH" }
puts "default_env:"
puts fetch(:default_env).to_s
puts "deploy_path: #{deploy_path}"

# Gets the current Git tag and revision
set :version_number, `git describe --tags`
# Default environments to skip
set :bundle_without, %w[pgsql thin rollbar test].join(" ")

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
  before :complile_assets, :retrieve_credentials 
  after :deploy, "git:version"
  after :deploy, "cleanup:remove_example_configs"

  desc 'Retrieve encrypted crendtials file from SSM ParameterStore'
  task :retrieve_credentials do
    on roles(:app), wait: 1 do
      ssm = Uc3Ssm::ConfigResolver.new
      credentials_yml_enc = ssm.parameter_for_key('credentials_yml_enc')
      f = File.open("#{release_path}/config/credentials.yml.enc", 'w')
      f.puts credentials_yml_enc.chomp 
      f.close
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
end
