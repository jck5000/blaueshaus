#!/bin/bash

source /etc/kiosk/env.sh

if [ "$KIOSK_MODE" = "gui" ]; then
  echo "🔓 GUI-Modus wird gestartet..."
  exec /home/kiosk/start-gui.sh
else
  echo "🔒 Kiosk-Modus wird gestartet..."
  exec /home/kiosk/start-kiosk.sh
fi
