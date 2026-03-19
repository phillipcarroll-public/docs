#!/bin/bash

containers=("app1" "app2" "db")

for container in "${containers[@]}"; do
        echo "Stopping container: $container"
        sudo lxc-stop -n "$container"
done

for container in "${containers[@]}"; do
	echo "Destroying container: $container"
	sudo lxc-destroy -n "$container"
done
