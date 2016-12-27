#!/bin/sh
sleep 10
if env | grep -q "RIAK_JOINING_IP"; then
  # Join node to the cluster
  (sleep 5;riak-admin cluster join "riak@${RIAK_JOINING_IP}"  && echo -e "Node Joined The Cluster") &

  # Are we the last node to join?
  (sleep 8; if riak-admin member-status | egrep "joining|valid" | wc -l | grep -q "${RIAK_CLUSTER_SIZE}"; then
    riak-admin cluster plan  && riak-admin cluster commit && echo -e "\nCommiting The Changes..."
  fi) &
fi
