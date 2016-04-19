#!/bin/bash                                                                     
# Install software dependecies and app compilation

#sh install/install-otp17.sh
#sh install/install-sofware-deps.sh

#if [ "$*" == "" ]; then
#        echo "No arguments provided"
#            exit 1
#fi

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
    brew install riak
    ulimit -n 65536
    riak start
fi

rebar get-deps
rebar compile
