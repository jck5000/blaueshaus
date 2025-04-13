#!/bin/bash

# nano machmalneu.sh
# chmod +x machmalneu.sh
# ./machmalneu.sh

echo "📦 STARTE KIOSK-INSTALLATION"

#########################################
# 🛑 Step 0: Neuen Benutzer 'kiosk' anlegen
#########################################
echo "👤 Lege Benutzer 'kiosk' an..."
adduser --disabled-password --gecos "" kiosk
usermod -aG video kiosk
usermod -aG render kiosk
usermod -aG tty kiosk
usermod -aG input kiosk
echo "✅ Benutzer 'kiosk' mit allen nötigen Gruppen angelegt."

#########################################
# 🔧 Step 1: Benötigte Pakete installieren
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
# 🌐 Step 2: Git-Repo klonen
#########################################
echo "🌐 Klone Projekt-Repo..."

mkdir -p /opt/kiosk-setup
cd /opt/kiosk-setup

git clone https://github.com/jck5000/blaueshaus.git .  # ⬅️ URL anpassen

echo "✅ Repository geklont."

#########################################
# 📂 Step 3: Konfigs & Skripte kopieren
#########################################

echo "📂 Kopiere Konfigs & Skripte..."

# globale Variablen
mkdir -p /etc/kiosk
cp configs/env.sh /etc/kiosk/

# Benutzerskripte
cp scripts/start-kiosk.sh /home/kiosk/
cp scripts/start-gui.sh /home/kiosk/
cp scripts/killffx.sh /home/kiosk/
cp scripts/.xinitrc /home/kiosk/
cp scripts/.bash_profile /home/kiosk/
chown kiosk:kiosk /home/kiosk/*

chmod +x /home/kiosk/*.sh

# Webhook-Server
cp scripts/webhook.py /home/kiosk/
chown kiosk:kiosk /home/kiosk/webhook.py

# reload-kiosk
cp scripts/reload-kiosk.sh /usr/local/bin/reload-kiosk
chmod +x /usr/local/bin/reload-kiosk

echo "✅ Dateien verteilt."

#########################################
# 🛠 Step 4: Autologin einrichten
#########################################

mkdir -p /etc/systemd/system/getty@tty1.service.d

cp systemd/override.conf /etc/systemd/system/getty@tty1.service.d/override.conf

echo "✅ Autologin aktiviert."

#########################################
# 🔁 Step 5: Webhook als systemd-Service
#########################################

cp systemd/kiosk-webhook.service /etc/systemd/system/

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable kiosk-webhook
systemctl restart kiosk-webhook

echo "✅ Webhook-Service aktiv."

#########################################
# 🕓 Step 6: Cronjob für Reload setzen
#########################################

crontab -u kiosk scripts/kiosk.crontab

echo "✅ Crontab gesetzt."

#########################################
# 🧹 Fertig!
#########################################

echo "🎉 Kiosk-System vollständig installiert."
echo "🔁 Jetzt am besten: reboot"
