#!/bin/bash

# crappy hack that seems to keep YouTube ads to a minumum.
# over two hours of Peppa Pig and no ads. Taking one for the team...
# grub@grub.net v0.01

# Change forceIP to the real IP from an nslookup of a 
# googlevideo hostname so you get something in your 
# geographical region. You can find one in your
# Pi-hole's query logs.
# They will look something like this:
#     r6---sn-ni5f-tfbl.googlevideo.com

# as root: run this once then run "pihole restartdns"
# You can cron this for auto-updating of the host file.

forceIP="123.456.789.999"

# nothing below here should need changing

piLogs="/var/log/pihole.log*"
ytHosts="/etc/hosts.youtube"

workFile=$(mktemp)
dnsmasqFile="/etc/dnsmasq.d/99-youtube.grublets.conf"

if [ ! -f $dnsmasqFile ]; then
	echo "addn-hosts=$ytHosts" > $dnsmasqFile
	touch $ytHosts
fi

cp $ytHosts $workFile
zgrep -e "reply.*-.*\.googlevideo.*\..*\..*\..*" $piLogs \
	| awk -v fIP=$forceIP '{ print fIP, $6 }' >> $workFile	
sort -u $workFile > $ytHosts
rm $workFile

exit
