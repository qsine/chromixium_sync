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

#CHG_FILES=/opt/chrxsync/chromixium_sync/chromium_apps
#  for f in "$CHG_FILES"/*.desktop; do
#    if [ "$f" != "$CHROMIXIUM_SCRIPTS"/test.sh ]; then
#    OLD_STR='#!env xdg-open'
#    NEW_STR='#!/usr/bin/env xdg-open'
#    echo "$f"
#    sed -i "s%$OLD_STR%$NEW_STR%g" $f
#    fi
#  done
echo " "
TARGET=/etc/passwd
echo "${TARGET%*${TARGET##*/}}"

#if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: test.sh"
#  sleep 1
#fi
