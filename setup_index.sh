#!/bin/sh

HOST=$1

echo setting up fluentlog_index at $HOST
curl -X PUT http://${HOST}/yz/index/fluentlog_index
echo "setting fluentlog_index to fluentlog bucket"
curl -X PUT http://${HOST}/buckets/fluentlog/props -H 'Content-type:application/json' -d '{"props":{"yz_index":"fluentlog_index"}}'

curl http://${HOST}/yz/index?index=true
curl http://${HOST}/buckets/fluentlog/props