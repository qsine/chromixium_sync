#!/bin/bash
echo ""
echo "Running: link-usr-dir.sh"
# by Kevin Saruwatari, 01-Apr-2015
# free to use with no warranty
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

echo ""
echo "Setup/verify link for ${ORIG_PATH}"
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

sleep 0.5
echo ""
echo "Exiting: link-usr-dir.sh"
