#!/usr/bin/awk -f
# This script is used to make pretty output from "git log --reverse ..." for
# the VM64 update script.

BEGIN { 
        beginning = 0 
        }

/^$/ { 
        beginning = 1 
        }

/^ / { 
        if (beginning == 1) {
                print "-", $0 
        } else {
                print " ", $0
        }
        beginning = 0 
        }
