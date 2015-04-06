#!/bin/bash

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Running: sync-as-root.sh"
#  sleep 1
fi

# by Kevin Saruwatari, 06-Apr-2015
# free to use/distribute with no warranty
# for use with Qsine installer push/pull files

# abort on error 
set -e

# check argument 1
if [ ! "$1" ]; then
  echo "No SOURCE specified. Aborting"
  echo "  Type sync-root-dir.sh --help for info"
  exit 1
else
  if [ "$1" = '--help' -o "$1" = '-h' ]; then
    echo ""
    echo "Usage: sync-usr-dir.sh " '"source_path" "target_path" "permiss"'
    echo "  Where:"
    echo "         source_path: source directory to send"
    echo "         target_path: target directory receiving files"
    echo "         permiss: permission setting 644, 750, etc."
    echo "         user: user to own the files (send $SYNC_USER)"
    echo ""
    exit 1
  fi
fi
# check argument 2
if [ ! "$2" ]; then
  echo "No TARGET specified. Aborting"
  exit 1
fi
# check argument 3
if [ ! "$3" ]; then
  echo "No PERM_SET specified. Aborting"
  exit 1
fi
# check argument 4
if [ ! "$4" ]; then
  echo "No USER_SET specified. Aborting"
  exit 1
fi

SOURCE="${1}"
TARGET="${2}"
PERM_SET="${3}"
USER_SET="${4}"
EXCL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""

# check if source is a link
if [ ! -h "${SOURCE}" ]; then
  # not a link, check if source is a directory
  if [ -d "${SOURCE}" ]; then
    echo "# ${SOURCE##*/} exists, syncing data to ${TARGET##*/}"
    sleep 1
    if [ "${RUN_MODE}" = "gui" ]; then
      rsync -a --links --delete --exclude-from "$EXCL_DIR/sync-excludes" \
        "${SOURCE}"/ "${TARGET}"/
    else
      rsync -aP --links --delete --exclude-from "$EXCL_DIR/sync-excludes" \
        "${SOURCE}"/ "${TARGET}"/
    fi
    # always set the top directory to 755
    chmod 755 $(find "${TARGET}" -type d)
    # make sure a file exists
    if [ "$(ls -A ${TARGET})" ]; then
      chmod "${PERM_SET}" $(find "${TARGET}" -type f)
    fi
    echo "  - dir sync complete"
    chown "${USER_SET}":"${USER_SET}" -R "${TARGET}"
  # check if source is a file
  elif [ -f "${SOURCE}" ]; then
    echo "# ${SOURCE##*/} exists, syncing data to ${TARGET##*/}"
    sleep 1
    if [ "${RUN_MODE}" = "gui" ]; then
      rsync -a --links --delete --exclude-from "$EXCL_DIR/sync-excludes" \
        "${SOURCE}" "${TARGET}"
    else
      rsync -aP --links --delete --exclude-from "$EXCL_DIR/sync-excludes" \
        "${SOURCE}" "${TARGET}"
    fi
    chown "${USER_SET}":"${USER_SET}" "${TARGET}"
    # always set the top directory to 755
    chmod "${PERM_SET}" $(find "${TARGET}" -type f)
    echo "  - file sync complete"
  else
    # if not exist in stock install, create it 
    if [ ! -d "${SOURCE}" ]; then
      . $CHROMIXIUM_SCRIPTS/custom-dir.sh "${SOURCE##*/}" "${SOURCE}" "$USER_SET"
      echo "a file is required for chromixium_sync" >> "${SOURCE}"/chrx-readme
      chown  "$USER_SET:$USER_SET" "${SOURCE}"/chrx-readme
      chmod  "644" "${SOURCE}"/chrx-readme
      if [ "${RUN_MODE}" = "gui" ]; then
        rsync -a --links --delete --exclude-from "$EXCL_DIR/sync-excludes" \
          "${SOURCE}"/ "${TARGET}"/
      else
        rsync -aP --links --delete --exclude-from "$EXCL_DIR/sync-excludes" \
          "${SOURCE}"/ "${TARGET}"/
      fi # gui/cmd
    fi # dir not exist
  fi
# check if source link is valid
elif [ -e "${SOURCE}" ]; then
  echo  "# ${SOURCE##*/} already linked, not synching"
  sleep 1
else
  echo  "# ${SOURCE} link is broken, exiting."
  sleep 2
  exit 1
fi

sleep 0.5

if [ $DIAG_MSG = 1 ]; then
  echo ""
  echo "# Exiting: sync-as-root.sh"
#  sleep 1
fi
