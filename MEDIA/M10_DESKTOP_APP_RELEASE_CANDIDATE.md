# ALCHUL — Standalone Desktop Applications (Batch 10 Preview)

**Date:** November 19, 2026  
**Engine:** Godot 4.7.2, Compatibility renderer  
**Status:** **REAL EXECUTABLE BUILD, EARLY NONCANONICAL PREVIEW**  
**CI evidence:** https://github.com/SouthPaw302/Alchul/actions/runs/44465043085  
**Primary archive:** https://drive.google.com/drive/folders/1A9ToR_URKeMmGTodi_W-zkZmizBNer3G

## What actually shipped as a preview

The same ALCHUL native Godot scene, integrated source art and static optimization work present in the current M10 review branch have been exported as complete self-contained desktop game/application builds. These are not installers, web pages, screenshots, or Godot project-source archives.

| Platform | Download | Standalone payload | Packaged ZIP SHA-256 | Export validation |
| --- | --- | --- | --- | --- |
| Windows 64-bit Intel/AMD | [Drive artifact archive](https://drive.google.com/file/d/10hoJiomhAvQDgbP-qt-xjfKRS-p9dccD/view) | `Alchul.exe`, Windows PE 64-bit with embedded Godot resources | `2d44d416f599e148a21bc7f9a368cb48ae2959f97a4ac75d17f634897c4a9c2e` | Official exporter + file signature + ZIP CRC passed |
| Linux 64-bit Intel/AMD | [Drive artifact archive](https://drive.google.com/file/d/1jnmdaD2pbkCr_sd1ON2k4F6pEJYVU3fX/view) | `Alchul.x86_64`, ELF x86_64 with embedded resources | `aa046518f52fc6f72220d401fa7472604b9ce09b479dbd96bb16e3fa5235a235` | Official exporter + ELF signature + actual standalone native Linux launch in virtual display passed |
| macOS Intel + Apple Silicon | [Drive artifact archive](https://drive.google.com/file/d/1DQLTBVHspyr5olyZ9V25EusrTUmhvrdz/view) | Godot-exported universal `.app` inside ZIP with project resources | `dd325977e8f46c9503d43e9c3aa3c30719967d45e52ebb6f65feba120a2e8ce0` | Official exporter + `.app` bundle inspection + ZIP CRC passed; **no physical Mac test** |

**Drive archive detail:** Drive copies wrap each platform's ZIP inside a GitHub Actions artifact ZIP, so Drive users must unpack **twice**. The direct conversation download versions are already the single application ZIP.

**Code/signing:** These are unsigned development builds, not signed commercial app releases. Windows SmartScreen and macOS Gatekeeper may warn or refuse to open; obtain formal platform signing and Apple notarization for public distribution. Linux execution permissions must be set if lost after extracting.

## User steps

1. Download the **single app ZIP** for the computer's operating system from the chat attachment, or access its matching Drive artifact archive and then extract the inner application ZIP.
2. Windows: extract and double-click `Alchul.exe`. Linux: extract, `chmod +x Alchul.x86_64`, then run it. macOS: unzip and open the ALCHUL `.app` bundle, subject to the unsigned app restriction.
3. Move with WASD; drag with the right mouse button to look; hold Shift to move faster; press E near a marker to inspect it; press 1/2/3 to change the interpretation lens.
4. No account, network connection, online 3D hosting, or Godot editor is required.

## Verified build actions

- GitHub workflow: `.github/workflows/alchul-desktop-build.yml`.
- Reproducible exporter script: `godot/tools/build_desktop.sh`.
- Real platform export settings: `godot/export_presets.cfg`, including macOS universal architecture and correctly imported ETC2/ASTC texture compression.
- Official engine executable SHA verified; official export templates downloaded from matching Godot 4.7.2 release.
- GitHub Actions official release exports all three platforms successfully and **runs the actual Linux exported game** under Xvfb using the Compatibility renderer, checking its exit status and absence of GDScript errors. All three archives passed SHA-256 and ZIP integrity checks.
- This desktop build uses the existing **draft** M10 PR; M9/M10 and website **main remain unmerged**. No live browser site was modified or represented as updated by desktop export.

## Remaining release needs

The world is an early exploration, not a finished scientifically approved reconstruction. Before announcing a public signed release: test the Windows and macOS binaries on actual machines, inspect performance with hardware GPUs, complete Batch 11 inhabitant research/animation, finish gameplay and accessibility, produce signing/notarization, archive source asset licensing/provenance, and establish game version numbering. The previous software-browser FPS issue is irrelevant to whether the native app can open; hardware testing is still prudent.
