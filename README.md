Running an Ubiquiti edgeOS router on a KPN FTTH connection combined with IPTV services in a double, triple or quad play subscribtion can cause some issues from now and then.
To ensure all unicast and multicast traffic is properly routed through the appropiate interfaces to have a working IPTV setup with features like recording, playback or pause resume you could use this script.
This script can be installed on a edgeOS host and scheduled through the system taskmanager to ensure the IGMP proxy keeps running like a charm ;)
And yes, this uses DHCP option 121 to retreive the right classless route since our friends at KPN stopped sending it as "router" option in the DHCP offer since October 2021....
