#!/bin/vbash
# Update route table for ipTV multicast traffic / mangled by JvO 27-11-2021
ScriptRelease=V9
CURPID=$(pidof igmpproxy)

echo "Back once again for the renegade master, D4 damage for the IpTV route behavior!"
# Check if lockfile is still in place from previous executions, if it is we stop right here.
        if [ -f "/config/scripts/routemangler.lock" ]; then
                echo "Lock file exists, stopping right here"
                exit 1
        fi

# Create lock file.
        echo "It seems there was no lock file, lets create one right here."
        touch /config/scripts/routemangler.lock

# Use vyatta script template to ensure proper function of edgeOS commands.
        source /opt/vyatta/etc/functions/script-template
        echo "Source selected"

sleep 2

# Current static that is defined for routing the IPTV traffic through the appropiate interface.
        echo "Set new static as defined below when it is not already in place."
        echo "set protocols static route 213.75.112.0/21 next-hop $NEW_IP"

CUR_IP=$(cat /config/config.boot | grep 213.75.112.0/21 -A1 | grep next-hop | awk '{ print $2}');

# New static to be set for routing the IPTV traffic through the appropiate interface.
NEW_IP=$(cat /var/run/dhclient_eth0.4_lease | grep new_dhcp_server_identifier | awk -F= '{print $2}' | tr -d \');

# Check if the proper route is in place, if it is we do not have to set the static route and save the configuration.
        if [ "$CUR_IP" == "$NEW_IP" ]; then
                echo "Say whhaattt, it looks like the address is the same so we don't have to set the static route, SNAFU?"
        elif [ "$CUR_IP" != "$NEW_IP" ]; then 
                configure                                                     
                delete protocols static route 213.75.112.0/21 next-hop $CUR_IP
                set protocols static route 213.75.112.0/21 next-hop $NEW_IP
                commit
                save    
                echo "Config activated and saved, let's roll further!"
        fi

sleep 1

# Check if IGMP Proxy is running at all, if it is not restart that mofo!
        if pgrep -x igmpproxy > /dev/null; then
                echo "IGMP Proxy is running as it should."
        else
                echo "IGMP Proxy is not running, lets restart it!"
                /opt/vyatta/bin/vyatta-op-cmd-wrapper restart igmp-proxy
        fi

# Check if IGMP proxy is running for more then 6 hours, restart when true.
if pgrep -x igmpproxy > /dev/null; then
                CURRUNTIME=$(ps -p $CURPID -o etimes=)
        if [ $CURRUNTIME -gt 21600 ]; then
                echo "It looks like that the IGMP Proxy running for more then 6 hours, time to restart!"
                /opt/vyatta/bin/vyatta-op-cmd-wrapper restart igmp-proxy
        else 
                echo "IGMP Proxy is not running for at least 6 hours so we don't do anything."
        fi
fi

# Let double check our IGMP proxy since you'll never know if it is still running like a charm.
        echo "Mighty IGMP Proxy, show me your PID:$CURPID"

# Delete lock file since we are all done here are we?
        echo "Hold your tits, we still got to delete the lock file!"
        rm /config/scripts/routemangler.lock

# Final confirmation....
echo "All done here!"