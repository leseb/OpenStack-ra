#!/bin/sh
#
#
# OpenStack Nova Cert (nova-cert)
#
# Description:  Manages an OpenStack Nova Cert (nova-cert) process as an HA resource
#
# Authors:      Sébastien Han
# Mainly inspired by the Glance API resource agent written by Martin Gerhard Loschwitz from Hastexo: http://goo.gl/whLpr
#
# Support:      openstack@lists.launchpad.net
# License:      Apache Software License (ASL) 2.0
#
#
# See usage() function below for more details ...
#
# OCF instance parameters:
#   OCF_RESKEY_binary
#   OCF_RESKEY_config
#   OCF_RESKEY_user
#   OCF_RESKEY_pid
#   OCF_RESKEY_monitor_binary
#   OCF_RESKEY_amqp_server_port
#   OCF_RESKEY_zeromq
#   OCF_RESKEY_additional_parameters
#######################################################################
# Initialization:

: ${OCF_FUNCTIONS_DIR=${OCF_ROOT}/lib/heartbeat}
. ${OCF_FUNCTIONS_DIR}/ocf-shellfuncs

#######################################################################

# Fill in some defaults if no values are specified

OCF_RESKEY_binary_default="nova-cert"
OCF_RESKEY_config_default="/etc/nova/nova.conf"
OCF_RESKEY_user_default="nova"
OCF_RESKEY_pid_default="$HA_RSCTMP/$OCF_RESOURCE_INSTANCE.pid"
OCF_RESKEY_monitor_binary_default="netstat"
OCF_RESKEY_database_server_port_default="3306"
OCF_RESKEY_amqp_server_port_default="5672"
OCF_RESKEY_zeromq_default="false"

: ${OCF_RESKEY_binary=${OCF_RESKEY_binary_default}}
: ${OCF_RESKEY_config=${OCF_RESKEY_config_default}}
: ${OCF_RESKEY_user=${OCF_RESKEY_user_default}}
: ${OCF_RESKEY_pid=${OCF_RESKEY_pid_default}}
: ${OCF_RESKEY_monitor_binary=${OCF_RESKEY_monitor_binary_default}}
: ${OCF_RESKEY_database_server_port=${OCF_RESKEY_database_server_port_default}}
: ${OCF_RESKEY_amqp_server_port=${OCF_RESKEY_server_amqp_port_default}}
: ${OCF_RESKEY_zeromq=${OCF_RESKEY_zeromq_default}}

#######################################################################

usage() {
    cat <<UEND
        usage: $0 (start|stop|validate-all|meta-data|status|monitor)

        $0 manages an OpenStack Nova Cert (nova-cert) process as an HA resource 

        The 'start' operation starts the identity service.
        The 'stop' operation stops the identity service.
        The 'validate-all' operation reports whether the parameters are valid
        The 'meta-data' operation reports this RA's meta-data information
        The 'status' operation reports whether the identity service is running
        The 'monitor' operation reports whether the identity service seems to be working

UEND
}

