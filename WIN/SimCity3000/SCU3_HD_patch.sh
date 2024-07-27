#!/bin/bash
#######################################################
# Simcity 3000 Unlimited Resolution Patch             #
# Tested with the GOG Version                         #
# bash port by CrazyGerry (agehring80)                #
# Original Python Patch from tetration:               #
# (https://github.com/tetration/Simcity3000-HD-patch) #
#######################################################

echo "Welcome to Simcity 3000/Simcity 3000 Unlimited Resolution Fix"
echo "After patching, you will be able to change your game's resolution up to 2560x1440."
echo "Warning: Some resolutions might be unstable and thus may make the game crash."
echo

md5=($(md5sum SC3U.exe))
if [ $md5 = "3f1817c8b543c87afa6de286632372d0" ]; then
    echo "Patch two offsets"
    printf '\xC2\x08\x00\x90' | dd conv=notrunc of=SC3U.exe bs=1 seek=$((0x7684))
    printf '\xC2\x08\x00\x90' | dd conv=notrunc of=SC3U.exe bs=1 seek=$((0x7756))
else
    echo "MD5 mismatch. Exit."
fi
