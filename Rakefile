
require 'yaml'
require 'sequel'

ENV["RACK_ENV"] ||= "development"

DEBUG = false

user="dirt"
server = 'dirt-staging'
deploy_location = '/opt/dirt2/'
github_url="git://github.com/perfectayush/dirt.git"

namespace :db do
  desc 'Migrate Dirt Database'
  task :migrate do
    db_config = YAML.load_file('config/database.yml')[ENV['RACK_ENV']]['dirt']
    Sequel.extension :migration
    DB = Sequel.connect(db_config)
    Sequel::Migrator.run(DB, 'db/migrations')
  end
end

namespace :code do
  desc 'Create deploy directory and sync code'
  task :deploy_prep do
    system_with_status do |e|
      e.message = "Creating #{deploy_location} on server #{server}"
      e.command = "ssh #{user}@#{server} sudo mkdir -p #{deploy_location} 2>&1"
    end

    system_with_status do |e|
      e.message = "Changing the owner of #{deploy_location} to #{user} on server #{server}"
      e.command = "ssh #{user}@#{server} sudo chown #{user}:#{user} #{deploy_location}"
    end
  end

  desc 'Sync code'
  task :sync do
    system_with_status do |e|
      e.message = "rsync-ing files to server #{server}"
      e.command = "rsync -avz --delete  --exclude='dirt.sqlite' . #{user}@#{server}:#{deploy_location}/dirt/ 2>&1"
    end

    system_with_status do |e|
      e.message = "Linking rsync'd path to #{deploy_location}current"
      e.command = "ssh #{user}@#{server} ln -snf #{deploy_location}dirt #{deploy_location}/current"
    end
  end

  desc 'Sync code & db'
  task :sync_all do
    system_with_status do |e|
      e.message = "rsync-ing files to server #{server}"
      e.command = "rsync -avz --delete . #{user}@#{server}:#{deploy_location}/dirt/ 2>&1"
    end

    system_with_status do |e|
      e.message = "Linking rsync'd path to #{deploy_location}current"
      e.command = "ssh #{user}@#{server} ln -snf #{deploy_location}dirt #{deploy_location}/current"
    end

  end

  desc "Git clone"
  task :git_clone do

    time_stamp = Time.now.to_i.to_s

    system_with_status do |e|
      e.message = "Git checkout code"
      e.command = "ssh #{user}@#{server} git clone #{github_url} #{deploy_location}dirt-#{time_stamp}" 
    end

    system_with_status do |e|
      e.message = "Linking rsync'd path to #{deploy_location}current"
      e.command = "ssh #{user}@#{server} ln -snf #{deploy_location}dirt-#{time_stamp} #{deploy_location}/current"
    end
  end

  desc 'Sync code back from server'
  task :sync_back, [:host] do |t, args|
    args.with_defaults(:host => "scratch")
    server = args.host
    system_with_status do |e|
      e.message = "rsync-ing files from server #{server}"
      e.command = "rsync -avz #{server}:#{deploy_location}/ . 2>&1"
    end
  end
end

namespace :app do
  desc 'Start dirt on remote server after migrating db'
  task :start do
    system_with_status do |e|
      e.message = "Starting dirt on #{server}"
      e.command = "ssh #{user}@#{server} \"/#{deploy_location}current/start_app.sh `</dev/null` >nohup.out 2>&1 &\""
    end
  end

  desc 'Stop dirt on remote server after migrating db'
  task :stop do
    system_with_status do |e|
      e.message = "Stoping dirt on #{server}"
      e.command = "ssh #{user}@#{server} #{deploy_location}/current/stop_app.sh"
    end
  end

  desc "Restart dirt on server"
  task :restart do
    Rake::Task["app:stop"].invoke
    Rake::Task["app:start"].invoke
  end

end

namespace :staging do
  desc "Prepare staging server for deplyoment"
  task :prep do
    Rake::Task["code:deploy_prep"].invoke
  end

  desc "Deploy app on staging server"
  task :deploy => [:prep] do
    Rake::Task["code:sync"].invoke
    Rake::Task["staging:restart"].invoke
  end

  desc "Deploy app on staging server with db"
  task :deploy_all => [:prep] do
    Rake::Task["code:sync_all"].invoke
    Rake::Task["staging:restart"].invoke
  end

  desc "Restart dirt on staging server"
  task :restart do
    Rake::Task["app:restart"].invoke
  end

  desc 'Stop app and remove code from remote server'
  task :undeploy => ["app:stop"] do
    servers.each do |server|
      system_with_status do |e|
        e.message = "Remove dir #{deploy_location} on server #{server}"
        e.command = "ssh #{user}@#{server} sudo rm -rf #{deploy_location} 2>&1"
      end
    end
  end
end

namespace :production do
  desc "Prepare production server for deplyoment"
  task :prep do
    Rake::Task["code:deploy_prep"].invoke
  end

  desc "Deploy app on production server"
  task :deploy => [:prep] do
    Rake::Task["code:git_clone"].invoke
  end
end


# -----------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------

class ExecParams
  attr_accessor :command
  attr_accessor :message
end

def system_with_status
  e = ExecParams.new
  yield e
  print "[*] %-65s" % e.message
  print "\n[DEBUG] %-65s" % e.command if DEBUG

  output = `#{e.command}`

  status = $?.success? ? "DONE" : "FAIL"
  puts "[#{status}]"
  raise output unless $?.success?
end
