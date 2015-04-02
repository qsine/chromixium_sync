#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "Running: upgrade-apt.sh"
#  sleep 1
fi

# by Kevin Saruwatari, 02-Apr-2015
# free to use/distribute with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

sleep 1
if [ ! -f "/tmp/APTUPDATE_RAN" ]; then
  echo "# apt-update/upgrade"
  if [ "${RUN_MODE}" = "gui" ]; then
    (
    echo "# Update Chromixium repos"
    apt-get update > /dev/null
    echo "# Update Chromixium"
    apt-get -y dist-upgrade > /dev/null
    echo "ran-this-power-cycle=true" > /tmp/APTUPDATE_RAN
    ) | zenity --progress \
        --title="Updating Chromixium..." \
        --text="Using apt-get..." \
        --pulsate \
        --auto-close
      if [ "$?" = -1 ]; then
        zenity --error --text="Update cancelled."
      fi
  else #cmd mode
    echo "Update Chromixium repos"
    apt-get update
    echo "Upgrade Chromixium"
    apt-get -y dist-upgrade
    echo "ran-this-power-cycle=true" > /tmp/APTUPDATE_RAN
  fi
fi

# clean up packages
echo ""
echo "#  ..clearing any unused packages"
if [ "${RUN_MODE}" = "gui" ]; then
  apt-get -y autoremove > /dev/null
else # cmd mode
  apt-get -y autoremove
fi # end mode
echo ""
echo "# done."

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "Exiting: upgrade-apt.sh"
#  sleep 1
fi
