OpenStack resource agent
========================

Currently I wrote the most 2 missing resource agent in OpenStack. The ra for nova-api and nova-scheduler mainly re-use the structure of the resource agent written by Martin Gerhard Loschwitz from Hastexo.

## Nova-API

The ra checks if the pid exists and also verifies if the nova-api listening ports are opened.

## Nova-Scheduler

The ra checks if the pid exists and also verifies if the connection to the AMQP server is properly established. Thus the ra is not compatible with Zero-MQ.

## Examples

   primitive p_nova_api ocf:openstack:nova-api \
	params config="/etc/nova/nova.conf" \
	op monitor interval="5s" timeout="5s" \
   primitive p_scheduler ocf:openstack:nova-scheduler \
	params config="/etc/nova/nova.conf" queue_port="5777" \
	op monitor interval="30s" timeout="30s" \ 
