#!/bin/bash 

### BEGIN INIT INFO
# Provides: munin2graphite
# Required-Start: $network $remote_fs $munin-node
# Required-Stop: $null
# Default-Start:  3 5
# Default-Stop:   0 1 2 6
# Short-Description: Populates carbon agents with munin-node data
# Description:    munin graphs to graphite servers
### END INIT INFO
if [ ! -d /usr/local/rvm/gems ]; then
    mkdir -p /usr/local/rvm/gems/
    ln -s /server/graphite/ruby/gems/ruby-1.8.7-p352/ /usr/local/rvm/gems/ruby-1.8.7-p352
fi

if [ ! -d /usr/local/rvm/rubies ]; then
    mkdir -p /usr/local/rvm/rubies
    ln -s /server/graphite/ruby/ruby-1.8.7-p352 /usr/local/rvm/rubies/ruby-1.8.7-p352
fi
export PATH=/server/graphite/ruby/rubies/ruby-1.8.7-p352/bin:$PATH:/usr/local/bin
export LD_LIBRARY_PATH=/server/graphite/ruby/rubies/ruby-1.8.7-p352/lib/
export GEM_PATH=/server/graphite/ruby/gems/ruby-1.8.7-p352
export MY_RUBY_HOME=/server/graphite/ruby/gems/ruby-1.8.7-p352/
/server/graphite/init.d/munin2graphite $@

