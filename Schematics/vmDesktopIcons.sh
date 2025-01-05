#!/bin/bash
# This script generates desktop icons for the VirtualAGC-VM64 virtual machine.
# There's one icon per drawing number in Schematics/.  Each icon loads the 
# associated drawing's top-level page into the KiCad schematic editor.

home=/home/virtualagc
desktop="$home/Desktop/Electrical Schematics"
schematics=$home/git/virtualagc-schematics/Schematics
cd $schematics
if [[ ! -d "$desktop" ]]
then
        mkdir "$desktop"
fi
for f in [0-9]*
do
        if [[ -d "$f" ]]
        then
                echo '[Desktop Entry'] >temp.desktop
                echo "Name=$f Schematics Viewer" >> temp.desktop
                echo "GenericName=" >> temp.desktop
                echo "Comment=" >> temp.desktop
                echo "Exec=eeschema $schematics/$f/module.sch" >> temp.desktop
                echo "Type=Application" >> temp.desktop
                echo "Icon=eeschema" >> temp.desktop
                echo "Terminal=false" >> temp.desktop
                chmod +x temp.desktop
                mv temp.desktop "$desktop"/$f.desktop
                gio set "$desktop"/$f.desktop "metadata::trusted" yes
        fi
done
