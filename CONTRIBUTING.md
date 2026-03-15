# Contributing to pacsDisplay

Thank you for your interest in contributing to pacsDisplay! This project has been developed over 27 years to provide reliable, standards-compliant medical display calibration and quality control tools.

## Table of Contents

- [Getting Started](#getting-started)
- [How to Report Bugs](#how-to-report-bugs)
- [How to Suggest Features](#how-to-suggest-features)
- [Development Guidelines](#development-guidelines)
- [Pull Request Process](#pull-request-process)
- [Code Style](#code-style)
- [Testing](#testing)
- [Community](#community)

## Getting Started

Before contributing, please:

1. **Read the documentation**
   - [README.md](README.md) - Project overview
   - [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - System architecture
   - [docs/BUILD.md](docs/BUILD.md) - Build instructions
   - [docs/MODULES.md](docs/MODULES.md) - Application documentation

2. **Set up your development environment**
   - Install Tcl (tclsh command)
   - Clone the repository
   - Review the build system: [build.tcl](build.tcl) and [build_manifest.tcl](build_manifest.tcl)

3. **Understand the standards**
   - DICOM Part 14 - Grayscale Standard Display Function
   - AAPM Report No. 270 - Quality Control for PACS Display Systems
   - AAPM On-Line Report No. 3 (TG18) - Assessment of Display Performance

## How to Report Bugs

Bugs are tracked as [GitHub Issues](../../issues). Before creating a bug report, please check existing issues to avoid duplicates.

### Bug Report Template

When reporting a bug, include:

**Environment:**
- Windows version (e.g., Windows 10, Windows 11)
- pacsDisplay version (check window titles or pdLaunch)
- Photometer model (e.g., i1Display Pro)
- Display configuration (single/multi-monitor)

**Description:**
- Clear, concise description of the problem
- Steps to reproduce the behavior
- Expected behavior
- Actual behavior
- Screenshots if applicable

**Application-Specific Information:**

For **lumResponse** issues:
- Measurement mode (Palette, QC 18x1, QC 16x2, External, etc.)
- Phase of measurement (initialization, recording, saving)
- Any error messages in console or log files

For **lutGenerate** issues:
- uLR file details (luminance range, gray levels)
- Target Lamb value
- LUT size (256, 512, 1024)

For **loadLUTsingle** issues:
- Display ID and EDID information
- LUT file being loaded
- Administrator privileges status

For **uniLum** issues:
- Measurement mode (internal vs external)
- Number of levels (1, 3, or 18)
- Stage of measurement when issue occurred

For **iQC** issues:
- Pattern type (TG270, TG18, ULN series)
- Display mode (full screen vs windowed)

**Known Issues:**

Before reporting, check these common issues:

1. **Virtual display devices** - getEDID may report different monitor numbers than Windows Display Settings when virtual displays are present (remote management software). Use EDIDprofile to identify correct monitor numbers.

2. **LUT loading at login** - Some Windows color management processes may reset LUTs after loadLUT runs at startup. Consider setting a delay in the config file (see execLoadLUT delay option).

3. **Windows security** - loadLUTsingle requires administrator privileges to program video card hardware.

## How to Suggest Features

Feature requests are welcome! Please create a [GitHub Issue](../../issues) with:

**Use Case:**
- Clinical or technical scenario
- Current workflow limitations
- How this feature would help

**Proposed Solution:**
- Your suggested approach
- Alternative solutions considered
- Integration with existing modules

**Standards Compliance:**
- Relevant DICOM, AAPM, or IEC standards
- Citation to specific sections if applicable

**Priority Areas:**

The following areas are particularly welcome for contributions:

1. **Cross-platform support** - Linux/macOS versions
1. **Additional photometer support** - Klein, Minolta, etc.
1. **QC database integration** - Result tracking and trending
1. **Automated QC** - Scheduled testing and reporting
1. **Documentation improvements** - Screen captures, tutorials, examples
1. **LUT library expansion** - Additional display models

## Development Guidelines

### Architecture Principles

1. **Portability** - For pdQC, no installation required, run from USB or network
2. **Standards compliance** - AAPM TG-18, Report 270, DICOM Part 14
3. **Simplicity** - Self-contained scripts, minimal dependencies
4. **Reliability** - Robust error handling, complete audit trails
5. **Traceability** - All measurements include timestamps and configuration

### Version Management

- Version numbers are stored in source files (single source of truth)
- Version block format in each module's .tcl file:

```tcl
#====================================================================
# MODULE
#====================================================================
#
#    <module> version <version>
#
#        <date> - M.J Flynn, N.B Bevins, P.M Tchou
#
#====================================================================
```

### File Organization

Each application follows starkit VFS structure:

```
source/tcl/<module>/
└── <module>.vfs/
    ├── lib/
    │   └── app-<module>/
    │       ├── <module>.tcl          # Main application
    │       ├── INSTRUCTIONS.txt      # User documentation
    │       ├── <module>Config.txt    # Configuration
    │       └── [support files]
    └── main.tcl                      # Entry point
```

### Configuration Files

- All user-adjustable settings in Config.txt files
- Tcl-formatted text (not binary)
- Comments explaining each parameter
- Default values suitable for typical use

### Documentation

- Each module MUST have INSTRUCTIONS.txt in VFS
- Plain text format (not PDF)
- Include usage, options, and features sections
- Keep synchronized with actual functionality

## Pull Request Process

### Before Submitting

1. **Test thoroughly**
   - Build with `tclsh build.tcl thin 6A` (or current version)
   - Test on Windows 10 and Windows 11 if possible
   - Verify with i1Display Pro if hardware changes
   - Check multi-monitor scenarios if applicable

2. **Update documentation**
   - Modify INSTRUCTIONS.txt if user-facing changes
   - Update version number in source file
   - Add entry to CHANGELOG.md
   - Update MODULES.md if new features

3. **Follow code style** (see below)

### Submitting

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/description`)
3. Commit your changes with clear messages
4. Push to your fork
5. Open a Pull Request with:
   - Clear description of changes
   - Related issue numbers
   - Testing performed
   - Screenshots if UI changes

### Review Process

1. Maintainers will review code and test
2. Feedback may be provided for revisions
3. Once approved, changes will be merged
4. Your contribution will be noted in CHANGELOG.md

## Code Style

### Tcl Conventions

**Indentation:**
- Use 4 spaces (not tabs)
- Consistent brace style

**Naming:**
- Variables: camelCase (e.g., `lumValue`, `testImageWidth`)
- Procedures: camelCase (e.g., `initMeter`, `readLuminance`)
- Global variables: Prefix with purpose (e.g., `apps_path`, `meter_`)
- Configuration variables: Match config file names

**Procedures:**
```tcl
proc myProcedure {arg1 arg2} {
    # Clear comment describing purpose

    # Local variables
    set localVar value

    # Implementation
    return $result
}
```

**Comments:**
- Explain WHY, not WHAT (code shows what)
- Document complex algorithms
- Note standards compliance (e.g., "per AAPM TG270 section 3.2")
- Include author and date for major changes

**Error Handling:**
```tcl
if {[catch {
    # risky operation
} errMsg]} {
    tk_messageBox -type ok -icon error \
        -message "Operation failed: $errMsg"
    return
}
```

**File I/O:**
- Always close file handles
- Use binary mode for non-text
- Check file existence before reading
- Validate file contents after reading

### Standards Compliance

When implementing measurement or calculation features:

1. **Cite the standard**
   ```tcl
   # Calculate LUDM per AAPM Report 270, Section 4.3
   set ludm [expr {abs($lum - $median) / $median * 100.0}]
   ```

2. **Use standard terminology**
   - GSDF (Grayscale Standard Display Function)
   - DDL (Digital Driving Level)
   - JND (Just Noticeable Difference)
   - LUDM (Luminance Uniformity Deviation from Median)
   - MLD (Mean Luminance Deviation)

3. **Match standard equations**
   - Use same variable names when possible
   - Document any deviations with rationale

### Security Considerations

**Avoid:**
- Command injection (use `exec` with list form)
- Path traversal (validate file paths)
- Unrestricted file operations
- Hardcoded credentials

**Example - Safe exec:**
```tcl
# Good - list form prevents injection
exec $spotread_path -yn -N {*}$args

# Bad - string concatenation
exec "$spotread_path -yn -N $args"
```

**Example - Path validation:**
```tcl
# Validate user-provided paths
if {![file isdirectory $userPath]} {
    error "Invalid directory path"
}
```

## Testing

### Manual Testing

For any changes, test:

1. **Basic functionality**
   - Application launches without errors
   - UI elements render correctly
   - Help/Instructions accessible

2. **Core features**
   - Primary use case works as expected
   - Configuration options apply correctly
   - Output files have correct format

3. **Error conditions**
   - Invalid input handled gracefully
   - File not found scenarios
   - Photometer disconnection
   - Insufficient permissions

### Test Data

Use these test scenarios:

**lumResponse:**
- DEMO mode (no photometer required)
- Various QC modes with sample data
- External measurement mode

**lutGenerate:**
- Sample uLR files in repository
- Various Lamb values (0.0, 1.0, 2.0)
- Different LUT sizes

**iQC:**
- All pattern categories
- Full screen and windowed
- Multi-monitor placement

### Regression Testing

Before major releases:
- Test all modules on clean Windows 10/11 system
- Verify USB deployment (no installation)
- Test multi-monitor configurations
- Validate EDID reading with multiple displays

## Community

### Communication

- **Bug reports & features:** [GitHub Issues](../../issues)
- **Code contributions:** [Pull Requests](../../pulls)
- **General questions:** Open an issue with "Question:" prefix

### Code of Conduct

- Be respectful and professional
- Focus on constructive feedback
- Help newcomers get started
- Credit others' contributions
- Follow medical software best practices

### Recognition

Contributors will be acknowledged in:
- CHANGELOG.md for their specific contributions
- Future releases including their work

## License

By contributing, you agree that your contributions will be licensed under the GNU General Public License v3.0, consistent with the project license.

Third-party components retain their original licenses:
- Tcl/Tk - BSD-style license
- Argyll CMS - AGPL/GPL
- Gnuplot - Custom permissive license

## Questions?

If you have questions about contributing:

1. Check the documentation in `docs/`
2. Search existing [GitHub Issues](../../issues)
3. Open a new issue with "Question:" prefix

Thank you for contributing to pacsDisplay!

---

**Project Website:** [pacsdisplay.org](https://pacsdisplay.org)
**Authors:** M.J. Flynn, N.B. Bevins, P.M. Tchou
