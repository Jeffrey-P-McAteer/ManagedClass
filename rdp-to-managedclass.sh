#!/bin/sh

# This script uses another utility (lanipof)
# and a hardcoded MAC to RDP into the system
# using the admin/"class" account.

# There's no need to replicate this for your own
# setup, I just enjoy saving keystrokes
# and not having to lookup IP addresses.


#SVR_IP=$(lanipof 'd5:f8:40') # Wifi
SVR_IP=$(lanipof '09:d8:37') # One of the Ethernet NICs

echo "SVR_IP=$SVR_IP"

xfreerdp \
  +clipboard \
  /w:1700 /h:900 \
  /scale-desktop:100 /scale-device:100 \
  +fonts /bpp:16 \
  /drive:'DOWNLOADS,/j/downloads' \
  /u:'admin' /p:'class' /v:$SVR_IP

