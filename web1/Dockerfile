#####################################
# to be used for creation of:
# loadbalancer, web1, web2
####################################

FROM ubuntu:16.04
 
RUN apt-get update &&\
    apt-get install -y openssh-server &&\
    apt-get install sudo -y &&\
    apt-get install vim -y
 
RUN /etc/init.d/ssh start
 
EXPOSE 22 3306 80
