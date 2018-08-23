#!/bin/bash


docker create -i -t --name <kafka_container> \
              -p 9092:9092 --cap-add=ALL \
               `docker images | grep <tag> | awk {'print $3'} | grep -vi image` /bin/bash

sleep 5 #just in case

docker start <kafka_container> 
