
require 'yaml'
require 'sequel'

ENV["RACK_ENV"] ||= "development"

DEBUG = false

servers = ['scratch']
deploy_location = '/home/ec2-user/dirt'

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
  task :deploy do
    servers.each do |server|
      system_with_status do |e| 
        e.message = "Creating #{deploy_location} on server #{server}"
        e.command = "ssh #{server} -- mkdir -p #{deploy_location} 2>&1"
      end

      system_with_status do |e| 
        e.message = "rsync-ing files to server #{server}"
        e.command = "rsync -avz --delete --exclude='dirt.sqlite' . #{server}:#{deploy_location}/ 2>&1" 
      end
    end 
  end 

  desc 'Sync code'
  task :sync do
    servers.each do |server|
      system_with_status do |e| 
        e.message = "rsync-ing files to server #{server}"
        e.command = "rsync -avz --delete  --exclude='dirt.sqlite' . #{server}:#{deploy_location}/ 2>&1"
      end
    end 
  end

  desc 'Sync code & db'
  task :sync_all do
    servers.each do |server|
      system_with_status do |e| 
        e.message = "rsync-ing files to server #{server}"
        e.command = "rsync -avz --delete . #{server}:#{deploy_location}/ 2>&1"
      end
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

namespace :server do
  desc 'Prepare server for deployment'
  task :prep => ["code:deploy"]
  task :prep, [:hosts] do |t,args|
    args.with_defaults(:hosts => servers)
    args.hosts.each do |server|
      system_with_status do |e|
        e.message = " -- Execute script on server #{server}"
        e.command = "ssh -t #{server} #{deploy_location}/prepare_server.sh"
      end
    end
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


