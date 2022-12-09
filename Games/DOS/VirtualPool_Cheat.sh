#!/bin/bash
#####################################################
# Virtual Pool 1.6.7 Patch (Cheat)                  #
# - Toggle the Tracking Key (T)                     #
#   Usually T key is disabled in network games      #
#   and computer games                              #
#   This patch toggles the cheat on & off           #
#####################################################

OffSet=0x178D2
CurrentVal=$(xxd -p -seek $OffSet -l7 POOL.EXE)
echo "The current value is: "$CurrentVal
if [ "$CurrentVal" = "833df499020003" ]; then
    echo "Cheat is inactive --> enable it."
    printf "\xeb\x10\x90\x90\x90\x90\x90" | dd conv=notrunc of=POOL.EXE bs=1 seek=$(($OffSet))
    echo -n "Changed: "
    xxd -seek $OffSet -l7 POOL.EXE
elif [ "$CurrentVal" = "eb109090909090" ]; then
    echo "Cheat is active --> disable it."
    printf "\x83\x3d\xf4\x99\x02\x00\x03" | dd conv=notrunc of=POOL.EXE bs=1 seek=$(($OffSet))
    echo -n "Changed: "
    xxd -seek $OffSet -l7 POOL.EXE
else
    echo "Something went wrong --> do nothing."
fi
