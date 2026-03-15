# pacsDisplay Architecture

## Overview

pacsDisplay is a suite of Tcl/Tk applications packaged as starkits for Windows deployment. The system provides medical display calibration and quality control tools designed for PACS environments.

## Core Technologies

### Tcl/Tk Framework
- **Language**: Tcl/Tk 8.6
- **Packaging**: Starkit architecture
- **Runtime**: basekit.exe (included Tcl interpreter)
- **Development**: sdx.kit for starkit creation

### External Dependencies
- **Argyll CMS** (spotread.exe) - Photometer interface
- **Gnuplot** - Data visualization and QC reporting
- **Windows C++ utilities** - EDID reading, LUT loading

## Application Architecture

### Starkit Structure

Each application follows a standard starkit virtual file system (VFS) layout:

```
<module>.vfs/
├── lib/
│   └── app-<module>/
│       ├── <module>.tcl          # Main application
│       ├── INSTRUCTIONS.txt      # User documentation
│       ├── <module>Config.txt    # Configuration file
│       └── [support files]       # Additional resources
└── main.tcl                      # Entry point
```

### Build Process

1. **Source**: Individual `.vfs` directories in `source/tcl/`
2. **Wrap**: sdx.kit creates `.kit` files from VFS
3. **Package**: basekit.exe + .kit → standalone `.exe`
4. **Distribute**: ZIP archive with all executables and resources

```
source/tcl/<module>/<module>.vfs  →  _dist/pdQC_v6A/<module>.exe
```

### Version Management

Version information is embedded in each module's main .tcl file:

```tcl
#====================================================================
# MODULE
#====================================================================
#
#    <module> version <version>
#
#        <date> - <authors>
#
#====================================================================
```

The build system extracts version numbers from these blocks, ensuring single source of truth.

## Package Types

### pdQC (Thin Package)
- **Purpose**: Portable quality control tools
- **Target**: USB or network deployment
- **Contents**: Core QC and calibration tools
- **Installation**: None required, run from any location

### pacsDisplay (Thick Package)
- **Purpose**: Full installation with all tools
- **Target**: Workstation installation
- **Contents**: All modules plus documentation
- **Installation**: System integration

## Module Categories

### Measurement Tools
- **lumResponse**: Luminance response measurement
  - Interfaces with i1Display Pro via Argyll spotread
  - Records uncalibrated (uLR) and calibrated (cLR) data
  - Multiple QC modes (18x1, 16x2, external, etc.)

- **i1meter**: Simple continuous luminance meter
  - Real-time luminance display
  - Ambient light measurement
  - Integration time control

- **uniLum**: Display uniformity assessment
  - 3×3 grid measurements
  - LUDM and MLD calculations per AAPM 270/TG-18
  - Internal and external measurement modes

### Calibration Tools
- **lutGenerate**: DICOM GSDF LUT generation
  - Processes uLR files to create calibration LUTs
  - Supports 256, 512, 1024 entry LUTs
  - Ambient light (Lamb) compensation
  - Multiple monitor calibration

- **loadLUTsingle**: LUT installation utility
  - Windows C++ application
  - Direct video card programming
  - Single monitor focus

### Quality Control
- **iQC**: Image quality test patterns
  - TG270 and TG18 compliant patterns
  - Full screen and windowed modes
  - Grayscale, resolution, geometric patterns

- **QC-check**: QC data re-analysis
  - Re-evaluate cLR with different Lamb
  - GSDF compliance verification
  - Gnuplot visualization

### Diagnostic Tools
- **EDIDprofile**: Display identification
  - Windows C++ application
  - Reads EDID via registry
  - Model, serial number, capabilities

- **ambtest**: Ambient light verification
  - HTML-based ambient light test
  - Measures combined display + ambient
  - Validates Lamb assumptions

- **gtest**: Gray level uniformity
  - Visual uniformity assessment
  - Adjustable gray levels
  - Full screen display

### Analysis Tools
- **uLRstats**: Uncalibrated response analysis
  - Statistical analysis of uLR measurements
  - Gamma curve fitting
  - Luminance range assessment

### Launcher
- **pdLaunch**: Application menu
  - Central launch point for all tools
  - Version information display
  - Quick start guide access

## Data Flow

### Calibration Workflow
```
1. lumResponse (Palette mode) → uLR_MANF_MODEL_SN.txt
2. lutGenerate + uLR file → LUT_MANF_MODEL_SN.txt
3. loadLUTsingle + LUT file → Video card calibration
```

### QC Workflow
```
1. loadLUTsingle (load calibration)
2. lumResponse (QC mode) → cLR_MANF_MODEL_SN.txt
3. QC-check + cLR file → QC-lr.txt + plots
```

### External Display QC
```
1. Display test pattern on external monitor
2. lumResponse (External mode) with photometer
3. User advances through patterns manually
4. Results saved as cLR_[displayID].txt
```

## File Formats

### uLR (Uncalibrated Luminance Response)
- Tab-delimited text file
- Columns: Measurement No., Avg Luminance, RGB Value, Gray-Step, Sub-Step, dL/L, u', v'
- Used for LUT generation

### cLR (Calibrated Luminance Response)
- Tab-delimited text file
- Same format as uLR
- Used for QC verification

