#!/bin/bash
echo ""
echo "Running: pull-from-drive.sh"
# by Kevin Saruwatari, 29-Mar-2015
# free to use with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

# must change to GDATA directory to push/pull
cd "$GOOGLE_DATA"
echo "Changed to:$(dirname "$(readlink -f "$0")")"

#============= pull start ================================
echo "Pull Google Drive to $GOOGLE_DATA..."
# push current repo 
drive pull -ignore-conflict -hidden=true -no-prompt=true "$CHRMX_REPO" 
# set directories to 755
chown -R "$SYNC_USER":"$SYNC_USER" "$CHRMX_REPO"
#============= pull end ================================

# fix chrome shortcuts from creating duplicate/default icons on plank
. $CHROMIXIUM_SCRIPTS/remap-chrome_apps.sh -e

#============= home directories start ================================
# create directory in Google Data that will push/pull
#  and make a link to for user Desktop in nautilus below
$CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_HFILES" "$GOOGLE_DATA/$CHRMX_HFILES" "$SYNC_USER" -e

# make sure user-dir update is off so manual changes stick 
echo "enabled=False" > ~/.config/user-dirs.conf

# check if home Desktop directory is not linked
if [ ! -h "$DEST_HOME/Desktop" ]; then
  # and if it still exists
  if [ -d "$DEST_HOME/Desktop" ]; then
    # if there are files move them
    if [ "$(ls -A $DEST_HOME/Desktop)" ]; then
      mv "$DEST_HOME/Desktop/"* "$GOOGLE_DATA/$CHRMX_HFILES/"
    fi
    # get rid of it
    rmdir "$DEST_HOME/Desktop"
  fi
  ln -s -f "$GOOGLE_DATA/$CHRMX_HFILES" "$DEST_HOME/Desktop"
  echo "  - USER_HOMEPP:$USER_HOMEPP link created"
else
  rm "$DEST_HOME/Desktop"
  ln -s -f "$GOOGLE_DATA/$CHRMX_HFILES" "$DEST_HOME/Desktop"
  echo "  - USER_HOMEPP:$USER_HOMEPP link updated"
fi

# create LocalFiles in user home that does not push/pull to Google Drive
$CHROMIXIUM_SCRIPTS/custom-dir.sh "LOCAL_FILES" "$LOCAL_FILES" "$SYNC_USER" -e

# move home directories and reconfig user dirs
if [ -d "$DEST_HOME/Desktop" ]; then
  echo "Desktop is used to push/pull files to Google Drive"
