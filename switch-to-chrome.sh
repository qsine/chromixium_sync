#!/bin/bash
echo ""
echo "Running: switch-to-chrome.sh"
# by Kevin Saruwatari, 01-Apr-2015
# free to use with no warranty
# removes chromium and pepperflash
# installs chrome stable, .deb is in /tmp and will be deteled on restart
# build link to start chome on chromium calls
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

echo "01"; echo "# remove chromium"

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
  echo "$(($i * 5))"; echo "# Checking for $PKG_NAME: $PKG_OK"
  if [ ! "" == "$PKG_OK" ]; then
    REMOVED_PKGS=$REMOVED_PKGS+1
    echo "$PKG_NAME installed. Removing $PKG_NAME."
    if [ "$RUN_MODE" = "gui" ]; then
      apt-get -y remove $PKG_NAME > /dev/null
    else
      apt-get -y remove $PKG_NAME
    fi
  fi

done

if [ ! "0" == "$REMOVED_PKGs" ]; then
  echo "20"; echo "# Cleaning up packages"
  if [ ! "" == "$PKG_OK" ]; then
    apt-get -y autoremove > /dev/null
  else
    apt-get -y autoremove
  fi
fi

echo "25"; echo "# Check if Chrome is installed"
sleep 1

PKG_NAME=google-chrome-stable
# no error abort
set +e
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
echo "# Checking for $PKG_NAME: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "# Installing $PKG_NAME."
  cd /tmp
  echo "changed to:$(dirname "$(readlink -f "$0")")"
  if [ -d /tmp/google-chrome-stable_current_i386.deb ]; then
    rm /tmp/google-chrome-stable_current_i386.deb
  fi
  if [ "$RUN_MODE" = "gui" ]; then
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb > /dev/null
  else
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
  fi
  dpkg -i google-chrome-stable_current_i386.deb
  ln -s -f /usr/bin/google-chrome /usr/bin/chromium-browser
  echo "REBOOT REQUIRED" > /tmp/REBOOT_FLAG
  sleep 5
  rm "$USER_APPS"/chrom*
fi
# abort on error 
set -e

# NOTE: leave the autostart and make all chrome shortcuts call chromium browser 
# it works if chromium is left installed

echo ""
echo "Exiting: switch-to-chrome.sh"
