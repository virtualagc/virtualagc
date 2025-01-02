#!/bin/bash
# This script is used on the VM VirtualAGC-VM64 to update the local Virtual AGC
# by getting the latest version of the source tree and building it.  However,
# it can potentially perform other tasks as well.

read -p "Are you sure (y/N)? " -n 1 -r
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
        cd ~/git/virtualagc
        git stash drop
        git pull
        time make clean install clean
        echo "Terminated.  Hit ENTER key or close this window."
        read
fi

