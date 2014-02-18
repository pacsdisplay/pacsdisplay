#########-#########-#########-#########-#########-#########-#########-###
#                                                                       #
#                         HFHS-pacsDisplay                              #
#                                                                       #
#  Microsoft Windows programs for generating and installing             #
#  DICOM grayscale look up tables (LUTs). Includes applications         #
#  to display grayscale test patterns and to perform QC evaluations     #
#  of calibrated monitors.                                              #
#                                                                       #
#  IMPORTANT: Only use with LUTs intended for the make and model        #
#             of monitor used on your workstation.                      #
#             The distribution includes a LUT-Library                   #
#             with generic LUTs for various monitors models.            #
#             A configuration file needs to be edited                   #
#             to load user generated LUTs.                              #
#                                                                       #
#                           M. Flynn                                    #
#                           Dec. 2013                                   #
#                                                                       #
#########-#########-#########-#########-#########-#########-#########-###
#                                                                       #
#  GENERAL PUBLIC LICENSE:                                              #
#  HFHS-pacsDisplay                                                     #
#  Copyright (C) 2013  Henry Ford Health System                         #
#                                                                       #
#  This program is free software; you can redistribute it and/or modify #
#  it under the terms of the GNU General Public License as published by #
#  the Free Software Foundation; either version 2 of the License, or    #
#  (at your option) any later version.                                  #
#                                                                       #
#  This program is distributed in the hope that it will be useful, but  #
#  WITHOUT ANY WARRANTY; without even the implied warranty of           #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU    #
#  General Public License for more details.                             #
#                                                                       #
#  You should have received a copy of the GNU General Public License    #
#  along with this program; if not, write to the Free Software          #
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA        #
#  02110-1301, USA.                                                     #
#                                                                       #
#  The full license can be found in the GNU-GPL.txt document in the     #
#  HFHS/pacsDisplay directory.                                          #
#                                                                       #
#  CONTACT INFORMATION:                                                 #
#     Michael Flynn                                                     #
#     Henry Ford Health System                                          #
#     One Ford Place - Suite 2F                                         #
#     Detroit, MI 48202                                                 #
#     mikef@rad.hfh.edu                                                 #
#                                                                       #
#########-#########-#########-#########-#########-#########-#########-###

CONTENTS:

  1. Installation

    1.1 Quick Installation
    1.2 Manual Installation

  2. Application Summary

    2.1 HFHS ePACS Grayscale
    2.2 HFHS Grayscale Tools

  3. Luminance Response Measurements

    3.1 LumResponse
    3.2 QC Evaluations

  4. Calibration LUTs, lutGenerate

  5. Loading LUTs, loadLUT

    5.1 The Configuration File
    5.2 Sample Config Files
    5.3 LLconfig

  6. The LUT-Library

    6.1 LUT-Library directories
    6.2 uLRstats (generic LUTs)

  7. Monitor EDIDs

    7.1 getEDID
    7.2 EDIDprofile

------------------------------------------------------------------------
1. Installation
------------------------------------------------------------------------

HFHS-pacsDisplay may be installed by a simple Microsoft batch file
that invokes an installation tcl script. Instructions for installation
using this are summarized in section 1.1 below. Alternative manual 
installation methods are described in section 1.2.

- No registry entries are made or changed by this install process
  and no system background services are installed.
- Adjustments to the display LUTs are made by a call
  to the graphic driver that is executed for each user upon login.

IMPORTANT:
----------
Once installation is complete, the behavior desired is
extablished by editing a configuation file;
      ../HFHS/pacsDisplay/LUTs/Current System/configLL.txt
Unless changed on installation, this folder is located in;
      Windows 7:   C:/Users/Public
      Windows XP:  C:/Documents and Settings/All Users

If calibration LUTs for the make and model of your monitor(s)
are not in the LUT-Library, you will need to use a photometer
to measure the uncalibrated luminiance response using lumResponse
and then generate a calibration LUT using lutGenerate.

The lumResponse program supports numberous photometers.
The currently recommended photometer is the X-Rite i1Display Pro
which can be purchased from several suppliers for about $225 (USD).

------------------------------------------------------------------------
      1.1 Quick Installation:
------------------------------------------------------------------------

  IMPORTANT - The installation described below will fully install
              executable programs and the distributed LUT-library.
              However, the current system described is distributed
              with a linear LUT that will not change monitor contrast.
              To achieve a calibrated display with improved contrast,
              the installation must be configurated with the proper LUT file.

------------------------------------------------------------------------

Note: These instructions assume that you have just unzipped the pacsDisplay
distribution files and are currently viewing the .../HFHS directory
which includes this document and the pacsDisplay folder.

Steps for installing the HFHS-pacsDisplay package:

Step 1 - Open the 'pacsDisplay' folder and run the 'pacsDisplay_install.bat' file.
Step 2 - Review the terms of the license agreement.
Step 3 - Select the installation options you want.

         -> "The default directory for pacsDisplay programs is:" (Change)

            Windows 7/XP 32 bit:  'C:/Program Files/HFHS/pacsDisplay' 
            Windows 7    64 bit:  'C:/Program Files (x86)/HFHS/pacsDisplay' 

            It is recommended that the default directory for installation of the
            pacsDisplay files be used. Shortcuts will always be installed to
            specifc folders in the Start Menu regardless of how this option is set.
            However, the shortcut targets will need to be changed if a non-default
            directory is specified.

         -> "The default directory for the LUTs folder is:" (Change)

            Windows  7:  'C:/Users/Public/HFHS/pacsDisplay'
            Windows XP:  'C:/Documents and Settings/All Users/HFHS/pacsDisplay' for 

            It is recommended that the default directory for the LUTs folder be used.
            The directory selected is written to the LUTsDir.txt file
            in the programs installation directory. If the LUTs folder is manually
            moved, the LUTsDIR.txt file must be edited.

         -> OPTIONS:

         1. "Overwrite any previous installation?" (Yes/No)

            Default: Yes

            This option should be set to "Yes" if you want to overwrite a 
            previous pacsDisplay installation. A "No" response will abort 
            installation if a prior version is encountered.

         2. "Overwrite an existing LUTs directory?" (Yes/No)

            Default: Yes

            Answering "Yes" to this option will install a new LUTs directory
            along with a default configLL.txt file.
            Typically the new release LUTs file will be installed and any
            user configLL.txt files or LUT files will be backed up
            prior to installation.

         3. "Install grayscale calibration toolset?" (Yes/No)

            Default: Yes

            Answering "Yes" to this option will install shortcuts to the Start
            Menu for the various utilities that come with the pacsDisplay
            program.  These tools are intended for IT/physics support.

            Answering "No" will install only the enterprise shortcuts, which
            provide tools for applying and verifying the calibration.
            Note that only the shortcuts are not installed, the programs
            will still be installed in the program files directory.

         4. "Run the config file builder (LLconfig) after install?" (Yes/No)

            Default: No

            When set to "Yes", this option will run the LLconfig program after
            installation.  LLconfig is a tool to help build configuration files
            for pacsDisplay applications.  It is recommended that you not use
            this option unless you are familiar with LLconfig.  Instructions
            for its use can be found in the pacsDisplay directory in the Readme
            file (README-HFHS_pacsDisplay.txt).  There will be an option to
            view the Readme file at the end of the install process.

