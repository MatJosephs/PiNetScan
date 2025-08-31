# InternalScan – Automated Internal Network Scanner on Raspberry Pi

## 📖 Overview
This project was created to automate **internal network scans** during security engagements.  

### Scenario
On an engagement, you identify an **exposed Ethernet port**. Instead of plugging in a laptop and scanning the network on the spot (which might look suspicious), you deploy a **Raspberry Pi**.  

The Pi automatically:
- Detects if the port is connected to the internet  
- Starts scanning the internal network  
- Sends **real-time updates** to a Discord channel  

### Features
- Uses **masscan** for rapid port discovery on the internal network  
- Runs **Nmap service scans** on identified hosts for detailed enumeration  
- Uses **HTTPX** to obtain screenshots from discovered web servers  
- Automates execution via a **systemd service** on boot  

---

## ⚙️ Installation

### 1. Place project files
Clone or copy the `InternalScan` folder to:
```
/home/pi/Projects/InternalScan
```

### 2. Ensure the script is executable
```
chmod +x /home/pi/Projects/InternalScan/eth_ip_alert.sh
```

### 3. Create and enable systemd service
Create the service file:
```
sudo tee /etc/systemd/system/scanner.service >/dev/null <<'EOF'
[Unit]
Description=Run scanner after network is up
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/Projects/InternalScan
ExecStart=/home/pi/Projects/InternalScan/eth_ip_alert.sh
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

Enable network wait service (Raspberry Pi with `dhcpcd`):
```
sudo systemctl enable --now dhcpcd-wait-online.service 2>/dev/null || true
```

Reload and enable scanner:
```
sudo systemctl daemon-reload
sudo systemctl enable --now scanner.service
```

---

## 🔍 Usage
Once deployed and plugged into a network port:
- The Pi will automatically boot and start scanning  
- Results are sent **live to your Discord webhook**  
- Logs can be checked locally with:
  ```
  journalctl -u scanner.service -f
  ```

---

## 🚀 Future Improvements
- Add support for **Nuclei** and other vulnerability scanners  
- Enable **persistent remote access** so the Pi can be managed remotely  
- Better result aggregation and reporting  

---

## ✅ Status
- Tested both on **client engagements** and **personal experiments**  
- Verified in **real-world conditions**  
- Lightweight, portable, modular  

---

## ⚠️ Disclaimer
This project is intended for **authorized security assessments** and **educational purposes only**.  
Do not deploy this in environments without proper legal authorization.  
