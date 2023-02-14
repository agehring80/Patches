#!/bin/bash
####################################################
# Virtual Pool 1.6.7 Patch (Full Install)          #
# - CD check skip & VPD root change to VPOOL path  #
# - Remove nasty 'bypass video driver message'     #
# - Disable or enable opening video                #
####################################################

PTarget=POOL.EXE

if [ ! -f $PTarget.org ]; then
    echo -e "$PTarget.org does not exist.\nCreate it as backup and origin."
    cp -v $PTarget $PTarget.org
else
    echo "Create new patch target from origin."
    cp -fv $PTarget.org $PTarget
fi
echo

OffSet1=0x14D89
echo -e "Skip CD check routine\n(e873 0500 00 -> 90{5})\nBefore 1:"
xxd -seek $OffSet1 -l5 $PTarget.org
printf "%0.s\x90" {1..5} | dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet1))
echo "Changed 1:"
xxd -seek $OffSet1 -l5 $PTarget
echo

OffSet2=0x32937
echo -e "Change the root of VPD path from CD to VPOOL (current) path\n(453а 5c76 7064 5c -> 2e5c 7670 645c 00)\nBefore 2:"
xxd -seek $OffSet2 -l7 $PTarget.org
printf '\x2E\x5C\x76\x70\x64\x5C\x00' | dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet2))
echo "Changed 2:"
xxd -seek $OffSet2 -l7 $PTarget
echo

OffSet3=0x14E1B
echo -e "Remove bypass video driver message\n(e821 0300 00 -> 90{5})\nBefore 3:"
xxd -seek $OffSet3 -l5 $PTarget.org
printf "%0.s\x90" {1..5} | dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet3))
echo "Changed 3:"
xxd -seek $OffSet3 -l5 $PTarget
echo

OffSet4=0x14E25
echo -e "Don't run, or run the opening video\n(bad4 b202 00 -> b00(1 or 0) f8c3 90)\nBefore 4:"
xxd -seek $OffSet4 -l5 $PTarget.org
# If you want to see (enable) the opening video, use the second line...
#printf '\xB0\x01\xF8\xC3\x90' | dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet4))
printf '\xB0\x00\xF8\xC3\x90' | dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet4))
echo "Changed 4:"
xxd -seek $OffSet4 -l5 $PTarget