### LUT Files
- Text file with LUT entries
- Format: R G B (space-separated)
- 256, 512, or 1024 entries
- Applied to video card hardware

### Configuration Files
- Tcl-formatted text files
- Module-specific settings
- Geometry, meter settings, gray levels
- Located in each module's VFS directory

## Build System

### Manifest-Driven Configuration
[build_manifest.tcl](../build_manifest.tcl) defines:
- Toolchain paths
- Source directories
- Package contents (thin vs thick)
- Module lists
- External dependencies

### Build Script
[build.tcl](../build.tcl) orchestrates:
1. Version extraction from source
2. VFS wrapping with sdx.kit
3. Executable creation
4. Dependency copying
5. ZIP archive creation

### Version Control
- Version numbers in source files (single source of truth)
- Letter-based versioning: 6A, 6B, 7A, etc.
- Extracted during build, not hardcoded

## Distribution Strategy

### Portable Design
- No installation required for pdQC
- Run from USB or network share
- Self-contained with basekit runtime
- Relative path resolution

### File Organization

The distribution structure (pdQC):

```
pdQC/
├── basekit.exe                   # Tcl/Tk runtime
├── pdLaunch.bat                  # Windows batch launcher
├── pdLaunch.kit                  # Main launcher starkit
├── pdLaunch-config.txt           # Launcher configuration
├── QUICKSTART_pdQC.txt           # Quick start guide
├── VERSION_INFO.txt              # Version information
├── GNU-GPL.txt                   # License
├── _NEW/                         # Default output directory
└── pacsDisplay-BIN/              # Applications directory
    ├── ambtest/
    │   ├── ambtest.kit
    │   └── ambtest.html
    ├── EDIDprofile/
    │   ├── EDIDprofile.kit
    │   └── INSTRUCTIONS.txt
    ├── gtest/
    │   ├── gtest.kit
    │   └── INSTRUCTIONS.txt
    ├── i1meter/
    │   ├── i1meter.kit
    │   ├── INSTRUCTIONS.txt
    │   └── config-meter.txt
    ├── iQC/
    │   ├── iQC.kit
    │   ├── INSTRUCTIONS.txt
    │   └── [pattern files]
    ├── loadLUTsingle/
    │   └── INSTRUCTIONS.txt
    ├── lumResponse/
    │   ├── lumResponse.kit
    │   ├── QC-check.kit
    │   ├── INSTRUCTIONS.txt
    │   ├── LRconfig.txt
    │   ├── 1786phase.txt
    │   ├── 766phase.txt
    │   ├── 256phase.txt
    │   ├── 16phase.txt
    │   └── 16phase10.txt
    ├── lutGenerate/
    │   ├── lutGenerate.kit
    │   └── INSTRUCTIONS.txt
    ├── uLRstats/
    │   ├── uLRstats.kit
    │   └── INSTRUCTIONS.txt
    ├── uniLum/
    │   ├── uniLum.kit
    │   ├── INSTRUCTIONS.txt
    │   └── uniConfig.txt
    ├── LIB/                     # Shared executables
    │   ├── spotread.exe         # Argyll CMS photometer interface
    │   ├── getEDID.exe          # EDID reader
    │   ├── loadLUTsingle.exe    # LUT loader
    │   └── gnuplot46-bin/       # Gnuplot binaries
    └── getInstalledPaths.txt    # Path configuration
```

Each application directory contains:
- `.kit` file (starkit - Tcl/Tk application)
- `INSTRUCTIONS.txt` (user documentation)
- Configuration files (`.txt`)
- Supporting data files (phase files, patterns, etc.)

Applications are launched via `basekit.exe <app>.kit`

## Key Design Principles

1. **Portability (thin build)**: No installation, run anywhere
2. **Simplicity**: Single executables, minimal dependencies
3. **Standards Compliance**: AAPM TG-18, Report 270, DICOM Part 14
4. **Extensibility**: Configuration files for customization
5. **Reliability**: Robust error handling, input validation
6. **Traceability**: Complete audit trail in output files

## Hardware Interface

### Photometer Support
Currently supports i1Display Pro via Argyll CMS:
- USB HID interface (no driver needed)
- Communication via spotread.exe command-line
- Tristimulus (XYZ) and chromaticity (u'v') output

### Video Card Interface
LUT loading via Windows API:
- Direct video card programming
- Per-display control
- Hardware gamma table manipulation

### Display Identification
EDID reading via Windows registry:
- Model name extraction
- Serial number retrieval
- Capability parsing
- No direct I2C access needed

## Future Considerations

- **Cross-platform support**: Linux/macOS versions
- **Additional photometers**: Klein, Minolta support
- **Network deployment**: Central configuration management
- **Database integration**: QC result tracking
- **Automated QC**: Scheduled testing and reporting

## References

- [Build Instructions](BUILD.md)
- [Module Documentation](MODULES.md)
- [Changelog](../CHANGELOG.md)
- DICOM Part 14 - Grayscale Standard Display Function
- AAPM Report No. 270 - Quality Control for PACS Display Systems
- AAPM On-Line Report No. 3 (TG18) - Assessment of Display Performance
