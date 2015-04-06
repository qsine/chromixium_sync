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

#  for f in "$CHROMIXIUM_SCRIPTS"/*.sh; do
#    if [ "$f" != "$CHROMIXIUM_SCRIPTS"/test.sh ]; then
#    OLDPATH='$CHROMIXIUM_SCRIPTS/custom-dir.sh'
#    NEWPATH='. $CHROMIXIUM_SCRIPTS/custom-dir.sh'
#    echo "$f"
#    sed -i "s%$OLDPATH%$NEWPATH%g" $f
#    fi
#  done

. /opt/chrxsync/chromixium_sync/set-paths.sh "serveradmin" "serveradmin"

echo "$DEST_HOME"


#if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: test.sh"
#  sleep 1
#fi
