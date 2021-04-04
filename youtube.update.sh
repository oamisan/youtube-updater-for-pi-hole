#!/bin/bash

# crappy hack that seems to keep YouTube ads to a minumum.
# over two hours of Peppa Pig and no ads. Taking one for the team...
# grub@grub.net v0.11, SD Write tweak revision 2

# Change forceIPv4 to the real IP from an nslookup of a
# googlevideo hostname so you get something in your
# geographical region. You can find one in your
# Pi-hole's query logs.
# They will look something like this:
#     r6---sn-ni5f-tfbl.googlevideo.com

# as root: run this once then run "pihole restartdns"
# You can cron this for auto-updating of the host file.
# Mine fires every minute:
# * * * * * /home/grub/bin/youtube.update.sh 2>&1


ytHosts="/etc/hosts.youtube"
piLogs="/var/log/pihole.log"
currenttime=$(date +%H%M)

if [ ! -f $ytHosts ]; then
        zgrep -e "reply.*-.*\.googlevideo.*\..*\..*\..*" $piLogs | awk '{ print $8, $6 }' | tail -1 > $ytHosts
fi

# renews forceIP every in morning i.e. 6AM

if [[ "$currenttime" > "0600" ]] && [[ "$currenttime" < "0602" ]]  ; then
        newIP=$(zgrep -e "reply.*-.*\.googlevideo.*\..*\..*\..*" $piLogs | awk '{ print $8 }' | tail -1)
        awk -v IP="$newIP" '{print IP, $2}' $ytHosts > $ytHosts.bak # updates exiting records with the new IP
        mv $ytHosts.bak $ytHosts
        forceIPv4=$newIP
else
        forceIPv4=$(head -1 $ytHosts | awk '{print $1}')
fi

# nothing below here should need changing

dnsmasqFile="/etc/dnsmasq.d/99-youtube.grublets.conf"

if [ ! -f $dnsmasqFile ]; then
    echo "addn-hosts=$ytHosts" > $dnsmasqFile
    touch $ytHosts
    piLogs="$piLogs*" # preload with results from all logs
    echo "Setup complete! Execute 'pihole restartdns' as root."
    echo "cron the script to run every minute or so for updates."
fi

# below was the SD card friendlier script by MijnKijk

ytEntries=$(wc -l $ytHosts)

for i in $(zgrep -e "reply.*-.*\.googlevideo.*\..*\..*\..*" $piLogs | awk '{ print $6 }')
do
   if [ $(grep -c "$i" $ytHosts) == 0 ]; then
      # Add line to ytHosts
      echo $forceIPv4 $i >> $ytHosts
   fi
done

if [ "$ytEntries" != "$(wc -l $ytHosts)" ]; then
   /usr/local/bin/pihole restartdns reload
fi


exit
