#!/bin/bash

while true; do

    docker-compose logs | grep "Listening on"
    if [ $? = 0 ]; then
        exit;
    fi
    sleep 5;
done