Step 4 - Review your selections and press the "INSTALL" button when ready.
Step 5 - If the installation completes successfully, an option will be given to
         view the Readme file (README-HFHS_pacsDisplay.txt) for further details
         and instructions.

------------------------------------------------------------------------
      1.2 Manual Installation
------------------------------------------------------------------------

The following instructions are intended for manual installation.
The files and directories involved only need to be placed in the
required locations. No registry entries need to be made or changed.

This package is intended for installation on a
system having a 'C:\Program Files' directory,
or 'C:\Program Files (x86)' for Windows 7 64 bit systems.

Unzip the HFHS-pacsDisplay.zip file to 'C:\Program Files'.
You should see the following path:

       C:\Program Files\HFHS\pacsDisplay\..
Do not change the organization of files under this path.

In the above path is a 'Links' directory.  It contains
separate directories with shortcuts for 32bit and 64 bit system:

       Links\32b_W7-XP\shortcuts or Links\64b_W7\shortcuts

Within these are shortcuts for

       allUsers_startMenu
       allUsers_startMenu_programs
       allUsers_startMenu_programs_startup

For Windows XP systems, these are placed in

       C:\Documents and Settings\All Users\...

For Windows 7 systems, these are placed in

       C:/ProgramData/Microsoft/Windows/Start Menu/...

where '...' depends on the name of the source directory.
Each of these directories is named so as to indicate
where their contents should be copied to.

There are three locations indicated in the directory names:

      * allUsers_startMenu => \Start Menu
           A single shortcut to iQC that places an icon
           at the top of the Start=>Programs menu that
           starts the test pattern application.

      * allUsers_startMenu_programs_startup => \Start Menu\Programs\Startup
           A single shortcut to loadLUT-dcm that will load
           a DICOM grayscale LUT to the graphic card 
           whenever a user logs into the system.

      * allUsers_startMenu_programs => \Start Menu\Programs
           There are two folders for which one or both can
           be moved to the ..All Users\programs directory:

           * HFHS ePACS grayscale
              Two shortcuts to start the test pattern application
              and to start an application that allows the user
              to change between a DICOM grayscale and a LINEAR
              grayscale.

           * HFHS Grayscale Tools
              A full set of shortcuts to applications for
              measuring the luminance response, generating
              calibrated LUTs, and installing LUTs.
              This should only be installed for qualified users.

It is possible to manually install the application on a drive other
than C:\Program Files\... If this is done, the shortcut targets 
summarized above need to be modified for the correct path.
Each shortcut must have the 'read-only' state removed, the paths
modified including the icon paths, and the shortcut saved.
It is suggested that the shortcuts be set to 'read-only' after these
changes are made.

------------------------------------------------------------------------
2. Application Summary
------------------------------------------------------------------------

Below are brief descriptions of each of the applications included in the
pacsDisplay package.  Further details on these programs and how to use
them can be found in sections 3.

------------------------------------------------------------------------
      2.1 HFHS ePACS Grayscale (Base applications)
------------------------------------------------------------------------

Shortcuts to the following programs are found in the Windows start programs
folder named 'HFHS ePACS Grayscale'. These are the only installed shortcuts
when the Installation option 3 for the toolset is set to NO.

    iQC:
      * Presents an image quality test pattern that demonstrates
        the grayscale characteristics of a display.
      * The base image size is 756 wide by 792 high.
      * The window size can be made smaller than the image, in which case
        the image can be panned using either the scroll bars or 'click
        and drag' using the left mouse button.
      * An alternate image of 2X size can be loaded using the <UP> arrow key.
        The window size will stay the same and the image can be panned
        by using the mouse and the left button. 
        The regular size image is then obtained using the <DOWN> arrow key.
      * An alternative window size of 2X that displays the 2X image can
        be obtained using the <RIGHT> arrow key.
        The normal window size is obtained using the <LEFT> arrow key.

    ChangeLUT:
      * Presents a small window with button to load the DICOM Grayscale
        currently configured or an alternative LINEAR Grayscale.
      * When used with the iQC test pattern displayed, this provides
        an effective way to see the difference in image appearance between
        the normally loaded grayscale (LINEAR) and the DICOM grayscale.

Additionally, a shortcut is put in the Windows startup directory where
it is executed every time a user logs in to the workkstation

    loadLUT-dicom:
      * Put in the appropriate startup directory (different for W7 and XP)
      * Loads the DICOM grayscale as configured in .../LUTs/Current System.


------------------------------------------------------------------------
      2.2 HFHS Grayscale Tools (additional applications)
------------------------------------------------------------------------

Shortcuts to the following additional programs are found in the Windows start
programs folder named 'HFHS Grayscale Tools'. These are installed
when the Installation option 3 for the toolset is set to YES.

    gtest:
      * Application to present uniform regions with adjustable gray levels
        to support macro images of lcd pixel structures.  All controls are
        implemented with key bindings. Help information is shown
        using the ? button.

    iQC-2x
      * Same as iQC but opens in the 2X image/window size.

    lumResponse
      * Application to generate a test pattern that steps through a
        palette of gray levels so that luminance can be measured using
        an IL1700 luminance meter connected using a serial line interface.
      * This is used in 256 mode to measure the calibrated response
        of a monitor having DICOM grayscale LUTs installed.
      * This is used in 766 or 1786 mode to measure the uncalibrated response
        of a monochrome or color display having a LINEAR LUT installed.
      * Make, model, and serial number of display normally used for
        identification.
      * A plot of the luminance vs p-values is provided at the end of a
        measurement.
      * Support a QC mode for verification of the luminance response
        of a calibrated monitor.

    LutGenerate
      * Generates a LUT for installation with loadLUT.
      * Reads luminance response measured by lumResponse.
      * Requires specification of maximum luminance, luminance ratio
        and ambient luminance.

    uLRstats
      * A utility tool to select a set of uncalibrated luminance response (uLR)
        files (i.e. palette files) and generate an average uLR file
        from which a generic LUT can be generated for model specific use.

    Uninstall pacsDisplay
      * Uninstall program that removes all files and folders from the
        'C:/Program Files/HFHS/pacsDisplay' directory.
      * An option is provided to save the LUTs directory.

