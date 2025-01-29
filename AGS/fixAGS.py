#!/usr/bin/env python3

import subprocess
import sys
import os

def run_command(cmd):
    """Run a shell command using subprocess, ensuring errors raise exceptions. Prints the command for clarity."""
    print(f"> {cmd}")
    subprocess.run(cmd, check=True, shell=True)

def main():
    # ---------------------------
    # 1) Pre-checks & Setup
    # ---------------------------
    
    # Determine OS + check for hst.imager/hst.imager.exe
    if os.name == "nt":
        # On Windows
        if os.path.exists("hst.imager.exe"):
            IMAGER_CMD = ".\\hst.imager.exe"
        else:
            print("Error: hst.imager.exe is not present in the current directory.")
            sys.exit(1)
        SLASH = "\\"
    else:
        # On Linux/macOS
        if not os.path.exists("hst.imager"):
            print("Error: hst.imager not present in the current directory.")
            sys.exit(1)
        IMAGER_CMD = "./hst.imager"
        SLASH = "/"

    # Check for required files
    for fname in ("Workbench.hdf", "AGS_Drive.hdf", "DeletePremus.script", "pfs3aio"):
        if not os.path.exists(fname):
            print(f"Error: {fname} does not exist in the current directory.")
            sys.exit(1)

    def pjoin(*args):
        """Join path components with the proper slash for this OS."""
        return SLASH.join(args)

    # Helper function to patch a file inside an HDF:
    # 1) Copy from HDF to local
    # 2) Do byte-level replace
    # 3) Copy back
    def patch_file_in_hdf(hdf_path, internal_path, patches):
        """
        :param hdf_path: e.g. "Workbench.hdf"
        :param internal_path: e.g. ["rdb", "dh0", "S", "startup-sequence"]
        :param patches: list of (search_bytes, replace_bytes)
        """
        # Build a string path like "Workbench.hdf\rdb\dh0\S\startup-sequence"
        in_path = pjoin(hdf_path, *internal_path)
        local_filename = internal_path[-1]  # e.g. "startup-sequence"

        # Copy out
        run_command(f'{IMAGER_CMD} fs copy "{in_path}" .')

        # Read+patch locally
        with open(local_filename, "rb") as f:
            data = f.read()
        for (search_bytes, replace_bytes) in patches:
            data = data.replace(search_bytes, replace_bytes)
        with open(local_filename, "wb") as f:
            f.write(data)

        # Copy back in
        # The destination is the folder, minus the final leaf
        out_path = pjoin(hdf_path, *internal_path[:-1])
        run_command(f'{IMAGER_CMD} fs copy "{local_filename}" "{out_path}"')

    # ---------------------------
    # 2) Ask about FS-UAE Patch
    # ---------------------------
    
    answer_fsuae = input("Do you want to patch the Startup Process Fix for FS-UAE? [y/N]: ").strip().lower()
    if answer_fsuae == "y":
        print("\nPatching FS-UAE startup-sequence in Workbench.hdf...\n")

        # The lines to remove for the FS-UAE crash fix:
        fsuae_search = (
            b"If $HW NOT EQ \"Real\"" b"\x0A"
            b" uae-configuration >ENV:Speed cpu_speed" b"\x0A"
            b" If $Speed NOT EQ \"max\"" b"\x0A"
            b"  uae-configuration cycle_exact false blitter_cycle_exact false cpu_speed max" b"\x0A"
            b" endif" b"\x0A"
            b"endif" b"\x0A"
            b"Delete >NIL: ENV:Speed" b"\x0A\x0A"
        )

        # We'll remove them by replacing with empty bytes
        patches = [(fsuae_search, b"")]

        # Patch the "startup-sequence" in Workbench.hdf\rdb\dh0\S
        patch_file_in_hdf("Workbench.hdf", ["rdb", "dh0", "S", "startup-sequence"], patches)

        print("FS-UAE Startup Process Fix patch applied.\n")
    else:
        print("Skipping FS-UAE Startup Process Fix.\n")

    # ------------------------------------
    # 3) Ask about removing Extra & Media
    # ------------------------------------

    print("If you want to remove Extra.hdf and Media.hdf drives to save space, choose 'y'.")
    print("In the AGS menu, there will be some links to non-existing Emulators and Extra Games.")
    print("We will copy DeletePremus.script into AGS_Drive so you can run it to fix the dead links.\n")

    answer_extra = input("Do you want to remove Extra and Media assignments at startup? [y/N]: ").strip().lower()
    if answer_extra == "y":
        print("\nRemoving Extra and Media assignments in AGS-Stuff (Workbench.hdf)...\n")

        # The lines to remove:
        # "Assign Emulators: Extra:Emulators\nAssign ST-00: Media:ST-00\n"
        remove_bytes = (
            b"Assign Emulators: Extra:Emulators" b"\x0A"
            b"Assign ST-00: Media:ST-00" b"\x0A"
        )
        patches = [(remove_bytes, b"")]

        # Patch AGS-Stuff in "Workbench.hdf\rdb\dh0\S\AGS-Stuff"
        patch_file_in_hdf("Workbench.hdf", ["rdb", "dh0", "S", "AGS-Stuff"], patches)

        print("Extra/Media assignments removed.\n")

        # Also copy DeletePremus.script into AGS_Drive:\rdb\dh1
        print("Copying DeletePremus.script to AGS_Drive:")
        ags_dh1 = pjoin("AGS_Drive.hdf", "rdb", "dh1")
        run_command(f'{IMAGER_CMD} fs copy "DeletePremus.script" "{ags_dh1}"')

        print("Done removing Extra/Media assignments.\n")
        print("Run your emulator, ESCape AGS, open a shell in Workbench and run:")
        print("  cd AGS_Drive:")
        print("  execute DeletePremus.script")
        print("  delete DeletePremus.script\n")
    else:
        print("Skipping Extra/Media assignment removal.\n")

    # ---------------------------
    # 4) Ask about shrinking
    # ---------------------------
    
    answer_shrink = input("Do you want to shrink the HDF files? (Takes time, saves a lot of space) [y/N]: ").strip().lower()
    if answer_shrink == "y":
        print("\nShrinking images...\n")
        
        # 1) Rename (move) files to .old
        for hdf_name in ("Workbench.hdf", "AGS_Drive.hdf", "Games.hdf", "Work.hdf"):
            if not os.path.exists(hdf_name):
                print(f"Error: {hdf_name} does not exist in the current directory.")
                sys.exit(1)
            os.rename(hdf_name, hdf_name.replace(".hdf", ".old"))

        # 2) Create (blank) HDF files with desired sizes
        #    then partition and format them
        # ---- Workbench.hdf (0.5 GB, bootable) ----
        run_command(f"{IMAGER_CMD} blank Workbench.hdf 0.5gb")
        run_command(f"{IMAGER_CMD} rdb init Workbench.hdf")
        run_command(f"{IMAGER_CMD} rdb fs add Workbench.hdf pfs3aio PFS3")
        run_command(f'{IMAGER_CMD} rdb part add Workbench.hdf DH0 PFS3 "*" --bootable')
        run_command(f'{IMAGER_CMD} rdb part format Workbench.hdf 1 "Workbench"')

        # ---- AGS_Drive.hdf (12 GB) ----
        run_command(f"{IMAGER_CMD} blank AGS_Drive.hdf 12gb")
        run_command(f"{IMAGER_CMD} rdb init AGS_Drive.hdf")
        run_command(f"{IMAGER_CMD} rdb fs add AGS_Drive.hdf pfs3aio PFS3")
        run_command(f'{IMAGER_CMD} rdb part add AGS_Drive.hdf DH1 PFS3 "*"')
        run_command(f'{IMAGER_CMD} rdb part format AGS_Drive.hdf 1 "AGS_Drive"')

        # ---- Games.hdf (6 GB) ----
        run_command(f"{IMAGER_CMD} blank Games.hdf 6gb")
        run_command(f"{IMAGER_CMD} rdb init Games.hdf")
        run_command(f"{IMAGER_CMD} rdb fs add Games.hdf pfs3aio PFS3")
        run_command(f'{IMAGER_CMD} rdb part add Games.hdf DH2 PFS3 "*"')
        run_command(f'{IMAGER_CMD} rdb part format Games.hdf 1 "Games"')

        # ---- Work.hdf (1 GB) ----
        run_command(f"{IMAGER_CMD} blank Work.hdf 1gb")
        run_command(f"{IMAGER_CMD} rdb init Work.hdf")
        run_command(f"{IMAGER_CMD} rdb fs add Work.hdf pfs3aio PFS3")
        run_command(f'{IMAGER_CMD} rdb part add Work.hdf DH4 PFS3 "*"')
        run_command(f'{IMAGER_CMD} rdb part format Work.hdf 1 "Work"')

        # 3) Copy old data into new
        # Define which HDFs and partitions to copy
        copies = [
            ("Workbench", "dh0"),
            ("AGS_Drive", "dh1"),
            ("Games",    "dh2"),
            ("Work",     "dh4")
        ]

        for base_name, part_name in copies:
            old_path = pjoin(f"{base_name}.old", "rdb", part_name)
            new_path = pjoin(f"{base_name}.hdf", "rdb", part_name)
            run_command(f'{IMAGER_CMD} fs copy "{old_path}" "{new_path}" --recursive')

        print("Shrinking done.\n")
    else:
        print("Skipping shrinking.\n")

    print("All requested operations are complete.")

if __name__ == "__main__":
    main()
