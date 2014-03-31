lock '3.1.0'

set :repo_url, 'git@github.com:bluffmf/cinema'
set :application, 'cinema'
application = 'cinema'
set :rvm_type, :user
set :rvm_ruby_version, 'ruby-2.1.0@cinema'

set :server, :unicorn

#set :ssh_options, { :forward_agent => true }

#set :use_sudo, false
set :keep_releases, 5
set :log_level, :debug

set :linked_dirs, fetch(:linked_dirs, []) + %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :normalize_asset_timestamps, false

# #on :start do
# # `ssh-add`
# #end

#SSHKit.config.command_map[:rake]  = "bundle exec rake"

namespace :deploy do
  task :restart do
    on roles(:app) do
      if test("[ -e #{fetch(:unicorn_pid)} ] && [ -e /proc/$(cat #{fetch(:unicorn_pid)}) ]")
        execute "kill -USR2 `cat #{fetch(:unicorn_pid)}`"
      else
        within release_path do
          with rails_env: fetch(:rails_env), bundle_gemfile: fetch(:bundle_gemfile) do
            execute :bundle, "exec unicorn_rails -c #{fetch(:unicorn_conf)} -E #{fetch(:rails_env)} -D"
          end
        end
      end
    end
  end

  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), bundle_gemfile: fetch(:bundle_gemfile) do
          execute :bundle, "exec unicorn_rails -c #{fetch(:unicorn_conf)} -E #{fetch(:rails_env)} -D"
        end
      end
    end
  end

  task :stop do
    on roles(:app) do
      execute "if [ -f #{fetch(:unicorn_pid)} ] && [ -e /proc/$(cat #{fetch(:unicorn_pid)}) ]; then kill -QUIT `cat #{fetch(:unicorn_pid)}`; fi"
    end
  end

  task :make_symlink do
    on roles(:app) do |host|
      execute "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end
  # config
  task :copy_conf_files do
    on roles(:app) do |host|
      execute "cp -f #{release_path}/config/deploy/#{fetch(:stage)}/unicorn.rb #{release_path}/config/"
    end
  end

  after :finishing, "deploy:cleanup"
end

before "deploy:updated", "deploy:copy_conf_files"
before "deploy:updated", "deploy:make_symlink"
after 'deploy:publishing', 'deploy:restart'


