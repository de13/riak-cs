FROM phusion/baseimage:latest
MAINTAINER Hussein Galal hussein.galal.ahmed.11@gmail.com

RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update -qq && apt-get install -y software-properties-common && \
    apt-add-repository ppa:webupd8team/java -y && apt-get update -qq && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer

# Install Riak
RUN curl https://packagecloud.io/install/repositories/basho/riak/script.deb | bash
RUN apt-get install -y riak

# Setup the Riak service
RUN mkdir -p /etc/service/riak
ADD scripts/riak.sh /etc/service/riak/run

RUN sed -i.bak 's/listener.http.internal = 127.0.0.1/listener.http.internal = 0.0.0.0/' /etc/riak/riak.conf && sed -i.bak 's/listener.protobuf.internal = 127.0.0.1/listener.protobuf.internal = 0.0.0.0/' /etc/riak/riak.conf && \
    echo "anti_entropy.concurrency_limit = 1" >> /etc/riak/riak.conf && \
    echo "javascript.map_pool_size = 0" >> /etc/riak/riak.conf && \
    echo "javascript.reduce_pool_size = 0" >> /etc/riak/riak.conf && \ 
    echo "javascript.hook_pool_size = 0" >> /etc/riak/riak.conf

# Add Automatic cluster support
ADD scripts/run.sh /etc/my_init.d/99_automatic_cluster.sh
RUN chmod u+x /etc/my_init.d/99_automatic_cluster.sh
RUN chmod u+x /etc/service/riak/run

# Enable insecure SSH key
RUN /usr/sbin/enable_insecure_key.sh

EXPOSE 22 8098 8087
CMD ["/sbin/my_init"]
