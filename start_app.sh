source ~/.bash_profile
cd /opt/dirt2/current
rake db:migrate
RACK_ENV="development" ruby application.rb -p1337 &
