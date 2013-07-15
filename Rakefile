
require 'yaml'
require 'sequel'

ENV["RACK_ENV"] ||= "development"

namespace :db do
  desc 'Migrate Dirt Database'
  task :migrate do
    db_config = YAML.load_file('config/database.yml')[ENV['RACK_ENV']]['dirt']
    Sequel.extension :migration
    DB = Sequel.connect(db_config)
    Sequel::Migrator.run(DB, 'db/migrations')
  end
end

