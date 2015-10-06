#! /bin/sh
echo "$0 start."

echo ROLE=${ROLE} >> /opt/cloudconductor/config

source /opt/cloudconductor/lib/common.sh

if [ -f ${CHEF_ENV_FILE} ]; then
  source ${CHEF_ENV_FILE}
fi

CONSUL_SECRET_KEY=$(cat /etc/consul.d/default.json | jq -r .acl_master_token)

service consul start

sleep 10

output="$(bash -x /opt/cloudconductor/bin/configure.sh ${CONSUL_SECRET_KEY})"
status=$?

if [ $status -ne 0 ] ; then
  echo $output
  exit $status
fi
