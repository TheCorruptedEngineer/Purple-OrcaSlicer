# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

OrcaSlicer — open-source C++17 3D slicer. wxWidgets GUI, CMake build system.

---

## ⚠️ This is a fork: Purple OrcaSlicer

**This checkout (`C:\Program Files\Purple-OrcaSlicer`) is the canonical one.** It is a full
source tree that is built in place — not an install directory. The `Orca.lnk` desktop shortcut
launches `build\src\Release\orca-slicer.exe` from here.

> A stale second checkout used to live at `Desktop\klipper stuff\OrcaSlicer`. It was deleted
> 2026-08-01 (~36 GB reclaimed) and left with a `READ-ME-MOVED.md` signpost. If a session
> starts there, work here instead.

### Fork chain

```
OrcaSlicer/OrcaSlicer              (upstream)
  └── NanashiTheNameless/OrcaSlicer  (parent — ~940 custom commits, tracks upstream closely)
        └── TheCorruptedEngineer/Purple-OrcaSlicer   (this repo — `origin`)
```

The GitHub repo was renamed `OrcaSlicer` → `Purple-OrcaSlicer`; old-name URLs work only via
GitHub's redirect. Version string lives in `version.inc` as `SoftFever_VERSION` and carries the
fork's own **`-Kurisu`** suffix (e.g. `2.5.0-Kurisu`) — upstream bumps the number, we keep the
suffix.

### Merging upstream — merge from **Nanashi**, never from OrcaSlicer/OrcaSlicer

This fork is built on top of Nanashi's ~940 commits. Merging `OrcaSlicer/OrcaSlicer` directly
would fight every one of them. Nanashi typically sits <30 commits behind upstream, so merging
from them keeps you effectively current.

```bash
git remote add nanashi https://github.com/NanashiTheNameless/OrcaSlicer.git   # if missing
git fetch nanashi main
git merge-tree --write-tree HEAD nanashi/main    # dry-run: see conflicts before merging
```

Always merge on a branch with a backup ref, never straight onto `main`.

**Conflict-resolution policy:** the purple theme is *only* color-literal swaps — it makes no
structural changes. So **take upstream's structure/logic in every conflict and re-apply the
purple literal on top.** Keeping "our" side of a refactored file has produced code that does
not compile (e.g. `NetworkPluginDialog.cpp`, where upstream replaced hand-rolled buttons with
the shared `DialogButtons` component).

Two counter-examples to that rule, both real:
- **`version.inc`** holds the `-Kurisu` branding. Taking upstream wholesale silently reverts it.
- When upstream **moves** colors (e.g. `SwitchButton.cpp`: hardcoded `doRender` colors → `StateColor`
  members), take the refactor and purple the *new* location, or the theme regresses to teal.

---

## The purple theme (#B13CFF)

### Palette — the canonical mapping

Defined by the fork's own commits; use these exact values when purpling new upstream code:

| Orca teal | → Purple | Role |
|---|---|---|
| `#009688`, `wxColour(0, 150, 136)`, `0x009688` | `#B13CFF`, `wxColour(177, 60, 255)`, `0xB13CFF` | primary accent |
| `#26A69A`, `wxColour(38, 166, 154)` | `#C060FF`, `wxColour(192, 96, 255)` | hover |
| `wxColour(0, 137, 123)`, `#00877B`, `#00675b` | `wxColour(142, 47, 191)`, `#8E2FBF` | pressed / dark |
| `#008172` | `#9B4AE0` | hover (dark mode) |
| `#E5F0EE`, `0xE5F0EE`, `#EBF9F0` | `#E5D6FF` | accent @ 10% |
| `#BFE1DE` | `#BFDCFF` | accent @ 25% |
| `#00AE42` | `#B13CFF` | selection accent |
| `ImVec4(0, 0.588, 0.533, 1)` | `ImVec4(0.694f, 0.235f, 1.0f, 1)` | ImGui accent |

### Where the theme lives — prefer these seams over new hardcoded literals

- **`src/slic3r/GUI/Widgets/StateColor.cpp`** — `gDarkColors` is a **light→dark** map and the
  theme's core. Adding an entry whose key already exists silently breaks it: `std::map`
  init-lists keep the **first** match, so a duplicate key drops the intended dark value.
- **`src/slic3r/GUI/BitmapCache.cpp`** — SVG icon recolor table (`replaces`). Note the literal
  is `"#0x00AE42"`, not `#00AE42`.
- **`src/slic3r/GUI/Widgets/WebViewHostDialog.cpp`** — sets `--orca-accent`, the CSS variable
  that themes **every** web dialog (terminal, plugins, speed dial, preset export). One line
  here beats hardcoding CSS; the old `resources/web/dialog/css/dark.css` approach was deleted
  upstream in favor of this.
- `resources/images/*.svg` — ~421 icons carry the accent color directly.

### Do NOT purple these

- **`src/libslic3r/PresetBundle.cpp`** — `#26A69A` there is the **default filament colour**
  written into project config. It's print data, not UI chrome.
