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
export PATH=/server/graphite/ruby/rubies/ruby-1.8.7-p352/bin:$PATH:/usr/local/bin
export LD_LIBRARY_PATH=/server/graphite/ruby/rubies/ruby-1.8.7-p352/lib/
export GEM_PATH=/server/graphite/ruby/gems/ruby-1.8.7-p352
export MY_RUBY_HOME=/server/graphite/ruby/gems/ruby-1.8.7-p352/
/server/graphite/init.d/munin2graphite $@