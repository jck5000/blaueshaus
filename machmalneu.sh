#!/bin/bash
set -euo pipefail

echo "📦 STARTE KIOSK-INSTALLATION"

#########################################
# 🛑 Benutzer 'kiosk' anlegen
#########################################
echo "👤 Lege Benutzer 'kiosk' an..."
adduser --disabled-password --gecos "" kiosk
usermod -aG video,render,tty,input kiosk
echo "✅ Benutzer erstellt."

#########################################
# 📦 Pakete installieren
#########################################
echo "📦 Installiere benötigte Pakete..."
apt update
apt install -y \
  xserver-xorg xinit openbox \
  firefox-esr x11vnc xdotool \
  python3-venv python3-pip \
  git curl wget

echo "✅ Software installiert."

#########################################
# 🌐 Repo klonen
#########################################
echo "🌐 Klone Repository nach /opt/kiosk-setup…"
mkdir -p /opt/kiosk-setup
cd /opt/kiosk-setup
git clone https://github.com/jck5000/blaueshaus.git .  # ggf. anpassen

echo "✅ Repository geklont."

#########################################
# 📂 Dateien verteilen
#########################################
echo "📂 Kopiere Konfigurationen…"

# Umgebungsvariablen
mkdir -p /etc/kiosk
cp env.sh /etc/kiosk/

# Autostart mit Netzwerkprüfung
cp kiosk-boot.sh /usr/local/bin/kiosk-boot.sh
chmod +x /usr/local/bin/kiosk-boot.sh

# Netzwerk-Konfiguration
cp interfaces /etc/network/interfaces
cp hosts /etc/hosts

# Benutzer-Skripte
install -m 755 -o kiosk -g kiosk scripts/start-gui.sh /home/kiosk/start-gui.sh
install -m 755 -o kiosk -g kiosk scripts/killffx.sh /home/kiosk/killffx.sh
install -m 644 -o kiosk -g kiosk scripts/.xinitrc /home/kiosk/.xinitrc
install -m 644 -o kiosk -g kiosk scripts/.bash_profile /home/kiosk/.bash_profile
install -m 644 -o kiosk -g kiosk scripts/kiosk.crontab /home/kiosk/kiosk.crontab

# reload-kiosk und webhook
install -m 755 scripts/reload-kiosk.sh /usr/local/bin/reload-kiosk
cp scripts/webhook.py /home/kiosk/
chown kiosk:kiosk /home/kiosk/webhook.py

echo "✅ Alle Dateien verteilt."

#########################################
# 🛠 Autologin mit /usr/local/bin/kiosk-boot.sh
#########################################
echo "🛠 Konfiguriere Autologin auf TTY1…"
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat <<EOF > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/local/bin/kiosk-boot.sh %I \$TERM
EOF

#########################################
# 🔁 Webhook-Dienst aktivieren
#########################################
echo "🔁 Aktiviere webhook.service…"
cp systemd/kiosk-webhook.service /etc/systemd/system/
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable kiosk-webhook
systemctl restart kiosk-webhook

#########################################
# 🕓 Crontab setzen
#########################################
echo "🕓 Setze Crontab für Benutzer 'kiosk'…"
crontab -u kiosk /home/kiosk/kiosk.crontab

#########################################
# 🧹 Fertig!
#########################################
echo "🎉 Kiosk-System vollständig installiert."
echo "🔁 Jetzt am besten: reboot"