- Semantic status colors (success/error/warning) and commented-out code.

---

## Building (Windows, this machine)

This machine has **Visual Studio 18 (2026)** and CMake 4.3.2.

```bat
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
cd /d "C:\Program Files\Purple-OrcaSlicer"
call .\build_release_vs.bat            &:: no args = deps + slicer
call .\build_release_vs.bat slicer     &:: skip deps (much faster)
```

- **Use `build_release_vs.bat`, NOT `build_release_vs2022.bat`.** The latter hardcodes
  `-G "Visual Studio 17 2022"` and fails here; `build_release_vs.bat` auto-detects
  `VS_MAJOR=18` → `"Visual Studio 18 2026"`.
- `vcvars64.bat` is exactly what the Start-menu **"x64 Native Tools Command Prompt for VS"**
  runs, so calling it from a script is equivalent. The *Cross* Tools prompts are wrong
  (`x64_x86` targets 32-bit). The script needs `msbuild` on PATH for VS detection, which only
  this environment provides.
- **`NoDefaultCurrentDirectoryInExePath=1`** is set on this machine — cmd will not find a
  `.bat` in the working directory. Invoke as `.\build_release_vs.bat` or clear the variable.
- Three `cmake.exe` are on PATH (`C:\Program Files\CMake` 4.3.2, `C:\Strawberry\c\bin`, VS's
  bundled copy). The first must win; that is the conflict the Orca wiki warns about.
- Timings: full deps+slicer ≈ 30 min; `slicer`-only incremental ≈ 2 min. **Editing
  `version.inc` triggers a CMake reconfigure and a broad recompile** — not a 2-minute build.

### Build gotchas

- `LNK1104: cannot open file ...\OrcaSlicer.dll` means **OrcaSlicer is running** and holding
  the DLL. Kill every `orca-slicer` process first — there is often more than one.
- Never edit source while a build is in flight.
- Official docs: <https://www.orcaslicer.com/wiki/developer_reference/how_to_build.html>

### UTF-8 mojibake — a real, recurring hazard here

Never regex-edit source with PowerShell one-liners. A past theme pass corrupted 9 strings this
way (`mm/s²` → `mm/sÂ²`, `°C` → `Â°C`, em-dashes, the ⌘ glyph), including **user-visible**
G-code viewer legends. Use the Edit tool or a Node script with explicit UTF-8 read/write.

To detect: `rg 'Â[°²³]|â€[""”“–—]|âŒ˜' src/`

---

## Testing

OrcaSlicer uses Catch2 v2 for testing. See `tests/CLAUDE.md` for comprehensive testing guide.

```bash
cd build && ctest --output-on-failure           # all tests
ctest --test-dir ./tests/libslic3r              # individual suite
ctest --test-dir ./tests/fff_print
```

Build tests with `.\build_release_vs.bat slicer tests` (CI uses exactly this).

### Verifying a theme change actually shipped

`tsc`-style "it compiled" is not proof. Check the literals are in the binary:

```powershell
$t=[Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes('build\src\Release\OrcaSlicer.dll'))
'#B13CFF','#C060FF','#8E2FBF' | % { "$_ -> " + ([regex]::Matches($t,[regex]::Escape($_))).Count }
```

Then launch `build\src\Release\orca-slicer.exe` and confirm it stays running.

---

## Project Structure

- **App startup**: `src/OrcaSlicer.cpp`
- **Slicing pipeline**: `src/libslic3r/Print.cpp`
- **Settings**: `src/libslic3r/PrintConfig.cpp` (all print/printer/material settings)
- **GUI**: `src/slic3r/GUI/` (wxWidgets-based UI)
- **Core algorithms**: `src/libslic3r/` subdirectories (GCode/, Fill/, Support/, Geometry/, Format/, Arachne/)
- **Printer profiles**: `resources/profiles/[manufacturer].json`
- **Web resources**: `resources/web/` (homepage, dialogs, guides)

## Code Style

- C++17 with selective C++20 features
- PascalCase for classes, snake_case for functions/variables
- `#pragma once` for headers
- Smart pointers and RAII preferred
- Parallelization via TBB — be mindful of shared state

## Critical Constraints

- **Backward compatibility required** for .3mf project files and printer profiles
- **Cross-platform** — all changes must work on Windows, macOS, and Linux
- Profile/format changes require version migration handling
- Dependencies built separately in `deps/build/`, then linked to main app

---

## Status / open items (2026-08-01)

- Merged 1178 commits from `nanashi/main` (12 conflicts) and pushed to `origin/main`.
  Backup ref: `backup-pre-merge-20260801`; merge branch: `merge-nanashi-20260801`.
- Position after merge: ~28 behind Nanashi, ~29 behind upstream (Nanashi moved during the merge).
- **README release links still point at the `V2.4.0-Kurisu` tag** (3 places) while the version
  is now `2.5.0-Kurisu`. Needs a new tag + link update — a release decision, left to the owner.
