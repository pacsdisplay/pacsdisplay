# Comprehensive Changelog - pacsDisplay Project

All notable changes to the pacsDisplay project are documented in this file, organized chronologically from newest to oldest. This comprehensive version includes all historical information extracted from source files, INSTRUCTIONS files, and devnotes.

---

## Version 6A (2026-03)

**Note:** This represents a major version bump from 5G to 6.0 due to significant architectural changes.

### Major Changes

#### Build System Modernization
- Migrated from starpacks to starkit architecture
- Implemented manifest-driven build system (`build.tcl` + `build_manifest.tcl`)
- Version numbers now extracted automatically from source files
- Command-line version specification for builds
- Automated `VERSION_INFO.txt` generation

#### Distribution Architecture
- Converted starpacks to starkits (requires `basekit.exe` runtime)
- Centralized shared executables in `LIB/` directory
- Included vendor license files in distribution
- Simplified directory structure

### Application Updates - February 2026

**lumResponse 2.5** (December 2025)
- Included HOLD/MOVE information for user in GUI for external display measurements
- Moved to starkit based application
- Updated eval html file to remove targets and include total JNDs
- Reverted to txt based help (instead of pdf)
- Used logging flag in config to enable/disable logging to enable running in read-only environements

**lutGenerate 2.6**
- Moved to starkit distribution
- Rearranged vfs to match other apps
- Reverted to Help_message (from PDF help)
- Displays total DICOM GSDF JNDs based on L'max and L'min values

**iQC 2.3**
- Updated to starkit version
- Included ULN series (18 steps) test patterns
- Supports TG270-pQC, TG270-sQC, and TG270-ULN images
- Added scroll support for changing gray levels in ULN mode

**uniLum 1.2**
- Updated to starkit version
- Added scaling for high dpi systems
- Improved external measurement workflow

**i1meter 1.4**
- Starkit version updates
- Included dpi scaling for high dpi displays
- Shift-click binding to copy luminance and chromaticity values to clipboard

**ambtest 1.2**
- Updated to run from starkit
- Bar pattern uniformity measurements

**gtest 1.4**
- Moved to starkit version
- Updated for high dpi systems
- Improved resize functionality

**EDIDprofile 1.3**
- Moved to starkit distribution format
- Moved support scripts into subdir
- Improved output formatting

**QC-check 2.5** (lumResponse utility)
- Updated to starkit distribution
- Re-analyze cLR data with different Lamb values

**uLRstats 1.2**
- Updated to starkit distribution
- Organized support scripts into tcl subdir within kit
- Reverted to text-based help file
- Improved generic LUT generation workflow

**loadLUTsingle 1.4**
- Revived for use within the pdQC application set
- Updated for starkit distribution
- Renamed from loadLUTdemo for clarity

**pdLaunch 1.3**
- Updated with starkit distribution
- Updated with loadLUTsingle integration
- Updated for high dpi display scaling
- Improved application launcher interface

### Added
- Vendor license files included in `LIB/` (tcl.txt, argyll_v3.5.0.txt, gnuplot.txt)
- External display measurement support
- Total JND calculations across all applications

### Changed
- All modules updated to starkit distribution format
- Documentation reverted to plain text (removed PDF dependencies)
- INSTRUCTIONS files now stored inside `.vfs`, copied during build

### Updated
- Argyll CMS spotread to v3.5.0
- basekit.exe from tclkits.rkeene.org
- Gnuplot libraries

### Fixed
- **lumResponse**: Bug when changing from 256 mode back to 52/18 mode

---

## Version 5G Series (2025)

### January 2025

**lumResponse 2.4**
- Included additional acquisition modes for external display systems with typical patterns
- Corrected issue where 256 mode doesn't load correctly after 18/52 is used
- Added QC (Ext 11) mode for SMPTE pattern measurements (11 gray levels)
- Added QC (Ext 18) mode for external 18-point measurements

