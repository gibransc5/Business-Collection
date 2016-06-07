#!/bin/bash                                                                     
# Install software dependecies and app compilation

if [ "$1" == "ubuntu" ]; 
then  echo "Installing on Ubuntu"
    apt-get install curl
    apt-get install wget
    sh install/install-otp17.sh
    sh install/install-sofware-deps.sh
fi
if [ "$1" == "mac" ];
then echo "Installing on Mac"
    brew update
    brew install homebrew/versions/erlang-r17 
    echo kern.maxfiles=65536 | sudo tee -a /etc/sysctl.conf
    echo kern.maxfilesperproc=65536 | sudo tee -a /etc/sysctl.conf
    sudo sysctl -w kern.maxfiles=65536
    sudo sysctl -w kern.maxfilesperproc=65536
    ulimit -n 65536 65536   
    brew install riak
    sed -i '' 's/storage_backend = bitcask/storage_backend = leveldb/g' /usr/local/Cellar/riak/2.1.3/libexec/etc/riak.conf 
    riak start
fi

rebar get-deps
rebar compile
