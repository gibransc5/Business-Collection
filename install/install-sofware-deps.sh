#!/bin/bash
# install and start riak

curl -s https://packagecloud.io/install/repositories/basho/riak/script.deb.sh | bash
apt-get install rebar
apt-get install git -y
apt-get install riak -y

ulimit -n 65536

riak start
