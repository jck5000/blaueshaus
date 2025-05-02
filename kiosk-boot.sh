#!/bin/bash
# kiosk-autologin.sh – Netzwerk-Check vor Autologin auf TTY1

source /etc/kiosk/env.sh

echo
echo "🔍 Netzwerk-Check – Press any key to abort"
echo "   Erwartete IP: $KIOSK_PVE_IP"
echo "   Erwartetes Gateway: $KIOSK_PVE_GW"
echo

while true; do
  # Nutzer kann abbrechen
  if read -t1 -n1 _; then
    echo; echo "⏹ Abgebrochen durch Nutzer."; exit 1
  fi

  CURRENT_IP=$(ip -4 addr show dev vmbr0 | awk '/inet /{print $2}' | cut -d/ -f1)
  GW_REACHABLE=$(ping -c1 -W1 "$KIOSK_PVE_GW" &>/dev/null && echo yes || echo no)
  NET_REACHABLE=$(ping -c1 -W1 "$PING_HOST" &>/dev/null && echo yes || echo no)

  clear
  echo "🔄 Netzwerk wird geprüft… (jede Sekunde)"
  echo
  echo "Aktuelle IP:      $CURRENT_IP"
  echo "Gateway erreichbar: $GW_REACHABLE"
  echo "Internet erreichbar: $NET_REACHABLE"
  echo
  echo "Drücke eine Taste, um abzubrechen."

  if [[ "$CURRENT_IP" == "$KIOSK_PVE_IP" && "$GW_REACHABLE" == yes && "$NET_REACHABLE" == yes ]]; then
    echo; echo "✅ Netzwerk OK – starte Autologin in 2 Sekunden…"
    sleep 2
    break
  fi

  sleep 1
done

exec /sbin/agetty --autologin kiosk --noclear "$@"
