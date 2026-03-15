# pacsDisplay

**Website:** [pacsdisplay.org](https://pacsdisplay.org)

Open source software for generating and installing DICOM grayscale LUTs and for performing QC on calibrated displays.

> **Download the latest release at [pacsdisplay.org](https://pacsdisplay.org)**

## Overview

pacsDisplay is a comprehensive toolkit for medical display calibration and quality control in PACS environments. The software suite provides tools for DICOM GSDF calibration, luminance response measurement, and display performance evaluation.

**pdQC** is the portable quality control package - a subset of pacsDisplay tools designed for USB or network deployment without installation requirements.

**Key Features:**
- DICOM grayscale LUT generation and installation
- Luminance response measurement and calibration
- Display uniformity assessment
- Image quality test patterns (TG270/TG18 compliance)
- EDID profiling and display identification
- Ambient light verification
- QC reporting and GSDF compliance verification

## Quick Start

### Download

**Download the latest release at [pacsdisplay.org](https://pacsdisplay.org)**

Or get it from the [GitHub Releases](../../releases) page:
- `pdQC_v6A.zip` - Portable QC tools (recommended for most users)

### Installation

1. Extract the ZIP file to a USB drive or local folder
2. Run `pdLaunch.bat` to launch the application menu
3. See `QUICKSTART_pdQC.txt` for detailed usage instructions

### Requirements

- Windows 7 or later (32-bit or 64-bit)
- i1 Display Pro photometer (recommended) or compatible device

## Included Applications

| Application | Version | Purpose |
|-------------|---------|---------|
| **lumResponse** | 2.5 | Measure display luminance response |
| **lutGenerate** | 2.6 | Generate calibration LUTs |
| **iQC** | 2.3 | Display image quality test patterns |
| **uniLum** | 1.2 | Measure display uniformity |
| **i1meter** | 1.4 | Simple luminance measurements |
| **ambtest** | 1.2 | Ambient light verification |
| **gtest** | 1.4 | Gray level uniformity assessment |
| **EDIDprofile** | 1.3 | Display EDID information |
| **QC-check** | 2.5 | Re-analyze QC data |
| **uLRstats** | 1.2 | Analyze uncalibrated response data |
| **loadLUTsingle** | 1.4 | Load calibration LUTs |

## Documentation

- [Build Instructions](docs/BUILD.md) - How to build from source
- [Module Descriptions](docs/MODULES.md) - Detailed application documentation
- [Architecture](docs/ARCHITECTURE.md) - System architecture overview
- [Changelog](CHANGELOG.md) - Version history

## Building from Source

```bash
# Prerequisites: Tcl (tclsh command)

# Build pdQC package
tclsh build.tcl thin 6A
```

See [docs/BUILD.md](docs/BUILD.md) for complete build instructions.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This software is distributed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.

Third-party components:
- Tcl/Tk - BSD-style license ([vendor/licenses/tcl.txt](vendor/licenses/tcl.txt))
- Argyll CMS - AGPL/GPL ([vendor/licenses/argyll_v3.5.0.txt](vendor/licenses/argyll_v3.5.0.txt))
- Gnuplot - Custom permissive license ([vendor/licenses/gnuplot.txt](vendor/licenses/gnuplot.txt))

## Authors

- Michael J. Flynn
- Nicholas B. Bevins
- Philip M. Tchou

## Support

- **Website & Downloads:** [pacsdisplay.org](https://pacsdisplay.org)
- **Report bugs:** [GitHub Issues](../../issues)
- **Documentation:** See `docs/` folder

## Citation

If you use this software in research, please cite:
```
pacsDisplay
Flynn, M.J., Bevins, N.B., Tchou, P.M.
https://pacsdisplay.org
```

## Links

- **Download & Documentation:** [pacsdisplay.org](https://pacsdisplay.org)
- **Source Code:** [github.com/pacsdisplay/pacsdisplay](https://github.com/pacsdisplay/pacsdisplay)
