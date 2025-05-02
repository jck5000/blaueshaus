#!/bin/bash

# nano /etc/kiosk/env.sh
# chmod +x /etc/kiosk/env.sh

# Eigene IP-Adresse (PVE-Host)
export KIOSK_PVE_IP="192.168.188.174"   # ← ändern, falls sich IP ändert

# Soll-Gateway
export KIOSK_PVE_GW="192.168.188.1"

# Ping-Ziel für Internet-Check
export PING_HOST="8.8.8.8"

# Home Assistant IP-Adresse (VM oder Container)
export KIOSK_HA_IP="100.85.64.126"     # ← ändern, wenn sich HA-Adresse ändert

# Bildschirmanschlussname (für xrandr und xset dpms)
export KIOSK_DISPLAY_PORT="DisplayPort-0"  # z. B. HDMI-1, DP-1, etc.

# (Optional) Standard-URL im Kioskmodus (z. B. Home Assistant Dashboard)
export KIOSK_URL="http://$KIOSK_HA_IP:8123/lovelace/kiosk?kiosk"

# (Optional) Profilname für Firefox (wird später gebraucht)
export KIOSK_FIREFOX_PROFILE="master"

# (Optional) Display-Variable, falls mehrfach gebraucht
export DISPLAY=":0"

# Delay Serverstart zu HA Ready
export KIOSKDELAY="90"


