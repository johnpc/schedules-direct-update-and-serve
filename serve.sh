#!/bin/bash

if ! /usr/bin/lsof -i :41969 > /dev/null 2>&1; then
    cd /home/umbrel/xmltv
    /usr/local/bin/serve -p 41969 >> /tmp/serve.log 2>&1 &
    echo $! > /tmp/serve-41969.pid
fi
