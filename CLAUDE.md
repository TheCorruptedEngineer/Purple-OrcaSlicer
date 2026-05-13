# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

OrcaSlicer — open-source C++17 3D slicer. wxWidgets GUI, CMake build system.

## Build Commands

```bash
# Windows (replace %build_type% with Debug/Release/RelWithDebInfo)
cmake --build . --config %build_type% --target ALL_BUILD -- -m

# Linux
cmake --build build --config RelWithDebInfo --target all --

# macOS
cmake --build build/arm64 --config RelWithDebInfo --target all --
```

## Testing

OrcaSlicer uses Catch2 v2 for testing. See `tests/CLAUDE.md` for comprehensive testing guide.

```bash
cd build && ctest --output-on-failure           # all tests
ctest --test-dir ./tests/libslic3r              # individual suite
ctest --test-dir ./tests/fff_print
```

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