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
 - put in your user name and password and it will give you an access code.
 - copy the code, paste it to the terminal and the script should complete.

Access to Google Drive is done via this: https://github.com/odeke-em/drive
It is still actively being developed and may break (it did yesterday for awhile).  But it seems like a very good project.

Once the script is installed you can access it by right clicking the desktop and navigate to Applications/System/Chromixium Sync.  This will give a GUI interface and you can set the repository name and users name.  After that you can:
 - update
 - push
 - pull
 - push_pull

Running the very first time, you have to push to create a repository on your Google Drive. 

If you have pushed from another machine and want to clone your settings, then select pull.

Note that if you have 2 machines with different user names, you want to use a single repo name to make the machines the same.  Be careful because when each machine writes to the repo, it will potentially clobber the data.  First, get on the machine that is the way you want it and push. After that get on the machine you want to sync and pull.

After a machine has pushed, you can rename it in the Google Drive with a "-" to keep it safe or push again with another repo name.  Repo names are tested to regex standard so anything other than letters and numbers are disallowed.  To pull the protected repo, you need to remove the "-" from the name in the Google Drive.

The scripts are in /opt/chrxsync/chromixium_sync.  To run from the command line, open a terminal then:

 - sudo bash /opt/chrxsync/chromixium_sync/chromixium_sync.sh config_code [repo_name] [user_name]

Where:
 - config_code: controls what the installer does
          --install: install std programs & setup push/pull RUN FIRST!
          --update: updates existing or installs new
          --push: push machine config data to Google Drive
          --pull: pull config data from Google Drive to machine
          --push_pull: push then pull config (Developer Mode)
          --gui: select parameters via dialogs
 - repo_name: name of the repo to push/pull
 - user_name: Linux user name, must have valid /home directory

The file structure gets modified by these scripts:
 - the paths are all in chromixium_sync.sh
 - look at remap-chrome_apps.sh, pull-from-drive.sh and push-to-drive.sh to see the changes

#----------------------------------------------
29-Mar-2015: pre-Alpha test only if you are brave!  Make an image of your system with CloneZilla first.

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
