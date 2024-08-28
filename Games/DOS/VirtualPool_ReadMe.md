# Virtual Pool Setup

There is a mouse issue in DosBox an VPOOL. If you setup a serial mouse, there is no issue. With DosBox-Staging you can setup a serial mouse. In the full CD version movies causes a crash in DosBox & DosBoxStaging (at the time of writing this).

DosBox-X can run the full version and also supports a serial mouse. But it runs very laggy on slower machines.

With some changes in the config, networking runs very good (Don't be rude and use the Cheat Patch then ;-)).

## Get the stripped version running smoothly.

1. Create the following structure:
- d:\VPOOL
  - DOSBOX-St        (folder with downloaded DosBoxStaging)
  - VPOOL          (folder with VPOOL files from CD and stripped POOL.EXE; create POOL.CFG here)
  - VPOOL.bat
  - VPOOL.conf
---
2. POOL.CFG (in VPOOL folder where the CD files are located) contains:
```
C=2
M=1
F=A
S=B
R=N
A=e000F
B=R1C.B
V=MVESA1H.D
P=ABBABBABH
```
---
3. VPOOL.bat contains:
```
start DOSBOX-St\dosbox -conf VPOOL.conf
```
---
4. VPOOL.conf contains:
```
# This is the configuration file for dosbox-staging (0.81.2).
# This file contains overwritten options for Virtual Pool

[sdl]
fullscreen          = true
output              = texture
texture_renderer    = direct3d

[render]
glshader           = none

[serial]
serial1       = mouse

[autoexec]
# Lines in this section will be run at startup.
mousectl com1 -s 150
mousectl -r 200
mount c ./VPOOL
c:
pool.exe
exit
```
