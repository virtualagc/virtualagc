#!/bin/bash
# This script is used on the VM VirtualAGC-VM64 to update the local Virtual AGC
# by getting the latest version of the source tree and building it.  However,
# it can potentially perform other tasks as well.

LOG_FILE=/home/virtualagc/Desktop/Update.log

echo If you have made local changes yourself to Virtual AGC, the update process 
echo will discard your changes.  If this is your situation, you might want 
echo to copy your changed files out of the source tree before proceeding.
echo ""
read -p "Are you sure you're ready to proceed at this time (y/N)? " -n 1 -r
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
        echo ""
        date > $LOG_FILE
        
        echo Stashing/dropping/pulling schematics branch >> $LOG_FILE
        cd ~/git/virtualagc-schematics 2>&1 >> $LOG_FILE
        git stash 2>&1 >> $LOG_FILE
        git stash drop 2>&1 >> $LOG_FILE
        git pull 2>&1 >> $LOG_FILE
        Schematics/vmDesktopIcons.sh
        
        echo Stashing/dropping master branch >> $LOG_FILE
        cd ~/git/virtualagc 2>&1 >> $LOG_FILE
        git stash 2>&1 >> $LOG_FILE
        git stash drop 2>&1 >> $LOG_FILE
        
        echo =================================================================
        git fetch origin 2>&1 >> $LOG_FILE
        echo Updates to be retrieved from Virtual AGC repository:
        git log --reverse HEAD..origin/master | grep '^ '
        echo =================================================================
        read -p "Proceed with update and rebuild (y/N)? " -n 1 -r
        if [[ "$REPLY" =~ ^[Yy]$ ]]
        then
                echo Pulling master branch >> $LOG_FILE
                cd ~/git/virtualagc
                git pull 2>&1 >> $LOG_FILE
                # The build stuff is separated out into an independent script, so
                # as to make sure that changes to the build procedure are captured
                # without a 2nd git pull.
                cd ~/git/virtualagc 2>&1 >> $LOG_FILE
                time ./rebuildVirtualAGC.sh 2>&1 | tee -a $LOG_FILE
        fi
        
        echo "Terminated.  Hit ENTER key or close this window."
        date >> $LOG_FILE
        read
fi

