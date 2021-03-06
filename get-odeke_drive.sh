#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Running: get-odeke_drive.sh"
  sleep 1
fi

# by Kevin Saruwatari, 02-Apr-2015
# free to use/distribute with no warranty
# for use with Qsine installer

# abort on error 
set -e

# check argument 1
if [ ! "$1" ]; then
  echo "No REF_NAME specified. Aborting"
  echo "  Type get-odeke_drive.sh --help for info"
  exit 1
else
  if [ "$1" = '--help' -o "$1" = '-h' ]; then
    echo ""
    echo "Usage: get-odeke_drive.sh "'"ref_path_name"'" "'"path_to_GO_directory"'" "'"home_directory"'" "
    echo "  Where:"
    echo "         ref_path_name: human readable for feedback"
    echo "         path_to_GO_directory: is GOPATH or path to GO install"
    echo "         home_directory: is location of .bashrc file to modify"
    echo ""
    exit 1
  fi
fi
# check argument 2
if [ ! "$2" ]; then
  echo "No GOPATH_DIR specified. Aborting"
  exit 1
fi
# check argument 3
if [ ! "$3" ]; then
  echo "No BASH_HOME_DIR specified. Aborting"
  exit 1
fi

REF_NAME="$1"
GOPATH_DIR="$2"
BASH_HOME_PATH="$3"

# update/upgrade apt
. $CHROMIXIUM_SCRIPTS/upgrade-apt.sh

# std apt-get packages:
for i in \
    "mercurial" \
    "golang" \
; do
  # no error abort
  set +e
  PKG_NAME="$i"
  echo "Checking for $PKG_NAME"
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
  # abort on error 
  set -e
  if [ "" == "$PKG_OK" ]; then
    echo "Not installed, setting up $PKG_NAME."
    apt-get -y install $PKG_NAME
  fi

done

# create directory if it does not exist
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "${REF_NAME}" "${GOPATH_DIR}" "root"

if [ ! "$(ls -A ${GOPATH_DIR})" ]; then
  echo "ODEKE_DRIVE:${GOPATH_DIR} is empty, getting go files..."

  # setup GO home and PATH to binaries
  export GOPATH="${GOPATH_DIR}"
  export PATH="$PATH:$GOPATH/bin"

  # add GOPATH and put binaries in PATH of .bashrc
  # so scripts can use the drive command
  echo "" >> ${BASH_HOME_PATH}/.bashrc
  echo "# added by Kev for ODEKE drive commands using GO" >> ${BASH_HOME_PATH}/.bashrc
  echo GOPATH=${GOPATH_DIR}>> ${BASH_HOME_PATH}/.bashrc
  echo PATH='$PATH':'$GOPATH'/bin >> ${BASH_HOME_PATH}/.bashrc

  go get -u github.com/odeke-em/drive/cmd/drive
else
  echo "    -ODEKE_DRIVE:${GOPATH_DIR} already installed"
fi

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: get-odeke_drive.sh"
  sleep 1
fi
