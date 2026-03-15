# Build Instructions

How to build pdQC/pacsDisplay distributions from source.

## Prerequisites

### Required Software

- **Tcl** - Any Tcl installation with `tclsh` command
- **Git** - For source control

### Build Tools (Included in vendor/bin)

- **basekit.exe** - Tcl runtime for starkits
- **sdx.kit** - Starkit Developer eXtension (packaging tool)

### C++ Development (Optional)

For rebuilding getEDID.exe or loadLUT executables:
- **Visual Studio** (any version supporting C++)
- Project files included in `source/cpp/`

## Quick Start

```bash
# Clone repository
git clone https://github.com/pacsdisplay/pacsdisplay.git
cd pacsdisplay

# Build pdQC thin client (version 6A)
tclsh build.tcl thin 6A

# Output: _dist/pdQC_v6A.zip
```

## Build System Overview

The build system uses two TCL scripts:

- **build.tcl** - Main build script with packaging logic
- **build_manifest.tcl** - Configuration file (paths, module lists)

### Build Process

1. Wrap `.vfs` directories into `.kit` files using sdx
2. Extract INSTRUCTIONS from inside .vfs structures
3. Copy executables to LIB/ directory
4. Copy vendor libraries and licenses
5. Copy basekit runtime
6. Generate VERSION_INFO.txt from source files
7. Create ZIP archive

## Build Commands

### Syntax

```bash
tclsh build.tcl <target> <version>
```

**Parameters:**
- `<target>` - Build target: `thin`, `thick`, or `all`
- `<version>` - Version string (e.g., "6A", "6B", "7A")

### Examples

```bash
# Build thin client (pdQC) version 6A
tclsh build.tcl thin 6A

# Build all packages version 7A (when thick is implemented)
tclsh build.tcl all 7A
```

### Available Targets

- **thin** - pdQC portable package (currently supported)
- **thick** - Full pacsDisplay installation (not yet implemented)
- **all** - Build both packages

## Configuration

### build_manifest.tcl

Edit this file to configure:

#### Toolchain Paths

```tcl
sdx             "vendor/bin/sdx.kit"
tclkit          "vendor/bin/basekit.exe"
zip_tool        "C:/Program Files/7-Zip/7z.exe"
```

#### Source Directories

```tcl
source_tcl_dir      "source/tcl"
source_cpp_getEDID  "source/cpp/getEDID/bin"
source_cpp_loadLUT  "source/cpp/loadLUT/bin"
vendor_bin          "vendor/bin"
misc_dir            "misc"
```

#### Module Lists

**Thin Package (pdQC):**
```tcl
thin_modules {
    pdLaunch ambtest EDIDprofile gtest i1meter
    iQC loadLUTsingle lumResponse QC-check
    lutGenerate uLRstats uniLum
}
thin_exes       { getEDID.exe loadLUTsingle.exe spotread.exe }
thin_dirs       { gnuplot46-bin }
```

**Thick Package (pacsDisplay):**
```tcl
thick_modules   { ... }  # Same as thin currently
thick_exes      { ... }  # Extended list
thick_dirs      { ... }  # Additional tools
```

## Directory Structure

```
pddev/
├── build.tcl                    # Build script
├── build_manifest.tcl           # Build configuration
├── source/
│   ├── tcl/                     # TCL modules
│   │   ├── ambtest/
│   │   │   └── ambtest.vfs/     # Starkit VFS structure
│   │   │       ├── lib/
│   │   │       │   └── app-ambtest/
│   │   │       │       ├── ambtest.tcl
│   │   │       │       ├── INSTRUCTIONS.txt
│   │   │       │       └── tcl/
│   │   │       └── main.tcl
│   │   └── ... (other modules)
│   └── cpp/                     # C++ sources
│       ├── getEDID/
│       └── loadLUT/
├── vendor/
│   ├── bin/                     # Third-party binaries
│   │   ├── basekit.exe
│   │   ├── sdx.kit
│   │   ├── spotread.exe
│   │   └── gnuplot46-bin/
│   └── licenses/                # Vendor licenses
├── misc/                        # Distribution files
│   ├── GNU-GPL.txt
│   ├── QUICKSTART_pdQC.txt
│   ├── pdLaunch.bat
│   └── getInstalledPaths_*.txt
└── _dist/                       # Build output
    ├── pdQC_v6A.zip
    └── _staging_thin/           # Temporary (deleted after build)
```

## Version Management

### Module Versions

Each module has a standardized version block in its main TCL file:

