#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# $SYNC_USER Running: build-shortcuts.sh"
  sleep 2
fi

# by Kevin Saruwatari, 06-Apr-2015
# free to use with no warranty
# build std shortcuts for all qsine machines
# place in GOOGLE_DATA/CHRMX_HFILES/.installs and
# Qsine installer will automatically run it
# the name must be in the format build-*

# abort on error 
set -e

echo "# build shortcut to yahoo for no reason, you need your own icon"
sleep 1
SHORTCUT_FILE="$USER_APPS"/yahoo.desktop
LAUNCHER_FILE="$USER_DOCK"/launchers/yahoo.dockitem
# create shortcut
echo "#!/usr/bin/env xdg-open" > "$SHORTCUT_FILE"
echo "" >> "$SHORTCUT_FILE"
echo "[Desktop Entry]" >> "$SHORTCUT_FILE"
echo "Version=1.0" >> "$SHORTCUT_FILE"
echo "Terminal=false" >> "$SHORTCUT_FILE"
echo "Type=Application" >> "$SHORTCUT_FILE"
echo "Name=Yahoo!" >> "$SHORTCUT_FILE"
echo "StartupWMClass=www.yahoo.com" >> "$SHORTCUT_FILE"
echo "Exec=/usr/bin/chromium-browser --app=http://www.yahoo.com" >> "$SHORTCUT_FILE"
echo "Icon=$GOOGLE_DATA/$CHRMX_HFILES/.installs/yahoo.png" >> "$SHORTCUT_FILE"
echo "NoDisplay=false" >> "$SHORTCUT_FILE"
echo "Categories=Network;Internet;" >> "$SHORTCUT_FILE"
# set permissions
chown "$SYNC_USER:$SYNC_USER" "$SHORTCUT_FILE"
chmod 750 "$SHORTCUT_FILE"

# create plank launcher
echo "[PlankItemsDockItemPreferences]" > "$LAUNCHER_FILE"
echo "Launcher=file://$SHORTCUT_FILE" >> "$LAUNCHER_FILE"
# set permissions
chown "$SYNC_USER:$SYNC_USER" "$LAUNCHER_FILE"
chmod 750 "$LAUNCHER_FILE"

# sometimes shortcuts need a logoff/on to display correctly
# echo "LOGOFF REQUIRED" > /tmp/LOGOFF_FLAG

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# $SYNC_USER Exiting: build-shortcuts.sh"
  sleep 1
fi
