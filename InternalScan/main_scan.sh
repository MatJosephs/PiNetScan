#!/bin/bash

NETWORK_RANGE=$1

TS=$(date +%Y%m%d%H%M%S)
WEBHOOK_URL="https://discord.com/api/webhooks/<WEBHOOK>"
rm -rf /home/pi/Projects/InternalScan/paused.conf
mkdir /home/pi/Projects/InternalScan/script_output

ports="";for p in $(cat /home/pi/Projects/InternalScan/ports.lst);do ports=$ports,$p;done

echo "[*] Read port list"

/usr/bin/curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"[+] Running masscan against $NETWORK_RANGE\"}" $WEBHOOK_URL

sudo masscan -p ${ports#?} $NETWORK_RANGE --rate 10000 -oX /home/pi/Projects/InternalScan/script_output/masscan.out

curl -X POST "$WEBHOOK_URL" -F "file=@/home/pi/Projects/InternalScan/script_output/masscan.out"

python3 /home/pi/Projects/InternalScan/masscan_to_nmap.py

grep open /home/pi/Projects/InternalScan/script_output/*.nmap | grep http | awk -F/ '{print $7}' | awk -F".nmap:" '{print $1":"$2}' > /home/pi/Projects/InternalScan/script_output/httpx.input
curl -X POST -F "file=@/home/pi/Projects/InternalScan/script_output/httpx.input" $WEBHOOK_URL

httpx -l /home/pi/Projects/InternalScan/script_output/httpx.input -ss --title --server


zip -r /home/pi/Projects/InternalScan/script_output/httpx_output.zip /home/pi/Projects/InternalScan/output
curl -X POST "$WEBHOOK_URL" -F "file=@/home/pi/Projects/InternalScan/script_output/httpx_output.zip"

exit 0


sudo masscan -p ${ports#?} 172.16.0.0/12 --rate 10000 -oX /home/pi/Projects/InternalScan/script_output/masscan.out

curl -X POST "$WEBHOOK_URL" -F "file=@/home/pi/Projects/InternalScan/script_output/masscan.out"

python3 /home/pi/Projects/InternalScan/masscan_to_nmap.py

grep open /home/pi/Projects/InternalScan/script_output/*.nmap | grep http | awk -F/ '{print $7}' | awk -F".nmap:" '{print $1":"$2}' > /home/pi/Projects/InternalScan/script_output/httpx.input
curl -X POST -F "file=@/home/pi/Projects/InternalScan/script_output/httpx.input" $WEBHOOK_URL

httpx -l /home/pi/Projects/InternalScan/script_output/httpx.input -ss --title --server


zip -r /home/pi/Projects/InternalScan/script_output/httpx_output.zip /home/pi/Projects/InternalScan/output
curl -X POST "$WEBHOOK_URL" -F "file=@/home/pi/Projects/InternalScan/script_output/httpx_output.zip"


sudo masscan -p ${ports#?} 10.0.0.0/8 --rate 10000 -oX /home/pi/Projects/InternalScan/script_output/masscan.out

curl -X POST "$WEBHOOK_URL" -F "file=@/home/pi/Projects/InternalScan/script_output/masscan.out"

python3 /home/pi/Projects/InternalScan/masscan_to_nmap.py

grep open /home/pi/Projects/InternalScan/script_output/*.nmap | grep http | awk -F/ '{print $7}' | awk -F".nmap:" '{print $1":"$2}' > /home/pi/Projects/InternalScan/script_output/httpx.input
curl -X POST -F "file=@/home/pi/Projects/InternalScan/script_output/httpx.input" $WEBHOOK_URL

httpx -l /home/pi/Projects/InternalScan/script_output/httpx.input -ss --title --server


zip -r /home/pi/Projects/InternalScan/script_output/httpx_output.zip /home/pi/Projects/InternalScan/output
curl -X POST "$WEBHOOK_URL" -F "file=@/home/pi/Projects/InternalScan/script_output/httpx_output.zip"