fi
if [ -d "$DEST_HOME/Documents" ]; then
  mv "$DEST_HOME/Documents" "$LOCAL_FILES/Documents"
  OLDLINE='XDG_DOCUMENTS_DIR="$HOME/Documents"'
  NEWLINE='XDG_DOCUMENTS_DIR="$HOME/'${LOCAL_FILES##*/}'/Documents"'
  sed -i "s%$OLDLINE%$NEWLINE%g" $DEST_HOME/.config/user-dirs.dirs
fi
if [ -d "$DEST_HOME/Downloads" ]; then
  mv "$DEST_HOME/Downloads" "$LOCAL_FILES/Downloads"
  OLDLINE='XDG_DOWNLOAD_DIR="$HOME/Downloads"'
  NEWLINE='XDG_DOWNLOAD_DIR="$HOME/'${LOCAL_FILES##*/}'/Downloads"'
  sed -i "s%$OLDLINE%$NEWLINE%g" $DEST_HOME/.config/user-dirs.dirs
fi
if [ -d "$DEST_HOME/Music" ]; then
  mv "$DEST_HOME/Music" "$LOCAL_FILES/Music"
  OLDLINE='XDG_MUSIC_DIR="$HOME/Music"'
  NEWLINE='XDG_MUSIC_DIR="$HOME/'${LOCAL_FILES##*/}'/Music"'
  sed -i "s%$OLDLINE%$NEWLINE%g" $DEST_HOME/.config/user-dirs.dirs
fi
if [ -d "$DEST_HOME/Pictures" ]; then
  mv "$DEST_HOME/Pictures" "$LOCAL_FILES/Pictures"
  OLDLINE='XDG_PICTURES_DIR="$HOME/Pictures"'
  NEWLINE='XDG_PICTURES_DIR="$HOME/'${LOCAL_FILES##*/}'/Pictures"'
  sed -i "s%$OLDLINE%$NEWLINE%g" $DEST_HOME/.config/user-dirs.dirs
fi
if [ -d "$DEST_HOME/Public" ]; then
  mv "$DEST_HOME/Public" "$LOCAL_FILES/Public"
  OLDLINE='XDG_PUBLICSHARE_DIR="$HOME/Public"'
  NEWLINE='XDG_PUBLICSHARE_DIR="$HOME/'${LOCAL_FILES##*/}'/Public"'
  sed -i "s%$OLDLINE%$NEWLINE%g" $DEST_HOME/.config/user-dirs.dirs
fi
if [ -d "$DEST_HOME/Templates" ]; then
  mv "$DEST_HOME/Templates" "$LOCAL_FILES/Templates"
  OLDLINE='XDG_TEMPLATES_DIR="$HOME/Templates"'
  NEWLINE='XDG_TEMPLATES_DIR="$HOME/'${LOCAL_FILES##*/}'/Templates"'
  sed -i "s%$OLDLINE%$NEWLINE%g" $DEST_HOME/.config/user-dirs.dirs
fi
if [ -d "$DEST_HOME/Videos" ]; then
  mv "$DEST_HOME/Videos" "$LOCAL_FILES/Videos"
  OLDLINE='XDG_VIDEOS_DIR="$HOME/Videos"'
  NEWLINE='XDG_VIDEOS_DIR="$HOME/'${LOCAL_FILES##*/}'/Videos"'
  sed -i "s%$OLDLINE%$NEWLINE%g" $DEST_HOME/.config/user-dirs.dirs
fi

#============= home directories start ================================


#:::::::::::::::::: linked directories :::::::::::::::::::::
# 01 gtk3: misc file/desktop setting
$CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_GTK3" "$USER_GTK3" "664"

# 02 lxpanel: clock/date settings
$CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_CLOCK" "$USER_CLOCK" "664"

# 03 nautilus: file manager settings
$CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_NAUT" "$USER_NAUT" "664"

# 04 nitrogen: current wallpaper setting
$CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_UWALL" "$USER_UWALL" "644"

# 05 ob-autostart: user autostart
$CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_ASTART" "$USER_ASTART" "644"

# 06 openbox: menu settings
$CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_MENU" "$USER_MENU" "644"

# 07 plank: dock settings
$CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_DOCK" "$USER_DOCK" "750"

# 08 screenlayout: multi-monitor settings
$CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_SCRNL" "$USER_SCRNL" "750"

# 09 applications: home folder shortcuts
$CHROMIXIUM_SCRIPTS/link-usr-dir.sh "$GOOGLE_DATA/$CHRMX_UAPPS" "$USER_APPS" "750"

#:::::::::::::::::: sync user files :::::::::::::::::::::
# 01 /home/user/.face: user icon on dock
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$GOOGLE_DATA/$CHRMX_REPO/.face" "$DEST_HOME/.face" "664" "$SYNC_USER"

#:::::::::::::::::: sync root files :::::::::::::::::::::
# 01 /home/user/.face: greeter user icon
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$GOOGLE_DATA/$CHRMX_REPO/.face" "$GREETER_ICON/$SYNC_USER" "644" "root"

#:::::::::::::::::: sync root directories :::::::::::::::::::::
# 01 /etc/lightdm: greeter login
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$GOOGLE_DATA/$CHRMX_LOGIN" "$LOGIN_PREF" "644" "root"

# 02 /usr/share/pixmaps/chromixium: icons for home folder shortcuts
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$GOOGLE_DATA/$CHRMX_ICONS" "$APP_ICONS" "644" "root"

# 03 /usr/share/wallpapers: wallpaper selection
$CHROMIXIUM_SCRIPTS/sync-as-root.sh "$GOOGLE_DATA/$CHRMX_WALLS" "$WALLS_USR" "644" "root"


# must change back to scripts directory
cd "$CHROMIXIUM_SCRIPTS"
echo "Changed to:$(dirname "$(readlink -f "$0")")"

echo ""
echo "Exiting: pull-from-drive.sh"
