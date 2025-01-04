#!/bin/bash
# This script is used on the VM VirtualAGC-VM64 to update the local Virtual AGC
# by getting the latest version of the source tree and building it.  However,
# it can potentially perform other tasks as well.

LOG_FILE=/home/virtualagc/Desktop/Update.log

echo The process of updating Virtual AGC should be harmless and easy,
echo although it will probably take several minutes. But if you have  
echo made changes yourself to the source-code tree, the update process 
echo will discard your changes.  If this is your situation, you might want 
echo to copy your changed files out of the source tree before proceeding.
echo ""
read -p "Are you sure you're ready to proceed at this time (y/N)? " -n 1 -r
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
        echo ""
        date > $LOG_FILE
        cd ~/git/virtualagc 2>&1 >> $LOG_FILE
        git stash 2>&1 >> $LOG_FILE
        git stash drop 2>&1 >> $LOG_FILE
        git pull 2>&1 >> $LOG_FILE
        
        # The build stuff is separated out into an independent script, so
        # as to make sure that changes to the build procedure are captured
        # without a 2nd git pull.
        time ./rebuildVirtualAGC.sh 2>&1 | tee -a $LOG_FILE
        
        echo "Terminated.  Hit ENTER key or close this window."
        date >> $LOG_FILE
        read
fi

