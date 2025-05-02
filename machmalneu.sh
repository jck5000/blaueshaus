#!/bin/bash
set -euo pipefail

echo "📦 STARTE KIOSK-INSTALLATION"

#########################################
# 🛑 Step 0: Benutzer 'kiosk' anlegen
#########################################
echo "👤 Lege Benutzer 'kiosk' an..."
adduser --disabled-password --gecos "" kiosk
usermod -aG video,render,tty,input kiosk
echo "✅ Benutzer 'kiosk' mit Gruppenrechten angelegt."

#########################################
# 🔧 Step 1: Pakete installieren
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
# 🌐 Step 2: Repository klonen
#########################################
echo "🌐 Klone Projekt-Repo..."
mkdir -p /opt/kiosk-setup
cd /opt/kiosk-setup
git clone https://github.com/jck5000/blaueshaus.git .  # ggf. URL anpassen
echo "✅ Repository geklont."

#########################################
# 📂 Step 3: Konfiguration & Skripte
#########################################
echo "📂 Kopiere Konfigurationsdateien…"

# globale Umgebungsvariablen
mkdir -p /etc/kiosk
cp env.sh /etc/kiosk/

# Netzwerk-Kontroll-Start
cp kiosk-boot.sh /usr/local/bin/kiosk-boot.sh
chmod +x /usr/local/bin/kiosk-boot.sh

# Benutzer-Startskripte
install -m 755 -o kiosk -g kiosk scripts/start-gui.sh /home/kiosk/start-gui.sh
install -m 755 -o kiosk -g kiosk scripts/killffx.sh /home/kiosk/killffx.sh
install -m 755 -o kiosk -g kiosk scripts/reload-kiosk.sh /usr/local/bin/reload-kiosk
install -m 644 -o kiosk -g kiosk scripts/.xinitrc /home/kiosk/.xinitrc
install -m 644 -o kiosk -g kiosk scripts/.bash_profile /home/kiosk/.bash_profile
install -m 644 -o kiosk -g kiosk scripts/kiosk.crontab /home/kiosk/kiosk.crontab

# Webhook-Server
cp scripts/webhook.py /home/kiosk/
chown kiosk:kiosk /home/kiosk/webhook.py

echo "✅ Skripte & Konfigurationen bereitgestellt."

#########################################
# 🛠 Step 4: Autologin mit Netzprüfung
#########################################
echo "🛠 Aktiviere Autologin mit Netzwerkprüfung…"
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat <<EOF > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/local/bin/kiosk-boot.sh %I \$TERM
EOF

#########################################
# 🔁 Step 5: Webhook als Dienst aktivieren
#########################################
echo "🔁 Aktiviere Webhook-Service…"
cp systemd/kiosk-webhook.service /etc/systemd/system/
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable kiosk-webhook
systemctl restart kiosk-webhook

#########################################
# 🕓 Step 6: Crontab aktivieren
#########################################
echo "🕓 Setze Crontab für Benutzer 'kiosk'…"
crontab -u kiosk /home/kiosk/kiosk.crontab

#########################################
# 🧹 Fertig!
#########################################
echo "🎉 Installation abgeschlossen!"
echo "🔁 Empfohlen: jetzt 'reboot'"