**uniLum 1.1**
- Updated to remove adding of Lamb to readings (still use for uniformity calcs)
- Added ability for external measurements
- External mode displays position indicators without measurement window

---

## Version 5F Series (2022)

### July 2022

**lumResponse 2.3**
- Modified save routine to only ask for directory
- No longer uses workstation name for folder creation
- Simplified file save workflow

### May 2022

**uniLum 1.0** (Initial Release)
- Based on i1meter v1.2
- Allows for 9-point uniformity measurement with 1, 3, 18 gray levels
- Outputs Luni.txt file with results in tsv format
- Calculates LUDM (Luminance Uniformity Deviation from Median)
- Calculates MLD (Mean Luminance Deviation)
- Compliant with AAPM Report 270 and TG-18 recommendations
- Supports configurable delay between measurements
- Display ID integration for file naming

### January 2022

**lumResponse 2.2c**
- Made use of env var I1D3_ESCAPE to allow for 3rd party i1d3 meters not already included in spotread
- Improved compatibility with various i1Display Pro rebranded variants

---

## Version 5E Series (2021)

### May 2021

**pdLaunch 1.2**
- Updated with ambtest integration
- Continued png icon conversion
- Improved launcher layout

**pdLaunch 1.1**
- Updated with ambtest
- Converted to png icons from bmp

### April 2021

**iQC 2.2**
- Updated with additional sizes (1024, 1536, 2048)
- Extended to allow any number of imgs, sizes
- More flexible image management system

**iQC 2.1**
- Updated with additional test patterns (TG270-pQC, TG270-sQC)
- Improved comments and code organization
- Removed img package dependencies
- Better cross-platform compatibility

**gtest 1.3**
- Added binding to allow window resize
- Removed bmp dependencies
- Moved procs to .tsp file for better organization
- Simplified procs to remove tweakGray command
- Modified layout to remove borders for cleaner appearance

**ambtest 1.1**
- Updated object to bar pattern (from oval)
- Improved contrast testing methodology
- Better alignment with other test patterns

**ambtest 1.0** (Initial Release)
- Moved into pddev environment
- Moved procs into separate doc
- Low contrast object detection in random locations
- Ambient light verification tool
- Adjustable contrast levels

---

## Version 5D Series (2020)

### April 2020

**lumResponse 2.2b**
- Moved qcmode to the LRconfig file
- Configuration simplification
- Better separation of concerns

---

## Version 5A Series (2019)

### October 2019

**lumResponse 2.2**
- **Major Update**: Complete overhaul to remove Expect usage
- Incorporated other QC methods
- Cleaned up related tsp scripts
- Removed support for IL1700 and LXcan photometers (obsolete hardware)
- Modernized codebase for Windows 10
- TODO: Add ability to measure external devices (completed in 2.4)

**i1meter 1.2**
- Rewritten to remove dependencies on Expect
- Current spotread options only allow for one readout
- Simplified meter communication
- Note: Looking at potential future releases of spotread for continuous output readings

**QC-check** (lumResponse utility)
- Updated to have user input QC type
- Allows re-analysis of cLR files with different Lamb values
- Supports modes: 256, 52, 18, 16

---

## Version 4C Series (2013-2014)

### March 2014

**lumResponse 2.1**
- Increased cLR output format to support the larger precision of the i1Display Pro
- Format now supports up to 7 decimal places for luminance values

### December 2013

**lumResponse 2.1** (Released Dec 15, 2013)
- **2.0 beta feedback update**
- Results saved to a named directory (organized by workstation)
- QC plots include manf & model information
- QC plots now have +/-10%, +/-20% tolerance bands
- Demo mode now has some fake luminance values for testing
- Log now written to directory from config file
- Region size in test image now set from Config
- Gnuplots changed to wxt terminal type (better rendering)
- QC16 u',v' limited to L>=5.0 cd/m2 (IEC requirement)
- Now using new eyeoneUtil.tsp (same as i1meter)
- Now specifying width and height of window and gray region in mm
- Setting pixel pitch using one of four values set in the config file
- QC 16x2 evaluation generates a standalone html report within the results folder
- HTML reports include embedded plots as base64 images

