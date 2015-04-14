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

#CHG_FILES=/opt/chrxsync/chromixium_sync/chrome_apps
#  for f in "$CHG_FILES"/*.desktop; do
#    if [ "$f" != "$CHROMIXIUM_SCRIPTS"/test.sh ]; then
#    OLD_STR='Exec=chromium-browser'
#    NEW_STR='Exec=chromium-browser --disable-gpu'
#    echo "$f"
#    sed -i "s%$OLD_STR%$NEW_STR%g" $f
#    fi
#  done

  SCRIPT_FILE="/home/serveradmin/LocalFiles/Documents/qsine-rdp-sh"
    WIN_VM="cam01"

  echo "# build FreeRDP script"
  sleep 1
  # create script
  echo "#!/bin/bash" > "$SCRIPT_FILE"
  echo "" >> "$SCRIPT_FILE"
  echo 'PASSWD=$(zenity --entry --title="Windows Password" --text="Enter your password:" --hide-text)' >> "$SCRIPT_FILE"
  echo "xfreerdp /v:$WIN_VM /u:qsine /multimon /bpp:24 +fonts /audio +clipboard /a:drive,$(hostname),/media/$SYNC_USER /p:"'$PASSWD' >> "$SCRIPT_FILE"
  echo "" >> "$SCRIPT_FILE"
  # set permissions
  chown "$SYNC_USER:$SYNC_USER" "$SCRIPT_FILE"
  chmod 750 "$SCRIPT_FILE"

 

#if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: test.sh"
#  sleep 1
#fi
