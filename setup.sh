#!/bin/bash                                                                     
# Script to check riak up and also starts virtual erlang machine and runs fuctions
# to set up data into riak buckets

riak ping
erl -pa ebin/ deps/*/ebin  -run buscol start_data -run init stop -noshell
echo "Database setup completed"
