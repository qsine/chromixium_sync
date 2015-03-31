#!/bin/bash
echo ""
echo "Running: chromixium_sync.sh"
# by Kevin Saruwatari, 29-Mar-2015
# free to use with no warranty
# sync chromixium to Google Drive

# abort on error 
set -e
echo "GOPATH:$GOPATH"
# set this variable to control copy scripts or Git them
GET_SCRIPTS="git" # "git" or "copy"
CS_STATE=0 # installation in unknown status
DEF_NAME=$SUDO_USER
REBOOT_FLAG=0

#---------------------------------------------------

# check argument 1
if [ ! "$1" ]; then
  echo "No CONFIG_CODE specified. Aborting"
  echo "  Type qsine-config.sh --help for info"
  exit 1
else
  if [ "$1" = '--help' -o "$1" = '-h' ]; then
    echo ""
    echo "Usage: chromixium_sync.sh " '"config_code" "repo_name" "user_name"'
    echo "  Where:"
    echo "     config_code: controls what the installer does"
    echo "        --install: install std programs & setup push/pull RUN FIRST!"
    echo "        --update: updates existing or installs new"
    echo "        --push: push machine config data to Google Drive"
    echo "        --pull: pull config data from Google Drive to machine"
    echo "        --push_pull: push then pull config (Developer Mode)"
    echo "        --gui: select parameters via dialogs"
    echo "     repo_name: name of the repo to push/pull"
    echo "     user_name: Linux user name, must have valid /home directory"
    echo ""
    exit 1
  fi
fi

CS_STATE=1 # calling command in right format
#---------------------------------------------------

case "$1" in
    --install )
        echo "  - installing applications for chromixium_sync"
        CONFIG_CODE="install"
        ;;
    --update )
        echo "  - updating applications for chromixium_sync"
        CONFIG_CODE="update"
        ;;
    --push )
        echo "  - will push machine config"
        CONFIG_CODE="push"
        ;;
    --pull )
        echo "  - will pull config to machine"
        CONFIG_CODE="pull"
        ;;
    --push_pull )
        echo "  - push then pull machine config"
        CONFIG_CODE="push_pull"
        ;;
    --gui )
        echo "  - run with Dialogs"
        CONFIG_CODE="gui"
        ;;
    *)
        echo "  - invalid control code, exiting"
        exit 1 
        ;;
esac
if [ "$CONFIG_CODE" = "gui" ]; then
  RUN_MODE="gui"
else
  RUN_MODE="cmd"
fi

CS_STATE=2 # calling command valid argument 1
#---------------------------------------------------

# check argument 2
if [ ! "$2" ]; then
  echo "No REPO_PROFILE specified, assuming $DEF_NAME"
  GET_NAMES="$DEF_NAME"
  DEF_REPO="$DEF_NAME"
else
  GET_NAMES="$2"
  DEF_REPO="$2"
fi
# check argument 3
if [ ! "$3" ]; then
  echo "No USER_CODE specified, assuming $DEF_NAME"
  GET_NAMES="$GET_NAMES"'<,>'"$DEF_NAME"
else
  GET_NAMES="$GET_NAMES"'<,>'"$3"
  DEF_NAME="$3"
fi

# more than one user can be sync's to Google Drive
# REPO_PROFILE is top level of the repo to push/pull
# SYNC_USER is the user account on the machine to push/pull
#   and must match the name in the /home directory

echo "GET_NAMES:$GET_NAMES will be overwritten by --gui" 

# dialog for user and repo names 
if [ $CONFIG_CODE = "gui" ]; then
  GET_NAMES=$(zenity --forms --title="Qsine Configuration/Sync Utility" \
	--text="Sync Chromixium settings to Google Drive" \
	--separator="<,>" \
	--add-entry="Repo Name: (Default:$DEF_REPO)" \
	--add-entry="Chromixium User (Default:$DEF_NAME)" \
        )
fi

CS_STATE=3 # user and repo names input
#---------------------------------------------------

