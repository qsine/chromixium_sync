#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Running: create-google_data.sh"
  sleep 1
fi

# by Kevin Saruwatari, 27-Mar-2015
# free to use/distribute with no warranty
# for use with Qsine installer
# call with "." to inherit environment variables from parent

# google data is the buffer to push/pull files and directories to/from google drive

# abort on error 
set -e

# check argument 1
if [ ! "$1" ]; then
  echo "No REF_NAME specified. Aborting"
  echo "  Type create-google_data.sh --help for info"
  exit 1
else
  if [ "$1" = '--help' -o "$1" = '-h' ]; then
    echo ""
    echo "Usage: create-google.sh "'"ref_path_name"'" "'"path_to_gdata"'" "'"go_path"'" "
    echo "  Where:"
    echo "         ref_path_name: human readable for feedback"
    echo "         path_to_gdata: the directory to hold Google Data, is recursive"
    echo "         go_path: the directory where GO is installed"
    echo ""
    exit 1
  fi
fi
# check argument 2
if [ ! "$2" ]; then
  echo "No GDATA_PATH specified. Aborting"
  exit 1
fi
# check argument 3
if [ ! "$3" ]; then
  echo "No GOPATH_DIR specified. Aborting"
  exit 1
fi

REF_NAME="$1"
GDATA_PATH="$2"
GOPATH_DIR="$3"

# check if ODEKE utilities are installed
if [ ! "$(ls -A ${GOPATH_DIR})" ]; then
  echo "no valid GOPATH found..."
  echo "  - run get-odeke_drive.sh before proceeding"
  exit 1
else
  echo "    -valid GOPATH found assuming ODEKE_DRIVE is already installed"
fi

# create directory if it does not exist
. $CHROMIXIUM_SCRIPTS/custom-dir.sh "${REF_NAME}" "${GDATA_PATH}" "$SYNC_USER"

# make sure GOPATH variables are found
if [[ $GOPATH != ${GOPATH_DIR} ]]; then
  export GOPATH="${GOPATH_DIR}"
fi
if [[ $PATH != *"$GOPATH/bin"* ]]; then
  export PATH="$PATH:$GOPATH/bin"
fi

# initialize if it is empty
if [ ! "$(ls -A ${GDATA_PATH})" ]; then
  echo "${REF_NAME}:${GDATA_PATH} is empty, initializing..."
  drive init "${GDATA_PATH}"
else
  echo "    -${REF_NAME}:${GDATA_PATH} already initialized"
fi


if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: create-google_data.sh"
  sleep 1
fi

