#!/bin/bash

PID=$(pgrep xfce4-session)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)

xfconf-query -c xsettings -p /NetThemeName -s "Numix-Holo"
xfconf-query -c xfwm4 -p /general/theme -s "Numix-Holo"
