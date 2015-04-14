#!/bin/bash

#if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Running: test.sh"
#  sleep 1
#fi

# by Kevin Saruwatari, 01-Apr-2015
# free to use/distribute with no warranty

# abort on error 
set -e

SYNC_USER="serveradmin"
REPO_PROFILE="serveradmin"

CHG_FILES=/opt/chrxsync/chromixium_sync/chrome_apps
  for f in "$CHG_FILES"/*.desktop; do
    if [ "$f" != "$CHROMIXIUM_SCRIPTS"/test.sh ]; then
    OLD_STR='Exec=chromium-browser'
    NEW_STR='Exec=chromium-browser --disable-gpu'
    echo "$f"
    sed -i "s%$OLD_STR%$NEW_STR%g" $f
    fi
  done

#ADMIN="serveradmin:x:1000:1000:"
#PFILE=/opt/chrxsync/chromixium_sync/passwd
# c\ only accepts literal string
#sed -i /$ADMIN/c\serveradmin:x:1000:1000:Administrator,,4032489066,:/home/serveradmin:/bin/bash $PFILE

#if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: test.sh"
#  sleep 1
#fi
