#!/bin/bash

docker create -i -t --name <zookeeper_container> -p 2181:2181 --cap-add=ALL  `docker images | grep <tag> | awk {'print $3'} | grep -vi image` /bin/bash

sleep 5

docker start <zookeeper_container> 
