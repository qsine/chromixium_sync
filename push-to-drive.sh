#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo " "
  echo "# Running: push-to-drive.sh"
  sleep 1
fi

# by Kevin Saruwatari, 08-Apr-2015
# free to use/distribute with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

# fix chrome shortcuts from creating duplicate/default icons on plank
. $CHROMIXIUM_SCRIPTS/remap-chrome_apps.sh

# must change to GDATA directory to push/pull
cd "$GOOGLE_DATA"
echo "# Changed to:$(dirname "$(readlink -f "$0")")"

#:::::::::::::::::: link user directories :::::::::::::::::::::
echo "01"; echo "# gtk2: misc file/desktop settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_GTK2" "$GOOGLE_DATA/$CHRMX_GTK2" "664" "$SYNC_USER"

echo "02"; echo "# gtk3: misc file/desktop settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_GTK3" "$GOOGLE_DATA/$CHRMX_GTK3" "664" "$SYNC_USER"

echo "03"; echo "# lxpanel: clock/date settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_CLOCK" "$GOOGLE_DATA/$CHRMX_CLOCK" "664" "$SYNC_USER"

echo "04"; echo "# nautilus: file manager settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_NAUT" "$GOOGLE_DATA/$CHRMX_NAUT" "664" "$SYNC_USER"

echo "05"; echo "# nitrogen: current wallpaper settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_UWALL" "$GOOGLE_DATA/$CHRMX_UWALL" "644" "$SYNC_USER"

echo "06"; echo "# ob-autostart: user autostart"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_ASTART" "$GOOGLE_DATA/$CHRMX_ASTART" "644" "$SYNC_USER"

echo "07"; echo "# openbox: menu settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_MENU" "$GOOGLE_DATA/$CHRMX_MENU" "644" "$SYNC_USER"

echo "08"; echo "# plank: dock settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_DOCK" "$GOOGLE_DATA/$CHRMX_DOCK" "750" "$SYNC_USER"

echo "09"; echo "# screenlayout: multi-monitor settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_SCRNL" "$GOOGLE_DATA/$CHRMX_SCRNL" "750" "$SYNC_USER"

echo "10"; echo "# applications: home folder shortcuts"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_APPS" "$GOOGLE_DATA/$CHRMX_UAPPS" "750" "$SYNC_USER"

#:::::::::::::::::: sync files :::::::::::::::::::::
echo "20"; echo "# /home/user/.face: user icon on dock"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$DEST_HOME/.face" "$GOOGLE_DATA/$CHRMX_REPO/.face" "664" "$SYNC_USER"

echo "21"; echo "# greeter user icon"
echo "# Ignore greeter icon, use dock icon for pull"

echo "22"; echo "# /etc/passwd: user mugshot info"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$SYS_ETC/passwd" "$GOOGLE_DATA/$CHRMX_ETC/passwd" "644" "$SYNC_USER"

#:::::::::::::::::: sync directories :::::::::::::::::::::
echo "30"; echo "# /etc/lightdm: greeter login"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$LOGIN_PREF" "$GOOGLE_DATA/$CHRMX_LOGIN" "644" "$SYNC_USER"

echo "31"; echo "# /usr/share/pixmaps/chromixium: icons for home folder shortcuts"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$APP_ICONS" "$GOOGLE_DATA/$CHRMX_ICONS" "644" "$SYNC_USER"

echo "32"; echo "# /usr/share/wallpapers: wallpaper selection"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$WALLS_USR" "$GOOGLE_DATA/$CHRMX_WALLS" "664" "$SYNC_USER"

#===================== push start ================================
echo "40"; echo "# Preparing to push..."
if [ "${RUN_MODE}" = "gui" ]; then
  (
    drive push -ignore-conflict -hidden=true -no-prompt=true "$CHRMX_REPO" 
  ) | zenity --progress \
      --title="Push to Google Drive" \
      --text="Pushing $GOOGLE_DATA to Google Drive..." \
      --percentage=0 \
      --auto-close
    if [ "$?" = -1 ]; then
      zenity --error --text="Pull cancelled."
    fi
else # cmd mode
  drive push -ignore-conflict -hidden=true -no-prompt=true "$CHRMX_REPO" 
fi

echo "99"; echo "# Buffer pushed to Google Drive"
sleep 1
#============= push end ================================

# must change back to scripts directory
cd "$CHROMIXIUM_SCRIPTS"
echo "# Changed to:$(dirname "$(readlink -f "$0")")"
sleep 1

if [ $DIAG_MSG = 1 ]; then
  echo " "
  echo "# Exiting: push-to-drive.sh"
  sleep 1
fi
