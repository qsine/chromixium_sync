#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Running: upgrade-chrx.sh"
  sleep 1
fi

# by Kevin Saruwatari, 07-Apr-2015
# free to use/distribute with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# abort on error 
set -e

ASK4CHROME=1

echo "05"; echo "# check for apt update/upgrade/cleanup"
. $CHROMIXIUM_SCRIPTS/upgrade-apt.sh

# update scripts if using Git
if [ "$GET_SCRIPTS" = "git" ]; then
  echo "30"; echo "#  -CHROMIXIUM_SCRIPTS installed, updating from Git"
  cd "${CHROMIXIUM_SCRIPTS}"
  echo "# Changed to:$(dirname "$(readlink -f "$0")")"
  git pull
else
  read -p "need to make a copy from /tmp script here."
  exit 1
  echo "30"; echo "#  -CHROMIXIUM_SCRIPTS installed, copy update from Git"
fi

# switch to chrome from chromium
if [ $ASK4CHROME = 1 ]; then 
  # no error abort 
  set +e
  PKG_NAME=google-chrome-stable
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
  echo "40"; echo "Checking for $PKG_NAME"
  # abort on error 
  set -e
  if [ "" == "$PKG_OK" ]; then
    echo "# $PKG_NAME not installed."
    if [ "$RUN_MODE" = "gui" ]; then
      # no error abort 
      set +e
      zenity --question --text="Switch from Chromium to Chrome?"
      if [ "$?" = 0 ]; then
        echo "# Installing Chrome, please be patient"
        . $CHROMIXIUM_SCRIPTS/switch-to-chrome.sh
      else
        # don't ask for chrome install again
        sed -i "s%ASK4CHROME=1%ASK4CHROME=0%g" $CHROMIXIUM_SCRIPTS/upgrade-chrx.sh
        sleep 1 
      fi
      # abort on error 
      set -e
    else # cmd mode
      echo ""
      while true; do
        read -p "Switch from Chromium to Chrome? (y/n):" yn
        case $yn in
          [Yy]* ) echo "Installing Chrome, please be patient"
                  . $CHROMIXIUM_SCRIPTS/switch-to-chrome.sh
                  break
                  ;;
          [Nn]* ) # don't ask for chrome install again
                  sed -i "s%ASK4CHROME=1%ASK4CHROME=0%g" $CHROMIXIUM_SCRIPTS/upgrade-chrx.sh
                  break
                  ;;
           * ) echo "Please answer y or n"
               ;;
        esac
      done
    fi # end gui/cmd line confirm
  fi # end switch to chrome
fi # end ask for chrome

# remap chrome apps
echo "80"; echo "#  ..remap chrome apps"
sleep 1
. $CHROMIXIUM_SCRIPTS/remap-chrome_apps.sh


# echo "# User installations"
sleep 1
USER_INS_PATH="$GOOGLE_DATA/$CHRMX_UCUST
chown "$SYNC_USER:$SYNC_USER" "$USER_INS_PATH"/*
chmod "644" "$USER_INS_PATH"/*
chmod "750" "$USER_INS_PATH"/*.sh

# user repository installs
GET_FILE_CNT=$(ls $USER_INS_PATH/* | grep $USER_INS_PATH/get- | wc -l)
if [ -d $USER_INS_PATH -a $GET_FILE_CNT -gt 0 ]; then
echo "# Installing $GET_FILE_CNT user apt scripts"
sleep 2
  if [ "${RUN_MODE}" = "gui" ]; then
    (
    for f in $USER_INS_PATH/get-*; do
      echo "#  Install user script: ${f##*/}"
      . $f
    done
    echo "# done."
    ) | zenity --progress \
      --title="User Applications..." \
      --text="Using apt-get..." \
      --pulsate \
      --auto-close
    if [ "$?" = -1 ]; then
      zenity --error --text="User installs cancelled."
    fi
  else # cmd mode
    echo "Install user packages"
    for f in $USER_INS_PATH/get-*; do 
      echo "Install user script: ${f##*/}"
      . $f
    done
    echo "done."
  fi # end user apts 
fi # if dir and file exist

# user source build installs
BUILD_FILE_CNT=$(ls $USER_INS_PATH/* | grep $USER_INS_PATH/build- | wc -l)
if [ -d $USER_INS_PATH -a $BUILD_FILE_CNT -gt 0 ]; then
  echo "# Installing $BUILD_FILE_CNT user build scripts"
  sleep 2
  if [ "${RUN_MODE}" = "gui" ]; then
    (
    for f in $USER_INS_PATH/build-*; do
      echo "#  User build script: ${f##*/}"
      . $f
    done
    echo "# done."
    ) | zenity --progress \
      --title="User Builds..." \
      --text="Building from source..." \
      --pulsate \
      --auto-close
    if [ "$?" = -1 ]; then
      zenity --error --text="User builds cancelled."
    fi
  else # cmd mode
    echo "Install user packages"
    for f in $USER_INS_PATH/build-*; do 
      echo "User build script: ${f##*/}"
      . $f
    done
    echo "done."
  fi # end user builds 
fi # if dir and file exist

# update/upgrade/cleanup apt
. $CHROMIXIUM_SCRIPTS/upgrade-apt.sh

echo "99"

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: upgrade-chrx.sh"
  sleep 1
fi
