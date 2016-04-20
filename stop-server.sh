#!/bin/bash                                                                     
# Stop server
#
./rel/buscol/bin/buscol stop
sleep 4
./rel/buscol/bin/buscol ping
echo "PANG - Server stopped"
