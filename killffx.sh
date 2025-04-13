# nano /home/kiosk/killffx.sh
# chmod +x /home/kiosk/killffx.sh

#!/bin/bash

echo "🧹 Beende Firefox, VNC und X..."
pkill -9 firefox-esr
pkill -9 firefox
pkill -9 x11vnc
pkill -u kiosk startx
pkill -u kiosk X
sleep 2

echo "✅ Alles beendet."