Shortcuts to these utility programs are placed in the 'loadLUT utilities'
folder within the 'HFHS Grayscale Tools' folder.

    LLconfg
      * This program provides a form-fillable interface to help build a
        config file for LoadLUT.
      * Supports up to 4 displays and provides access to the model and
        serial number information from the EDID.

    loadLUT-dicom, loadLUT-linear
      * Depending on the argument in the shortcut, this loads the LUTs in the
        ../LUTs/Current System or the ../LUTs/Current System/linear directory.
        LoadLUT.exe is executed from the execLoadLUT.exe program to report errors.
        The LUT is loaded in the driver with no application window.
      * The error messages reported can be changed in the
        execLL-messages.txt file in the loadLUT directory.

    loadLUT
      * Provides a utility tool to find a LUT file and load it
        to a specific monitor number.

------------------------------------------------------------------------
3. Luminance Response Measurements
------------------------------------------------------------------------

The lumResponse application can be is to measure the gray pallette for a
display and record the luminance values in a uLR text file (Palette modes).
These uLR palettes are then used to generate a DICOM calibration LUTs
as described in the next section. LumResponse can also be used
to measure the luminance response of a calibrated monitor and
record the values in a cLR text file (QC modes). The cLR values
can then be evaluated in relation to the DICOM GSDF.

------------------------------------------------------------------------
      3.1 LumResponse
------------------------------------------------------------------------

This program puts a large secondary  window on the screen
with a grey background and a central square target region.
The target gray level is varied to assess display luminance response.
The grey intensity of the target region is cycled
through increasing intensity values to measure luminance versus grey value.
The measurements are made by luminance meter (photometers or colorimeters),
that are typically connected using a USB port. Currently 4 meter types
are supported.

---------------
 Mode Options
---------------

The 'Mode' button at the top left of the utility selects the type of
measurement to be made.  The current mode is displayed in the window title. 
The various modes are as follows:

For uLR measurement:

  1786 Palette - This mode is used for measuring the uncalibrated luminance
    response of a color display.  Make sure the display is using a linear
    LUT (i.e - no calibration) before proceeding.

  766 Palette - This mode is used for measuring the uncalibrated luminance
    response of a monochrome display.  Make sure the display is using a
    linear LUT (i.e - no calibration) before proceeding.

For cLR measurement:

  QC (256x1) - This mode is used for measuring the luminance response of a
    display after a LUT has been installed in order to verify that a DICOM
    calibration is in place. One measurement is made for 256 driving levels.

  QC (16x2) - This mode is used for measuring the luminance response of a
    display after a LUT has been installed in order to verify that a DICOM
    calibration is in place. Two measurements are made at each of 16 different
    primary driving levels (8,24,40,...248). The measurements are made a driving 
    levels just above and just below the primary driving level from which
    the contrast is computed. For some luminance meters, color gray
    tracking is also reported.

Other modes:

  DEMO MODE - This mode is for demonstration purposes.  It will quickly cycle
    from black to white but no measurements will be taken.  The IL1700 does
    not need to be connected for the demo to run.

  OTHER - This option allows the user to use a customized perturbation series
    for the luminance measurements.  For advanced users only.

--------------------------
Geometry and Meter Options
--------------------------

The "GEOM" and "METER" buttons provide access to advanced options for the
test image window and the photometer, respectively.  The "GEOM"
options can be used to customize the geometry and position of the test image.
The initial values for the geometry options are set in the LRconfig.txt file
which is in the .../pacsDisplay-BIN/lumResponse/ directory of Program Files [(x86)].
The intial configuration is for a 1024x1024 window with an 8 cm gray target
region on monitors with a .230 mm pixel pitch. This should be suitable for
the majority of monitor models.

The "METER" options include selection of the meter model and 
settings effecting the way display luminance is measured.
Further information is given byt "?" buttons next to each setting.

Four meters are currently supported;

  - International Light IL1700 Research Radiometer
      This device uses a serial line interface to report measured values.
      It has been replaced by the ILT1700 that uses a USB interface.
      The IL1700 option is retained only for legacy purposes.

  - IBA Dosimetry LXcan Spot Luminance Meter.
      This device is capable of making spot luminance measures some
      distance from the monitor surface. It is effective in measuring
      the amient luminance which is used in building a calibration LUT.
      A USB driver provided by IBA Dosimetry is used to record values.

and two meters that use the Argyll CMS spotread procedure (www.argyllcms.com).

  - xRite i1Display 2 photometer.
      This modestly priced photometer uses a USB interface.
      The photometer used the USB device driver from the open source
      Argyll Color Management System (Argyll CMS, www.argyll.com)
      which must be loaded the first time the meter is used.
      (see www.argyllcms.com/doc/Installing_MSWindows.html)
      While many of these are still in use, it has been replaced
      by the i1Display Pro described next.

  - Xrite i1Display Pro.
      This recently introduced and modestly priced photometer from xRite
      has improved precision and faster response than the i1Display 2.
      It is the currently recommended device if you need to buy a photometer
      and is available from several distributers for about $200-250 USD.
      It is also sold with different labels such as the NEC SpectraSenor Pro.
      The device uses communicates using USB ports as a human interface
      device (HID) using the Windows HID driver. As such, it will generally
      attach and be ready to use without the need to load a driver.

--------------------------
  Making Measuremennts
--------------------------

Once a mode has been selected and the meter specified (defaults to i1Display Pro),
a Display ID should be created to identify the measurement results
once they are saved.  The name that is selected will be used to name the output file.

The "Display #" box is used to select the display that you wish to identify.
This number is the same as that used by Windows and listed in the Display
Properties window.  Pressing the "GET EDID ID" button will then retrieve the
model and serial number (S/N) information from the EDID for that display and
use it to build the Display ID.  The result is displayed in the text box.  A
custom ID can be entered into the text box if so desired.  It is suggested
that the model and serial number of the display be included.

