#!/bin/bash

#if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Running: test.sh"
  sleep 1
#fi

# by Kevin Saruwatari, 01-Apr-2015
# free to use/distribute with no warranty

# abort on error 
set -e

# setup customization paths
# we have to remove Chrome shortcuts from these directories
APP_SHARE="/usr/share/applications"
APP_LOCAL="/usr/local/share/applications"

# set the base for user home  
DEST_HOME="/home/$SYNC_USER"
    # user readable backup directory for displaced applications
    #  and Google Drive data is copied before a push.
    #  User can delete the directories including the base.
    BACKUP_BASE="$DEST_HOME/SettingsBU"
    # Local files in home that will not go to Google Drive 
    LOCAL_FILES="$DEST_HOME/LocalFiles"
# user sync/link dirs
    USER_GTK3="$DEST_HOME/.config/gtk-3.0"
    USER_CLOCK="$DEST_HOME/.config/lxpanel"
    USER_NAUT="$DEST_HOME/.config/nautilus"
    USER_UWALL="$DEST_HOME/.config/nitrogen"      # current wallpaper setting
    USER_ASTART="$DEST_HOME/.config/ob-autostart" # may require USER_SCRN
    USER_MENU="$DEST_HOME/.config/openbox"
    USER_DOCK="$DEST_HOME/.config/plank/dock1"
    USER_SCRNL="$DEST_HOME/.screenlayout"         # holds multi-monitor settings
    USER_APPS="$DEST_HOME/.local/share/applications"
# root sync dirs
LOGIN_PREF="/etc/lightdm"
APP_ICONS="/usr/share/pixmaps/chromixium"
WALLS_USR="/usr/share/wallpapers"
GREETER_ICON="/var/lib/AccountsService/icons"

# directories hold custom scripts, source code and sync buffer
# ODEKE_DRIVE are the GO programs the push and pull the Google Drive
# GOOGLE_DATA is the buffer ODEKE pushes and pulls to
#  and it is purposely kept out of easy viewing of the user
#  because they should not read and write data directly
#  as it does not autonomously nor intelligently sync with Google Drive
SYNC_BASE="/opt/chrxsync"
    ODEKE_DRIVE="$SYNC_BASE/odeke_drive"
    CHROMIXIUM_SCRIPTS="$SYNC_BASE/chromixium_sync"  # pull from git repo

UDATA_BASE="$DEST_HOME/.local/share/chrxsync"
        GOOGLE_DATA="$UDATA_BASE/google_data"


# these are the directories used as the repository on the Google Drive
# CHRMX_BASE must be in the root directory of the Google Drive
# CHRMX_SYNC is the next level down and is used to hold the repos
#  for multiple users.  Other user data that will not sync can be 
#  kept in directories at the same level.
# CHRMX_REPO is the top level for the actual repo and is typically the 
#  GNU/Linux user name.  Hence one Google account can be used to sync multiple
#  users or multiple profiles for single user.
CHRMX_BASE="Chromixium"
    CHRMX_SYNC="$CHRMX_BASE/chromixium_profiles"
        CHRMX_REPO="$CHRMX_SYNC/$REPO_PROFILE"
            CHRMX_HFILES="$CHRMX_REPO/home_googlefiles"
# user sync/link dirs
            CHRMX_GTK3="$CHRMX_REPO/home_user_.config_gtk3"
            CHRMX_CLOCK="$CHRMX_REPO/home_user_.config_lxpanel"
            CHRMX_NAUT="$CHRMX_REPO/home_user_.config_nautilus"
            CHRMX_UWALL="$CHRMX_REPO/home_user_.config_nitrogen"
            CHRMX_ASTART="$CHRMX_REPO/home_user_.config_ob-autostart"
            CHRMX_MENU="$CHRMX_REPO/home_user_.config_openbox"
            CHRMX_DOCK="$CHRMX_REPO/home_user_.config_plank_dock1"
            CHRMX_SCRNL="$CHRMX_REPO/home_user_.screenlayout"
            CHRMX_UAPPS="$CHRMX_REPO/home_user_.local_share_applications"
# root sync dirs
            CHRMX_ICONS="$CHRMX_REPO/usr_share_pixmaps_chromixium"
            CHRMX_WALLS="$CHRMX_REPO/usr_share_wallpapers"
            CHRMX_LOGIN="$CHRMX_REPO/etc_lightdm"

#==============================================================

  for f in "$CHROMIXIUM_SCRIPTS"/*.sh; do
    if [ "$f" != "$CHROMIXIUM_SCRIPTS"/test.sh ]; then
    OLDPATH='$CHROMIXIUM_SCRIPTS/custom-dir.sh'
    NEWPATH='. $CHROMIXIUM_SCRIPTS/custom-dir.sh'
    echo "$f"
    sed -i "s%$OLDPATH%$NEWPATH%g" $f
    fi
  done

#if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: test.sh"
  sleep 1
#fi
