#!/bin/bash
#####################################################
# Virtual Pool 1.6.7 Patch (Full Install)           #
# - CD check replaced with VPD data path function   #
# - Remove nasty 'bypass video driver message'      #
# - Disable or enable opening video                 #
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

OffSet1=0x15301
echo -e "Replace complete CD check function with a path extension function\nfor a new data path (ex.: C:\VPOOL\VPD) at 02AED0\nBefore 1:"
xxd -seek $OffSet1 -l52 $PTarget.org
(awk '{printf $2}' | xxd -r -p | dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet1))) << PathExtensionCode
#002B:E194  BE87B70200          mov  esi,0002B787          ; copy address of vpool path to esi (SI = Source Index)      
#002B:E199  BFD0AE0200          mov  edi,0002AED0          ; copy address of new data path to edi (DI = Destination I...)      
#002B:E19E  8A06                mov  al,[esi]              ; char at esi-address to al      
#002B:E1A0  8807                mov  [edi],al              ; al to edi-address content
#002B:E1A2  46                  inc  esi                   ; esi++
#002B:E1A3  47                  inc  edi                   ; edi++
#002B:E1A4  84C0                test al,al                 ; you could also use  cmp al,0  if you prefer that
#002B:E1A6  75F6                jne  0000E19E (-a)         ; repeat the loop if al != 0
#002B:E1A8  4F                  dec  edi                   ; set the pointer back to the 0
#002B:E1A9  807FFF5C            cmp  byte [edi-0001],5C    ; check if the char before 0 is a backslash
#002B:E1AD  7404                je   0000E1B3 ($+4)        ; if so... jump
#002B:E1AF  C6075C              mov  byte [edi],5C         ; otherwise overwrite the 0 with backslash and go on
#002B:E1B2  47                  inc  edi                   ; set the pointer behind the backslash
#002B:E1B3  C60776              mov  byte [edi],76         ; v   add the data path for files (ex: from a CD) to the copied install path 
#002B:E1B6  C6470170            mov  byte [edi+0001],70    ; p
#002B:E1BA  C6470264            mov  byte [edi+0002],64    ; d
#002B:E1BE  C647035C            mov  byte [edi+0003],5C    ; (backslash)
#002B:E1C2  C6470400            mov  byte [edi+0004],00    
#002B:E1C6  F8                  clc
#002B:E1C7  C3                  ret
PathExtensionCode
echo "Changed 1:"
xxd -seek $OffSet1 -l52 $PTarget
echo

OffSet2=0x7C6A
echo -e "Use the new data path address 02AED0 for pictures\n(ca b7 02 -> d0 ae 02)\nBefore 2:"
xxd -seek $OffSet2 -l3 $PTarget.org
printf "\xD0\xAE" \
| dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet2))
echo "Changed 2:"
xxd -seek $OffSet2 -l3 $PTarget
echo

OffSet3=0x195E1
echo -e "Use the new data path address 02AED0 for movies\n(ca b7 02 -> d0 ae 02)\nBefore 3:"
xxd -seek $OffSet3 -l3 $PTarget.org
printf '\xD0\xAE' \
| dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet3))
echo "Changed 3:"
xxd -seek $OffSet3 -l3 $PTarget
echo

OffSet4=0x14E1B
echo -e "Remove bypass video driver message\n(e821 0300 00 -> 90{5})\nBefore 4:"
xxd -seek $OffSet4 -l5 $PTarget.org
printf "%0.s\x90" {1..5} \
| dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet4))
echo "Changed 4:"
xxd -seek $OffSet4 -l5 $PTarget
echo

OffSet5=0x14E25
echo -e "Don't run, or run the opening video\n(bad4 b202 00 -> b00(1 or 0) f8c3 90)\nBefore 5:"
xxd -seek $OffSet5 -l5 $PTarget.org
# If you want to see (enable) the opening video, use the second line...
#printf '\xB0\x01\xF8\xC3\x90' | dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet5))
printf '\xB0\x00\xF8\xC3\x90' | dd conv=notrunc of=$PTarget bs=1 seek=$(($OffSet5))
echo "Changed 5:"
xxd -seek $OffSet5 -l5 $PTarget