meta_data() {
    cat <<END
<?xml version="1.0"?>
<!DOCTYPE resource-agent SYSTEM "ra-api-1.dtd">
<resource-agent name="nova-cert">
<version>1.0</version>

<longdesc lang="en">
Resource agent for the OpenStack Nova Cert Service (nova-cert)
May manage a nova-cert instance or a clone set that 
creates a distributed nova-cert cluster.
</longdesc>
<shortdesc lang="en">Manages the OpenStack Nova Cert (nova-cert)</shortdesc>
<parameters>

<parameter name="binary" unique="0" required="0">
<longdesc lang="en">
Location of the OpenStack Nova Cert server binary (nova-cert)
</longdesc>
<shortdesc lang="en">OpenStack Nova Cert server binary (nova-cert)</shortdesc>
<content type="string" default="${OCF_RESKEY_binary_default}" />
</parameter>

<parameter name="config" unique="0" required="0">
<longdesc lang="en">
Location of the OpenStack Nova Cert (nova-cert) configuration file
</longdesc>
<shortdesc lang="en">OpenStack Nova Cert (nova-cert registry) config file</shortdesc>
<content type="string" default="${OCF_RESKEY_config_default}" />
</parameter>

<parameter name="user" unique="0" required="0">
<longdesc lang="en">
User running OpenStack Nova Cert (nova-cert)
</longdesc>
<shortdesc lang="en">OpenStack Nova Cert (nova-cert) user</shortdesc>
<content type="string" default="${OCF_RESKEY_user_default}" />
</parameter>

<parameter name="pid" unique="0" required="0">
<longdesc lang="en">
The pid file to use for this OpenStack Nova Cert (nova-cert) instance
</longdesc>
<shortdesc lang="en">OpenStack Nova Cert (nova-cert) pid file</shortdesc>
<content type="string" default="${OCF_RESKEY_pid_default}" />
</parameter>

<parameter name="database_server_port" unique="0" required="0">                                                                                                                                                              
<longdesc lang="en">                                                                                                                                                                                                      
The listening port number of the database server. Mandatory to perform a monitor check                                                                                                                                        
</longdesc>                                                                                                                                                                                                               
<shortdesc lang="en">Database listening port</shortdesc>                                                                                                                                                                      
<content type="integer" default="${OCF_RESKEY_database_server_port_default}" />                                                                                                                                              
</parameter>  

<parameter name="amqp_server_port" unique="0" required="0">                                                                                                                                                              
<longdesc lang="en">                                                                                                                                                                                                      
The listening port number of the AMQP server. Mandatory to perform a monitor check                                                                                                                                        
</longdesc>                                                                                                                                                                                                               
<shortdesc lang="en">AMQP listening port</shortdesc>                                                                                                                                                                      
<content type="integer" default="${OCF_RESKEY_amqp_server_port_default}" />                                                                                                                                              
</parameter>  

<parameter name="zeromq" unique="0" required="0">                                                                                                                                                              
<longdesc lang="en">                                                                                                                                                                                                      
If zeromq is used, this will disable the connection test to the AMQP server                                                                                                                                     
</longdesc>                                                                                                                                                                                                               
<shortdesc lang="en">Zero-MQ usage</shortdesc>                                                                                                                                                                      
<content type="boolean" default="${OCF_RESKEY_zeromq_default}" />                                                                                                                                              
</parameter>

<parameter name="additional_parameters" unique="0" required="0">
<longdesc lang="en">
Additional parameters to pass on to the OpenStack Nova Cert (nova-cert)
</longdesc>
<shortdesc lang="en">Additional parameters for nova-cert</shortdesc>
<content type="string" />
</parameter>

</parameters>

<actions>
<action name="start" timeout="10" />
<action name="stop" timeout="10" />
<action name="status" timeout="10" />
<action name="monitor" timeout="5" interval="10" />
<action name="validate-all" timeout="5" />
<action name="meta-data" timeout="5" />
</actions>
</resource-agent>
END
}

#######################################################################
# Functions invoked by resource manager actions

nova_cert_validate() {
    local rc

    check_binary $OCF_RESKEY_binary

    # A config file on shared storage that is not available
    # during probes is OK.
    if [ ! -f $OCF_RESKEY_config ]; then
        if ! ocf_is_probe; then
            ocf_log err "Config $OCF_RESKEY_config doesn't exist"
            return $OCF_ERR_INSTALLED
        fi
        ocf_log_warn "Config $OCF_RESKEY_config not available during a probe"
    fi

    getent passwd $OCF_RESKEY_user >/dev/null 2>&1
    rc=$?
    if [ $rc -ne 0 ]; then
        ocf_log err "User $OCF_RESKEY_user doesn't exist"
        return $OCF_ERR_INSTALLED
    fi

    true
}

nova_cert_status() {
    local pid
    local rc

    if [ ! -f $OCF_RESKEY_pid ]; then
        ocf_log info "OpenStack Nova Cert (nova-cert) is not running"
        return $OCF_NOT_RUNNING
    else
        pid=`cat $OCF_RESKEY_pid`
    fi

    ocf_run -warn kill -s 0 $pid
    rc=$?
    if [ $rc -eq 0 ]; then
        return $OCF_SUCCESS
    else
        ocf_log info "Old PID file found, but OpenStack Nova Cert (nova-cert) is not running"
        return $OCF_NOT_RUNNING
    fi
}

nova_cert_monitor() {
    local rc
    local token

    nova_cert_status
    rc=$?

    # If status returned anything but success, return that immediately
    if [ $rc -ne $OCF_SUCCESS ]; then
        return $rc
    fi

    # Check whether we are supposed to monitor by logging into nova-cert
    # and do it if that's the case.
    if ! check_binary $OCF_RESKEY_monitor_binary; then
                ocf_log warn "$OCF_RESKEY_monitor_binary missing, can not monitor!"
        else
			if [ $OCF_RESKEY_zeromq = true ]; then
				PID=`cat $OCF_RESKEY_pid`
				CERT_DATABASE_CO_CHECK=`"$OCF_RESKEY_monitor_binary" -punt | egrep "$OCF_RESKEY_database_server_port" | egrep "$PID" | egrep -q "ESTABLISHED"`
				rc_database=$?
				if [ $rc_database -ne 0 ]; then
				    ocf_log err "Nova Cert is not connected to the database server: $rc"
				    return $OCF_NOT_RUNNING
				fi
			else
                PID=`cat $OCF_RESKEY_pid`
                # check the connections according to the PID
                CERT_DATABASE_CO_CHECK=`"$OCF_RESKEY_monitor_binary" -punt | egrep "$OCF_RESKEY_database_server_port" | egrep "$PID" | egrep -q "ESTABLISHED"`
                rc_amqp=$?
                CERT_AMQP_CO_CHECK=`"$OCF_RESKEY_monitor_binary" -punt | egrep "$OCF_RESKEY_amqp_server_port" | egrep "$PID" | egrep -q "ESTABLISHED"`
                rc_database=$?
				if [ $rc_amqp -ne 0 ] || [ $rc_database -ne 0 ]; then
				    ocf_log err "Nova Cert is not connected to the AMQP server and/or the database server: $rc"
				    return $OCF_NOT_RUNNING
				fi
			fi
        fi

    ocf_log debug "OpenStack Nova Cert (nova-cert) monitor succeeded"
    return $OCF_SUCCESS
}

