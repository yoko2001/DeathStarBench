#!/bin/sh
container_ids=$(docker ps -q)
if [ -n "$container_ids" ]; then
    docker kill $(docker ps -q)
fi