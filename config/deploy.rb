require "bundler/capistrano"
load 'deploy/assets'

server "hosting.base42.nl", :web, :app, :db, primary: true
set :user, "jankeesvw"

set :application, "TwelveTwenty"

set :deploy_to, "/home/#{user}/web/domains/twelvetwenty.nl/subdomains/pre"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git://github.com/TwelveTwenty/website.git"
set :branch, "develop"

set :bundle_without, [:development, :test]

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  desc "Access log files"
  task :logs do
    run "cd #{current_path}/log && tail -f -n 50 *.log"
  end
end

namespace :application do

  desc "Remove config from Git repository"
  task :remove_config do
    run "rm #{release_path}/config/database.yml"
    run "rm #{release_path}/config/config.yml"
  end

  desc "Copy real config files"
  task :create_symlinks do
    run "ln -fs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -fs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
    run "ln -fs #{shared_path}/uploads #{release_path}/public/uploads"
  end

  desc "Add deploy details to app folder"
  task :write_deploy_details do
    run "echo \"Last deployment: `date -R`\" > #{release_path}/public/deployment.txt"
    run "echo \"Git commit hash: `cat #{current_path}/REVISION` \" >> #{release_path}/public/deployment.txt"
    run "echo \"Github: https://github.com/TwelveTwenty/website/commit/`cat #{current_path}/REVISION` \" >> #{release_path}/public/deployment.txt"
  end

end

after :deploy, "application:remove_config"
after :deploy, "application:create_symlinks"
after :deploy, "application:write_deploy_details"
after :deploy, "passenger:restart"