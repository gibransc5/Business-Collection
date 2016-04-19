#!/bin/bash                                                                     
# Load virtual machine with dependecies and run the function delete db

erl -pa ebin/ deps/*/ebin  -run buscol start_data -run init stop -noshell
