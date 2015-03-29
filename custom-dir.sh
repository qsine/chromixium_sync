#!/bin/bash
echo ""
echo "Running: custom-dir.sh"
# by Kevin Saruwatari, 27-Mar-2015
# free to use with no warranty
# makes custom directories 
# for use with Qsine installer

# abort on error 
set -e

# check argument 1
if [ ! "$1" ]; then
  echo "No REF_NAME specified. Aborting"
  echo "  Type custom-dir.sh --help for info"
  exit 1
else
  if [ "$1" = '--help' -o "$1" = '-h' ]; then
    echo ""
    echo "Usage: custom-dir.sh "'"ref_path_name" "path_to_make" "owner"'
    echo "  Where:"
    echo "         ref_path_name: human readable for feedback"
    echo "         path_to_make: the directory to create, is recursive"
    echo "         owner: user to set as owner"
    echo ""
    exit 1
  fi
fi
# check argument 2
if [ ! "$2" ]; then
  echo "No MAKE_PATH specified. Aborting"
  exit 1
fi
# check argument 3
if [ ! "$3" ]; then
  echo "No USER_SET specified. Aborting"
  exit 1
fi

# create directory if it does not exist
REF_NAME="$1"
MAKE_PATH="$2"
USER_SET="$3"

# directory for qsine customization
if [ ! -d "${MAKE_PATH}" ]; then
  echo "-making ${REF_NAME}:${MAKE_PATH}"
  mkdir -p "${MAKE_PATH}"
  chown "${USER_SET}":"${USER_SET}" "${MAKE_PATH}"
else
  echo "  -${REF_NAME}:${MAKE_PATH} already exists"
fi

echo ""
echo "Exiting: custom-dir.sh"
