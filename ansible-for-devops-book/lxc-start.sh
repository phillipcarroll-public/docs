#!/bin/bash

containers=("app1" "app2" "db")

for container in "${containers[@]}"; do
	echo "Starting container: $container"
	sudo lxc-start -n "$container" -d
done
