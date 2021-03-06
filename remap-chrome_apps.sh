#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo " "
  echo "# Running: remap-chrome_apps.sh"
  sleep 1
fi

# by Kevin Saruwatari, 13-Apr-2015
# free to use/distribute with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

# initiate directories
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_BASE" "$GOOGLE_DATA/$CHRMX_BASE" "$SYNC_USER"
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_SYNC" "$GOOGLE_DATA/$CHRMX_SYNC" "$SYNC_USER"
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_REPO" "$GOOGLE_DATA/$CHRMX_REPO" "$SYNC_USER"

#============= clear /usr apps start ================================
# backup then clear chrome .desktop files in /usr directories
# prevents duplicate/unassigned icons from showing up in the dock

# create backup in user home so it can be found
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "BACKUP_BASE" "$BACKUP_BASE" "$SYNC_USER"

# APP_SHARE="/usr/share/applications"
if [ "$(ls -A $APP_SHARE | grep chrom)" -o "$(ls -A $APP_SHARE | grep google)" ]; then
  TIMESTAMP="$(date +%Y_%m_%d_%H_%M_%S)-usr_share_applications"
  echo "Found Chrome shortcuts in APP_SHARE:$APP_SHARE..."
  echo "  - moving to: $BACKUP_BASE/$TIMESTAMP"
  . $CHROMIXIUM_SCRIPTS/custom-dir.sh "BACKUP_BASE/TIMESTAMP" "$BACKUP_BASE/$TIMESTAMP" "$SYNC_USER"
  # no error abort
  set +e
  mv "$APP_SHARE"/chrom* "$BACKUP_BASE/$TIMESTAMP"
  mv "$APP_SHARE"/google* "$BACKUP_BASE/$TIMESTAMP"
  # abort on error 
  set -e
  chown -R $SYNC_USER:$SYNC_USER "$BACKUP_BASE/$TIMESTAMP"
else
  echo "    -no Chrome shortcuts in $APP_SHARE"
fi
# APP_LOCAL="/usr/local/share/applications"
if [ "$(ls -A $APP_LOCAL | grep chrom)" ]; then
  TIMESTAMP="$(date +%Y_%m_%d_%H_%M_%S)-usr_local_share_applications"
  echo "Found Chrome shortcuts in APP_LOCAL:$APP_LOCAL..."
  echo "  - moving to: $BACKUP_BASE/$TIMESTAMP"
  . $CHROMIXIUM_SCRIPTS/custom-dir.sh "BACKUP_BASE/TIMESTAMP" "$BACKUP_BASE/$TIMESTAMP" "$SYNC_USER"
  mv "$APP_LOCAL"/chrom* "$BACKUP_BASE/$TIMESTAMP"
  chown -R $SYNC_USER:$SYNC_USER "$BACKUP_BASE/$TIMESTAMP"
else
  echo "    -no Chrome shortcuts in $APP_LOCAL"
fi
# USER_APPS="$DEST_HOME/.local/share/applications"
if [ "$(ls -A $USER_APPS | grep chrome)" ]; then
  TIMESTAMP="$(date +%Y_%m_%d_%H_%M_%S)-home_local_share_applications"
  echo "Found Chrome shortcuts in USER_APPS:$USER_APPS..."
  echo "  - moving to: $BACKUP_BASE/$TIMESTAMP"
  . $CHROMIXIUM_SCRIPTS/custom-dir.sh "BACKUP_BASE/TIMESTAMP" "$BACKUP_BASE/$TIMESTAMP" "$SYNC_USER"
  # remove chrome created shortcuts - keep chromixium
  mv "$USER_APPS"/chrome* "$BACKUP_BASE/$TIMESTAMP"
  chown -R $SYNC_USER:$SYNC_USER "$BACKUP_BASE/$TIMESTAMP"
else
  echo "    -no Chrome shortcuts in $USER_APPS"
fi
#============= clear /usr apps end ================================

#============= remap apps and launcher start ================================
# no error abort
set +e
rm "$USER_APPS"/chromixium*
echo " copy in chromium desktop files and icons"
cp "$CHROMIXIUM_SCRIPTS"/chromium_apps/* "$USER_APPS"/
cp "$CHROMIXIUM_SCRIPTS"/pixmaps/* "$APP_ICONS"/
# if chrome is installed install chrome adjusted shortcuts
PKG_NAME="$CHROME_PKG"
echo "Checking for $PKG_NAME"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
if [ "install ok installed" == "$PKG_OK" ]; then
  echo " copy in chrome adjusted shortcuts and icons"
  cp "$CHROMIXIUM_SCRIPTS"/chrome_apps/* "$USER_APPS"/
fi
chown "$SYNC_USER:$SYNC_USER" "$USER_APPS"/*
chmod "750" "$USER_APPS"/*

# delete old launchers and copy in adjusted stock ones
rm "$USER_DOCK"/launchers/chrom*
cp "$CHROMIXIUM_SCRIPTS"/chromium_apps/launchers/* "$USER_DOCK"/launchers/
chown "$SYNC_USER:$SYNC_USER" "$USER_DOCK"/launchers/*
chmod "750" "$USER_DOCK"/launchers/*
# repoint launchers to user home directory 
for f in "$USER_DOCK"/launchers/*; do
  OLDPATH="switch_path"
  NEWPATH="$USER_APPS"
  sed -i "s%$OLDPATH%$NEWPATH%g" $f
done
# abort on error 
set -e
echo "LOGOFF REQUIRED" > /tmp/LOGOFF_FLAG
#============= remap apps and launcher end ================================

#============= home directories start ================================
# create directory in Google Data that will push/pull
#  and make a link to for user Desktop in nautilus below
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_HFILES" "$GOOGLE_DATA/$CHRMX_HFILES" "$SYNC_USER"

# make the user custom script directory
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_UCUST" "$GOOGLE_DATA/$CHRMX_UCUST" "$SYNC_USER"

# check if home Desktop directory is not linked
if [ ! -h "$USER_HFILES" ]; then
  # and if it still exists
  if [ -d "$USER_HFILES" ]; then
    # if there are files move them
    if [ "$(ls -A $USER_HFILES)" ]; then
      mv "$USER_HFILES/"* "$GOOGLE_DATA/$CHRMX_HFILES/"
    fi
    # get rid of it
    rmdir "$USER_HFILES"
  fi
  ln -s -f "$GOOGLE_DATA/$CHRMX_HFILES" "$USER_HFILES"
  echo "  - USER_HOMEPP:$USER_HOMEPP link created"
fi

# make sure user-dir update is off so manual changes stick 
echo "enabled=False" > ~/.config/user-dirs.conf

# create LocalFiles in user home that does not push/pull to Google Drive
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "LOCAL_FILES" "$LOCAL_FILES" "$SYNC_USER"

# move home directories and reconfig user dirs
if [ -d "$USER_HFILES" ]; then
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

#============= home directories end ================================


if [ $DIAG_MSG = 1 ]; then
  echo " "
  echo "# Exiting: remap-chrome_apps.sh"
  sleep 1
fi
