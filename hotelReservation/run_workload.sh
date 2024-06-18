#!/bin/sh
#restart services
sudo ./zramon.sh
overall_mem_limit=5000
./run.sh $overall_mem_limit
datetime_str=$(date +"%Y-%m-%d-%H-%M-%S")
numthreads=8
numconns=600
duration=2m
requests=200
root_dir=$(dirname "$(readlink -f "$0")")
log_dir="$root_dir/log"
log_file="$log_dir/wrk-report-mem:$overall_mem_limit-n$numthreads-nconn$numconns-du$duration-req$requests-$datetime_str.log"
echo $log_file

#run the workload
../wrk2/wrk -D exp -t $numthreads -c $numconns -d $duration -L -s ./wrk2/scripts/hotel-reservation/mixed-workload_type_1.lua http://127.0.0.1:5000 -R $requests > $log_file

./readinfo.sh >> $log_file