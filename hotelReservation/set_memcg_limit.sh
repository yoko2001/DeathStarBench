#!/bin/bash
all_app_limit=$1 #MB
echo "mem limit set to $1"
root_memcg="/sys/fs/cgroup/hotel_reservation.slice"
root_memcg_limit="$root_memcg/memory.max"
sudo sh -c "echo $(($all_app_limit * 1024 * 1024)) > $root_memcg_limit"
sudo cat $root_memcg_limit