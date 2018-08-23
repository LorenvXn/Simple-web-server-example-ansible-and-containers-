FROM ubuntu:16.04 
 
 
RUN apt-get -y update && \
                 apt-get -y install wget curl  iproute2 -y && \
                 apt-get install software-properties-common python-software-properties -y && \
                 apt-get -y clean all
 
ENV DEBIAN_FRONTEND noninteractive
 
WORKDIR /opt
 
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
                                        python get-pip.py && \
                                        pip install celery kafka-python Flask
 
 
RUN apt-get update -y
 
 
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list && \
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list && \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && apt-get update && apt-get install -y curl dnsutils oracle-java8-installer ca-certificates
 
 
RUN wget http://archive.apache.org/dist/kafka/0.10.0.1/kafka_2.11-0.10.0.1.tgz && \
         tar xvzf kafka_2.11-0.10.0.1.tgz && \
         mv kafka_2.11-0.10.0.1  kafka
 
WORKDIR /opt/kafka 
