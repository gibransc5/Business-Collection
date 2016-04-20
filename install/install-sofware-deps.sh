#!/bin/bash
# install and start riak

curl -s https://packagecloud.io/install/repositories/basho/riak/script.deb.sh | bash
apt-get install rebar -y
apt-get install git -y
apt-get install riak -y

sed -i 's/storage_backend = bitcask/storage_backend = leveldb/g' /etc/riak/riak.conf

ulimit -n 65536

riak start