**i1meter 1.1** (Dec 29, 2013)
- Resets meterStatus to 0 after iOneQuit calls
- Posts a message at the beginning about the meter
- For mode changes, changes display to grey 0s (visual feedback)
- Added bindings to put values on the clipboard
  - Right-click on values to copy
  - Shift-right-click to copy all values tab-separated
- Completed the INSTRUCTIONSm.txt file

**pdLaunch 1.0** (Dec 29, 2013) - Initial Release
- Application launcher for pdQC portable package
- Simple interface to launch pacsDisplay programs
- Relative path handling for USB deployment
- Program folder navigation
- Initial bmp icon-based interface

**i1meter 1.0** (Initial Release - Dec 22, 2013)
- Initial test version
- Continuous luminance/illuminance measurement
- Support for i1Display Pro via Argyll spotread
- lum/lux mode selection
- u'v' and C_u'v' chromaticity options
- Averaging capability

**gtest 1.2** (Dec 27, 2013)
- Corrected bug with hex value formats less than 16
- Added leading 0 to the specifier (%02x instead of %2x)
- Adjusting binding on ALT-B1 for focus pattern
- Added ability to set or unset pure R, G, or B color (solid color mode)
- Changed help message so it can stay up for reference (non-modal)

**lutGenerate 2.4** (Dec 2006 - Jan 2007)
- Allowed the user to select the output file location
- Included timestamp in output file
- Modified output to print 'target Lum+Lamb' and 'uLR Lum+Lamb' columns
- Reads the path to the LUT-directory from the Program Files installation directory
- Reorganized the widget layout
- Updated terminology to reflect AAPM, ACR, & IEC documentation
- Now reporting the ambient ratio, Lamb/Lmin as a fraction (typically less than 1)
- Color coding: yellow for TG18 and ACR warning (<1/4), red for TG18 limit (<2/3)
- Added help button with INSTRUCTIONS.txt

**EDIDprofile 1.2** (Dec 2013)
- Selects and makes a save directory (initial directory set in config file)
- Changed name of output file to profile-HOSTNAME_DATE.txt
- TK window is now withdrawn (only the directory select window is shown)
- dumpEdid replies now sent to log file
- Application runs without the console (cleaner execution)
- Asks to view the file at completion
- Reorganized tables for array size
- Added newlines for improved readability
- Now extracts system profile information from Windows registry

**iQC 2.0** (Feb 13, 2014)
- Updated to version 2.0 with help button at upper left
- Improved user interface
- Enhanced pattern management

**loadLUTsingle 1.2** (Dec 2013)
- Read LUTs path from LUTsDir.txt file
- Improved configuration management

