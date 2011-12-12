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
LINK=$( stat  -t  -c %N $0|awk '{print $3}'|sed "s/'//g"|sed "s/\`//g" )

export RUBY_BASE=`dirname $LINK`/../ruby/
export RUBY_LIB_PREFIX=$RUBY_BASE/rubies/ruby-1.8.7-p352/
export RUBYLIB=$RUBY_LIB_PREFIX/lib/ruby/site_ruby/1.8:$RUBY_LIB_PREFIX/lib/ruby/site_ruby/1.8/x86_64-linux:$RUBY_LIB_PREFIX/lib/ruby/site_ruby:$RUBY_LIB_PREFIX/lib/ruby/vendor_ruby/1.8:$RUBY_LIB_PREFIX/lib/ruby/vendor_ruby/1.8/x86_64-linux:$RUBY_LIB_PREFIX/lib/ruby/vendor_ruby:$RUBY_LIB_PREFIX/lib/ruby/1.8:$RUBY_LIB_PREFIX/lib/ruby/1.8/x86_64-linux
export LOAD_PATH=$RUBY_BASE/rubies/ruby-1.8.7-p352/lib/ruby/site_ruby/1.8/
export PATH=$RUBY_BASE/rubies/ruby-1.8.7-p352/bin:$PATH:/usr/local/bin
export LD_LIBRARY_PATH=$RUBY_BASE/rubies/ruby-1.8.7-p352/lib/
export GEM_PATH=$RUBY_BASE/gems/ruby-1.8.7-p352
export GEM_HOME=$GEM_PATH
export MY_RUBY_HOME=$RUBY_BASE/gems/ruby-1.8.7-p352/
`dirname $LINK`/munin2graphite $@

