#!/bin/bash
# This script is used on the VM VirtualAGC-VM64 to update the local Virtual AGC
# by getting the latest version of the source tree and building it.  However,
# it can potentially perform other tasks as well.

LOG_FILE=/home/virtualagc/Desktop/Update.log

echo If you have made local changes yourself to Virtual AGC, the update process 
echo will discard your changes.  If this is your situation, you might want 
echo to preserve your changed files in some manner.
echo ""
read -p "Are you sure you're ready to proceed at this time (y/N)? " -n 1 -r
echo ""
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
        date > $LOG_FILE
        
        echo Updating schematics ...
        cd ~/git/virtualagc-schematics 2>&1 >> $LOG_FILE
        git stash 2>&1 >> $LOG_FILE
        git stash drop 2>&1 >> $LOG_FILE
        git pull 2>&1 >> $LOG_FILE
        
        Schematics/vmDesktopIcons.sh
        # This identifies 'python' with 'python3' if that isn't already happening.
        if ! which python &>/dev/null
        then 
                echo virtualagc | sudo -S apt -q install python-is-python3
        fi
        
        
        echo Preparing to update source code ...
        cd ~/git/virtualagc 2>&1 >> $LOG_FILE
        git stash 2>&1 >> $LOG_FILE
        git stash drop 2>&1 >> $LOG_FILE
        
        git fetch origin 2>&1 >> $LOG_FILE
        echo =================================================================
        echo List of updates to be retrieved from Virtual AGC repository:
        git log --reverse HEAD..origin/master | ./gitLogCleanup.awk
        echo =================================================================
        read -p "Proceed with update of Virtual AGC source code (y/N)? " -n 1 -r
        echo ""
        if [[ "$REPLY" =~ ^[Yy]$ ]]
        then
                echo Updating source code ...
                cd ~/git/virtualagc
                git pull 2>&1 >> $LOG_FILE
                read -p "Proceed with rebuild of Virtual AGC (y/N)? " -n 1 -r
                echo ""
                if [[ "$REPLY" =~ ^[Yy]$ ]]
                then                
                        echo Rebuilding from source code ...
                        # The build stuff is separated out into an independent script, so
                        # as to make sure that changes to the build procedure are captured
                        # without a 2nd git pull.
                        cd ~/git/virtualagc 2>&1 >> $LOG_FILE
                        time ./rebuildVirtualAGC.sh 2>&1 | tee -a $LOG_FILE
                fi
        fi
        
        echo ""
        echo "End of update process."
        date >> $LOG_FILE
        read -p "Hit any key or close this window: " -n 1
fi