**uLRstats 1.1** (Dec 12, 2013)
- Revised config file similar to lumResponse
- Now finds install path or open in directory
- Will run from within the dev directory with LIB and _NEW directories
- Log file now written to user LOGs for installed app
- Now using generic notepad call not notepad.exe in LIB
- Disabled the initial presentation of the select window
- lumResponse no longer measures red, green, blue at the beginning
  - Changed to three black measurements (#000000) for meter stabilization
- Removed the color comparison analysis
  - Values still read and processed but not reported
- Updated for current gnuplot version
- Manf and Model extracted and used to label generic file
- Generic file naming: uLR_MANF_MODEL_GENERIC.txt

### February 2013

**lumResponse 2.0** (Feb 28, 2013)
- **Major Update**: Chrominance measurements added
- For photometers using the Argyll spotread program, the chrominance is now read (u'v')
- QC(16x2) mode software to evaluate the luminance/chrominance response has been rewritten
- Plot formats upgraded with better visualization
- Developed under Windows 7 64 bit
- Uses gnuplot version 4.6
- Uses Argyll version 1.4.0
- Support for the X-rite i1Display Pro using the Argyll spotread program
- New QC color white point tracking analysis
- Plots for D65 (2 degree) target comparison
- u'v' chromaticity coordinate tracking
- C_u'v' distance from D65 white point

---

## Version 4a Series (2011)

### August 2011

**qc16plot** (Aug 26, 2011) - Initial Release
- Utility for re-analyzing QC16x2 cLR data
- Allows evaluation with different Lamb values
- Generates plots and reports from existing cLR files
- Later renamed to QC-check

### June 2011

**lumResponse 1.9** (Jun 01, 2011)
- **Major Update**: Multiple meter support
- Incorporated routines to support the Display 2 Luminance USB meter (i1Display2)
- The Argyll spotread program is used to read the meter continuously and parse the reply
- The three measures at the beginning changed from red, green, blue to black (#000000)
  - i1Display2 stops returning when taken from high luminance quickly to black
  - Probably due to automatic integration time adjustment
  - Argyll routines are a better way to measure white point and color space
  - Keeping three measures maintains uLR format compatibility with lutGenerate
  - Using black may help stabilize the meter
- Added message for record with OTHER mode
- Added QC mode with 16 measures of 2 values
  - Used to assess dL/L vs gray level
  - 16 base gray levels with 2 measurements each
- Corrected help window title

---

## Version 3I+ Series (2008)

### November 2008

**iQC 1g** (Nov 11, 2008)
- Updated version with improvements

### October 2008

**lumResponse 1.8** (Oct 02, 2008)
- Incorporated routines to support the LXcan Luminance meter
- Uses USB connection instead of serial
- Generalized the GUI for any luminance meter
- Abstracted meter-specific code for easier extension
- Supports IL1700 (serial), LXcan (USB), and future meters

---

## Version 1.6-1.7 Series (2006-2007)

### April 2007

**lumResponse 1.7** (Apr 09, 2007)
- Updated to use getEDID 1.1
- Improved EDID parsing and display identification

### January 2007

**lumResponse 1.6** (Multiple dates)
- **Jan 10**: Fixed minor error in display of last sub-step
- **Jan 8**: Minor changes to message windows for clarity
- **Jan 5**: Added outlier indicator in IL window (visual feedback)
- **Jan 4**: Changed font color to dark grey for main values in IL window until initialized
- **Jan 3**: Updated messages before and after luminance acquisition

### December 2006

**lumResponse 1.6** (Dec 17-22, 2006)
- **Dec 17**: Added window for defining settings
  - Test window properties configuration
  - IL1700 initialization settings
  - Restructured main window design
  - IL1700 result incorporated in main window
  - Help dialogues incorporated for settings
- **Dec 18**: Added option to build Display ID from EDID values
  - Automatic extraction of manufacturer and model
  - Serial number integration
- **Dec 19**: Fixed error preventing test image re-initialization
  - Added instructional messages before and during measurement
  - Merged DisplayID and EDID options bar
  - Added tolerance option to outlier checks
  - Added outlier statistics to output (resolved/accepted counts)
  - Updated plot options
    - Plot of luminance vs. p-value
    - Save plots as PNG files
- **Dec 22**: Added additional delay during outlier tests
  - Controlled by config file setting
  - Adjusted display of minor/major states in IL window
  - Correctly matches ILavg value

**lumResponse 1.5f** (Sep 2006 - Dec 2006)
- **Sep 2006**: Added dL/L column to output file
  - Option to plot dL/L after saving
  - Requires Gnuplot in the same directory
- **Nov 2006**: Made command and IL1700 windows visible over all other program windows
  - Always-on-top functionality for critical windows
- **Dec 1**: Changed output format
  - Color measurements start with '#' (treated as comments)
  - Grayscale measurements start at 1 (data lines)
- **Dec 5**: Multiple improvements
  - Added major and minor grey level steps to output (before dL/L column)
  - Changed outlier treatment to catch negative luminance changes
  - Negative changes caught regardless of outlier limit
  - Altered COMnum option to allow any serial port number (not just 1 or 2)
  - Moved wgnuplot.exe to directory specified by lumConfig.txt
- **Dec 6**: Display improvements
  - Changed IL1700 window to display major/minor grey levels starting at 1
  - Changed config file name from lumConfig.txt to LRconfig.txt
  - Included major and minor phases in log file
  - Added relative luminance change to log
  - Added header labels
  - Added option to filter negative luminance changes separately from positive
  - Negative changes no longer automatically treated as outliers
  - Outlier filtering no longer turned off if limit values set to 0
- **Dec 7**: Outlier handling improvements
  - Added option to accept outlier as measurement value (user choice)
  - Formatted log file to line up columns
  - Formatted output file to line up columns
  - Fixed error with major and minor phases in output file
- **Dec 14**: Major outlier handling rewrite
  - Fixed error in outlier handling
  - Now handled in lumResponse.tcl (not in tL_IL1700.tsp)
  - Added config option to limit number of outlier tests
  - Added config option for verbose logging
  - When set, log file includes all data from IL1700
  - This was previously the default behavior
- **Dec 15**: Code reorganization
  - Restructured code to put procedures in subdirectory
  - Moved xirlDef to sourced file
  - Output log entries to console for debugging
  - Minor formatting changes to log and output files
  - Added timestamp to files
  - Fixed error where outliers not tallied properly
  - Changed default mode to 1786

**iQC 1.0** (Dec 20, 2006) - Initial Release
- Display image quality control test patterns
- TG18 test pattern support
- Full-screen pattern display
- Basic pattern navigation

**gtest 1.1** (Dec 18, 2006)
- Added functions to adjust color balance
- R, G, B individual adjustments
- Fine control over color output

**gtest 1.0b** (Oct 06, 2006)
- Incorporated tcl call to get path
- Allows bmp image reads when wrapped with TclApp

**gtest 1.0a** (Oct 01, 2006)
- Changed focus canvas widget to fill with black
- Pattern is now black and gray (gray = current widget color)

**gtest 1.0** (Sep 25, 2006)
- Initial release
- Gray level adjustment utility
- Rectangle and oval patterns
- Focus pattern overlay

**lutGenerate 2.3** (Sep 2006 - Nov 2006)
- **Sep 2006**: Interface improvements
  - Removed mode button (using only text mode)
  - Changed default ambient Luminance to 0.1 cd/m²
  - Updated displayed luminance values
  - Added ambient luminance to displays
  - Added minimum luminance to displays
  - Added target values after ambient included
  - Target minimum luminance font changes to red if below available minimum
  - Added target amb/min luminance to displayed values
  - Font color coding based on AAPM TG-18 guidelines:
    - 0.00-0.25: black (good)
    - 0.25-0.66: yellow (acceptable)
    - 0.66+: red (unacceptable)
  - Starting directory for uLR files set to "C:\Program Files\HFHS\pacsDisplay-BIN"
- **Nov 2006**: Usability improvements
  - Edited values to be more intuitive
  - Altered Ambient ratio to match AAPM TG-16
  - Added maximum possible luminance display
  - Target maximum luminance font changes to red if above available maximum
  - Re-arranged interface
  - Changed formatting of text for easier understanding
  - Starting directory changed to new LUTs directory
  - Removed starting luminance values (cleaner interface)
- **Dec 2006**: Version included in window title

**uLRstats 1.0** (Dec 05, 2006)
- Initial release
- Added dL/L plot for average palette
- Checks each file and average file for non-increasing values
- Writes issues to log file
- Adds note in message dialogue if non-increasing values found
- Checks palette size
- Identifies files with different palette sizes
- Reads each file, tests first line, checks number of lines
- Added hex RGB column to average response
- Enables lutGenerate to create calibration LUT from generic uLR

**loadLUTsingle 1.1** (Dec 2006)
- Adjusted to new LUT-Library structure
- Updated path handling

**loadLUTsingle 1.0** (May 2005 - Dec 2006)
- **May 2005**: Initial version
- **Dec 2006**: Version included in window title
- Simple interface for loading LUTs to graphics card
- Supports single display LUT loading

---

## Version 1.5 Series (2005)

### November 2005

**lumResponse 1.5e** (Nov 2005)
- Allowed switching of COM ports in config file
- Improved serial port flexibility

### May 2005

**lumResponse 1.5d** (May 2005)
- Line changed in lumConfig.txt
- Permits improved wrapping with tclApp
- New executable generation

---

## Version 1.5 Series (2004)

### January 2004

**lumResponse 1.5c** (Jan 2004)
- Default output filename changed
- Includes "cLR" or "uLR" depending on mode
- Better file organization

---

## Version 1.5 Series (2003)

### October 2003

**lutGenerate 2.2** (Oct 2003)
- Final release of 2.2 series
- Stable version for production use

### April 2003

**lumResponse 1.5b** (Apr 2003)
- Included tests of pure R, G, and B outputs
- Pauses allow IL1700 time to adjust
- Improved meter stabilization

---

## Version 1.5 Series (2002)

### November 2002

**lumResponse 1.5a** (Nov 2002)
- Provided means to cancel data acquisition
- No longer requires closing entire program
- Improved user experience during long measurements

### October 2002

**lumResponse 1.5** (Oct 2002)
- Allowed RGB phase changes directed by text file
- Added means to filter out extraneous luminance values
- Statistical filtering of measurements
- Log file output added
- Detailed measurement logging

### August 2002

**lumResponse 1.4** (Aug 2002)
- Stripped down version of 1.3
- Focused on grey palette measurement
- Simplified for production use

---

## Version 1.1-1.3 Series (2001)

### November 2001

**lumResponse 1.3** (Nov 2001)
- Version updates
- Bug fixes and stability improvements

---

## Version 1.0-1.2 Series (2000)

### October 2000

**EDIDprofile 1.0** (Oct 2000)
- Initial release
- EDID extraction from Windows registry
- Display property reporting

---

## Version 1.0-1.2 Series (1999)

### October 1999

**lumResponse 1.2** (Oct 1999)
- Added support to sequence RGB values
- Through a 3 x 256 set
- Enhanced color calibration capabilities

### June 1999

**lumResponse 1.1** (Jun 1999)
- Changed region color definition
- Supports RGB color types for special calibrations
- Background remains gray with R=G=B

---

## Complete Application Version Summary (Feb 2026)

| Application | Version | Initial Release | Latest Update | Purpose |
|-------------|---------|----------------|---------------|---------|
| lumResponse | 2.5 | Jun 1999 | Dec 2025 | Luminance response measurements (uLR/cLR) |
| lutGenerate | 2.6 | Oct 2003 | Feb 2026 | Generate DICOM calibration LUTs |
| iQC | 2.3 | Dec 2006 | Feb 2026 | Image quality control test patterns |
| uniLum | 1.2 | May 2022 | Feb 2026 | Luminance uniformity measurements |
| i1meter | 1.4 | Dec 2013 | Feb 2026 | Continuous luminance/illuminance measurement |
| ambtest | 1.2 | Apr 2021 | Feb 2026 | Ambient light verification |
| gtest | 1.4 | Sep 2006 | Feb 2026 | Gray level adjustment utility |
| EDIDprofile | 1.3 | Oct 2000 | Feb 2026 | EDID profile extraction |
| QC-check | 2.5 | Aug 2011 | Feb 2026 | Re-analyze cLR data with different Lamb (originally qc16plot) |
| uLRstats | 1.2 | Dec 2006 | Feb 2026 | Generic LUT generation from multiple uLRs |
| loadLUTsingle | 1.4 | May 2005 | Feb 2026 | Load LUT to graphics card |
| pdLaunch | 1.3 | Dec 2013 | Feb 2026 | Application launcher |

---

## Key Features and Technology Evolution

### Meter Support Evolution
- **1999-2008**: IL1700 (serial port) photometer primary support
- **2008**: Added LXcan USB photometer support
- **2011**: Added i1Display2 USB colorimeter support
- **2013**: Added X-Rite i1Display Pro support (became recommended device)
- **2019**: Removed IL1700 and LXcan support (obsolete hardware)
- **2019-present**: i1Display Pro and variants only (including rebranded versions)

### Software Architecture Evolution
- **Pre-2006**: Basic Tcl/Tk scripts
- **2006**: Modular architecture with sourced .tsp files
- **2006-2019**: TclApp wrapped starpacks with Expect package
- **2019**: Removed Expect dependency, direct spotread integration
- **2025-2026**: Migration to starkit/starpack distribution format
- **2026**: Manifest-driven build system

### QC Mode Evolution
- **2006**: QC 16x2 mode introduced (16 base levels, 2 measurements each)
- **2011**: Enhanced QC mode with 16 measures
- **2013**: QC mode with html reports and embedded plots
- **2013**: White point tracking and chromaticity analysis
- **2019**: Multiple QC modes (256x1, 52x1, 18x1, 16x2)
- **2025**: External display measurement modes (11, 18) for systems where direct measurement isn't possible

### Display Technology Support
- **1999-2006**: CRT-focused features (RGB phosphor tests)
- **2006-2011**: Transition to LCD displays
- **2011-2013**: Modern LCD with LED backlighting
- **2013-2019**: Wide color gamut displays
- **2025**: External display measurements
- **2026**: High DPI displays (UI improvement)

### Standards Compliance Evolution
- **Early versions**: Basic DICOM GSDF compliance
- **2006**: AAPM TG-18 (Report OR-3) compliance
  - 18-point QC measurements
  - dL/L contrast evaluation
  - ±10% and ±20% tolerance bands
- **2013**: IEC 61223-2-5 standard compliance
  - Minimum luminance requirements
  - Ambient light ratio limits
- **2014**: ACR-AAPM-SIIM Technical Standard compliance
  - Electronic Practice of Medical Imaging
  - Diagnostic vs. general use specifications
- **2019+**: ACR-AAPM-SIIM updated standards
- **2022+**: AAPM Report 270 compliance
  - Uniformity measurements (LUDM, MLD)
  - 3-level routine testing
  - Total JND calculations

### Measurement Capabilities Evolution
- **1999**: Basic luminance measurements (256 gray levels)
- **2002**: RGB palette perturbations (1786 mode for color, 766 for monochrome)
- **2006**: dL/L contrast calculations and plotting
- **2011**: Chromaticity measurements (u'v')
- **2013**: White point tracking, D65 distance calculations
- **2022**: Uniformity measurements (9-point LUDM/MLD)
- **2025**: External display measurements with countdown timers
- **2026**: Total JND reporting across luminance range

### Output and Reporting Evolution
- **Early versions**: Simple text files
- **2006**: Formatted text with column alignment, timestamps
- **2006**: Gnuplot integration for visualization
- **2013**: HTML reports with embedded base64 images
- **2013**: PNG plot exports
- **2013**: Detailed log files with measurement statistics
- **2022**: TSV format for uniformity data
- **2026**: Comprehensive QC reports with total JND information

### Configuration Management Evolution
- **Early versions**: Hard-coded values
- **2002**: lumConfig.txt introduction
- **2006**: Renamed to LRconfig.txt, expanded options
- **2013**: Separate config files per application
- **2013**: Config files outside executable (not wrapped)
- **2025**: Enhanced config with external measurement parameters

### User Interface Evolution
- **Early versions**: Basic Tk widgets
- **2006**: xirlDefs style standardization
- **2006**: Help dialogs and instructions
- **2013**: Modern button styles and layouts
- **2013**: Always-on-top windows for critical displays
- **2021**: High DPI awareness
- **2026**: Scaled UI for high DPI displays (dpiscale)

---

## Development Team History

### Primary Authors
- **Michael J. Flynn** - Original author, Henry Ford Health Systems
  - X-ray Imaging Lab, Henry Ford Health
  - Nuclear Engineering and Radiological Sciences, University of Michigan
  - Primary developer: 1999-2014
  - Continued contributions: 2014-2019

- **Philip M. Tchou** - Co-developer
  - X-ray Imaging Lab, Henry Ford Health Systems
  - Contributions: 2003-2014

- **Nicholas B. Bevins** - Lead developer (recent versions)
  - Imaging Physics, MaineHealth Maine Medical Center - Portland, ME
  - Lead developer: 2019-present
  - Major contributions: Windows 10 compatibility, starkit migration, external measurements
  - ambtest, uniLum tools
  - TG270 integrations
  - github and pacsdisplay.org management
  - pdweb tools

### Institutional Affiliations
- X-ray Imaging Research Laboratory, Henry Ford Health (formerly Henry Ford Health Systems)
- Nuclear Engineering and Radiological Sciences, University of Michigan
- Imaging Physics, MaineHealth Maine Medical Center

### Copyright
Copyright: Xray Imaging Research Laboratory, Henry Ford Health, Detroit, Michigan

---

## Technology Stack Evolution

### Core Technologies
- **Tcl/Tk**: 8.4 → 8.5 → 8.6
- **TclKit/Basekit**: ActiveState → rkeene.org builds
- **Packaging**: tclApp starpacks → starkits

### External Dependencies
- **Argyll CMS**: 1.4.0 → 3.5.0
  - spotread utility for meter communication
  - Color management calculations
- **Gnuplot**: Various versions → 4.6
  - Scientific plotting
  - QC chart generation
- **getEDID**: Custom C++ utility
  - Windows registry access
  - EDID extraction

### Supported Platforms
- **Windows XP** (2003-2014)
- **Windows 7** 32-bit and 64-bit (2013-2020)
- **Windows 10** (2019-present)
- **Windows 11** (2021-present)

---

## Distribution Formats Evolution

### Early Versions (1999-2006)
- Standalone Tcl scripts
- Required Tcl/Tk installation
- Manual dependency management

### Wrapped Versions (2006-2019)
- TclApp wrapped starpacks
- All dependencies bundled
- Single executable per application

### Starkit Distribution (2019-2026)
- Separate runtime (basekit.exe)
- Shared library directory (LIB/)
- Smaller per-application size
- Easier updates and maintenance

### Current Distribution (2026)
- Starkit .kit files
- Shared basekit.exe runtime
- Centralized LIB/ with common executables
- Vendor license files included
- Manifest-driven build system

---

## Documentation Evolution

### Early Versions
- Minimal inline comments
- Basic README files

### 2006-2013
- INSTRUCTIONS.txt files per application
- PDF help documents
- Integrated help dialogs

### 2013-2019
- HTML help with embedded images
- Online documentation links
- Comprehensive INSTRUCTIONS files

### 2019-2026
- Return to text-based help (better maintainability)
- INSTRUCTIONS files stored in .vfs
- Markdown documentation (this file)
- Integrated ? help buttons

---

*This comprehensive changelog is compiled from:*
- *Source code header comments in all .tcl files*
- *INSTRUCTIONS.txt files from all applications*
- *Version history embedded in code*
- *Git commit history (where available)*
- *Development notes and release documentation*

*Last updated: March 2026*
