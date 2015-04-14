#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo " "
  echo "# Running: remap-home.sh"
  sleep 1
fi

# by Kevin Saruwatari, 13-Apr-2015
# free to use/distribute with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

#============= home directories start ================================
# create directory in Google Data that will push/pull
#  and make a link to for user Desktop in nautilus below
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_HFILES" "$GOOGLE_DATA/$CHRMX_HFILES" "$SYNC_USER"

# make the user custom script directory
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "CHRMX_UCUST" "$GOOGLE_DATA/$CHRMX_UCUST" "$SYNC_USER"

# check if home Desktop directory is linked
if [ -h "$USER_HFILES" ]; then
  # test if link is the same as the target dir
  if [ "$(readlink -f $USER_HFILES)" = "$GOOGLE_DATA/$CHRMX_HFILES" ]; then
    echo  "# $USER_HFILES already linked"
  else
    echo "# ...changed repo, linking $USER_HFILES"
    sleep 1
    rm "$USER_HFILES"
    ln -s -f "$GOOGLE_DATA/$CHRMX_HFILES" "$USER_HFILES"
    echo "#  - USER_HOMEPP:$USER_HOMEPP link updated"
  fi
fi
#============= home directories end ================================

if [ $DIAG_MSG = 1 ]; then
  echo " "
  echo "# Exiting: remap-home.sh"
  sleep 1
fi
