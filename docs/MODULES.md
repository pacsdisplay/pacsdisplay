# Module Documentation

Detailed documentation for all pdQC/pacsDisplay applications based on their INSTRUCTIONS files.

## Table of Contents

- [lumResponse](#lumresponse) - Luminance response measurement
- [lutGenerate](#lutgenerate) - LUT generation
- [iQC](#iqc) - Image quality test patterns
- [uniLum](#unilum) - Uniformity measurements
- [i1meter](#i1meter) - Simple luminance meter
- [ambtest](#ambtest) - Ambient light verification
- [gtest](#gtest) - Gray level uniformity
- [uLRstats](#ulrstats) - Generic LUT analysis
- [loadLUTsingle](#loadlutsingle) - LUT loading

---

## lumResponse

**Purpose:** Measure display luminance response and create calibration data

### Overview

The lumResponse application measures the gray palette for a display and records the luminance values in uLR (uncalibrated luminance response) or cLR (calibrated luminance response) text files. uLR palettes are used to generate DICOM calibration LUTs. cLR values are used to evaluate calibrated displays in relation to the DICOM GSDF.

The program displays a large secondary window with an optional grey background and a central square target region. The target gray level is varied to assess display luminance response. Measurements are made by luminance meters (photometers or colorimeters) connected via USB.

### Mode Options

#### For uLR measurement (Palette modes):

**1786 Palette**
- Used for measuring the uncalibrated luminance response of a color display
- Make sure the display is using a linear LUT (no calibration) before proceeding
- 7 sub-steps per gray level

**766 Palette**
- Used for measuring the uncalibrated luminance response of a monochrome display
- Make sure the display is using a linear LUT (no calibration) before proceeding
- 3 sub-steps per gray level

#### For cLR measurement (QC modes):

**QC (256x1)**
- Used for measuring the luminance response to verify DICOM calibration is in place
- One measurement made for each of the 256 driving levels

**QC (52x1)**
- Used for measuring the luminance response to verify DICOM calibration is in place
- One measurement made every five driving levels

**QC (18x1)**
- Used for measuring the luminance response to verify DICOM calibration is in place
- One measurement made every 15 driving levels
- This is the mode specified in AAPM Report OR-3 (TG18) for routine QC

**QC (16x2)**
- Used for measuring the luminance response to verify DICOM calibration is in place
- Two measurements made at each of 16 different primary driving levels (8, 24, 40, ...248)
- Measurements made at driving levels just above and below the primary driving level from which contrast is computed

**QC (External 18)**
- Used for measuring the luminance response of an external display to verify DICOM calibration
- User is responsible for placing the photometer on the external display and controlling the appropriate gray level
- One measurement made every 15 driving levels
- Appropriate patterns include TG18-LN, TG270-ULN series, TG18-pQC, TG270-pQC, and TG270-sQC patterns

**QC (External 11)**
- Used for measuring the luminance response of an external display to verify DICOM calibration
- User controls appropriate gray level for each measurement
- One measurement made every 25.5 driving levels (rounded to nearest integer)
- Intended for use with the SMPTE pattern available on many modality acquisition workstation displays

#### Other modes:

**DEMO MODE**
- For demonstration purposes
- Quickly cycles from black to white but no measurements are taken
- Meter does not need to be connected

**OTHER**
- Allows user to use a customized perturbation series for luminance measurements
- For advanced users only

### Geometry and Meter Options

**GEOM Options**
- Customize the geometry and position of the test image window
- Initial values set in LRconfig.txt file in the lumResponse directory

**METER Options**
- Selection of meter model
- Settings affecting how display luminance is measured
- Help buttons ("?") next to each setting provide additional information

### Supported Meters

**X-Rite i1Display Pro**
- Recommended device for purchase ($200-250 USD)
- Improved precision and faster response than previously supported photometers
- Also sold as: NEC SpectraSensor Pro, DisplayPro Plus, ColorMunki Display/i1Display Studio, Calibrite ColorChecker Display/Pro/Plus, and others
- Communicates via USB as human interface device (HID) using Windows HID driver
- Generally ready to use without loading a driver

### Making Measurements

#### Setup Steps:

**Step 1: Position Test Image**
- Opens test image window that needs to be centered on the screen of the display to be measured
- Window should be about the same size as the screen
- Window size can be changed manually using GEOM settings

**Step 2: Initialize Meter**
- Begins communication with the luminance meter
- Activates the meter display at the bottom of the window
- Position the luminance meter in front of the display, centered on the square target
- Meter should be positioned close to or in contact with the display surface

**Step 3: Record Data**
- Starts the measurement process
- User will be asked to confirm monitor is in correct calibration (linear for uLRs and DICOM for cLRs)
- Ensure power saver settings will not cause screen to darken
- Pressing button during measurement will pause and provide option to abort or continue

**Step 4: Save Data**
- Press to save luminance data once measurement is complete
- User will be asked where to save the output file
- Default directory is the _NEW folder
- Option to plot luminance vs p-values is provided after data is saved

#### Display ID Creation:

- Create Display ID to identify measurement results
- Name selected will be used to name the output file
- "Display #" box selects the display to identify (same as Windows Display Properties)
- "GET EDID ID" button retrieves model and serial number (S/N) from EDID
- Custom ID can be entered in text box if desired
- Suggested to include model and serial number of display

### Output File Columns

**MEASUREMENT No.**
- Sequential measurement number

**AVG LUMINANCE**
- Average luminance value measured for each gray step

**RGB VALUE**
- Hexadecimal RGB value for the measurement

**GRAY-STEP**
- Current stage of luminance measurement
- Represents standard graylevel (1-256)

**SUB-STEP**
- Represents perturbation steps in graylevel sequence
- 7 sub-steps in 1786 mode
- 3 sub-steps in 766 mode
- 256, 52, 18, 11, and Demo modes do not use sub-steps

**dL/L**
- Relative difference between current and prior measurement

**u'**
- Chromaticity u' value (for supported meters, Yuv, CIE 1976)

**v'**
- Chromaticity v' value (for supported meters, Yuv, CIE 1976)

### Output Files

Files saved with names:
- **uLR_MANF_MODEL_SN.txt** - Uncalibrated palette files
- **cLR_MANF_MODEL_SN.txt** - Calibrated QC files

The luminance response recorded represents surface luminance in the absence of reflected room lights (Lamb). When doing QC evaluations or computing DICOM calibration LUTs, Lamb value is specified and added to each value.

### QC Evaluations

The American Association of Physicists in Medicine (AAPM) described a quantitative test of a DICOM calibrated monitor in 2005 (AAPM On Line report #3).

#### QC (256, 52, 18, 11, 16x2) Evaluation:

The lumResponse application includes routines to evaluate QC 256, 52, 18, 11, 16x2 cLR. The AAPM and IEC method makes 18 luminance measurements at equally spaced gray levels (Digital Driving Levels, DDL). For 256 gray levels, these are spaced every 15 gray levels (17 x 15 + 1 = 256). 17 relative luminance changes are evaluated and contrast is compared to DICOM GSDF.

**ACR-AAPM-SIIM Technical Standard for Electronic Imaging recommends:**
- Contrast response of monitors for diagnostic interpretation should be within 10% of GSDF over full LR
- For other uses, contrast response should be within 20% of GSDF over full LR

**QC 16x2 Mode Protocol:**
- Essentially same as AAPM and IEC method
- 16 pairs of measures made over full range of 256 level grayscale
- Base value for each measurement pair increments in steps of 16: 0, 16, 32, ..., 240
- Two measures made by adding 5 or 11 to base value with R, G, and B values equal
- Contrast evaluated represents contrast estimate (dL/L) for levels of 8, 24, 30, 46, ..., 248 with contrast computed for gray level changes of 6
- Improved estimate compared to gray level changes of 15 for AAPM/IEC method
- Protocol makes three measurements of Lmin at gray level 0 and one measurement of Lmax at gray level 255

Note: Protocol set in 16phase.txt file in lumResponse application directory.

#### QC Evaluation Output:

After saving QC cLR, user has option to evaluate results. Output includes:

**QC-lr.txt** - Evaluation report placed in same folder

**Graphic plots (PNG format):**
- **QC-Plot-LUM.png** - Luminance vs Gray Level (semi-log plot)
- **QC-Plot-dLL.png** - Contrast (dL/L) vs Gray Level with 10% and 20% error conditions; maximum relative error, L'max and L'min labeled
- **QC-Plot-JND.png** - JNDs per Gray Level vs Gray Level (see DICOM 3.14)
- **QC-Plot-uv.png** - Color gray tracking with u'v' relative to D65

**QC-plot.gpl** - Gnuplot command file left in folder

Evaluation uses default Lamb value from 'METER' options. Results can be re-evaluated with different Lamb using QC check application.

---

## lutGenerate

**Purpose:** Generate DICOM GSDF calibration LUTs from uncalibrated luminance response files

### Overview

Calibration of a display using pacsDisplay involves loading a look-up table (LUT) to the graphic driver. The LUT is a list of 256 RGB values used to replace standard grayscale values (R=G=B) to match the DICOM grayscale display function (GSDF). Creating the LUT requires measuring the full range of gray values the display is capable of (grayscale palette), then using those values closest to the desired DICOM GSDF in a calibration LUT.

LutGenerate takes a uLR file (output by lumResponse) and builds a LUT file based on parameters specified.

### Basic Usage Steps

**Step 1: Select a uLR File**
- Press "SELECT FILE" button and choose appropriate uLR file for the display to be calibrated
- LutGenerate reads the uLR file and automatically updates fields throughout the window
- 'Desired Maximum Luminance' field set to maximum luminance value found in uLR file
- Both display name and desired maximum luminance may be changed manually after loading uLR

**Step 2: Determine Calibration Parameters**

Three parameters must be specified:

**Lamb**
- Ambient luminance expected for the display
- Typically measured using photometer when display is turned off with room lighting set to desired illumination
- Room lights should not cause direct specular reflections on display surface

**L'max**
- Desired combined maximum luminance (maximum from display plus ambient luminance: Lmax + Lamb)
- Initial value set at maximum from selected uLR file plus entered Lamb
- If changed, must be lower than shown initially

**r'**
- Luminance ratio equal to L'max/L'min
- ACR-AAPM-SIIM Technical Standard for Electronic Practice of Medical Imaging and AAPM Report 270 recommend value of 350 for displays with luminance levels typical of most systems
- For displays with much higher luminance levels (~1000 cd/m²), lower luminance ratios may be used to achieve same total number of JNDs (~600 for display with Lmin ~1 and Lmax ~350)

Typically L'max is left at value from uLR and default r' of 350. Lamb may need adjustment (along with room lighting) to maintain Ar within acceptable range.

**Step 3: Verify Calibration Parameters**

Hit 'ENTER' key after changing calibration parameter to update values:

**Ar, Lamb/Lmin (Ambient Ratio)**
- AAPM Reports OR03 (TG18) and 270 call for this value to be no more than 2/3
- Recommends value of less than 1/4
- Text changes to yellow if value above 1/4 but less than 2/3
- Red if above 2/3

**Total DICOM GSDF JNDs**
- For displays with operating parameters near default values (L'max 350 cd/m², L'min 1.0 cd/m²), total JNDs will be ~600 (581.6 if numbers exact)
- Luminance ratio (r') serves as convenient means of matching display appearance across displays without calculating total JNDs
- Total JNDs potentially better indicator of contrast appearance
- For display systems with operating parameters significantly different from defaults, matching total JNDs may provide superior contrast resolution matching

**Target Lmax**
- Maximum luminance resulting from loading generated LUT in graphic driver in absence of ambient luminance (Lmax not L'max)
- Text turns red if goes above possible maximum luminance indicated by uLR

**Target Lmin**
- Minimum luminance resulting from loading generated LUT in graphic driver in absence of ambient luminance (Lmin not L'min)
- Text turns red if goes below possible minimum luminance indicated by uLR

**Possible Lmin**
- Minimum luminance found in selected uLR file

**Possible Lmax**
- Maximum luminance found in selected uLR file

Check to be certain values are correct before continuing.

**Step 4: Generate the LUT**
- Click "GENERATE" button to build calibration LUT
- User will be asked where to save LUT file
- For full installations, commonly stored within LUT-Library/_NEW directory in folder specific to workstation display

### Output

LUT text files containing 256 RGB triplets

---

## iQC

**Purpose:** Display image quality control test patterns

### Overview

iQC provides interactive quality control test patterns for display assessment. The application displays resizable test patterns with keyboard and mouse navigation controls.

### Available Images

- **TG270-pQC** - Perception Quality Control pattern
- **TG270-sQC** - Standard Quality Control pattern
- **TG270-ULN** - Uniformity/Luminance pattern

### Controls

#### To change image and window size:
- **Right Arrow** - Show larger image in larger window
- **Left Arrow** - Show smaller image in smaller window

#### To change image size and pan image:
- **Up Arrow** - Show larger image in same window
- **Down Arrow** - Show smaller image in same window
- **Left Mouse** - Click and drag to pan image

#### To change the image:
- **Right Click** - Cycles through available images

#### To change gray level (ULN only):
- **Scroll Up/Down**
- **Page Up/Down**

### Pattern Descriptions

#### pQC Bar patterns

**Contrast (2 sections of 4 regions)**
- Outer section - 8 gray levels
- Inner section - 2 gray levels

**Frequency (4 regions in each section)**
- 4 pixels per line pair
- 6 pixels per line pair
- 12 pixels per line pair
- 18 pixels per line pair

#### sQC Bar patterns

**Contrast (bar patterns within squares)**
- Upper left - 5 gray levels (+3 in 0 square)
- Lower left - +5 gray levels (-3 in 255 square)

#### ULN patterns

9 regions for uniformity and luminance response measurements

---

## uniLum

**Purpose:** Automated collection of luminance uniformity data

### Overview

The uniLum program automates collection of luminance uniformity data of a display system. The software displays a window for the user to resize to the desired measurement area. The software interfaces with an X-Rite i1Display Pro photometer (or rebranded names) using the ArgyllCMS spotread utility. The spotread utility returns the luminance reading for each gray level within each location on the display.

At completion, the software can display results in a text window for copying to another location. User has ability to save results to a .txt file. Both text window and .txt file present the luminance uniformity deviation from the median (LUDM) and mean luminance deviation (MLD), as defined in AAPM reports 270 and TG-18, at each gray level and maximum values across all gray levels.

For external measurements, measurements use nine values and go from upper left to upper right, then middle right to middle left, and finally from lower left to lower right. The program interface shows the position of the measurement.

### Usage

**Image**
- Opens new window for uniformity measurements
- Window can be resized to allow for arbitrary display matrix
- Upper left part of pattern shows first region to be measured
- Target circle in center for photometer placement

**Read**
- Begins measurements
- Initiates delay countdown
- After delay, first series of measurements take place within first region
- Number of measurements controlled by user selection of 1-, 3-, or 18-levels
- Levels passed to initial call, so changing mid-read has no effect on current sequencing
- External measurements always use 1 level

**Save**
- Saves measurements after completing
- Option to save results to .txt file
- File contains: date/time, configuration settings, measured values for each point, LUDM/MLD calculations at each gray level, overall maximum

**Play/Pause**
- User can "pause" measurement process during delay countdown
- Process waits until "play" button selected to resume measurements

### Options

**Levels**
- User selects desired number of gray levels to measure at each uniformity position
- Gray levels defined in uniConfig.txt file
- Pre-loaded values roughly correspond to:
  - 1-level: 80% level
  - 3-level: 10%, 50%, and 80% levels
  - 18-level: every 15 gray levels
- AAPM report 270 recommends measuring 3 levels for routine testing
- For external measurements, only one level measured

**Lamb**
- Lamb text entry automatically added to each measured luminance level to record combined luminance
- Changing after measurement completed has no effect on saved data

**Delay**
- Delay in lower right of measurement window shows live counter of time until next measurement sequence begins (in seconds)
- User can adjust time by clicking up/down arrows with left mouse button before measurements begin

**Display ID**
- Display ID appended to end of file name when saving

### Features

**Calibration**
- config-meter.txt file in distribution directory has variable to adjust meter readings
- iLcalVal is multiplicative calibration factor
- Software distributed with calibration factor of 1.0

**Averaging**
- Application averages sequential meter values before updating display
- Number of values to average set by avgN variable in uniConfig.txt file in distribution directory
- Software distributed with avgN set to 2
- Small numbers at bottom of meter show value of avgN

---

## i1meter

**Purpose:** Continuous measurements of luminance or illuminance and chromaticity

### Overview

The i1meter application makes continuous measures of luminance or illuminance and chromaticity using a colorimeter. The Xrite i1Display Pro is currently the only supported colorimeter. Available through distributors at cost of about $200-$250. OEM versions such as SpectraCal Pro function equivalently.

No special drivers required. Devices function as Human Interface Device (HID) and will load standard Windows HID driver. The i1meter application uses spotread program from Argyll Color Management System which can report luminance (cd/m²) or illuminance (lux) depending on position of diffuser shield. For either luminance or illuminance, spotread reads chromaticity as CIE u',v'.

### Usage

**READ**
- With meter connected to USB port, READ button measures desired value the number of times required by avgN
- Note: i1Display Pro integration time varies with luminance; measures are slow at low luminance

### Options

**lum or lux**
- Options for Luminance (cd/m²) or Illuminance (lux)
- Meter starts with setting of Luminance
- If changed, meter must be restarted

**u',v' or C_u'v'**
- Options for chromaticity units
- Either u',v' (CIE 1960) or vector distance between u',v' and D65 2 degree observer white point
- If changed, meter must be restarted

### Features

**Clipboard**
- When cursor over either luminance/illuminance value or chromaticity value, value can be copied to Windows clipboard using right mouse button
- Values can then be pasted to editor or spreadsheet
- Using shift-click on luminance values will include color coordinates as well (as tab separated values)

**Calibration**
- config-meter.txt file in distribution BIN directory has variable to adjust meter readings
- iLcalVal is multiplicative calibration factor
- Software distributed with calibration factor of 1.0

**Averaging**
- Application averages sequential meter values before updating display
- Number of values to average set by avgN variable in config-meter.txt file in distribution directory
- Software distributed with avgN set to 2
- Small numbers at bottom of meter show value of avgN along with individual meter luminance/illuminance values as acquired
- Value can be increased/decreased by clicking on it with left/right mouse buttons

---

## ambtest

**Purpose:** Ambient Light Visual Test

### Overview

A low contrast bar pattern is located randomly on the background. Used to verify low contrast visualization in the darkest part of the operating range. Adjustment of ambient lighting or grayscale calibration may be required to visualize.

### Controls

**B1 (left click)**
- Click on low contrast object with left mouse button
- Success message displayed if object is clicked
- If missed, failure is displayed

**Move**
- Click on Move to relocate low contrast object

**Change Contrast (Shift-Click)**
- Shift-click with left or right mouse buttons to increase/decrease contrast of low contrast object
- One click increases by one gray level
- Right/left clicks on current contrast display will also adjust contrast

---

## gtest

**Purpose:** Gray level uniformity and color balance assessment

### Key Bindings

#### Bindings on Gray Region

- **B1** - Change gray value by -15
- **B3** - Change gray value by +15
- **CTRL-B1** - Change gray value by -5
- **CTRL-B3** - Change gray value by +5
- **SHFT-B1** - Change gray value by -1
- **SHFT-B3** - Change gray value by +1
- **ALT-B1** - Show or hide focus pattern
- **CTRL-SHFT-B1** - Show or hide RGB values

#### Bindings on Color Balance Values (upper right)

- **B1** - Change R, G, or B value by -15
- **B3** - Change R, G, or B value by +15
- **CTRL-B1** - Change R, G, or B value by -5
- **CTRL-B3** - Change R, G, or B value by +5
- **SHFT-B1** - Change R, G, or B value by -1
- **SHFT-B3** - Change R, G, or B value by +1
- **ALT-B1** - Set R, G, or B to solid color
- **ALT-B1** - If set, unset solid color

#### Start Control

- **B1 - START** - Hide focus pattern

---

## uLRstats

**Purpose:** Evaluate uLRs and produce generic uLR files for LUT generation

### Overview

Experience shows that displays with same manufacturer and model will have uncalibrated response file that is similar except for brightness variations. This results if manufacturer changes model designation when LCD panel used for product line is changed. In this case, a generic LUT can be used for DICOM calibration without having to measure S/N specific uLR and create S/N specific LUT.

uLRstats is a tool to evaluate uLRs of a set of displays, identify those to be used as basis of generic uLR, and produce file with average luminance for each palette entry. This can then be used with lutGenerate to build generic LUT file.

### Selecting Files

When uLRstats first run, use SELECT button to select directory with set of uLRs to be evaluated.

Within Select window:

1. Use Path button to select uLR directory from Folder Browse window. Window should open with NEW directory of LUT-Library where new display folders can be built. Closing window with OK enters selected folder path in filePath entry.

2. Assuming uLRs all have filenames of form uLR*.txt, use Glob button to build list of filenames.

3. Highlight files to be evaluated using SHIFT+<LEFT CLICK> and CTRL+<LEFT CLICK>.

4. After files selected, close Select window with OK.

Processing bar at bottom of application window will change to indicate number of uLRs to analyze. Use this button to begin.

### Analysis

During analysis, uLRs checked for unusually large changes in luminance, dL/L. These recorded in log file. Dialogue window will report total number and offer to open log file. Not unusual to have modest number of out-of-limit changes.

### Output Files

Analysis creates six files in uLR directory:

**uLR_[MANUFACTURER]_[MODEL]_GENERIC.txt**
- The average uLR

**uLR-LminLmax**
- Table of Lmin, Lmax, and filename for each uLR processed
- Useful when evaluating which files may not want to be included in generic uLR
- Order of files corresponds to number in plots

**uLR-plot.gpl**
- Gnuplot command file to generate three plots shown in window and saved as png files

**uLR-Plot_LminLmax.png**
- Plot of Lmax vs Lmin

**uLR-Plot-dL_L.png**
- Plot of dL/L values for each palette entry and file

**uLR-PlotULRs.png**
- Plot of luminance vs palette entry for each file

### Typical Workflow

uLRs typically evaluated in two steps:

1. First, all uLRs evaluated together
2. Displays with atypical uLRs identified from plots
3. Second analysis done using only typical uLRs

When done, generic LUT can be built with lutGenerate.

---

## loadLUTsingle

**Purpose:** Load calibration LUT to graphics card for specified display

### Overview

The loadLUTsingle application loads a LUT file to the graphics card of the system for a specified display ID. LUTs can be generated using lutGenerate application and corresponding uLR file measured with lumResponse application. Display ID is visible in EDID profile, but may change if system goes through power cycle or if displays are added/removed.

Full installation of pacsDisplay can be configured to automatically load LUTs for all connected displays at startup, enabling DICOM compliance for all configured displays.

### Controls

**LUT**
- Select LUT to select desired LUT to load
- LUT should correspond to make/model of display

**LOAD**
- LOAD the specified LUT to the specified Display ID

---

## Common Notes

### File Naming Conventions

- **uLR files**: uLR_MANUFACTURER_MODEL_SERIALNUMBER.txt
- **cLR files**: cLR_MANUFACTURER_MODEL_SERIALNUMBER.txt
- **Generic uLR files**: uLR_MANUFACTURER_MODEL_GENERIC.txt

### Ambient Luminance (Lamb)

Ambient luminance represents the luminance caused by reflected room lights. In lumResponse, the recorded values represent surface luminance in absence of Lamb. When performing QC evaluations or computing DICOM calibration LUTs, Lamb value is specified and added to each value to get combined luminance (L').

### Configuration Files

Many applications use configuration text files in their distribution directories:
- **LRconfig.txt** - lumResponse geometry settings
- **config-meter.txt** - Meter calibration and averaging settings
- **uniConfig.txt** - uniLum gray levels and averaging
- **16phase.txt** - lumResponse QC 16x2 protocol

### ArgyllCMS Integration

Several applications (uniLum, i1meter) use the spotread utility from ArgyllCMS for meter communication with i1Display Pro devices.

---

For build instructions and development information, see [BUILD.md](BUILD.md).
