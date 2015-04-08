# chromixium_sync
Sync Chromixium user account settings to Google Drive

08-Apr-2015: pre-Alpha test only if you are brave!  Make an image of your system with CloneZilla first.

Seems to be working okay on fresh install of Chromixium (root privileges required):
 - cd /tmp
 - wget https://github.com/qsine/chromixium_sync/archive/master.zip
 - unzip master.zip
 - cd chromixium_sync-master/
 - sudo ./chromixium_sync.sh --install
Which will by default use the logged in user name for the repo name and the user files to sync.

To specify a custom repo name:
 - sudo ./chromixium_sync.sh --install repo_name

To specify another user (must exist on the machine):
 - sudo ./chromixium_sync.sh --install repo_name user_name
  * I have not tested push/pull into other users yet.

Note that installing with custom names will create a shortcut with the custom names as the default.  Edit the chromixium_sync.desktop file in ~/.local/share/applications to change names.

When the local buffer is initialized, it will give a link to Google to get permission to access Drive.  
 - right click the link and open it.
 - put in your user name and password and it will give you an access code.
 - copy the code, paste it to the terminal and the script should complete.

Access to Google Drive is done via this: https://github.com/odeke-em/drive
It is still actively being developed and may break (it has while I've been developing).  But it seems like a very good project.

Once the installation is complete, you can access the script by:
 - right clicking the desktop
 - navigate to Applications/System
 - click on Chromixium Sync (runs in GUI mode)

or (and this is recommended for early days to get more troubleshooting feedback):
 - open a terminal
 - type the command as explained below

Running the first time ever, you have to use "push" to create a repository on your Google Drive.  If you have pushed earlier and want to clone your settings after a machine reinstall, then use "pull" before pushing.

Note that if you have 2 machines with different user names, use a single repo name to make the machines the same.  Be careful because when each machine writes to the repo, it will potentially clobber the data from the other.  First, get on the machine that is the way you want it and push. After that get on the machine you want to modify and pull.

In GUI mode a dialog prompts for repository name and user name.  Both default to logged in user name un).  After that you can:
 - update
 - push
 - pull
 - push_pull
 - ask4chrome (if it not installed)

After a machine has pushed, you can rename it in the Google Drive with a "-" to keep it safe or push again with another repo name.  Repo names are tested to regex standard so anything other than letters and numbers are disallowed.  To pull the protected repo, you need to remove the "-" from the name in the Google Drive.

The scripts are in /opt/chrxsync/chromixium_sync.  To run from the command line, open a terminal then:

 - sudo bash /opt/chrxsync/chromixium_sync/chromixium_sync.sh config_code [repo_name] [user_name]

Where:
 - config_code: controls what the installer does
   . --install: install std programs & setup push/pull RUN FIRST!
   . --update: updates existing or installs new
   . --push: push machine config data to Google Drive
   . --pull: pull config data from Google Drive to machine
   . --push_pull: push then pull config (Developer Mode)
   . --gui: select parameters via dialogs
   . --ask4chrome: updates with switch-to-chrome option (if it is not already installed)
 - repo_name: optional - name of the repo to push/pull
 - user_name: optional - Linux user name, must have valid /home directory

The file structure gets modified by these scripts:
 - the paths are all in chromixium_sync.sh
 - look at remap-chrome_apps.sh, pull-from-drive.sh and push-to-drive.sh to see the changes

In the spirit of ChromeOS most data should be saved in the cloud or on a server or be streamed from a server.  Users should not try to push/pull large amounts of their own data (movies, music, etc) with this utility.  Not only will it be slow but Google Drive will impose limits.  Hence:
 - user working directories are remapped to LocalFiles which do not get pushed/pulled
 - Desktop get linked to the repo and user can put files they want pushed/pulled into here.

The scripts will find and run user scripts in hidden directory CHRMX_HFILES/.installs (Desktop/.installs) named get-* or build-*. These files can be used to install from repos, build from source, tweak changes if the repo is used to sync more than one machine, etc.  Desktop gets pushed/pulled and so after a pull, the script recommends running an update which will run any scripts you keep in there.

