#!/bin/bash
sudo -u kiosk DISPLAY=:0 xdotool search --onlyvisible --class "Firefox" key ctrl+r
