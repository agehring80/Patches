#!/bin/bash
######################################################
# SimCity 2000 - Special Edition Windows Patch       #
# You must be owner of the pruduct ! Do not steal !  #
# Created by CrazyGerry (agehring80)                 #
# - Load-Save Game Dialog Crash Fix from alekasm     #
#   (https://github.com/alekasm/SC2000X)             #
# - Movies in SimCity2000 path instead of the CD-ROM #
#   (Copy all files (movies) from CD-Rom DATA folder #
#     to SimCity2000 Folder\MOVIES)                  #
# - Hint to adjust the registry at startup           #
######################################################

md5=($(md5sum SIMCITY.EXE))
if [ $md5 = "f1ad828513d75004345e3324b3d97e46" ]; then
    echo "1. Fix Dialog Crash (OpenFileNameA)"
    # The 14th parameter (Flags) of the structure OpenFileNameA contains enable flags for OFN_EXPLORER & OFN_ENABLEHOOK.
    # This causes null reference exception and SimCity2000 crashes. 
    # https://learn.microsoft.com/en-us/windows/win32/api/commdlg/ns-commdlg-openfilenamea
    # alekasm fixed it with a 3 bytes patch.
    printf '\x20' | dd conv=notrunc of=SIMCITY.EXE bs=1 seek=$((0x9F8FA))
    printf '\xEB\xEB' | dd conv=notrunc of=SIMCITY.EXE bs=1 seek=$((0x9F959))

    echo "2. Change hint to adjust the registry."
    printf '.,\xD,\xA,F,i,x, ,p,a,t,h,s, ,i,n, ,S,E,T,U,P,.,R,E,G, ,&, ,i,m,p,o,r,t, ,S,E,T,U,P,.,R,E,G,.,' \
    | sed 's/,/\x0/g' | dd conv=notrunc of=SIMCITY.EXE bs=1 seek=$((0x12E3C2))

    echo "3. Change movies folder name to MOVIES."
    printf 'MOVIES\' | dd conv=notrunc of=SIMCITY.EXE bs=1 seek=$((0xDDC78))

    echo "4a. Take the SimCity2000 HOME folder from the regitry as parent for MOVIES"
    printf 'HOME\x0\x0\x0' | dd conv=notrunc of=SIMCITY.EXE bs=1 seek=$((0xDDC80))
    echo "4b. Change the variable pointers from the CD-ROM path to the variable with the home folder"
    printf '\xD8' | dd conv=notrunc of=SIMCITY.EXE bs=1 seek=$((0x89CA4))
    printf '\xD8' | dd conv=notrunc of=SIMCITY.EXE bs=1 seek=$((0x89CAF))

    echo "5. Disable 6 CD-ROM path checks (needed in Win98 or Wine, >= WinXP would work without this)"
    for Offset in 0x5599 0x55AA 0x55BD 0x8A748 0x8A75B 0x8A764
    do
        printf '\x90\x90' | dd conv=notrunc of=SIMCITY.EXE bs=1 seek=$(($Offset))
    done
else
    echo "MD5 mismatch. Exit."
fi
