#!/bin/bash
echo "# "
echo "# Running: remap-chrome_apps.sh"
# by Kevin Saruwatari, 29-Mar-2015
# free to use with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

#============= clear /usr apps start ================================
# backup then clear chrome .desktop files in /usr directories
# prevents duplicate/unassigned icons from showing up in the dock

# create backup in user home so it can be found
$CHROMIXIUM_SCRIPTS/custom-dir.sh "BACKUP_BASE" "$BACKUP_BASE" "$SYNC_USER" -e

# APP_SHARE="/usr/share/applications"
if [ "$(ls -A $APP_SHARE | grep chrom)" ]; then
  TIMESTAMP="$(date +%Y_%m_%d_%H_%M_%S)-usr_share_applications"
  echo "Found Chrome shortcuts in APP_SHARE:$APP_SHARE..."
  echo "  - moving to: $BACKUP_BASE/$TIMESTAMP"
  $CHROMIXIUM_SCRIPTS/custom-dir.sh "BACKUP_BASE/TIMESTAMP" "$BACKUP_BASE/$TIMESTAMP" "$SYNC_USER" -e
  if [ "$(find $APP_SHARE -name chrom*)" ]; then
    mv "$APP_SHARE"/chrom* "$BACKUP_BASE/$TIMESTAMP"
  fi
  if [ "$(find $APP_SHARE -name google*)" ]; then
    mv "$APP_SHARE"/google* "$BACKUP_BASE/$TIMESTAMP"
  fi
  chown -R $SYNC_USER:$SYNC_USER "$BACKUP_BASE/$TIMESTAMP"
else
  echo "    -no Chrome shortcuts in $APP_SHARE"
fi
# APP_LOCAL="/usr/local/share/applications"
if [ "$(ls -A $APP_LOCAL | grep chrom)" ]; then
  TIMESTAMP="$(date +%Y_%m_%d_%H_%M_%S)-usr_local_share_applications"
  echo "Found Chrome shortcuts in APP_LOCAL:$APP_LOCAL..."
  echo "  - moving to: $BACKUP_BASE/$TIMESTAMP"
  $CHROMIXIUM_SCRIPTS/custom-dir.sh "BACKUP_BASE/TIMESTAMP" "$BACKUP_BASE/$TIMESTAMP" "$SYNC_USER" -e
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
  $CHROMIXIUM_SCRIPTS/custom-dir.sh "BACKUP_BASE/TIMESTAMP" "$BACKUP_BASE/$TIMESTAMP" "$SYNC_USER" -e
  # remove chrome created shortcuts - keep chromixium
  mv "$USER_APPS"/chrome* "$BACKUP_BASE/$TIMESTAMP"
  chown -R $SYNC_USER:$SYNC_USER "$BACKUP_BASE/$TIMESTAMP"
else
  echo "    -no Chrome shortcuts in $USER_APPS"
fi
#============= clear /usr apps end ================================

#============= remap apps and launcher start ================================
# check if desktop files have been copied previously
CHROM_FILE_COUNT=0
for f in "$USER_APPS"/chromixium*; do
  CHROM_FILE_COUNT=$(($CHROM_FILE_COUNT+1))
done
echo "CHROM_FILE_COUNT:$CHROM_FILE_COUNT"
if [ "$CHROM_FILE_COUNT" -lt "35" ]; then
  echo "# copy in chromium desktop files"
  cp "$CHROMIXIUM_SCRIPTS"/chromium_apps/* "$USER_APPS"/ || true
  # if chrome is installed install chrome adjusted shortcuts
  PKG_NAME=google-chrome-stable
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed") || true
  echo Checking for $PKG_NAME: $PKG_OK
  if [ "install ok installed" == "$PKG_OK" ]; then
    echo "# copy in chrome adjusted shortcuts and icons"
    cp "$CHROMIXIUM_SCRIPTS"/chrome_apps/* "$USER_APPS"/ || true
    cp "$CHROMIXIUM_SCRIPTS"/chrome_apps/pixmaps/* "$APP_ICONS"/ || true
  fi
  chown "$SYNC_USER:$SYNC_USER" "$USER_APPS"/*
  chmod "750" "$USER_APPS"/*

  # delete old launchers and copy in adjusted stock ones
  rm "$USER_DOCK"/launchers/chrome* || true
  cp "$CHROMIXIUM_SCRIPTS"/chromium_apps/launchers/* "$USER_DOCK"/launchers/
  chown "$SYNC_USER:$SYNC_USER" "$USER_DOCK"/launchers/*
  chmod "750" "$USER_DOCK"/launchers/*
  # repoint launchers to user home directory 
  for f in "$USER_DOCK"/launchers/*; do
    OLDPATH="switch_path"
    NEWPATH="$USER_APPS"
    sed -i "s%$OLDPATH%$NEWPATH%g" $f
  done
fi
#============= remap apps and launcher end ================================

echo "# "
echo "# Exiting: remap-chrome_apps.sh"
