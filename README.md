# YouTube updater for Pi-hole

Quick and dirty script that may help with YouTube ads. Run this as root in 
our Pi-hole and cron it.
This is not ideal and not as good as running a proper ad blocker in a 
browser, but for things like AppleTV it seems to work well enough.

From the script:
crappy hack that seems to keep YouTube ads to a minumum.
over two hours of Peppa Pig and no ads. Taking one for the team...

hange forceIP to the real IP from an nslookup of a 
googlevideo hostname so you get something in your 
geographical region. You can find one in your
Pi-hole's query logs.
They will look something like this:
 r6---sn-ni5f-tfbl.googlevideo.com

as root: run this once then run "pihole restartdns"
You can cron this for auto-updating of the host file.