The remaining portion of the lumResponse window provides the steps for the
luminance response measurement and a button to begin each step.  They are
described here:

  Step 1: Position Test Image
    This opens up a test image window that needs to be centered on the screen
    of the display to be measured.  The window should be about the same size as
    the screen.  You may want to set the display to be measured as the primary
    display in order to get the right test window size.  Otherwise, you can
    change the display size manually using the GEOM settings.

  Step 2: Initialize Meter
    This button begins communication with the luminance meter.  It
    activates the meter display at the bottom of the window, providing
    information regarding the measurement.  The details of this monitor are
    explained further below.

    At this point, the luminance meter should be setup in front of the display,
    and centered on the square target in the middle of the test window.
    Depending on the meter used, it should be positioned close to or in contact
    with the display surfacd such that the luminance is not perturbed.
    the room lights should be set low and if necessary the monitor
    should be covered with a dark cloth. The cloth not cover any vents
    in the back of the display as this can cause it to
    heat up quickly and may affect the measurement.

  Step 3: Record Data
    This starts the measurement process.  You will be asked to be sure that
    the monitor is in the correct calibration (linear for uLRs and DICOM for cLRs)
    and that the power saver settings will not cause the screen to darken.
    Pressing this button once a measurement has begun
    will pause the measurement and provide an option to abort or continue.

  Step 4: Save Data
    Press this button to save the luminance data once a measurement is complete.
    You will be asked where to save the output file.  The default directory in
    the _NEW folder in the LUT-Library. An option to plot the
    luminance vs p-values is provided after the data is saved.


  Columns for the luminance response saved file:

    MEASUREMENT No. - Sequential measurment number.

    AVG LUMINANCE   - The average luminance value measured for each gray step.

    RGB VALUE       - Octal RGB value for the measurement.

    GRAY-STEP       - The current stage of the luminance measurement.
                      This number represents the standard graylevel (1-256).
                      Negative values represent the initialization frames.

    SUB-STEP        - This second number represents the perturbation steps
                      in the graylevel sequence.
                      There are 7 sub- steps in 1786 mode and 3 in 766 mode.
                      The 256 and Demo modes do not use sub-steps.

    dL/L            - Relative difference between the current
                      and the prior measurement.
    x               - Chromaticity x value (for supported meters, Yxy, CIE 1932)
    x               - Chromaticity y value (for supported meters, Yxy, CIE 1932)

Files are save with files names of,
    uLR_MANF_MODEL_SN.txt for uncalibrated palette files and
    cLR_MANF_MODEL_SN.txt for calibrated QC files.

The luminance response recorded with lumResponse represent surface luminance
in the absence of the luminance caused by reflected room lights, Lamb.
When doing QC evaluations or computing DICOM calibration LUTs,
a value of Lamb is specified and added to each value.

------------------------------------------------------------------------
      3.2 QC Evaluations
------------------------------------------------------------------------

