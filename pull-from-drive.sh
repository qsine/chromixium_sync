#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Running: pull-from-drive.sh"
  sleep 1
fi

# by Kevin Saruwatari, 06-Apr-2015
# free to use/distribute with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

# must change to GDATA directory to push/pull
cd "$GOOGLE_DATA"
echo "# Changed to:$(dirname "$(readlink -f "$0")")"

#============= pull start ================================
echo "01"; echo "# Preparing to pull"
# pull repo 
if [ "${RUN_MODE}" = "gui" ]; then
  (
    drive pull -ignore-conflict -hidden=true -no-prompt=true "$CHRMX_REPO" 
  ) | zenity --progress \
      --title="Pull from Google Drive" \
      --text="Pulling Google Drive to $GOOGLE_DATA..." \
      --percentage=0 \
      --auto-close
    if [ "$?" = -1 ]; then
      zenity --error --text="Pull cancelled."
    fi
else # cmd mode
  drive pull -ignore-conflict -hidden=true -no-prompt=true "$CHRMX_REPO" 
fi

echo "60"; echo "# Buffer pulled from Google Drive"
sleep 1

# set directories to 755
chown -R "$SYNC_USER":"$SYNC_USER" "$CHRMX_REPO"
#============= pull end ================================

# fix chrome shortcuts from creating duplicate/default icons on plank
. $CHROMIXIUM_SCRIPTS/remap-chrome_apps.sh

#:::::::::::::::::: link user directories :::::::::::::::::::::
echo "61"; echo "# gtk2: misc file/desktop settings"
. $CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_GTK2" "$USER_GTK2" "664"

echo "62"; echo "# gtk3: misc file/desktop settings"
. $CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_GTK3" "$USER_GTK3" "664"

echo "63"; echo "# lxpanel: clock/date settings"
. $CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_CLOCK" "$USER_CLOCK" "664"

echo "64"; echo "# nautilus: file manager settings"
. $CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_NAUT" "$USER_NAUT" "664"

echo "65"; echo "# nitrogen: current wallpaper settings"
. $CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_UWALL" "$USER_UWALL" "644"

echo "66"; echo "# ob-autostart: user autostart"
. $CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_ASTART" "$USER_ASTART" "644"

echo "67"; echo "# openbox: menu settings"
. $CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_MENU" "$USER_MENU" "644"

echo "68"; echo "# plank: dock settings"
. $CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_DOCK" "$USER_DOCK" "750"

echo "69"; echo "# screenlayout: multi-monitor settings"
. $CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_SCRNL" "$USER_SCRNL" "750"

echo "70"; echo "# applications: home folder shortcuts"
. $CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_UAPPS" "$USER_APPS" "750"

#:::::::::::::::::: sync files :::::::::::::::::::::
echo "80"; echo "# /home/user/.face: user icon on dock"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$GOOGLE_DATA/$CHRMX_REPO/.face" "$DEST_HOME/.face" "664" "$SYNC_USER"

echo "81"; echo "# /home/user/.face: greeter user icon"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$GOOGLE_DATA/$CHRMX_REPO/.face" "$GREETER_ICON/$SYNC_USER" "644" "root"

#:::::::::::::::::: sync directories :::::::::::::::::::::
echo "90"; echo "# /etc/lightdm: greeter login"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$GOOGLE_DATA/$CHRMX_LOGIN" "$LOGIN_PREF" "644" "root"

echo "91"; echo "# /usr/share/pixmaps/chromixium: icons for home folder shortcuts"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$GOOGLE_DATA/$CHRMX_ICONS" "$APP_ICONS" "644" "root"

echo "92"; echo "# /usr/share/wallpapers: wallpaper selection"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$GOOGLE_DATA/$CHRMX_WALLS" "$WALLS_USR" "644" "root"

# must change back to scripts directory
cd "$CHROMIXIUM_SCRIPTS"
echo "# Changed to:$(dirname "$(readlink -f "$0")")"
sleep 1

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: pull-from-drive.sh"
  sleep 1
fi
