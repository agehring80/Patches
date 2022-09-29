#!/bin/bash
#####################################################
# Virtual Pool 1.6.7 Patch (Strip it)               #
# You must be owner of the pruduct ! Do not steal ! #
# Created by CrazyGerry (agehring80)                #
# - Remove CD Check, Movies and Main Menu           #
# - Remove nasty 'bypass video driver message'      #
# - Adjust Exit textes                              #
#####################################################

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
echo -en "Replace complete CD check routine and set a flag to run ingame mode\n(e873 0500 000f 82b7 0000 00 -> c605 07b0 0200 2190 9090 90)\nBefore 1: "
xxd -seek $OffSet1 -l11 $PTarget.org
printf "\xC6\x05\x07\xB0\x02\x00\x21\x90\x90\x90\x90" \
| dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet1))
echo -n "Changed 1: "
xxd -seek $OffSet1 -l11 $PTarget
echo

OffSet2=0x14E1B
echo -en "Remove bypass video driver message\n(e821 0300 00 -> 90{5})\nBefore 2: "
xxd -seek $OffSet2 -l5 $PTarget.org
printf "%0.s\x90" {1..5} \
| dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet2))
echo -n "Changed 2: "
xxd -seek $OffSet2 -l5 $PTarget
echo

OffSet3=0x14E25
echo -en "Don't run the opening video\n(bad4 b202 00 -> b001 f8c3 90)\nBefore 3: "
xxd -seek $OffSet3 -l5 $PTarget.org
printf '\xB0\x01\xF8\xC3\x90' \
| dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet3))
echo -n "Changed 3: "
xxd -seek $OffSet3 -l5 $PTarget
echo

OffSet4=0x1837C
echo -en "Remove Main Menu relevant code, check flag (from above), set flag to exit game\n(8b3d d2b7 02 ??{193} 0200 3d80 8744 0472 2ac6 054c 4102 0001\n->  e8f2 3200 00 90{193} 803d 07b0 0200 2175 2ac6 0507 b002 002e)\nBefore 4:\n"
xxd -seek $OffSet4 -l214 $PTarget.org
(printf "\xe8\xf2\x32\x00\x00" && printf "%0.s\x90" {1..193} && printf "\x80\x3d\x07\xb0\x02\x00\x21\x75\x2a\xc6\x05\x07\xb0\x02\x00\x2e") \
| dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet4))
echo -en "Changed 4:\n"
xxd -seek $OffSet4 -l214 $PTarget
echo

OffSet5=0x1847A
echo -en "Do the Exit jump, when ingame is left\n(7411 -> eb1f)\nBefore 5: "
xxd -seek $OffSet5 -l2 $PTarget.org
printf "\xEB\x1F" \
| dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet5))
echo -n "Changed 5: "
xxd -seek $OffSet5 -l2 $PTarget
echo

OffSet6=0x44A08
echo -en "Text Change: From 'Main Menu' to 'Exit Game'\n(4d61 696e 204d 656e 75 -> 4578 6974 2047 616d 65)\nBefore 6: "
xxd -seek $OffSet6 -l9 $PTarget.org
printf "\x45\x78\x69\x74\x20\x47\x61\x6d\x65" \
| dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet6))
echo -n "Changed 6: "
xxd -seek $OffSet6 -l9 $PTarget
echo

OffSet7=0x44A37
echo -en "Text Change: From 'to Main Menu' to 'Virtual Pool'\n(746f 204d 6169 6e20 4d65 6e75 -> 5669 7274 7561 6c20 506f 6f6c)\nBefore 7: "
xxd -seek $OffSet7 -l12 $PTarget.org
printf "\x56\x69\x72\x74\x75\x61\x6c\x20\x50\x6f\x6f\x6c" \
| dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet7))
echo -n "Changed 7: "
xxd -seek $OffSet7 -l12 $PTarget
