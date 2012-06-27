OpenStack resource agent
========================

Currently I wrote the most 2 missing resource agent in OpenStack. The ra for nova-api and nova-scheduler mainly re-use the structure of the resource agent written by Martin Gerhard Loschwitz from Hastexo.

## Prerequisite

    $ sudo mkdir /usr/lib/ocf/resource.d/openstack
    $ cd /usr/lib/ocf/resource.d/openstack
    $ sudo wget https://raw.github.com/leseb/OpenStack-ra/master/nova-api-ra
    $ sudo chmod +x nova-api-ra

And so on for every resource agent. For more information about each ra (here example for nova-scheduler):

    $ sudo crm ra info ocf:openstack:nova-scheduler

## Nova-API

The ra checks if the pid exists and also verifies if the nova-api listening ports are opened.

Usage:

    primitive p_nova_api ocf:openstack:nova-api-ra \
        params config="/etc/nova/nova.conf" \
        op monitor interval="5s" timeout="5s"

## Nova-Scheduler

The ra checks if the pid exists and also verifies if the connection to the AMQP server is properly established. Thus the ra is also compatible with Zero-MQ but in this case only checks the connection to the database.

Usage:

    primitive p_scheduler ocf:openstack:nova-scheduler-ra \
        params config="/etc/nova/nova.conf" amqp_server_port="5765" database_server_port="3307" \
        op monitor interval="30s" timeout="30s"

If you use zero-MQ:

    primitive p_scheduler ocf:openstack:nova-scheduler-ra \
        params config="/etc/nova/nova.conf" zeromq="true" \
        op monitor interval="30s" timeout="30s"

## Nova-cert

Same checks as nova-scheduler

## Nova-consoleauth

Same checks as nova-scheduler

## Nova-vnc

The ra checks if the pid exists and also verifies if the vnc service is listenning on his port. The ra is also compatible with xvpvnc, simply change the listenning port with the console_port parameters.

    primitive p_vnc ocf:openstack:nova-vnc-ra \
        params config="/etc/nova/nova.conf" console_port="5900" \
        op monitor interval="30s" timeout="30s"
