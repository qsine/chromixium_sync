# chromixium_sync
Sync Chromixium user account to Google Drive

#----------------------------------------------
29-Mar-2015: pre-Alpha test only if you are brave!  Make an image of your system with CloneZilla first.

Seems to be working okay on fresh install of Chromixium (root priveledges required):
 - cd /tmp
 - wget https://github.com/qsine/chromixium_sync/archive/master.zip
 - unzip master.zip
 - cd chromixium_sync-master/
 - sudo ./chromixium_sync.sh --install

When the buffer is initialized, it will give a link to Google to get permission to access Drive.  
 - right click the link and open it.
 - put in your user name and password and it will give you and access code.
 - copy the code, paste it to the terminal and the script should complete.

Access to Google Drive is done via this: https://github.com/odeke-em/drive
It is still actively being developed and may break (it did yesterday for awhile).  But it seems like a very good project.

Once the script is installed you can access it by right clicking the desktop and navigate to Applications/System/Chromixium Sync

The file structure gets modified by these scripts:
 - the paths are all in chromixium_sync.sh
 - look at pull-from-drive.sh and push-to-drive.sh to see the changes

#----------------------------------------------
27-Mar-2015: pre-Alpha test only if you are brave!

The scripts seem to be working but I highly recommend making an image of your system with CloneZilla first.

#----------------------------------------------
20-Mar-2015: pre-Alpha Don't test!

The scripts are working from /tmp directory on fresh installs of Chromixium to multiple repo's on the drive.  I am putting them on Git today to test pulling and installing.

#----------------------------------------------
13-Mar-2015: Not useful to anyone yet.

This is just me hoping to sync my settings on Google Drive with scripts.

Created Git repo
