#!/bin/bash
source /etc/kiosk/env.sh

# Warten auf Home Assistant (Port 8123) – max. $KIOSKDELAY
timeout=$KIOSKDELAY
count=0
while true; do
    code=$(curl -s -o /dev/null -w "%{http_code}" http://$KIOSK_HA_IP:8123)
    if [ "$code" = "200" ]; then
        break
    fi
    sleep 1
    ((count++))
    if [ "$count" -ge "$timeout" ]; then
        /sbin/reboot || exit 1
    fi
done

# Warten, bis X vollständig läuft – max. $KIOSKDELAY
timeout=$KIOSKDELAY
count=0
while ! xset -q > /dev/null 2>&1; do
    sleep 1
    ((count++))
    if [ "$count" -ge "$timeout" ]; then
        /sbin/reboot || exit 1
    fi
done

# Bildschirmkonfiguration
xrandr --output "$KIOSK_DISPLAY_PORT" --mode 1920x1080

# DPMS & Screensaver deaktivieren
xset s off
xset -dpms
xset s noblank

# Maus ausblenden 
unclutter -idle 0.1 -root &

# Openbox starten (als Window Manager)
openbox-session &

# Starte x11vnc für Fernzugriff
# Quatsch pkill -u kiosk x11vnc
x11vnc -display :0 -auth /home/kiosk/.Xauthority -forever -nopw &

# Firefox im Kiosk-Modus starten
exec firefox-esr --kiosk -P "$KIOSK_FIREFOX_PROFILE" "$KIOSK_URL"
