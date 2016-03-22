cnpa-regional-contest-web
=========================

To get running in production on OCS Solutions:

o ssh paulkristoff@gemini.ocssolutions.com
o cd ~/rails_apps/cnpa-regional-contest-web
o git pull - pulls from master
o bundle exec rake assets:precompile - recreates javascript
o touch ~/rails_apps/cnpa-regional-contest-web/tmp/restart.txt - restarts server

o bundle --path  vendor/bundler/
o bundle install --path ~/.gem/.
