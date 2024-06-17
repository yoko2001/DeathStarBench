#!/bin/bash
process_stat() {
  file_path="$1"
  if [ ! -f "$file_path" ]; then
    # echo "文件不存在: $file_path"
    return 1
  fi
  workingset_refault_anon=0
  workingset_refault_file=0

  # 逐行读取文件并进行处理
  while IFS= read -r line; do
    # 在这里编写你要对每一行进行的操作
    if [[ "$line" == workingset_refault_anon* ]]; then
      number="${line#* }"
      number=$((number))
      workingset_refault_anon=$number
    #   echo "workingset_refault_anon: $workingset_refault_anon"
    elif [[ "$line" == workingset_refault_file* ]]; then
      number="${line#* }"
      number=$((number))
      workingset_refault_file=$number
    #   echo "workingset_refault_file: $workingset_refault_file"
    fi
  done < "$file_path"

  echo "$workingset_refault_anon $workingset_refault_file"
}
# 获取正在运行的所有Docker容器的ID和容器名称
container_info=$(docker ps --format "{{.ID}} {{.Names}}")

echo "正在运行的Docker容器的ID和容器名称:"
root_memcg="/sys/fs/cgroup/hotel_reservation.slice"
root_memcg_peak=$(cat $root_memcg/memory.peak)
root_memcg_peak_mb=$(echo "scale=1; $root_memcg_peak / 1024 / 1024" | bc)
echo "docker-compose hotel_reservation peak:$root_memcg_peak_mb mb"

# 使用循环遍历每一组ID和名称
while read -r id name
do
  matching_folder=$(find "$root_memcg" -type d -name "docker-$id*" | head -n 1)
  if [ -n "$matching_folder" ]; then
    docker_memcg="$matching_folder"
    docker_memcg_peak=$(cat $docker_memcg/memory.peak)
    docker_memcg_peak_mb=$(echo "scale=1; $docker_memcg_peak / 1024 / 1024" | bc)
    docker_memcg_stat_path=$docker_memcg/memory.stat
    statlist=$(process_stat $docker_memcg_stat_path)
    read -r workingset_refault_anon workingset_refault_file <<< "$statlist"
    echo "docker id:$id name:$name peak:$docker_memcg_peak_mb mb refault_anon:$workingset_refault_anon refault_file:$workingset_refault_file"
  fi
done <<< "$container_info"