# parse names from dialog
case $? in
  0)
    i=1

    for name in ${GET_NAMES//,/ }
      do
        # parse repo name
        if [ "$i" = "1" ]; then

          # test default is accepted
          if [ "$name" = "<" ] ; then
            name="$DEF_REPO"
          else
            name=${name:0:(${#name}-1)}
          fi

          # test to regex
          if [[ "$name" =~ ^[a-z][a-zA-Z0-9_]*$ ]]; then
            echo "  $i $name is valid repo, continuing..."
            REPO_PROFILE="$name"
          else
            echo "  $i $name invalid repo name, exiting."
            exit 1
          fi

        fi

        # parse Chromixium user
        if [ "$i" = "2" ]; then

          # test default is accepted
          if [ "$name" = ">" ] ; then
            name="$DEF_NAME"
          else
            name=${name:1:${#name}}
          fi

          # test if user exists on the system
          if id -u "$name" >/dev/null 2>&1; then
            echo "  $i $name is valid user, continuing..."
            SYNC_USER="$name"
          else
            echo "  $i $name user does not exist, exiting."
            exit 1
          fi

        fi

      ((i++))
    done
    ;;
  1)
    echo "cancelled, exiting"
    exit 1
    ;;
  -1)
    echo "An unexpected error has occurred, exiting."
    exit 1
    ;;
esac

CS_STATE=4 # user and repo names validated
#---------------------------------------------------

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
# setup GO home and PATH to binaries
export GOPATH="$ODEKE_DRIVE"
export PATH="$PATH:$GOPATH/bin"

CS_STATE=5 # user and repo paths defined
#---------------------------------------------------

# test if base directories exist
if [ -d "$SYNC_BASE" \
  -a -d "$UDATA_BASE" \
   ]; then
  CS_STATE=6 # base directories exist
  #---------------------------------------------------
else
  echo " Missing base directories, installation required."
fi

# test Chromixium scripts exists
if [ -d "$CHROMIXIUM_SCRIPTS" ]; then
  if [ "$(ls -A $CHROMIXIUM_SCRIPTS)" ]; then
    if [ $CS_STATE -ge 6 ]; then
      CS_STATE=7 # Chromixium scripts installed
    fi
    #---------------------------------------------------
  else
    echo " Missing Chromixium script, installation required."
  fi
else
  echo " Missing Chromixium scripts directory, installation required."
fi

# test ODEKE drive exists
if [ -d "$ODEKE_DRIVE" ]; then
  if [ "$(ls -A $ODEKE_DRIVE)" ]; then
    if [ $CS_STATE -ge 7 ]; then
      CS_STATE=8 # ODEKE drive installed
    fi
    #---------------------------------------------------
  else
    echo " Missing ODEKE drive utilities, installation required."
  fi
else
  echo " Missing ODEKE directory, installation required."
fi

# test Google Data exists
if [ -d "$GOOGLE_DATA" ]; then
  if [ "$(ls -A $GOOGLE_DATA)" ]; then
    if [ $CS_STATE -ge 8 ]; then
      CS_STATE=9 # Google Data installed
    fi
    #---------------------------------------------------
  else
    echo " Missing Google Data, installation required."
  fi
else
  echo " Missing Google Data directory, installation required."
fi

# check for installation required 
if [ $CS_STATE -lt 9 -o "$CONFIG_CODE" = 'install' ]; then
  # if installation is specifically called then just run it
  if [ "$CONFIG_CODE" != 'install' ]; then 
    # confirm with user to install
    if [ "$RUN_MODE" = "gui" ]; then
      zenity --question --text="Chromixium Sync not setup, okay to install?"
      if [ "$?" = 0 ]; then
        CONFIG_CODE="install"
        echo "Installing CS_STATE:$CS_STATE, CONFIG_CODE:$CONFIG_CODE"
      else
        exit 1
      fi
    else # ... or command line
      echo ""
      while true; do
        read -p "Chromixium Sync not setup, okay to install? (y/n):" yn
        case $yn in
          [Yy]* ) CONFIG_CODE="install"
                  echo "Installing CS_STATE:$CS_STATE, CONFIG_CODE:$CONFIG_CODE"
                  break
                  ;;
          [Nn]* ) exit 1
                  ;;
           * ) echo "Please answer y or n"
               ;;
        esac
      done
    fi # end gui/cmd line confirm
  fi # end config_code check

  #============= base install start ================================
  # make base directory if it doesn't exist
  if [ ! -d "$SYNC_BASE" ]; then
    echo ""
    echo "-making SYNC_BASE:$SYNC_BASE"
    mkdir -p "$SYNC_BASE"
    chown "root:root" "$SYNC_BASE"
  else
    echo "  -SYNC_BASE:$SYNC_BASE already exists..."
  fi # end make base

  # make user data base directory if it doesn't exist
  if [ ! -d "$UDATA_BASE" ]; then
    echo ""
    echo "-making UDATA_BASE:$UDATA_BASE"
    mkdir -p "$UDATA_BASE"
    chown "$SYNC_USER":"$SYNC_USER" "$UDATA_BASE"
  else
    echo "  -UDATA_BASE:$UDATA_BASE already exists..."
  fi # end make user base

  # check if chromixium_sync scripts directory exists
  if [ "$CS_STATE" -lt 7 ]; then
    echo "CHROMIXIUM_SCRIPTS missing, install Git and clone"

    if [ "$GET_SCRIPTS" = "copy" ]; then
      # make script directory if it doesn't exist
      if [ ! -d "$CHROMIXIUM_SCRIPTS" ]; then
        echo ""
        echo "-making CHROMIXIUM_SCRIPTS:$CHROMIXIUM_SCRIPTS"
        mkdir -p "$CHROMIXIUM_SCRIPTS"
        chown "root:root" "$CHROMIXIUM_SCRIPTS"
      else
        echo "  -CHROMIXIUM_SCRIPTS:$CHROMIXIUM_SCRIPTS already exists..."
      fi # end make scripts
      # find where we are running from 
      WHERE_I_AM="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
      rsync -aP --delete --exclude .git "${WHERE_I_AM}/" "${CHROMIXIUM_SCRIPTS}/"
      chmod "755" "$CHROMIXIUM_SCRIPTS"/*.sh
      echo "CHROMIXIUM_SCRIPTS:$CHROMIXIUM_SCRIPTS installed"
    else
      if [ ! -f "/tmp/APTUPDATE_RAN" ]; then
        echo "update Ubuntu repos and upgrade"
        apt-get update
        apt-get -y dist-upgrade
        echo "ran-this-power-cycle=true" > /tmp/APTUPDATE_RAN
      fi
      # install Git if missing
      echo "Checking for Git"
      # no error abort
      set +e
      PKG_OK=$(dpkg-query -W --showformat='${Status}\n' git|grep "install ok installed")
      # abort on error 
      set -e
      if [ "" == "$PKG_OK" ]; then
        echo "No Git. Setting it up..."
        aptitude install -y git
      fi

      # get scripts from Git
      cd "$SYNC_BASE"
      echo "Changed to:$(dirname "$(readlink -f "$0")")"
      git clone https://github.com/qsine/chromixium_sync
      chown "root:root" "$CHROMIXIUM_SCRIPTS"
      chmod "755" "$CHROMIXIUM_SCRIPTS"/*.sh
    fi # copy or Git
    # make desktop file
    echo "#!/usr/bin/env xdg-open" > "$USER_APPS"/chrxsync.desktop
    echo "" >> "$USER_APPS"/chrxsync.desktop
    echo "[Desktop Entry]" >> "$USER_APPS"/chrxsync.desktop
    echo "Version=1.0" >> "$USER_APPS"/chrxsync.desktop
    echo "Terminal=false" >> "$USER_APPS"/chrxsync.desktop
    echo "Type=Application" >> "$USER_APPS"/chrxsync.desktop
    echo "Name=Chromixium Sync" >> "$USER_APPS"/chrxsync.desktop
    echo "StartupWMClass=zenity" >> "$USER_APPS"/chrxsync.desktop
    echo "Exec="gksudo -u root -- $CHROMIXIUM_SCRIPTS"/chromixium_sync.sh --gui $REPO_PROFILE $SYNC_USER" >> "$USER_APPS"/chrxsync.desktop
    echo "Icon="$CHROMIXIUM_SCRIPTS"/qsine-logo.png" >> "$USER_APPS"/chrxsync.desktop
    echo "NoDisplay=false" >> "$USER_APPS"/chrxsync.desktop
    echo "Categories=System;" >> "$USER_APPS"/chrxsync.desktop
  fi # end get Chromixium scripts

  # install GO tools to push/pull data to/from Google Drive
  if [ "$CS_STATE" -lt 8 ]; then
    if [ ! -f "/tmp/APTUPDATE_RAN" ]; then
      echo "update Ubuntu repos and upgrade"
      apt-get update
      apt-get -y dist-upgrade
      echo "ran-this-power-cycle=true" > /tmp/APTUPDATE_RAN
    fi
    . $CHROMIXIUM_SCRIPTS/get-odeke_drive.sh "ODEKE_DRIVE" "$ODEKE_DRIVE" "$DEST_HOME"
  fi # end get ODEKE utilities

  # google data is the buffer to push/pull files and directories to/from google drive
  if [ "$CS_STATE" -lt 9 ]; then
    if [ ! -f "/tmp/APTUPDATE_RAN" ]; then
      echo "update Ubuntu repos and upgrade"
      apt-get update
      apt-get -y dist-upgrade
      echo "ran-this-power-cycle=true" > /tmp/APTUPDATE_RAN
    fi
    . $CHROMIXIUM_SCRIPTS/create-google_data.sh "GOOGLE_DATA" "$GOOGLE_DATA" "$ODEKE_DRIVE"
  fi # end make Google Data

  #============= base install end ================================
fi # end check for installation

CS_STATE=10 # valid base installation confirmed
#---------------------------------------------------

if [ "${RUN_MODE}" = "gui" ]; then
  CONFIG_CODE=$(zenity  \
                --list  --text "Chromium Sync Config" \
                --radiolist  --column "Pick" \
                --column "Config" \
                    TRUE  "update" \
                    FALSE "push" \
                    FALSE "pull" \
                    FALSE "push_pull" \
                  );
fi


#============= push start ================================
if [ "$CONFIG_CODE" = 'push' -o "$CONFIG_CODE" = 'push_pull' ]; then

  # push data to Google Drive
  # use "." so subshell inherits environment variables
  if [ "${RUN_MODE}" = "gui" ]; then
    (
    . $CHROMIXIUM_SCRIPTS/push-to-drive.sh -e 
    ) | zenity --progress \
        --title="Push to Google Drive" \
        --text="Prep for push..." \
        --percentage=0 \
        --auto-close
      if [ "$?" = -1 ]; then
        zenity --error --text="Push cancelled."
      fi
  else #cmd mode
    . $CHROMIXIUM_SCRIPTS/push-to-drive.sh -e
  fi
fi
#============= push end ================================

#============= install/update start ================================
if [ "$CONFIG_CODE" = 'install' -o "$CONFIG_CODE" = 'update' ]; then

  # update/upgrade is done on install
  if [ ! -f "/tmp/APTUPDATE_RAN" ]; then
    if [ "${RUN_MODE}" = "gui" ]; then
      (
      echo "update Ubuntu repos and upgrade"
      apt-get update
      apt-get -y dist-upgrade
      echo "ran-this-power-cycle=true" > /tmp/APTUPDATE_RAN
      ) | zenity --progress \
          --title="Updating Chromixium..." \
          --text="Using apt-get..." \
          --percentage=0 \
          --auto-close
        if [ "$?" = -1 ]; then
          zenity --error --text="Update cancelled."
        fi
    else #cmd mode
      echo "update Ubuntu repos and upgrade"
      apt-get update
      apt-get -y dist-upgrade
      echo "ran-this-power-cycle=true" > /tmp/APTUPDATE_RAN
    fi
  fi
  # update scripts if using Git
  if [ "$GET_SCRIPTS" = "git" ]; then
    if [ "${RUN_MODE}" = "gui" ]; then
      (
      echo "  -CHROMIXIUM_SCRIPTS:${CHROMIXIUM_SCRIPTS} already installed, updating from Git"
      cd "${CHROMIXIUM_SCRIPTS}"
      echo " Changed to:$(dirname "$(readlink -f "$0")")"
      git pull
      ) | zenity --progress \
          --title="Sync Scripts..." \
          --text="Udating from Git..." \
          --percentage=0 \
          --auto-close
        if [ "$?" = -1 ]; then
          zenity --error --text="Scripts cancelled."
        fi
    else #cmd mode
      echo "  -CHROMIXIUM_SCRIPTS:${CHROMIXIUM_SCRIPTS} already installed, updating from Git"
      cd "${CHROMIXIUM_SCRIPTS}"
      echo "Changed to:$(dirname "$(readlink -f "$0")")"
      git pull
    fi
  fi

  # switch to chrome from chromium
  PKG_NAME=google-chrome-stable
  # no error abort 
  set +e
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
  # abort on error 
  set -e
  echo "Checking for $PKG_NAME: $PKG_OK"
  if [ "" == "$PKG_OK" ]; then
    echo "$PKG_NAME not installed."
    if [ "$RUN_MODE" = "gui" ]; then
      # no error abort 
      set +e
      zenity --question --text="Switch from Chromium to Chrome?"
      if [ "$?" = 0 ]; then
        (
        . $CHROMIXIUM_SCRIPTS/switch-to-chrome.sh -e
        ) | zenity --progress \
          --title="Switch to Chrome..." \
          --text="Install Chrome..." \
          --percentage=0 \
          --auto-close
        if [ "$?" = -1 ]; then
          zenity --error --text="Chrome install cancelled."
        fi
      else
        echo "zenity=$?, continiung" 
      fi
      # abort on error 
      set -e
    else # cmd mode
      echo ""
      while true; do
        read -p "Switch from Chromium to Chrome? (y/n):" yn
        case $yn in
          [Yy]* ) . $CHROMIXIUM_SCRIPTS/switch-to-chrome.sh -e
                  break
                  ;;
          [Nn]* ) break
                  ;;
           * ) echo "Please answer y or n"
               ;;
        esac
      done
    fi # end gui/cmd line confirm
  fi # end switch to chrome

  # remap chrome apps
  if [ "${RUN_MODE}" = "gui" ]; then
    (
    echo "  ..remap chrome apps"
    . $CHROMIXIUM_SCRIPTS/remap-chrome_apps.sh -e
    ) | zenity --progress \
      --title="Remap Chrome Apps..." \
      --text="Checking apps..." \
      --percentage=0 \
      --auto-close
    if [ "$?" = -1 ]; then
      zenity --error --text="Remap cancelled."
    fi
  else # cmd mode
    echo "  ..remap chrome apps"
    . $CHROMIXIUM_SCRIPTS/remap-chrome_apps.sh -e
  fi # end remap chrome apps

  # clean up
  if [ "${RUN_MODE}" = "gui" ]; then
    (
    echo "  ..clearing any unused packages"
    apt-get -y autoremove
    echo "done."
    ) | zenity --progress \
      --title="Clean up Chromixium..." \
      --text="Using apt-get..." \
      --percentage=0 \
      --auto-close
    if [ "$?" = -1 ]; then
      zenity --error --text="Cleanup cancelled."
    fi
  else # cmd mode
    echo "  ..clearing any unused packages"
    apt-get -y autoremove

    echo ""
    echo "done."
  fi # end clean up 

fi

#============= install/update end ================================

#============= pull start ================================
if [ "$CONFIG_CODE" = 'pull' -o "$CONFIG_CODE" = 'push_pull' ]; then

  # pull new data from Google Drive
  #   Note: this will clear Chrome .desktop apps from /usr directories
  #         to prevent duplicate/unassigned icons from showing up in the dock
  # use "." so subshell inherits environment variables
  if [ "${RUN_MODE}" = "gui" ]; then
    (
    . $CHROMIXIUM_SCRIPTS/pull-from-drive.sh -e
    ) | zenity --progress \
        --title="Pull from Google Drive" \
        --text="Pulling..." \
        --percentage=0 \
        --auto-close
      if [ "$?" = -1 ]; then
        zenity --error --text="Pull cancelled."
      fi
  else #cmd mode
    . $CHROMIXIUM_SCRIPTS/pull-from-drive.sh -e
  fi

fi
#============= pull end ================================

echo ""
echo "Exiting: chromixium_sync.sh"
if [ "${RUN_MODE}" = "gui" ]; then
  zenity --info --text="Chromixium Sync complete."
fi

if [ $REBOOT_FLAG == 1 ]; then
    if [ "$RUN_MODE" = "gui" ]; then
      # no error abort 
      set +e
      zenity --question --text="Reboot required, restart now?"
      if [ "$?" = 0 ]; then
        reboot
      fi
      # abort on error 
      set -e
    else # cmd mode
      echo ""
      while true; do
        read -p "Reboot required, restart now? (y/n):" yn
        case $yn in
          [Yy]* ) reboot
                  break
                  ;;
          [Nn]* ) break
                  ;;
           * ) echo "Please answer y or n"
               ;;
        esac
      done
    fi # end gui/cmd line confirm
fi # end restart
