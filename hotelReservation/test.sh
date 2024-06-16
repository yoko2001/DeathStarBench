#!/bin/sh

sudo mkdir /sys/fs/cgroup/cpu_mem_example
sudo echo "+cpu +memory" | sudo sh -c "cat > /sys/fs/cgroup/cpu_mem_example/cgroup.subtree_control"
sudo cgexec -g cpu,memory:/sys/fs/cgroup/cpu_mem_example sleep 1