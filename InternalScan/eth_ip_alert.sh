#!/bin/bash

# Discord webhook URL
WEBHOOK_URL="https://discord.com/api/webhooks/<WEBHOOK>"

# Check if eth0 is up and has an IP address
i=0
while true; do
  ((i++))
  if [ "$i" -gt 7 ]; then
    echo "[!] Failed to get eth0 interface! Quitting..."
    /usr/bin/curl -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\": \"Failed to get eth0 interface! Quitting...\"}" \
        $WEBHOOK_URL
    exit 1
  fi
  IP=$(ifconfig eth0 | grep 'inet ' | sed -E 's|.*inet (.*) *netmask.*|\1|g')
  if [ -n "$IP" ]; then
    # If IP is found, send to Discord
    echo Found IP: $IP
    /usr/bin/curl -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\": \"🌐 Raspberry Pi Connected! IP Address: $IP\"}" \
        $WEBHOOK_URL


    NETWORK_RANGE=$(/home/pi/Projects/InternalScan/cidr.py)
    echo Found network range: $NETWORK_RANGE

    /usr/bin/curl -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\": \"🌐 Network range: $NETWORK_RANGE\"}" \
        $WEBHOOK_URL


    /bin/bash /home/pi/Projects/InternalScan/main_scan.sh $NETWORK_RANGE

    exit 0

  else
    # If no IP, wait for 30 seconds and check again
    IP=$(hostname -I)
    IPCONFIG=$(ifconfig eth0 | head -n1)
    echo "[-] Did not find eth0 interface. Current IP: $IP"
    /usr/bin/curl -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\": \"🌐 Did not find eth0 IP, sleeping for 30 seconds: $IP | $IPCONFIG \"}" \
        $WEBHOOK_URL
    sleep 30
  fi
done
