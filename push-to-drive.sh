#!/bin/bash
echo " "
echo "# Running: push-to-drive.sh"
# by Kevin Saruwatari, 01-Apr-2015
# free to use with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

# fix chrome shortcuts from creating duplicate/default icons on plank
. $CHROMIXIUM_SCRIPTS/remap-chrome_apps.sh -e

# must change to GDATA directory to push/pull
cd "$GOOGLE_DATA"
echo "# Changed to:$(dirname "$(readlink -f "$0")")"

#:::::::::::::::::: link user directories :::::::::::::::::::::
echo "01"; echo "# gtk3: misc file/desktop settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_GTK3" "$GOOGLE_DATA/$CHRMX_GTK3" "664" "$SYNC_USER"

echo "02"; echo "# lxpanel: clock/date settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_CLOCK" "$GOOGLE_DATA/$CHRMX_CLOCK" "664" "$SYNC_USER"

echo "03"; echo "# nautilus: file manager settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_NAUT" "$GOOGLE_DATA/$CHRMX_NAUT" "664" "$SYNC_USER"

echo "04"; echo "# nitrogen: current wallpaper settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_UWALL" "$GOOGLE_DATA/$CHRMX_UWALL" "644" "$SYNC_USER"

echo "05"; echo "# ob-autostart: user autostart"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_ASTART" "$GOOGLE_DATA/$CHRMX_ASTART" "644" "$SYNC_USER"

echo "06"; echo "# openbox: menu settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_MENU" "$GOOGLE_DATA/$CHRMX_MENU" "644" "$SYNC_USER"

echo "07"; echo "# plank: dock settings"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_DOCK" "$GOOGLE_DATA/$CHRMX_DOCK" "750" "$SYNC_USER"

echo "08"; echo "# screenlayout: multi-monitor settings"
#   don't exist in stock install so create it to keep error checking in sync-as-root valid
if [ ! -d "$USER_SCRNL" ]; then
  $CHROMIXIUM_SCRIPTS/custom-dir.sh "USER_SCRNL" "$USER_SCRNL" "$SYNC_USER" -e
  echo "# a file is required for chromixium_sync" >> "$USER_SCRNL"/chrx-readme
  chown  "$SYNC_USER:$SYNC_USER" "$USER_SCRNL"/chrx-readme
fi
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_SCRNL" "$GOOGLE_DATA/$CHRMX_SCRNL" "750" "$SYNC_USER"

echo "09"; echo "# applications: home folder shortcuts"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_APPS" "$GOOGLE_DATA/$CHRMX_UAPPS" "750" "$SYNC_USER"

#:::::::::::::::::: sync files :::::::::::::::::::::
echo "20"; echo "# /home/user/.face: user icon on dock"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$DEST_HOME/.face" "$GOOGLE_DATA/$CHRMX_REPO/.face" "664" "$SYNC_USER"

echo "21"; echo "# greeter user icon"
#---------------------------------------------------
echo "# Ignore greeter icon, use dock icon for pull"
#

#:::::::::::::::::: sync directories :::::::::::::::::::::
echo "30"; echo "# /etc/lightdm: greeter login"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$LOGIN_PREF" "$GOOGLE_DATA/$CHRMX_LOGIN" "644" "$SYNC_USER"

echo "31"; echo "# /usr/share/pixmaps/chromixium: icons for home folder shortcuts"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$APP_ICONS" "$GOOGLE_DATA/$CHRMX_ICONS" "644" "$SYNC_USER"

echo "32"; echo "# /usr/share/wallpapers: wallpaper selection"
. $CHROMIXIUM_SCRIPTS/sync-as-root.sh "$WALLS_USR" "$GOOGLE_DATA/$CHRMX_WALLS" "664" "$SYNC_USER"

#===================== push start ================================
echo "40"; echo "# Pushing to Google Drive..."

# push current repo 
drive push -ignore-conflict -hidden=true -no-prompt=true "$CHRMX_REPO" 
echo "99"; echo "# Buffer pushed to Google Drive"

#============= push end ================================

# must change back to scripts directory
cd "$CHROMIXIUM_SCRIPTS"
echo "# Changed to:$(dirname "$(readlink -f "$0")")"
sleep 1

echo " "
echo "# Exiting: push-to-drive.sh"
sleep 1
