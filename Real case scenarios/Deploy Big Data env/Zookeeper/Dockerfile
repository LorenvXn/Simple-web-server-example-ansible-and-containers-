FROM ubuntu:16.04
 
RUN apt-get update 
        RUN apt-get install -y --no-install-recommends apt-utils &&\
                apt-get update &&\
                apt-get install -y curl  wget iproute2
 
#ENV DEBIAN_FRONTEND noninteractive
 
 
WORKDIR /opt
 
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py 
 
RUN apt-get update -y
 
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list && \
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" |tee -a /etc/apt/sources.list && \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true| /usr/bin/debconf-set-selections && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && apt-get update && apt-get install -y curl dnsutils oracle-java8-installer ca-certificates
 
RUN wget -q -O - http://mirror.csclub.uwaterloo.ca/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz | tar -xzf - -C /opt \
        && mv /opt/zookeeper-3.4.10 /opt/zookeeper \
        && cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg
 
 
#EXPOSE 2181 2888 3888
 
WORKDIR /opt/zookeeper
