#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# $SYNC_USER Running: build-qsine_machines.sh"
  sleep 2
fi

# by Kevin Saruwatari, 06-Apr-2015
# free to use with no warranty
# place in GOOGLE_DATA/CHRMX_HFILES/.installs and
# Qsine installer will automatically run it
# the name must be in the format build-*

# as other machine come on, specific configs are set here
#  - admin laptop needs broadcom wifi drivers

# abort on error 
set -e

if [ "$(hostname)" = "admin" ]; then
  echo "# admin laptop detected"
  sleep 1

  echo "# apt-update/upgrade"
  . $CHROMIXIUM_SCRIPTS/upgrade-apt.sh

  # need broadcom wireless driver:
  for i in \
    "bcmwl-kernel-source" \
  ; do
    # no error abort
    set +e
    PKG_NAME="$i"
    echo "# Checking for $PKG_NAME"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
    # abort on error 
    set -e
    if [ "" == "$PKG_OK" ]; then
      echo "# Setting up $PKG_NAME, please be patient"
      apt-get -y install $PKG_NAME
    fi
    sleep 1
  done

#  echo "LOGOFF REQUIRED" > /tmp/LOGOFF_FLAG
fi

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# $SYNC_USER Exiting: build-qsine_machines.sh"
  sleep 1
fi
