;Original python repository: https://github.com/tetration/Simcity3000-HD-patch
;This AHK2 is tested with GOG Version MD5:3f1817c8b543c87afa6de286632372d0
message := "Welcome to Simcity 3000/Simcity 3000 Unlimited Resolution Fix`n`n"
          . "After patching, you will be able to change your game's resolution up to 2560x1440.`n`n"
          . "Warning: Some resolutions might be unstable and thus may make the game crash."
MsgBox(message)
FilePath := "SC3U.exe"
Size := FileGetSize(FilePath)
if !FileExist(FilePath . ".bak")
{
   FileCopy(FilePath, FilePath . ".bak")
}
else
{
   MsgBox("Backup File exists. Probably patched, already.")
   ExitApp()
}
if Size != 1155072
{
   MsgBox("Filesize mismatch.")
   ExitApp()
}

FileObj := FileOpen(FilePath, "rw")
if !FileObj
{
   MsgBox("Failed to open the file.")
   ExitApp()
}

Hex := "C2080090"
Bin := Hex2Bin(Hex)
Offset := 0x7684
FileObj.Seek(Offset)
FileObj.RawWrite(Bin.Ptr, Bin.Size)
Offset := 0x7756
FileObj.Seek(Offset)
FileObj.RawWrite(Bin.Ptr, Bin.Size)
FileObj.Close()
MsgBox("File patching complete!")
ExitApp()

Hex2Bin(Hex)
{
   Bin := Buffer(StrLen(Hex) // 2, 0)
   P := 0
   Loop Parse, Hex
   {
      If (A_Index & 1)
         H := A_LoopField
      Else
         NumPut("UChar", "0x" . H . A_LoopField, Bin, P++)
   }
   Bin.Size := P
   return Bin
}
