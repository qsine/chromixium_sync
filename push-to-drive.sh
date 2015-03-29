#!/bin/bash
echo "# "
echo "# Running: push-to-drive.sh"
# by Kevin Saruwatari, 29-Mar-2015
# free to use with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

# initiate directories
$CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_BASE" "$GOOGLE_DATA/$CHRMX_BASE" "$SYNC_USER" -e
$CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_SYNC" "$GOOGLE_DATA/$CHRMX_SYNC" "$SYNC_USER" -e
$CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_REPO" "$GOOGLE_DATA/$CHRMX_REPO" "$SYNC_USER" -e

# fix chrome shortcuts from creating duplicate/default icons on plank
. $CHROMIXIUM_SCRIPTS/remap-chrome_apps.sh -e


# must change to GDATA directory to push/pull
cd "$GOOGLE_DATA"
echo "# Changed to:$(dirname "$(readlink -f "$0")")"

#:::::::::::::::::: linked directories :::::::::::::::::::::
# 01 gtk3: misc file/desktop setting
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_GTK3" "$GOOGLE_DATA/$CHRMX_GTK3" "664" "$SYNC_USER"

# 02 lxpanel: clock/date settings
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_CLOCK" "$GOOGLE_DATA/$CHRMX_CLOCK" "664" "$SYNC_USER"

# 03 nautilus: file manager settings
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_NAUT" "$GOOGLE_DATA/$CHRMX_NAUT" "664" "$SYNC_USER"

# 04 nitrogen: current wallpaper setting
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_UWALL" "$GOOGLE_DATA/$CHRMX_UWALL" "644" "$SYNC_USER"

# 05 ob-autostart: user autostart
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_ASTART" "$GOOGLE_DATA/$CHRMX_ASTART" "644" "$SYNC_USER"

# 06 openbox: menu settings
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_MENU" "$GOOGLE_DATA/$CHRMX_MENU" "644" "$SYNC_USER"

# 07 plank: dock settings
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_DOCK" "$GOOGLE_DATA/$CHRMX_DOCK" "750" "$SYNC_USER"

# 08 screenlayout: multi-monitor settings
#   don't exist in stock install so create it to keep error checking in sync-as-root valid
if [ ! -d "$USER_SCRNL" ]; then
  $CHROMIXIUM_SCRIPTS/custom-dir.sh "USER_SCRNL" "$USER_SCRNL" "$SYNC_USER" -e
  echo "# a file is required for chromixium_sync" >> "$USER_SCRNL"/chrx-readme
fi
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_SCRNL" "$GOOGLE_DATA/$CHRMX_SCRNL" "750" "$SYNC_USER"

# 09 applications: home folder shortcuts
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$USER_APPS" "$GOOGLE_DATA/$CHRMX_UAPPS" "750" "$SYNC_USER"

#:::::::::::::::::: sync user files :::::::::::::::::::::
# 01 /home/user/.face: user icon on dock
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$DEST_HOME/.face" "$GOOGLE_DATA/$CHRMX_REPO/.face" "664" "$SYNC_USER"

#:::::::::::::::::: sync root files :::::::::::::::::::::
# 01 greeter user icon
#---------------------------------------------------
echo "# Ignore greeter icon, use dock icon for pull"
#

#:::::::::::::::::: sync root directories :::::::::::::::::::::
# 01 /etc/lightdm: greeter login
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$LOGIN_PREF" "$GOOGLE_DATA/$CHRMX_LOGIN" "644" "$SYNC_USER"

# 02 /usr/share/pixmaps/chromixium: icons for home folder shortcuts
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$APP_ICONS" "$GOOGLE_DATA/$CHRMX_ICONS" "644" "$SYNC_USER"

# 03 /usr/share/wallpapers: wallpaper selection
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$WALLS_USR" "$GOOGLE_DATA/$CHRMX_WALLS" "644" "$SYNC_USER"

#===================== push start ================================
# push GOOGLE_DATA to the Drive
echo "# Push buffer to Google Drive..."

# push current repo 
drive push -ignore-conflict -hidden=true -no-prompt=true "$CHRMX_REPO" 
echo "# Buffer pushed to Google Drive"
#============= push end ================================

# must change back to scripts directory
cd "$CHROMIXIUM_SCRIPTS"
echo "# Changed to:$(dirname "$(readlink -f "$0")")"

echo "# "
echo "# Exiting: push-to-drive.sh"
