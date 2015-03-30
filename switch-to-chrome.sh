#!/bin/bash
echo ""
echo "Running: switch-to-chrome.sh"
# by Kevin Saruwatari, 27-Mar-2015
# free to use with no warranty
# removes chromium and pepperflash
# installs chrome stable, .deb is in /tmp and will be deteled on restart
# build link to start chome on chromium calls
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

# remove chromium:

REMOVED_PKGS=0

for i in {1..2}; do
  if [ "$i" = "1" ]; then
    PKG_NAME="chromium-browser"
  fi

  if [ "$i" = "2" ]; then
    PKG_NAME="pepperflashplugin-nonfree"
  fi

  # no error abort
  set +e
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
  # abort on error 
  set -e
  echo Checking for $PKG_NAME: $PKG_OK
  if [ ! "" == "$PKG_OK" ]; then
    REMOVED_PKGS=$REMOVED_PKGS+1
    echo "$PKG_NAME installed. Removing $PKG_NAME."
    apt-get -y remove $PKG_NAME
  fi

done

if [ ! "0" == "$REMOVED_PKGs" ]; then
  apt-get -y autoremove
fi

# install chrome

PKG_NAME=google-chrome-stable
# no error abort
set +e
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
echo Checking for $PKG_NAME: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "$PKG_NAME not installed. Adding $PKG_NAME."
  cd /tmp
  echo "changed to:$(dirname "$(readlink -f "$0")")"
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
  dpkg -i google-chrome-stable_current_i386.deb
  ln -s -f /usr/bin/google-chrome /usr/bin/chromium-browser
  rm "$USER_APPS"/chromixium*
fi
# abort on error 
set -e

# NOTE: leave the autostart and make all chome shortcuts call chromium browser 
# it works if chromium is left installed

echo ""
echo "Exiting: switch-to-chrome.sh"