```tcl
# ==============================================================================
# MODULE VERSION: 2.5
# ==============================================================================
```

**Location:** `source/tcl/<module>/<module>.vfs/lib/app-<module>/<module>.tcl`

The build system extracts these versions automatically for VERSION_INFO.txt generation.

### Updating Versions

1. Edit the MODULE VERSION comment in the source TCL file
2. Update version history comments below it
3. Run build - version is extracted automatically

**Example:**
```tcl
# ==============================================================================
# MODULE VERSION: 2.6
# ==============================================================================

# -----------------------------------------------------------------------
#
#                    lumResponse.tcl
#
#   v2.5 - NB - Feb 2026    - External display support
#   v2.6 - NB - Mar 2026    - Added new feature XYZ
```

## Build Output

### Thin Package (pdQC)

**File:** `_dist/pdQC_v<version>.zip`

**Structure:**
```
pdQC/
├── basekit.exe
├── pdLaunch.kit
├── pdLaunch.bat
├── pdLaunch-config.txt
├── GNU-GPL.txt
├── QUICKSTART_pdQC.txt
├── VERSION_INFO.txt
├── _NEW/
│   └── _README_pdNEW.txt
└── pacsDisplay-BIN/
    ├── getInstalledPaths.txt
    ├── ambtest/
    │   ├── ambtest.kit
    │   └── INSTRUCTIONS.txt
    ├── ... (other modules)
    └── LIB/
        ├── getEDID.exe
        ├── loadLUTsingle.exe
        ├── spotread.exe
        ├── gnuplot46-bin/
        ├── tcl.txt
        ├── argyll_v3.5.0.txt
        └── gnuplot.txt
```

## Development Workflow

### 1. Modify Source Code

Edit files in `source/tcl/<module>/<module>.vfs/`

### 2. Update Version

If releasing new version, update MODULE VERSION block

### 3. Test Locally

```bash
# Build and extract to test location
tclsh build.tcl thin TEST
cd _dist
unzip pdQC_vTEST.zip -d test/
cd test/pdQC
./pdLaunch.bat
```

### 4. Build Release

```bash
tclsh build.tcl thin 5I
```

### 5. Test Distribution

Extract and verify all applications work

### 6. Create GitHub Release

```bash
git tag v5I
git push origin v5I
# Upload _dist/pdQC_v5I.zip to GitHub release
```

## Troubleshooting

### "sdx.kit not found"

**Problem:** Build can't find sdx.kit
**Solution:** Check `build_manifest.tcl` sdx path points to `vendor/bin/sdx.kit`

### "basekit.exe not found"

**Problem:** Runtime missing from vendor
**Solution:** Download from [tclkits.rkeene.org](https://tclkits.rkeene.org/) and place in `vendor/bin/`

### "7-Zip not found"

**Problem:** Zip command not found
**Solution:** Ensure zip utility is available in your system PATH

### "VFS not found"

**Problem:** Module .vfs directory missing
**Solution:** Verify directory structure in `source/tcl/<module>/`

### Version extraction fails

**Problem:** MODULE VERSION block not found
**Solution:** Add standardized version block to TCL source file:
```tcl
# ==============================================================================
# MODULE VERSION: X.X
# ==============================================================================
```

## Advanced Topics

### Adding New Modules

1. Create `.vfs` directory structure in `source/tcl/`
2. Add MODULE VERSION block to main TCL file
3. Add module to `thin_modules` list in `build_manifest.tcl`
4. Build and test

### Custom Distribution Files

Add files to `misc/` directory and update build.tcl:

```tcl
set misc_files {GNU-GPL.txt QUICKSTART_pdQC.txt pdLaunch.bat YOUR_FILE.txt}
```

### Modifying Vendor Components

1. Replace files in `vendor/bin/`
2. Update licenses in `vendor/licenses/`
3. Test compatibility
4. Document changes in CHANGELOG.md

## Continuous Integration (Future)

Example GitHub Actions workflow:

```yaml
name: Build pdQC
on: [push, pull_request]
jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Tcl
        run: choco install activetcl
      - name: Build
        run: tclsh build.tcl thin ${{ github.ref_name }}
      - name: Upload artifact
        uses: actions/upload-artifact@v2
        with:
          name: pdQC
          path: _dist/*.zip
```

## See Also

- [Module Documentation](MODULES.md) - Application details
- [Architecture](ARCHITECTURE.md) - System design
- [CHANGELOG.md](../CHANGELOG.md) - Version history
- [README.md](../README.md) - Project overview
