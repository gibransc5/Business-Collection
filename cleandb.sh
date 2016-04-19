#!/bin/bash                                                                     
# Load virtual machine with dependecies and run the function delete db

erl -pa ebin/ deps/*/ebin  -run buscol clean -run init stop -noshell
echo "Database clean"
