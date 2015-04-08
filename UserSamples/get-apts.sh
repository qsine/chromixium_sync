#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# $SYNC_USER Running: get-apts.sh"
  sleep 2
fi

# by Kevin Saruwatari, 06-Apr-2015
# free to use with no warranty
# standard packages from Ubuntu repos
# for all qsine machines
# can be used stand-alone
# place in GOOGLE_DATA/CHRMX_HFILES/.installs and
# Qsine installer will automatically run it
# the name must be in the format get-*

# abort on error 
set -e
echo "# apt-update/upgrade"
. $CHROMIXIUM_SCRIPTS/upgrade-apt.sh

# std apt-get packages:
for i in \
  "evince" \
  "gnome-calculator" \
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


if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# $SYNC_USER Exiting: get-apts.sh"
  sleep 1
fi
