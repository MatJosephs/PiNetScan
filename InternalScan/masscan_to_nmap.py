#!/bin/python3
import xml.etree.ElementTree as ET
import subprocess
import requests


def send_discord_file(webhook_url, file_path, message=None):
    """
    Send a file to a Discord webhook. Optionally, you can also send a message with the file.
    :param webhook_url: The Discord webhook URL
    :param file_path: The path to the file you want to upload
    :param message: An optional message to send along with the file
    """

    # Prepare the payload (message)
    data = {}
    if message:
        data["content"] = message

    # Open the file in binary mode for uploading
    with open(file_path, 'rb') as file:
        files = {
            'file': (file_path, file)
        }

        # Send the POST request with the file
        response = requests.post(webhook_url, data=data, files=files)

    # Check if the file was successfully sent
    if response.status_code <= 204:
        print("Successfully sent the file to Discord.")
    else:
        print(f"Failed to send the file. Status code: {response.status_code}")



def send_discord_message(webhook_url, message):
    """
    Send a message to a Discord webhook. If the message is too long (over 2000 characters),
    it will be split into multiple messages.
    """
    # Discord's maximum message length
    MAX_LENGTH = 2000
    # Split the message if it is too long
    if len(message) > MAX_LENGTH:
        parts = [message[i:i + MAX_LENGTH] for i in range(0, len(message), MAX_LENGTH)]
    else:
        parts = [message]

    # Send each part as a separate message
    for part in parts:
        payload = {
            "content": part
        }
        response = requests.post(webhook_url, json=payload)

        # Check if the message was successfully sent
        if response.status_code == 204:
            print("Successfully sent a message part!")
        else:
            print(f"Failed to send the message part. Status code: {response.status_code}")


WEBHOOK_URL="https://discord.com/api/webhooks/<WEBHOOK>"


tree = ET.parse("/home/pi/Projects/InternalScan/script_output/masscan.out")
root = tree.getroot()

nmap_dict = {}

for host in root.findall('host'):
    ip = host.find('address').get('addr')
    ports = []
    for port in host.find('ports').findall('port'):
        port_id = port.get('portid')
        ports.append(port_id)
    if ip in nmap_dict:
        nmap_dict[ip].extend(ports)
    else:
        nmap_dict[ip] = ports

discord_message = "Formatted masscan output:\n"
for ip in nmap_dict:
    discord_message += ip + ": " + ", ".join(nmap_dict[ip]) + "\n"

send_discord_message(WEBHOOK_URL, discord_message)

for ip in nmap_dict:
    nmap_command = ['nmap', '-sV', '-sC', '-T5', '-vv', ip, '-p', ','.join(nmap_dict[ip]), '-oN', f'/home/pi/Projects/InternalScan/script_output/{ip}.nmap']
    print("[*] Running nmap:", ' '.join(nmap_command))

    try:
        result = subprocess.run(nmap_command, capture_output=True, text=True, check=True)
        nmap_output = result.stdout
        send_discord_file(WEBHOOK_URL, f"/home/pi/Projects/InternalScan/script_output/{ip}.nmap")
    except subprocess.CalledProcessError as e:
        print(f"Error running nmap: {e}")
