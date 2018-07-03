FROM ubuntu:16.04
 
RUN apt-get update &&\
    apt-get install -y openssh-server &&\
    apt-get install vim -y
 
RUN /etc/init.d/ssh start
 
EXPOSE 22