nova_cert_start() {
    local rc

    nova_cert_status
    rc=$?
    if [ $rc -eq $OCF_SUCCESS ]; then
        ocf_log info "OpenStack Nova Cert (nova-cert) already running"
        return $OCF_SUCCESS
    fi

    # run the actual nova-cert daemon. Don't use ocf_run as we're sending the tool's output
    # straight to /dev/null anyway and using ocf_run would break stdout-redirection here.
    su ${OCF_RESKEY_user} -s /bin/sh -c "${OCF_RESKEY_binary} --flagfile=$OCF_RESKEY_config \
       $OCF_RESKEY_additional_parameters"' >> /dev/null 2>&1 & echo $!' > $OCF_RESKEY_pid

    # Spin waiting for the server to come up.
    # Let the CRM/LRM time us out if required
	sleep 1
    while true; do
    nova_cert_monitor
    rc=$?
    [ $rc -eq $OCF_SUCCESS ] && break
    if [ $rc -ne $OCF_NOT_RUNNING ]; then
        ocf_log err "OpenStack Nova Cert (nova-cert) start failed"
        exit $OCF_ERR_GENERIC
    fi
    sleep 1
    done

    ocf_log info "OpenStack Nova Cert (nova-cert) started"
    return $OCF_SUCCESS
}

nova_cert_stop() {
    local rc
    local pid

    nova_cert_status
    rc=$?
    if [ $rc -eq $OCF_NOT_RUNNING ]; then
        ocf_log info "OpenStack Nova Cert (nova-cert) already stopped"
        return $OCF_SUCCESS
    fi

    # Try SIGTERM
    pid=`cat $OCF_RESKEY_pid`
    ocf_run kill -s TERM $pid
    rc=$?
    if [ $rc -ne 0 ]; then
        ocf_log err "OpenStack Nova Cert (nova-cert) couldn't be stopped"
        exit $OCF_ERR_GENERIC
    fi

    # stop waiting
    shutdown_timeout=15
    if [ -n "$OCF_RESKEY_CRM_meta_timeout" ]; then
        shutdown_timeout=$((($OCF_RESKEY_CRM_meta_timeout/1000)-5))
    fi
    count=0
    while [ $count -lt $shutdown_timeout ]; do
        nova_cert_status
        rc=$?
        if [ $rc -eq $OCF_NOT_RUNNING ]; then
            break
        fi
        count=`expr $count + 1`
        sleep 1
        ocf_log debug "OpenStack Nova Cert (nova-cert) still hasn't stopped yet. Waiting ..."
    done

    nova_cert_status
    rc=$?
    if [ $rc -ne $OCF_NOT_RUNNING ]; then
        # SIGTERM didn't help either, try SIGKILL
        ocf_log info "OpenStack Nova Cert (nova-cert) failed to stop after ${shutdown_timeout}s \
          using SIGTERM. Trying SIGKILL ..."
        ocf_run kill -s KILL $pid
    fi

    ocf_log info "OpenStack Nova Cert (nova-cert) stopped"

    rm -f $OCF_RESKEY_pid

    return $OCF_SUCCESS
}

#######################################################################

case "$1" in
  meta-data)    meta_data
                exit $OCF_SUCCESS;;
  usage|help)   usage
                exit $OCF_SUCCESS;;
esac

# Anything except meta-data and help must pass validation
nova_cert_validate || exit $?

# What kind of method was invoked?
case "$1" in
  start)        nova_cert_start;;
  stop)         nova_cert_stop;;
  status)       nova_cert_status;;
  monitor)      nova_cert_monitor;;
  validate-all) ;;
  *)            usage
                exit $OCF_ERR_UNIMPLEMENTED;;
esac

