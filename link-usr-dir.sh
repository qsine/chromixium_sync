#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Running: link-usr-dir.sh"
#  sleep 1
fi

# by Kevin Saruwatari, 06-Apr-2015
# free to use/distribute with no warranty
# for use with Qsine installer pulling files

# abort on error 
set -e

# check argument 1
if [ ! "$1" ]; then
  echo "No REPO_PATH specified. Aborting"
  echo "  Type link-usr-dir.sh --help for info"
  exit 1
else
  if [ "$1" = '--help' -o "$1" = '-h' ]; then
    echo ""
    echo "Usage: link-usr-dir.sh " '"repo_path" "original_path" "permiss"'
    echo "  Where:"
    echo "         repo_path: Google Data directory link points to (source)"
    echo "         original_path: directory that is turned into a link (target)"
    echo "         permiss: permission setting 644, 750, etc."
    echo ""
    exit 1
  fi
fi
# check argument 2
if [ ! "$2" ]; then
  echo "No ORIG_PATH specified. Aborting"
  exit 1
fi
# check argument 3
if [ ! "$3" ]; then
  echo "No PERM_SET specified. Aborting"
  exit 1
fi

REPO_PATH="${1}"
ORIG_PATH="${2}"
PERM_SET="${3}"

# if no REPO_PATH...
if [ ! -d "${REPO_PATH}" ]; then
  echo "# REPO_PATH:${REPO_PATH##*/} not found..."
  sleep 1
  # ...and no original path or already linked, create the repo path
  if [ ! -d "${ORIG_PATH}" -o -h "${ORIG_PATH}" ]; then
    echo "# ...ORIG_PATH:${ORIG_PATH##*/} not found either, faking a repo"
    sleep 1
    . $CHROMIXIUM_SCRIPTS/custom-dir.sh "${REPO_PATH##*/}" "${REPO_PATH}" "$SYNC_USER"
    echo "a file is required for chromixium_sync" >> "${REPO_PATH}"/chrx-readme
    chown  "$SYNC_USER:$SYNC_USER" "${REPO_PATH}"/chrx-readme
    chmod  "664" "${REPO_PATH}"/chrx-readme
  else # ... and there is an original directory, put it to the repo
    echo "# ...ORIG_PATH:${ORIG_PATH##*/} found, syncing to repo"
    sleep 1
    . $CHROMIXIUM_SCRIPTS/sync-as-root.sh "${ORIG_PATH}" "${REPO_PATH}" "${PERM_SET}" "$SYNC_USER"
  fi # original dir
fi # repo dir not exist


echo ""
echo "# repo okay, setup/verify link for ${ORIG_PATH##*/}"
sleep 1
# always set the top directory to 755
chmod 755 $(find "${REPO_PATH}" -type d)
chmod "${PERM_SET}" $(find "${REPO_PATH}" -type f)

# check if directory is already linked
if [ ! -h "${ORIG_PATH}" ]; then
  echo "ORIG_PATH:${ORIG_PATH} not linked"

  # check if original directory still exists
  if [ -d "${ORIG_PATH}" ]; then
    mv "${ORIG_PATH}" "${ORIG_PATH}.old"
    echo "  - ORIG_PATH: backed up to ${ORIG_PATH}.old"
    # call for reboot
    echo "REBOOT REQUIRED" > /tmp/REBOOT_FLAG
  fi

  # create link
  ln -s -f "${REPO_PATH}" "${ORIG_PATH}"
  echo "  - ORIG_PATH:${ORIG_PATH} link created"

else
  # update for repo change
  rm "${ORIG_PATH}"
  ln -s -f "${REPO_PATH}" "${ORIG_PATH}"
  echo "  - ORIG_PATH:${ORIG_PATH} link updated"
fi

echo "LOGOFF REQUIRED" > /tmp/LOGOFF_FLAG

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: link-usr-dir.sh"
#  sleep 1
fi
