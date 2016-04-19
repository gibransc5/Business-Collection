#!/bin/bash                                                                     
# Install software dependecies and app compilation

sh install/install-otp17.sh
sh install/install-sofware-deps.sh 
rebar get-deps
rebar compile
