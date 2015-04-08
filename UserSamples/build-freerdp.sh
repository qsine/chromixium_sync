#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# $SYNC_USER Running: build-freerdp.sh"
  sleep 2
fi

# by Kevin Saruwatari, 06-Apr-2015
# free to use with no warranty
# install FreeRDP from source
# for all qsine machines
# place in GOOGLE_DATA/CHRMX_HFILES/.installs and
# Qsine installer will automatically run it
# the name must be in the format build-*

# abort on error 
set -e

REF_NAME="GITPULL_DIR"
GITPULL_DIR="/usr/src/"

# first install must be in a command window
#if [ "$RUN_MODE" = "gui" -a ! "$(find ${GITPULL_DIR} -name FreeRDP)" ]; then
#  zenity --warning --text="This script must install thru a terminal with the --update flag"
#  exit
#fi

# update/upgrade apt
. $CHROMIXIUM_SCRIPTS/upgrade-apt.sh

# make sure ant rdp packages are gone:

REMOVED_PKGS=0

for i in \
    "freerdp-x11" \
    "remmina" \
    "remmina-common" \
    "remmina-plugin-rdp" \
    "remmina-plugin-vnc" \
    "remmina-plugin-gnome" \
    "remmina-plugin-nx" \
    "remmina-plugin-telepathy" \
    "remmina-plugin-xdmcp" \
; do
  # no error abort
  set +e
  PKG_NAME="$i"
  echo "# Checking for $PKG_NAME"
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
  # abort on error 
  set -e
  if [ "install ok installed" == "$PKG_OK" ]; then
    REMOVED_PKGS=$REMOVED_PKGS+1
    echo "# Removing $PKG_NAME."
    apt-get -y remove $PKG_NAME
  fi
  sleep 1
done

# apt-get build packages:
for i in \
    "build-essential" \
    "git-core" \
    "cmake" \
    "libssl-dev" \
    "libx11-dev" \
    "libxext-dev" \
    "libxinerama-dev" \
    "libxcursor-dev" \
    "libxdamage-dev" \
    "libxv-dev" \
    "libxkbfile-dev" \
    "libasound2-dev" \
    "libcups2-dev" \
    "libxml2" \
    "libxml2-dev" \
    "libxrandr-dev" \
    "libgstreamer0.10-dev" \
    "libgstreamer-plugins-base0.10-dev" \
    "libxi-dev" \
    "libavutil-dev" \
    "libavcodec-dev" \
    "libxtst-dev" \
    "libgtk-3-dev" \
    "libgcrypt11-dev" \
    "libssh-dev" \
    "libpulse-dev" \
    "libvte-2.90-dev" \
    "libxkbfile-dev" \
    "libfreerdp-dev" \
    "libtelepathy-glib-dev" \
    "libjpeg-dev" \
    "libgnutls-dev" \
    "libgnome-keyring-dev" \
    "libavahi-ui-gtk3-dev" \
    "libvncserver-dev" \
    "libappindicator3-dev" \
    "intltool" \
; do
  # no error abort
  set +e
  PKG_NAME="$i"
  echo "# Checking for $PKG_NAME"
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
  # abort on error 
  set -e
  if [ "" == "$PKG_OK" ]; then
    echo "# Setting up $PKG_NAME."
    aptitude -y install $PKG_NAME
  fi

done

# create directory if it does not exist
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "${REF_NAME}" "${GITPULL_DIR}" "root"

# build and install FreeRDP
if [ ! "$(find ${GITPULL_DIR} -name FreeRDP)" ]; then
  echo "# FREERDP_SRC:${GITPULL_DIR}/FreeRDP is empty, git clone files..."
  sleep 1
  cd "${GITPULL_DIR}"
  echo "# Changed to:$(dirname "$(readlink -f "$0")")"
  sleep 1
  echo "# Cloning Git..."
  git clone https://github.com/FreeRDP/FreeRDP.git

  cd FreeRDP
  echo "# Changed to:$(dirname "$(readlink -f "$0")")"
  sleep 1
  echo "# Compiling FreeRDP, please be patient"
  cmake -DCMAKE_BUILD_TYPE=Debug -DWITH_SSE2=ON -DWITH_CUPS=on -DWITH_WAYLAND=off -DWITH_PULSE=on -DCMAKE_INSTALL_PREFIX:PATH=/opt/remmina_devel/freerdp .
  make
  echo "# Installing FreeRDP"
  make install
  echo "# Configure FreeRDP"
  echo /opt/remmina_devel/freerdp/lib/i386-linux-gnu/ | tee /etc/ld.so.conf.d/freerdp_devel.conf > /dev/null
  ldconfig
  ln -s /opt/remmina_devel/freerdp/bin/xfreerdp /usr/local/bin/
else
  echo "#    -FREERDP_SRC:${GITPULL_DIR} already cloned, updating..."
  cd "${GITPULL_DIR}/FreeRDP"
  echo "# Changed to:$(dirname "$(readlink -f "$0")")"
  echo "# Updating FreeRDP source"
  git remote update
  echo "# Recompiling FreeRDP, please be patient"
  make
  echo "# Reinstalling FreeRDP"
  make install
fi

# build the .desktop in build-qsine_shortcuts.sh

# must change back to scripts directory
cd "$CHROMIXIUM_SCRIPTS"
echo "Changed to:$(dirname "$(readlink -f "$0")")"

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# $SYNC_USER Exiting: build-freerdp.sh"
  sleep 1
fi
