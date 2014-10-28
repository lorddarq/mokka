default_environment['PATH'] = "/opt/ruby/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin"

set :user, ENV['CAPUSER']
set :runner, "mokka"
set :application, "mokka"
set :rails_env, "production"
set :deploy_to, "/apps/#{runner}/#{application}-git"
set :use_sudo, true

ssh_options[:paranoid] = false

role :rails, '144.76.29.15:58023', '144.76.29.25', :primary => true
role :db, '144.76.29.15:58023'

alias :old_run :run
def run(command)
  old_run "#{sudo :as => runner} -i sh -c '#{command}'"
end

namespace :deploy do
  task :default do
    update
    precompile_assets
    restart
  end

  task :setup do
    run "cd #{deploy_to}; mkdir -p log tmp; cp config/database.yml.production config/database.yml; cp config/lam_auth.yml.production config/lam_auth.yml"
    run "cd #{deploy_to}/public; ln -s . #{application}"
  end

  task :update do
    run "cd #{deploy_to}; git checkout db/schema.rb; git pull; bundle install --deployment --without development test"
  end

  task :migrate, :roles => :db do
    update
    run "cd #{deploy_to} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate"
    precompile_assets
    restart
  end

  task :precompile_assets do
    run "cd #{deploy_to}; RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
  end

  task :restart do
    run "cd #{deploy_to}; touch tmp/restart.txt;"
  end
end
