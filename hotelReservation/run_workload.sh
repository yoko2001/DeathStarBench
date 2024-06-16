#!/bin/sh
numthreads=8
numconns=400
duration=60s
../wrk2/wrk -D exp -t $numthreads -c $numconns -d $duration -L -s ./wrk2/scripts/hotel-reservation/mixed-workload_type_1.lua http://127.0.0.1:5000 -R 300