The American Association of Physicists in Medicine (AAPM) described a
quantitative test of a DICOM calibrated monitor in 2005 (AAPM On Line report #3).
This was included in an IEC standard as a basic test (IEC).

--------------------------
  QC (16x2) Evaluation
--------------------------

The lumResponse applications includes routines to evaluate the QC 16x2 cLR.
The AAPM and IEC method makes 18 luminance measurements at equally spaced
gray levels (Digital Driving Levels, DDL). For a graphi system with 256
gray levels, these are spaced every 15 gray levels (17 x 15 + 1 = 256).
17 relative luminance changes are then evaluted and this contrast is 
compared to the DICOM GSDF. The ACR-AAPM-SIIM Technical Standard for
Electronic Imaging (2012) recommends;
      "The contrast response of monitors used for diagnostic
       interpretation should be within 10 % of the GSDF over the full LR.
       For other uses, the contrast response should be
       within 20 % of the GSDF over the full LR."

The measurement protocol used by lumResponse for the QC 16x2 mode is essentially
the same at the AAPM and IEC method except that 16 pairs of measures are made
over the full range of a 256 level grayscale. The base value for each of
the 16 measurement pairs increments in steps of 16; 0,16,32,...,240.
The two measures are then made by adding 5 or 11 to the base value with
the red, green, and blue values of each being equal.

The contrast evaluated from these measure represents the contrast estimate, dL/L,
for levels of 8, 24, 30, 46, ..., 248 with the contrast computed for gray level
changes of 6. This provides an improved estimate of contrast compared
to measures using gray level changes of 15 for the AAPM and IEC method.
Additionally, the protocol makes three measurements of Lmin at a gray level
of 0 and one measurement of Lmax at a gray level of 255.

  NOTE: The protocol is set in the 16phase.txt file located in the
        .../pacsDisplay-BIN/lumResponse/ folder in Program Files [(x86)]

After saving the QC 16x2 cLR in a directory with the monitor model name,
the user has the option to evaluate the results. An evaluation report, QC-lr.txt,
is place in the same folder along with four graphic plots in png format.
The gnuplot command file is along left in the folder, QC-plot.gpl.
The plotted results include;

      QC-Plot-LUM.png - Luminance vs Gray Level using a semi log plot
      QC-Plot-dLL.png - Contrast, dL/L, vs Gray Level with 10% and 20% error conditions.
                        The maximum relative error along with L'max and L'min are labeled.
      QC-Plot-JND.png - JNDs per Gray Level vs Gray Lever (see DICOM 3.14)
      QC-Plot-uv.png  - Color gray tracking with u'V' relative to D65.

The evaluation uses a default value of Lamb from the 'METER' options.
The results can be re-evaluated with a different Lamb by using the
QC check application that select the cLR file to re-evaluate and provides
an entry for the new Lamb value.

--------------------------
  QC (256x1) Evaluation
--------------------------

AAPM OR3 also described an advanced measurement test for which the calibrated
luminance is measure for each of 256 gray levels and the contrast or
JNDs per gray level evaluated using the difference between each measurement
as adjacent gray levels. The QC (256x1) mode measures each of 256 luminances
with red, green, and blue values being equal (i.e. 256 gray levels).
These are then evaluated using a method similar to that for the QC (16x2) mode.

------------------------------------------------------------------------
4. Calibration LUTs, lutGenerate
------------------------------------------------------------------------

Calibration of a monitor using pacsDisplay involves loading a look-up
table (LUT) to the graphic driver. The LUT is a list of 256 RGB values
used to replace the standard grayscale values (R=G=B) in order to match
with the DICOM grayscale display function (GSDF).
Creating the LUT requires measuring the full range of gray values
that the display is capable of, the grayscale palette, and then
using those values that are closest to the desired DICOM GSDF
in a calibration look-up table (LUT).
LutGenerate takes a uLR file (output by LumResponse) and builds a LUT file
based on the parameters you specify.

The basic usage steps are;

  1. Select a uLR File

    Start by pressing the "SELECT FILE" button and choosing the appropriate uLR
    file for the display to be calibrated.  LutGenerate will read the uLR file
    and automatically update the fields throughout the window as appropriate.
    This includes the 'Desired Maximum Luminance' field, which will be set to the
    maximum luminance value found in the uLR file.  Both the display name and
    desired maximum luminance may be changed manually after loading a uLR.

  2. Determine Calibration Parameters

    Three parameters must be specified before generating the calibration LUT,

      Lamb  - The ambient luminance expected for the display.
              This is typically measure using a photometer
              when the monitor is turned off and the room lighting
              is set to establish the desired illumination.
              Room lights should not cause direct specular reflections
              on the monitor surface.
      L'max - The desired actual maximum luminance, which is the maximum from
              the monitor plus the ambient luminance(Lmax + Lamb) can be changed.
              The initual value is set at the maximum from the selected uLR file
              plus the entered Lamb. If change it must be lower that shown initially.
      r'    - The luminance ratio equal to L'max/L'min.
              ACR-AAPM-SIIM Technical Guidelines recommend a value of 350.

    Typically these are left the value of L'max taken from the uLR,
    and the default r' of 350. Lamb may need to be adjusted (along with the room
    lighting) in order to maintain Ar within an acceptable range.

  3. Verify Calibration Parameters

    Hitting the 'ENTER' key after changing one of the calibration parameters will
    update the other values presented below:

      Ar, Lamb/Lmin (Ambient Ratio) - The AAPM TG-18 report calls for this
        value to be no move that 2/3 and recommends a value of less than 1/4.
        The text changes to yellow if the value is above 1/4 but less than 2/3
        and red if it is above 2/3

      Target Lmax    - This value is equal to the maximum luminance that will result
                       from loading the generated LUT in the graphic driver
                       in the absence of ambient luminance (i.e. Lmax not L'max).
                       The text will turn red if it goes above the possible
                       maximum luminance indicated by the uLR.

      Target Lmin    - This value is equal to the minimum luminance that will result
                       from loading the generated LUT in the graphic driver
                       in the absence of ambient luminance (i.e. Lmin not L'min).
                       The text will turn red if it goes below the possible
                       maximum luminance indicated by the uLR.

      Possible Lmin - The minimum luminence found in the selected uLR file.

      Possible Lmax - The maximum luminence found in the selected uLR file.
     
    Check to be certain that these values are correct before continuing.
 
  4. Generate the LUT

    Click on the "GENERATE" button to build the calibration LUT.  You will be
    asked where to save the LUT file.  The are commonly stored within the
    LUT-LIbrary/_NEW directory in a folder specific to the workstation monitor.

------------------------------------------------------------------------
5. Loading LUTs, loadLUT
------------------------------------------------------------------------

 Usage:  loadLUT.exe [(working directory)]

 Command Line Options:
   (working directory) - If a working directory is specified, then all
   input files will be read from that directory.  The log file will also
   be written to that directory.  If no directory is specified, the 
   current directory will be used.

loadLUT is the program in the pacsDisplay package responsible for applying
a calibration LUT to a display.  It reads from a configuration file,
'configLL.txt', which it looks for in its starting directory or working
directory (if specified).  ChangeLUT, execLoadLUT, and loadLUTdemo provide
expanded interfaces for running loadLUT.  Further details on using loadLUT
and related utilities are given in this section.


------------------------------------------------------------------------
      5.1 The Configuration File
------------------------------------------------------------------------

loadLUT uses a configuration file, 'configLL.txt', to designate which
displays are to be calibrated and what LUTs to load.  It will look for
this file either in the same directory as loadLUT.exe or in a specified
directory, as mentioned in the usage instructions above.

For a standard pacsDisplay installation, there are configLL.txt files in
two strategic directories that need to be properly configured relative to
the make and model of each monitor installed on the system:

       ...\LUTs\Current System

       ...\LUTs\Current System\Linear

where ... refers to the LUTs installation path.

Below is the standard layout for the configLL.txt file, configured for a
two-monitor system:

           # First 2 lines reserved for comments.
           #
           /LUTsearch [dir]   - Optional line, invokes model/SN LUT search
           /LDTsearch         - Optional line, invokes dated LUT search
           /noload            - Optional line, checks LUT but does not load
           /noEDID            - Optional line, bypasses EDID checks
           /nolog             - Optional line, prevents writing of log file
           2                  - Number of displays to be calibrated
           1                  - Display number
           "MANF_MODEL"       - Model descriptor (or "*")
           "SN"               - Serial number (or "*")
           "calLUT1.txt"      - Default calibration filename
           2                  . -
           "MANF_MODEL"       .  |   Four lines for
           "SN"               .  |   each of N monitors
           "calLUT2.txt"      . -

  Comments:
  The first two lines are reserved for comments and will not affect how
  loadLUT performs.

  Options:
  Options, if present, are included right after the comment lines and must
  start with a '/' character.  The following options are currently available:

     /LUTsearch [dir] - 
               This option is used when managing a group of systems
               having monitor models that are in the LUT-Library.
               The arguement, dir, is the LUT-Library full path name.
               During installation, a default configLL.txt is created
               in the Current System directory which has the /LUTsearch
               option with the correct pathname based on the installion.

                Note1: The path should be entering using quotes.
                       If not, paths with spaces will not be valid.
                Note2: The directory arguement can be formed with either
                       forward or reverse slash characters.
                Note3: If no arguement is provided, loadLUT will assume
                       the the LUT-Library is in the 'program file'
                       installation directory which was used in early versions.
                       Beginning with package 5A, this is no longer valid
                       and a correct directory should always be entered.

               When this option is set, loadLUT first gets the monitor
               manufacturer (MANF), model (MODEL), and serial number (SN)
               from the EDID that Windows store in the registry.
               If it doesn't find them, it will use the the config file values.
               If the /noEDID option is set, then the model descriptor
               and serial number are also taken from the config file.

               The program then looks in the LUT-Library 
               to find the appropriate LUT folder based on the
               model descriptor, ...\LUT-Library\<MANF_MODEL*>\.
               The "*" denotes a wildcard.  If the  folder name
               has characters beyond <MANF_MODEL>, it will still
               be accepted.

               Several loadLUT utilities can be used to identify the
               model descriptor, MANF_MODEL, for the monitors on a
               particular system. The first row of the monitor table
               created by EDIDprofile has the model descriptor.
               LLconfig will also get the EDID and show the model descriptor.

               The program will first look in the LUTs directory of the
               LUT folder, ...\LUT-Library\<MANF_MODEL*>\LUTs , to see 
               if a LUT is present with a matching serial number.
               These LUTs are generated by LUTgenerate with a file name
               of the form LUT_MANF_MODEL_SN_*. Additional values at the
               end docuement LUTgenerate input parameter values.
               SN can be either the 4 digit VESA EDID number
               or the extended VESA EDID number (see the configLL program).

               If a serial number specific LUT is not found,
               loadLUT will look in the LUT folder directory for a
               generic LUT file, LUT_MANF_MODEL_GENERIC_*.
               If that also fails, it will load the
               default LUT file specified in configLL.txt.
               This default LUT file must be in the Current System directory.

     /LDTsearch [#] - this rarely used option is similar to the
               LUTsearch option.  It uses the year and week of
               manufacture, along with the model name from the
               EDID to find the appropriate LUT file from the 
               ..\Current System\LDT\ directory.  The "#"
               indicates the date tolerance, i.e. - the number
               of weeks before or after the specified date that
               the search will accept.  The default is 3 weeks.

               If the /noEDID option is set, then the search
               fails.

               file format:
                         LDT_<MANF_MODEL>_<year(xxxx)><week(1-52)>_*

               Note: If both LUTsearch and LDTsearch are set,
                     LUTsearch takes priority.  If LUTsearch fails,
                     loadLUT will still run LDTsearch.  If LDTsearch
                     also fails, then loadLUT will use the default LUT file.

     /noload - when this option is set, loadLUT will save the
               current display LUTs in backup files without
               loading new LUTs.

     /noEDID - this option prevents loadLUT from searching the
               registry for EDID information.  This may allow
               loadLUT to avoid errors with some display
               configurations, but also disables loadLUT's
               ability to verify display information.

     /nolog - when this option is set, loadLUT will not attempt
               to generate a log file.  This may be needed if
               loadLUT is run under an account that has limited
               access privelages.

  Number of Displays:
    Following the options is the number of displays to be calibrated.  Each
    display is listed below this line and four lines must be present for
    each display.

  Display Number:
    The reference to display number is for the number that pacsDisplay
    finds in the registry for the monitor using getEDID.
    The Display Number is usually the same that Windows reports
    for each display under Display Properties => Settings.
    However, for systems that have certain remote management software
    installed the numbers can be shifted up for some of monitors in
    a multi-monitor system. If this occurs, used EDIDprofile to document
    the getEDID display number which is in the first row of the table.

  Model Descriptor (or "*"):
    The model descriptor is checked against what is listed in the EDID.
    A mismatch will cause loadLUT to output an error message and will not
    load a LUT.  It will then continue on to the next display.  The Model
    can be replaced with a "*" in order to bypass the check for that line.
    If there are spaces in the model descriptor, it should be enclosed in
    quotes.  This is generally recommended even if there are no spaces.

  Serial number (or "*")
    The serial number is checked against what is listed in the EDID.  A
    mismatch will cause loadLUT to output an error message and will not
    load a LUT.  It will then continue on to the next display.  The Model
    can be replaced with a "*" in order to bypass the check for that line.
    If there are spaces in the serial number, it should be enclosed in
    quotes.  This is generally recommended even if there are no spaces.

    In general, the EDID will contain a 4-digit serial number.  Some EDIDs
    also include an extended serial number longer than 4 digits.  If either
    one matches the serial number given in the config file, then this check
    will be successful.

  Default Calibration Filename:
    The next line is the default calibration filename.  This is the LUT file
    that the progarm will use to adjust the display.  If any of the search
    options are in place, then they will take precedence in selecting a LUT
    file.  Should the search options be unsuccessful, then loadLUT will use
    this filename by default.

Several files are installed in the Current System directory
some of which must be present.

   The Current System folder contains the configLL.txt file
   that should be edited based on user requirements along
   with the linear LUT, linearLUT.txt, used as the default LUT.
   For routine system managment, it is recommended that a LUT folder
   be built in the LUT-Library and the linear LUT left as the default.

   The Linear folder, ...\LUTs\Current System\Linear, contains
   a configLL.txt files for loading linear LUTs and a copy of
   the linear LUT file, linearLUT.txt.

For this distribution, the LUT-library contains collections of
uncalibrated luminance response files, uLR files, along with derived
average response and calibration LUT files for these monitors:
           MANF_MODEL_(3g)
where the number in parentheses indicates the number of uLR files.
The "g" indicates that a generic file also exists.  Additionally,
directories with uLR files but no generic LUT are included for
other monitor models.

For this distribution, the Current System LUT directory has a
default configLL.txt file that asserts the \LUTsearch option with the
model_name and S/N set to "*". If an S/N match or GENERIC match
is not found in the LUT-library, the default LUT is assigned to
that for a linear LUT. To demonstrate that calibrated LUTs are being
loaded on a monitor that does not have a LUT folder in the LUT-Library,
this linear LUT needs to be temporarily replaced with some calibration LUT.

    IMPORTANT - The 'Current System' configLL.txt file must be
                properly configured for the monitors used
                as is illustrated in the examples below.

------------------------------------------------------------------------
      5.2 Sample Config Files
------------------------------------------------------------------------

Example 1:
This configuration is for a single display, identified in Windows as display
"1", with no model name or S/N verification.

           # First 2 lines reserved for comments.
           #
           1
           1
           "*"
           "*"
           "<LUT filename for display #1>"

Example 2:
This configuration extends to display "3".  The EDID information for this
display will be checked for a matching model descriptor.  If the model name
given here is different from what is found in the EDID, an error will occur
and the program will abort.  No check will be made to match a serial number.

           # First 2 lines reserved for comments.
           #
           2
           1
           "*"
           "*"
           "<LUT filename for display #1>"
           3
           "DELL 2007FP"
           "*"
           "<LUT filename for display #3>"
           
Example 3:
This configuration includes the option to search for the LUT files in the
'..\LUTs\LUT-Library' directory.  For display #1, the filename will be
based on the model name and serial number given in the EDID.  For display
#3, the model name "DELL 2007FP" will be checked against that in the EDID,
while the serial number will be whatever is found in the EDID.  These model
names and serial numbers will be used to build the filenames for LUTsearch.
If the search for the specific files and generic files are unsuccessful,
then the listed default LUT files will be used instead.

           # First 2 lines reserved for comments.
           #
           /LUTsearch
           2
           1
           "*"
           "*"
           "<LUT filename for display #1>"
           3
           "DELL 2007FP"
           "*"
           "<LUT filename for display #3>"

Example 4:
This configuration includes a search based on the date of manufacture of
the display.  It will search through the files in '..\Current System\LDT\',
choosing the one that is closest to the date of manufacture, but not going
beyond 52 weeks from that date.

           # First 2 lines reserved for comments.
           #
           /LDTsearch 52
           2
           1
           "*"
           "*"
           "<LUT filename for display #1>"
           3
           "DELL 2007FP"
           "*"
           "<LUT filename for display #3>"

Example 5:
Here we have a 4 display system with LUTs being drawn from the
'..\LUTs\LUT-Library' directory.  However, since the /noEDID option is
being used, LUTsearch will instead build the intended filenames using the
monitor descriptors and serial numbers given below.  Those that have only
"*" for both the model and serial number will automatically fail the file
search and will instead default to the given LUT filename.  Display #3
gives a model name, but no serial number.  LUTsearch will not be able to
build a specific LUT filename for display #3, but it will still search for
a generic file in the <model_name*> directory before going to the default
LUT file.

           # First 2 lines reserved for comments.
           #
           /noEDID
           /LUTsearch
           4
           1
           "*"
           "*"
           "<LUT filename for display #1>"
           2
           "*"
           "*"
           "<LUT filename for display #2>"
           3
           "DELL 2007FP"
           "*"
           "<LUT filename for display #3>"
           4
           "DELL 2007FP"
           "T61164A5ABYU"
           "<LUT filename for display #4>"

------------------------------------------------------------------------
      5.3 LLconfig Tool
------------------------------------------------------------------------

LLconfig is a tool to help build a LoadLUT configuration file for a
particular display setup.  The format for the configuration file is described
in the README-HFHS_pacsDisplay.txt document in the pacsDisplay directory.

REQUIREMENTS:
- The EDID functions require that getEDID.exe be in the same directory as
the LLconfig executable.

USAGE:
1. Options - The top bar lists the possible LoadLUT options that can be set.
Click on the boxes next to the option names to select (or de-select) them.

2. Number of Displays - Selecting a number means that entries for all of the
displays up to and including that number will be included.  For example, if
"3" is selected, entries for displays 1, 2, and 3 will be generated in the
final configuration file.  These display numbers correspond to the numbers in
the "Display Properties" window.

3. Display Entries - Text entry bars are provided to list the configuration
information for each individual display.

  Monitor Descriptor - This is the name of the display as given by the
    EDID information.  If left blank, a wild card character ("*") will be
    inserted into the configuration file instead.

  Serial Number - This is either the 4-digit or extended serial number found
    in the EDID.  If left blank, a wild card character ("*") will be
    inserted into the configuration file instead.

  Default LUT file - This is the LUT file that will be applied to the display
    if LUTsearch and LDTsearch are not selected or if the file being searched
    for is not found.  If left blank, "linearLUT.txt" will be inserted as the
    LUT file for that display.

  GET EDID - This button runs getEDID and looks for the monitor descriptor
    and serial number entries for that display.  If found, these items will
    be copied to the appropriate text entry bars.  If both a 4-digit and
    extended serial number are found, then the user will be asked to select
    one.

  SELECT LUT - This button opens a file-select window so that the user can
    browse for the LUT file they want for that display.

4. BUILD CONFIG FILE - This button will take the current form information and
build a configLL.txt file formatted for LoadLUT.  The user will be asked where
to save the file.

5. RESET FORM - This button resets the form to its initial state.

6. QUIT - This button exits the program.  Form information will not be saved.

------------------------------------------------------------------------
6. The LUT-Library
------------------------------------------------------------------------

Section 4 above explains how the loadLUT program can search the LUT-Library
to find a appropriate LUT. Using the LUTsearch option, the LUT-Library
is searched to find a LUT matching the manufacturer, model, and serial number
obtained from the EDID data for each monitor found. In not found, loadLUT
looks for a generic LUT.

This section explains how the LUT-Library is organized and
how generic LUTs can be built using the uLRstats tool,

------------------------------------------------------------------------
      6.1 LUT-Library directories
------------------------------------------------------------------------

The LUT-library contains a collection of uncalibrated luminance
response files (uLR files) and calibration look-up table files (LUT files).
The files are organized in directories with names
based on the model descriptor (manufacturer_model) normally 
encountered when reading the EDID from a monitor device.
The number in parenthesis indicates the number of monitors
having uLR files within the directory.
The letter g after the parenthetic number indicates that
a generic lut file has been prepared and is included.

Within each monitor directory, for example DELL_2007FP_(10g),
There are two subdirectories call uLRs and LUTs.
Typically a number of monitors will be evaluated using lumResponse
to obtain uLRs with filenames that begin with uLR and contrain
the manufacturer, model, and serial number. For example,
      uLR_DELL_2007FP_C953667D38RL.txt
      in .../LUTs/LUT-Library/DELL_2007FP_(10g)/uLRs/
The uLRs directory may also contain plot results from uLRstats
which is explained in the next section.

Calibration look-up tables files built using lutGenerate
are stored in the LUTs directory. For example,
      LUT_DELL_2007FP_C953667D38RL_0.10_217.00_350.00.txt
      in .../LUTs/LUT-Library/DELL_2007FP_(10g)/LUTs/
These files will begin with LUT, will contain the manufacturer,
model, and serial number, and will have the values for
Lamb, Lmax, and Luminance ratio that were used to build the LUT.
If multiple LUT files are present, as may be the case if several are
generated with different luminance ratio values, the <S/N> or GENERIC
expression can be appended with _* characters. In this case the
file used under the \LUTsearch option will be the first found with
alphabetic listing.

The monitor directory may also contain a generic LUT built using
uLRstats and a README file with information explaining 
how and why the monitor was added to the LUT-Library. For example,
LUT_DELL_2007FP_GENERIC_0.18_227.90_350.00.txt
      in .../LUTs/LUT-Library/DELL_2007FP_(10g)
The serial number section of the filename is replaced with
'GENERIC' for these files.

Since loadLUT searchs the LUT-library as a part of the \LUTsearch
option, the location of the library and the library structure
should be maintained as installed. 

The file names for LUT files should be of the form
               LUT_<model_name>_<S/N>_*
                     where <S/N> can be either the 4 digit VESA
                     EDID number or the extended VESA EDID number
                     and * can be any addition characters
The model_name is that returned in the VESA EDID as the model
descriptor and is commonly of the form "DELL 2007FP" with
the spaces replaced by '_' characters.
If a generic lut is desired it should be selected or built using
the uLRstats utility and placed at the top of the model name directory
in the format LUT_<model_name>_GENERIC*

If a new monitor folder is built, email the pacDisplay contact person
identified at the beginning of the file to make arrangements for
inclusion of the new monitors in the next LUT-Library release.
A log file is maintained in the LUT-Library folder documenting
the history of contributed monitor folders. The LUT-Library folder
also has a file documenting the current version number, VERSION_INFO.txt.
The version information is read and shown using the ChangeLUT program.
Beginning with version pacsDisplay versin 5A, the LUT-Library version
is maintained separate from the program installation package version.

------------------------------------------------------------------------
      6.2 uLRstats (generic LUTs)
------------------------------------------------------------------------

Experience has shown that monitors with the same manufacturer and model
will have an uncalibrated response file that is similar expect for
brightness variations. This results if a manufacturer changes the model
designation when the LCD panel used for a product line is changed.
In this case, a generic LUT can be used for DICOM calibration without
having to measure the S/N specific uLR and create an S/N specific LUT.

uLRstats is a tool to evaluate the uLRs of a set of monitors,
identify those to used as a basis of a generic uLR, and produce a file
with the average luminance for each palette entry. This can then be
used with lutGenerate to build the generic LUT file.

When uLRstats is first run, use the SELECT button to select the directory
with a set of uLRs to be evaluated. Within the Select window,
first use the Path button to select the uLR directory from the
Folder Browse window. The window should open with the _NEW directory
of the LUT-Library where new monitor folders can be built.
Closing the window with OK enters the selected folder path in the filePath entry.
Assuming the uLRs all have filenames of the form uLR*.txt,
use the Glob button to build a list of filenames, then highlight the
files to be evaluated using SHIFT+<LEFT CLICK> and CTRL+<LEFT CLICK>.
After files are selected, close the Select window with OK.
The processing bar at the bottom of the application window will change
to indicated the number of uLRs to analyze. Use this button to begin.

During the analysis, the uLRs are checked for unusually large changes
in luminance, dL/L. These are recorded in the log file. A dialogue
window with report the total number and offer to open the log file.
It is not unusual to have a modest number of out of limit changes.

The analysis will create six files in the uLR directory,for example,

  uLR_DELL_2007FP_GENERIC.txt, the average uLR and,

  uLR-LminLmax          - A table of Lmin, Lmax, and filename for
                          each uLR processed. This can be useful when
                          evaluating which files may not want to be
                          included in the generic uLR. The order of these
                          files corresponds to the number in the plots.
  uLR-plot.gpl          - Gnuplot command file to generate three plots shown
                          in a window and saved as png files.
  uLR-Plot_LminLmax.png - Plot of Lmax vs Lmin
  uLR-Plot-dL_L.png     - Plot of the dL/L values for each pallete entry and file.
  uLR-PlotULRs.png      - Plot of luminance vs palette entry for each file.

Typically, uLRs are evaluated is two steps. First all uLRs are evaluated.
Those monitors with atypical uLRs are then identified from the plots.
Then a second analysis is done using only typical uLRs.

When done, a generic LUT can be built with lutGenerate.

------------------------------------------------------------------------
7. Monitor EDIDs
------------------------------------------------------------------------

Monitors need to communicate information regarding the device to the
graphics card so that appropriate display communication can be established.
The Video Electronics Standards Association (VESA) standardized the method
to do this called the Extended Display Identification Data (EDID).
The monitor device information is stored in Read Only Memory (ROM)
within the monitor where it can be read by the graphic card.
The EDID data structure contains information including the manufacturer,
the model, the serial number, the data of manufacture.
Display information includes the display size, array size and timings
support for other array sizes. For further information see,
http://en.wikipedia.org/wiki/Extended_display_identification_data.

Various pacDisplay programs obtain EDID information from the Windows
Registry to identify the monitors present on a particular workstation.
This is done within loadLUT when LUT-Library searchs are done to find LUTs.
It is also done with lumResponse and lutGenerate to establish a display ID
used to build luminance responce files and LUT files.
A utility tool, edidProfile, is used to quickly obtain monitor ID information
for all displays on a workstation.

------------------------------------------------------------------------
      7.1 getEDID
------------------------------------------------------------------------

The command line program getEDID.exe in the distibuted package is used
by several pacsDisplay programs to get information from the EDID.
It takes a single arguement that is the display number.
The program is a core utility that is not supported by a graphic appication
other than EDIDprofile described in the next section.

The program uses an approach suggested by Calvin Guan, a software engineer
at ATI Technologies Inc., that was posted on the internet in 2004.
A series of function calls from the Windows graphics device interface (GDI)
library for C++ is used to get the data from the monitor’s EDID which
is decoded to obtain details on the display. Visual C++ was used to build getEDID.

------------------------------------------------------------------------
      7.2 EDIDprofile
------------------------------------------------------------------------

When evaluating a display workstation, particularly those with multiple
monitors, it is useful to be able to tabulate information from the EDIDs
that document the workstation characteristics.
This is particulary true when doing a QC evaluation of a system.

EDIDprofile is a utility program that sequentially executes getEDID
from monitor device 1 to N. N is set in a configuration file to 6.\
The program first obtains information from the registry regarding the
workstation and it's processors. Then the EDID packets obtained are
parsed to obtain;
      - Adapter display ID
      - Adapter string
      - Monitor Descriptor
      - Extended S/N
      - Week of manufacture
      - Year of manufacture
      - Max. horizontal image size (mm)
      - Max. vertical   image size (mm)
      - Horizontal array size: Native
      - Horizontal array size: Current
      - Vertical array size: Native
      - Vertical array size: Current
      - Est. hor. pixel size (microns)
      - Est. ver. pixel size (microns)
The estimated pixel sizes are computer from the image size and array resolution.

The current and native array sizes are included since the
current should alway be set to the native for a digital monitor.
The pixels size is computed from the image size in the EDID and
is thus subject to a small error relative to manufacturers specifications.
This estimate is still useful in establishing that the pixel size
meets professional recommendations.

The results of EDIDprofile are recorded in a text file that can be
written in a user selectable directory. The default is the _NEW directory
in which a folder is created with the workstation name.
This can subsequently be used to record QC results using lumResponse.
