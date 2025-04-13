#!/bin/bash
set -x  # Debug-Ausgabe aktivieren
source /etc/kiosk/env.sh

echo "⏳ Warte auf X ($KIOSKDELAY Sekunden max)..."
timeout=$KIOSKDELAY
count=0
while ! xset -q > /dev/null 2>&1; do
    sleep 1
    ((count++))
    if [ "$count" -ge "$timeout" ]; then
        echo "❌ X ist nicht bereit. Breche ab."
        exit 1
    fi
done

echo "🖥️ Konfiguriere Bildschirm..."
xrandr --output "$KIOSK_DISPLAY_PORT" --mode 1920x1080
sleep 1

echo "⚙️ Deaktiviere DPMS / Screensaver..."
xset s off
xset -dpms
xset s noblank

# Optional: unclutter aktivieren
# unclutter -idle 0.1 -root &

echo "🚀 Starte Openbox..."
openbox-session &
sleep 2

echo "🔍 Starte VNC..."
x11vnc -display :0 -auth /home/kiosk/.Xauthority -forever -nopw &
sleep 2

echo "🌐 Starte Firefox im GUI-Modus..."
exec firefox-esr -P "$KIOSK_FIREFOX_PROFILE" "$KIOSK_URL"

