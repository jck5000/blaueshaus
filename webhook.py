from flask import Flask, request
import subprocess

app = Flask(__name__)

@app.route('/display', methods=['POST'])
def display():
    action = request.json.get("action")
    print(f"📩 Received action: {action}")  # 🪵 Loggt im Terminal

    if action == "on":
        cmd = "xset dpms force on; xset -dpms; xset s off; xset s noblank"
    elif action == "off":
        cmd = "xset dpms force off; xset s noblank"
    elif action == "mode_gui":
        cmd = "/home/kiosk/killffx.sh && KIOSK_MODE=gui startx"
    elif action == "mode_kiosk":
        cmd = "/home/kiosk/killffx.sh && startx"
    else:
        return "Invalid action", 400

    print(f"🚀 Executing: {cmd}")  # 🪵 Befehl anzeigen

    subprocess.run([
        "bash", "-c",
        f"source /etc/kiosk/env.sh && DISPLAY=:0 {cmd}"
    ])

    return "OK", 200


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8888)
