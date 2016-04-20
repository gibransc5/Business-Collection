#!/bin/bash                                                                     
# Generate release and start server
#
rebar generate
./rel/buscol/bin/buscol start
sleep 4
./rel/buscol/bin/buscol ping
echo "Server started on 127.0.0.1:8080"
