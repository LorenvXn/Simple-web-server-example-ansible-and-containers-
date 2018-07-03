FROM ubuntu:16.04
 
RUN apt-get update &&\
    apt-get install -y openssh-server
 
 
RUN apt-get install software-properties-common -y  && \
    apt-add-repository ppa:ansible/ansible -y  && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7BB9C367 &&\ 
    apt-get update &&\
    apt-get install ansible -y
 
EXPOSE 80 8080 22
