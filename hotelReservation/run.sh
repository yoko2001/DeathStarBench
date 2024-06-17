#!/bin/sh
container_ids=$(docker ps -q)
if [ -n "$container_ids" ]; then
    docker kill $(docker ps -q)
fi
docker rm -f $(docker ps -aqf "name=consul")
docker rm -f $(docker ps -aqf "name=frontend")

sleep 1
sudo systemctl stop hotel_reservation.slice
sudo systemctl start hotel_reservation.slice

CGROUPNAME=hotelres
CGROUP_PATH="/sys/fs/cgroup/yuri/${CGROUPNAME}/cgroup.procs"

sudo cgdelete -r memory:/yuri/${CGROUPNAME}
sudo cgdelete -r memory:/yuri

if [ ! -d "/sys/fs/cgroup/yuri/" ];then
        sudo mkdir /sys/fs/cgroup/yuri
fi
sudo sh -c 'echo "+memory +cpu" >> /sys/fs/cgroup/yuri/cgroup.subtree_control'

if [ ! -d "/sys/fs/cgroup/yuri/${CGROUPNAME}/" ];then
        sudo mkdir /sys/fs/cgroup/yuri/${CGROUPNAME}
        sudo sh -c 'echo "+cpu +memory" >> /sys/fs/cgroup/yuri/${CGROUPNAME}/cgroup.subtree_control'
else
        echo "cgroup yuri/${CGROUPNAME} already exists"
fi

# sudo sh -c "echo 0 >> /sys/fs/cgroup/yuri/${CGROUPNAME}/cpuset.mems"

echo "adding to cgroup"
# sudo cgexec -g memory:/sys/fs/cgroup/yuri/${CGROUPNAME} sleep 1
echo "adding complete"
docker-compose --compatibility up -d 

# docker run -d --name=frontend --config source=server_config,target=/config.json -e TLS -e GC -e JAEGER_SAMPLE_RATIO -e LOG_LEVEL  -p 5000:5000 --restart=always --cgroup-parent=hotel_reservation.slice deathstarbench/hotel-reservation:latest frontend
sudo cat /sys/fs/cgroup/yuri/${CGROUPNAME}/cgroup.procs