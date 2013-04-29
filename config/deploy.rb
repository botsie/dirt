require 'capistrano/ext/multistage'

set :application, "dirt"

set :scm, :git
set :repository,  "git@github.com:botsie/dirt.git"
set :scm_passphrase, ""

set :user, "dirt"

set :stages, ["staging", "production"]
set :default_stage, "staging"

