#!/bin/bash
echo ""
echo "Running: test.sh"
# by Kevin Saruwatari, 27-Mar-2015
# free to use with no warranty

# abort on error 
set -e

kill -9 `ps aux | grep chrom | grep -v grep | awk '{print $2}'`

echo ""
echo "Exiting: test.sh"
