OpenStack resource agent
========================

Currently I wrote the most 2 missing resource agent in OpenStack. The ra for nova-api and nova-scheduler mainly re-use the structure of the resource agent written by Martin Gerhard Loschwitz from Hastexo.

## Nova-API

The ra checks if the pid exists and also verifies if the nova-api listening ports are opened.

## Nova-Scheduler

The ra checks if the pid exists and also verifies if the connection to the AMQP server is properly established. Thus the ra is not compatible with Zero-MQ.
