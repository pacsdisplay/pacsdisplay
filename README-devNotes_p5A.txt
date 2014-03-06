Last changed: Feb. 2014 
|---------------------------------------------------------|
|             pacsDisplay development notes               |
|                                                         |
|     Authors:     M. Flynn                               |
|                  P. Tchou                               |
|                  N. Bevins                              |
|                                                         |
|     Contents:    CURRENT RELEASE VERSIONS               |
|                  INSTALLATION                           |
|                  DEVELOPMENT HISTORY                    |
|                  BUGS ACTIVE/RESOLVED                   |
|                  TO DO LIST                             |
|                                                         |
|---------------------------------------------------------|
CURRENT RELEASE VERSIONS:

See the distribution directory,
.../HFHS/pacsDisplay/VERSION_INFO.txt
for the active versions.

-----------------------
INSTALLATION:

Complete installation instructions are now in
.../pacsDisplay/README-HFHS_pacsDisplay.txt

-----------------------
DEVELOPMENT HISTORY:

-----------------------------------------------------------------------------
04/25/06 - BEGAN HISTORY DOCUMENTATION
-----------------------------------------------------------------------------

04/25/06 - Installer for shorcuts and file moving created.  Further development in
           progress.
07/28/06 - LLconfig 1.0 completed.  Requires getEDID.
           This get monitor information from the EDID, asks for the LUT to use and builds the
           configuration file for the default locations.
           User must choose current or linear sub-directory.
07/28/06 - getEDID 1.0 completed.  Frontend (tcl) scripts in development.
09/21/06 - Fixed a bug in LLconfig that was reading the wrong EDID entries for displays 2-4.
09/21/06 - LumResponse 1.5f completed.  Added output columns for dL/L and results directly
           plotted with gnuplot.  Requires Gnuplot.  Binary included.
09/22/06 - LoadLUT 2.3 includes more detailed log messages regarding model and S/N checks.
           loadLUT now puts a message to the error dialoque saying what model it was
           looking for and what was found if the LUT does not load.
09/27/06 - LutGenerate 2.3
            - removed Mode button and set to only produce text-mode outputs
            - reworked interface to properly indicate ambient luminance effects on target
              luminance values
            - minimum luminance (from uLR and target values) added
            - target minimum luminance value changes to red when value is out of the uLR's
              range
            - Added target amb/min luminance to displayed values.  The font changes color
              depending on the value compared to the AAPM TG-18 guidelines:
                  0.00-0.25   black (good)
                  0.25-0.66   yellow (acceptable)
                  0.66+       red (unacceptable)
            - Starting directory for uLR files set to "C:\Program Files\HFHS\pacsDisplay-BIN"
09/29/06 - Install 1.1
            - Added a directory check to delete and replace previous installation directories
            - Gives option to open LLconfig at the end to build a configuration file
10/06/06    - Added option to not overwrite files in the "Current System" directory.
10/10/06    - Added instructions to set HFHS directory to "Full Access" for clients using the
              loadLUT utilities.
10/18/06    - Added option to remove installation files if installed from someplace other
              than "C:/Program Files/HFHS".  This still leaves behind the (empty) HFHS folder
         - Uninstall 1.1 (pacsDisplay)
            - Initial release for pacsDisplay.  Version matched to Install 1.1 program.
10/19/06 - Install 1.1
            - Start menu folder, "HFHS rPACS dcmLUTs" changed to "HFHS Grayscale Tools"
            - Option provided to install grayscale tools (full install) or not (enterprise)
            - gTest added to install package
10/23/06    - All options compiled into a single interface window.
10/24/06    - Default settings built into a config file, "install_config.txt".
10/30/06 - **NEW DIRECTORY STRUCTURE**
            - Shortcuts moved to new "shortcuts" directory.
            - Install executables and config file moved to "install" directory.
            - LUTs directory moved out into main HFHS directory.
         - Adjusted programs to new directory structure:
            - Install / Uninstall (now version 1.2)
            - ChangeLUT (now version 1.1)
            - execloadLUT (now version 1.1)
10/31/06    - LLConfig (now version 1.1)
         - Added LLConfig shortcut to the Grayscale Tools
         - Install 1.2
            - Added option at the end of an installation to open the README file.
11/02/06    - Added license and disclaimer message
         - GNU GENERAL PUBLIC LICENSE (GPL) statement added to installation and stored in
           pacsDisplay-BIN directory as GNU-GPL.txt
11/03/06 - LLconfig 1.1
            - Moved buttons to the bottom of the interface.
11/05/06 - **NEW DIRECTORY STRUCTURE**
            - Entire directory structure moved from "/HFHS/" to "/HFHS/pacsDisplay/".
            - "shortcuts" directory moved to the "/HFHS/pacsDisplay/" level.
            - "README-HFHS_pacsDisplay.txt" moved to the "/HFHS/pacsDisplay/" level.
         - Adjusted programs to new directory structure
            - Install / Uninstall 1.2 updated
11/14/06 - Install 1.2
            - Moved the temp .bat file out of the pacsDisplay directory in order to fix
              an error where the readme file was not being opened when the source
              directories were also being deleted.
11/15/06 - LutGenerate 2.3
            - Edited values to be more intuitive.
            - Altered Ambient ratio to match AAPM TG-16.
            - Added maximum possible luminance display
            - Target maximum luminance font will change to red if it is higher than the
              available maximum luminance
            - Re-arranged interface and changed formatting of the text to be easier to
              understand
            - Starting directory changed to new LUTs directory
         - LumResponse 1.5f
            - Made the command window visible over the test image window.
11/21/06    - Made the IL1700 also visible over the test image window.
         - LutGenerate 2.3
            - Removed starting luminance values
11/25/06 - LumResponse 1.5f
            - Fixed build that was missing tL_IL1700.ts in the wrapper.
            - Corrected typo in code causing the plotting option after a measurement to
              produce an error.
11/29/06 - Updated the README file to include detailed instructions for using the
           pacsDisplay applications to calibrate a display, along with examples of
           'configLL.txt' files for loadLUT.
12/01/06 - LumResponse 1.5f
            - Changed the output so the color measurements start with '#' and are treated
              as comments while the grayscale measurements start at 1.
         - Updated the following programs to include their version in their window titles and
           updated their copy dates:
            - Install 1.2
            - LLconfig 1.1
            - ChangeLUT 1.1
            - loadLUTdemo 1.0
            - LutGenerate 2.3
12/05/06 - LumResponse 1.5f
            - Added major and minor phase steps to the output, before the DL/L column.
            - Changed outlier checks to treat negative luminance changes as outliers,
              regardless of the outlier limit.
            - Altered the COMnum option to allow any number for the serial port, rather than
              just 1 or 2.
            - Moved wgnuplot.exe to a directory specified by the lumConfig.txt file.
12/06/06    - Changed the IL1700 window to display the major and minor grey levels starting at
              1 instead of 0.
            - Changed name of config file from lumConfig.txt to LRconfig.txt.
            - Included major and minor phases in log file, relative luminance change, and
              header labels.
            - An option was added to the config file that allows for the filtering of negative
              changes in luminance separate from positive ones.
            - Negative changes are no longer automatically treated as outliers.
            - Outlier filtering is no longer turned off if the limit values are set to 0.
12/07/06    - Included an option when an outlier is found to accept an outlier it as a
              measurement value if it persists.
            - Formatted log file to line up columns.
            - Formatted output file to line up columns.
            - Fixed an error with the major and minor phases in the output file.
12/07/06    - Shortcuts were changed for uncertain reasons.
              Shortcuts were repaired and set to read-only.
12/12/06 - LoadLUT 2.4
            - Changed LUTsearch so it would check for both the 4-digit and extended serial
              numbers.  Preference is given to the extended serial number.
            - Fixed an error with the search options where spaces in the directory names were
              changed to underscores.
12/14/06 - LumResponse 1.5g
            - Fixed an error in the outlier handling.  Will now be handled in lumResponse.tcl
              rather than in tL_IL1700.ts.
            - Included config option to limit the number of outlier tests.
            - Included config option for verbose logging.  When set, the log file will include
              all data from the IL1700.  This was previously the default.
12/15/06 - MAJOR UPDATE: Adjusted to new LUT-Library directory structure.
            - ChangeLUT 1.2
            - execLoadLUT 1.2
            - loadLUTdemo 1.1
            - loadLUT 2.4
            - Install 1.3
         - LutGenerate 2.4
            - Allowed the user to select the output file.
            - Included timestamp in output file.
         - LumResponse 1.5g
            - Restructured code to put procedures in a sub directory. Moved xirlDef to sourced
              file.
            - Output log entries to console for debugging.
            - Minor formatting changes to log and output files including a timestamp.
            - Fixed an error where the outliers were not being tallied properly.
            - Changed default mode to 1786.
12/17/06  - LumResponse 1.6
            - Added settings windows to change selected options from LRconfig.txt
            - restructured code, revised outlier definition, redesigned main window.
12/17/06 - LoadLUT 2.4
            - Updated to new LUTsearch procedures.  LUTsearch will now search for the LUT file
              in a LUT-Library directory with the display model name.  If it cannot find the
              file, then it will search for a generic LUT.
12/17/06 - gtest 1.1
            - revised to include color balance corrections
12/18/06 - Install 1.3
            - Moved Linear into Current System folder.
            - Included LUT-Library, and automatically updated.
         - LumResponse 1.6
            - Added option to build a Display ID from the EDID values.
12/19/06    - Fixed error preventing test image from being re-initialized.
            - Added messages to instruct users before and during a measurement.
            - Merged DisplayID and EDID options bar.
            - Added tolerance option to outlier checks.
            - Added number of outliers resolved/accepted to the output at the end of a
               measurement.
            - Updated plot options to include a plot of the luminance vs. p-value and save
               the plots as PNG files.
         - Uninstall 1.3
            - Version matched to install program.
            - Added version file to be removed.
12/22/06 - LumResponse 1.6
            - Added an additional delay during outlier tests controlled by a config file
              setting.
            - Adjusted display of minor/major states in IL window to correctly match the
              ILavg value.
12/27/06 - Install 1.3
            - Fixed multiple errors where attempts to copy directories were failing due to
              the directories already existing.
12/28/06    - Removed automatic LUT-Library overwrite, installing it only if it does not
              already exist.
         - LoadLUT 2.4
            - Wildcards included in LUTsearch for the LUT-Library directories
              (...\LUT-Library\<model_name*>)
            - LUTsearch will now search for the generic LUT directly in the <model_name*>
              directory instead of <model_name*>\LUTs.
         - lutGenerate 2.4
            - text on 'generate lut' button changed to red 'processing'
              while lut is being generated.
         -uLRstats1.0
            - plot generation commands (*.gnu file) generated with only
              file name and not full path in case location is changed.
         - loadLUT 2.4
            - fixed a minor error where the log file was incorrectly indicating that the
              LUTsearch function had failed when a 4-digit S/N file was found but not an
              extended S/N file.

-----------------------------------------------------------------------------
01/03/07  Released Package 3h - HFHS-pacsDisplay-p3h.zip
-----------------------------------------------------------------------------

01/03/07 - LumResponse 1.6
            - Jan 3 2007  Updated some of the messages before and after the luminance
              acquisition.
01/04/07 - LutGenerate 2.4
            - modified output to print 'target Lum+Lamb' and 'uLR Lum+Lamb'.
         - LumResponse 1.6
            - Changed font color to a dark grey for the main values in the IL window
              until initialized.
01/05/07    - Added outlier indicator in IL window.
01/08/07    - Minor changes to message windows.
01/09/07 - LoadLUTtest 1.1
            - Increased string buffer sizes to prevent read overflow errors.
01/10/07 - LLconfig 1.2
            - Code simplified.
            - Default values included at start to make them more intuitive.
         - LumResponse 1.6
            - Fixed minor error in display of last sub-step.
01/18/07 - README-HFHS_pacsDisplay.txt
            - updated help information particularly in section 3
01/26/07 - LumResponse 1.6
            - All parameters in the GEOM and IL1700 windows where
              parameters can be changed now have documentation
              activated by the help icon.

03/27/07 - Lut Library - 2007WFP added
                         1907FPV 350 LR LUT generated and made GENERIC
                         2007WFP 350 LR LUT made GENERIC

-----------------------------------------------------------------------------
03/27/07 - Released Package 3I - HFHS-pacsDisplay-p3I.zip
-----------------------------------------------------------------------------

03/29/07 - getEDID 1.1
            - added display resolution (native and current) to the output

04/09/07    - reformatted output to STDIO and error codes
         - LLconfig 1.3
            - Updated to use getEDID 1.1
         - LumResponse 1.7
            - Updated to use getEDID 1.1

04/11/07 - getEDID 1.1
            - removed error message box
            - extract and report image size mm field
            - reformatted output log file
04/12/07    - added pseudo display device detection and updated error codes.
04/23/07    - removed all remaining message boxes

07/12/07 - Added LUT data contributed by Mayo Clinic to Library.

10/04/08  - getEDID 1.1a
            - added the 'adapter string' and 'adapter name' to the end of
              the list of fields returned in the pip delimited record.
              This was done to identify the graphic card and the windows display
              number in the new EDIDprofile application.

10/15/08  - EDIDprofile1-0
            - tcl application to poll a set of EDID display numbers
              (default is from 1 to 6) and list the properties in columnar
              fashion. System information is summarized at the top.
              The adapter number (DISPLAY1, DISPLAY2, ...) correctly identifies
              the monitor with respect to the number shown in the windows
              display properties windows. Table placeholders are at the bottom
              where pass/fail visual test entries can be made.
            - ???? autogenerate dell config file and optionally install.
              ???? default same directory for installed package.

10/21/08  - lumResponse1-8
            - Generalized the application to support other types of luminance
              meters and added support for the LXcan USB meter from IBA Dosimetry.
              - LRconfig.txt revised with respect to the meter control and
                outlier detection variables. The meter used is defined now in
                this file. Variables are set for each meter defined in a procedure
                at the end of this file.
              - The GUI was modified to remove any reference to the IL1700 and
                use generic meter terms. In the 'METER' window, the meter used
                can now be changed using a radio buttom selection. Similarly, the
                documentation pages invoked by '?' buttons were revised to
                change specific reference to the IL1700.
                   NOTE: the tcl code still used IL or il to reference to variables
                         and procedures associated with meter measurements.
                         This was not changed. Just read these as generic luminance
                         related terms.
              - Included the LXcan executable and dll files in a BIN directory 
                for which the path in the code is defined as BINLX.
              - In the file lumR-IL.ts (formerly lumR-IL1700.ts) are the procedure
                to initialize the meter and the procedure invoked in reponse to the
                read fileevent (read handler). These now test for the meter defined,
                initialize the appropriate meter and set up the fileevent, and
                in the handler again test for the meter type and get the value on
                the read channel. Much of the handler involves the logistic of
                averaging or outlier testing which is done the same for all meters.
              - To add a new meter;
                New meters should provide an command line executable that returns
                measurement values in a timed continuous fashion using stdio.
                - revise LRconfig.txt to define the desired meter variables at the end.
                - add a new radio buttom with the new meter definition.
                - revise the two procedures in lumR-IL.ts
            - ???? 17 step mode
            - ???? cLR analysis for 17/256 cLRs

11/11/08  - iQC1g
            - png images converted from 24 bpp color to 8 bit grayscale using irfanview.

11/14/08 - version 3I+
            - packaged with updated LUT library as version 3I+
            - incorporated 

-----------------------------------------------------------------------------
11/17/08 - Released Package 4a - HFHS-pacsDisplay-p4a.zip  (Note: lower case a for test release)
-----------------------------------------------------------------------------

             The major version change to the 4 series is intended
             to reflect the incorporation of support for new USB luminance meters.
             Additionally, it marks the stabilization of the many features
             that were sequentially added in the 3 series of releases.

11/17/08 - version 4a 
		- The beta version of 4a with support for the IL1700 was
		  released. This version received extensive use withing HFHS
		  but was not released elsewhere.
		- Version 4b was used internally but differed only in that
		  additions had been made to the LUT library.

-----------------------------------------------------------------------------
11/17/08 - Released Package 4C - HFHS-pacsDisplay-p4C.zip
-----------------------------------------------------------------------------

05/01/11 - version 4C
		- Version 1.9 of LumResponse now has support for both the
		  IL1700, the LXcan, and the i1Display2 puck from xRite.
		  The i1Display2 is read using the Argyll spotread program
		  executed with Expect extensions to handle the text dialogue.
		  Preliminary testing indicates that the response of the
		  the i1display2 (obtained from CDWG as the NEC version)
		  agrees with a percent of the IL1700.
		- Version 1.9 of LumResponse now has support for a 16
		  step QC acquisiton. When this is saved, there is an
 		  option to analyze the data and provide a report that
		  can be plotted with gnuplot and has contrast in relation
		  to the DICOM GSDF. This mode increments by 16 similar
		  to the DEMO mode. The phase file has two modes that are
		  used to get the luminance difference for contrast assessment.
		  This is currently set for an offset of 8 and difference
		  of 6 gray levels.
		- Added labels to changeLUT to show version information.
		  Versions are now stated separately for the package and
		  for the LUT_library of a package so that library additions
		  can be made and documented only by the library version.

06/05/11 - Notes from SIIM2011 and changes made
                - assemble docs for distribution
                - timing of meter for i1
                - Libusb driver for distr.
                - install to other dirs
                - win 7 install
                x QC 16x2 correct for avg jnd
                x QC 16x2 need Lamb for analysis.
                x QC 16x2 improve report statistics
                - remove color from uLRstats (no longer in lumResponse)
                - need incorporation of EDIDprofile

05/31/11  -  Began the developement of version 5 which will be
             the first to offer support for Windows 7 (32 & 64 bit)
             along with QC evaluation support.

05/31/11  - ChangeLUT now reads the first line from Version files
            in the installed pacsDisplay directory and in the LUTs directory
            and shows current installed version information at the bottom.
            ChangeLUT now also serves a version check application.

08/08/11  - corrected title of help window in lumResponse.
          - revised new QC results analysis.

06/08/13  - Support for Windows 7 (32b & 64b) alonge with XP 32b.
            - install scripts use Program Files (x86) for 64 bit.
              New instructions for W7 security settings.
          - Significant upgrages to lumResponse (version 2.1)
            - Support for i1Display Pro which used the USB human interface
              and therefore does not need a driver installed.
              This is now the preferred meter with low noise and fast response.
            - Now reads color coordinates for each gray level.
              QC16x2 mode generates a white point tracking graphic result.
            - QC results now saved to named directory
              and plots have monitor model labels.
            - plots updated for +/-10% and +/-20%.
            - Demo mode now has fake luminance values.
          - updated gnuplot and argyll LIB routines.

-----------------------------------------------------------------------------
06/08/13  - Released Package 5a_beta (limited release at SIIM)
-----------------------------------------------------------------------------

11/23/13  - Beta test problems corrected.
            - Corrected bad links in W7-64bit shortcut,
                  execLUT.exe, pacsDisplay_uninstall.bat.
              Renamed loadLUT shortcuts for clarity.
            - Updated the version and README documentation files
              in the package distribution.
            - Updated the 16phase.txt file with the 5-11 phases
              used in the BIN-display version.
            - ConfigLR.txt updated with alternate path definitions
              for release and BIN or dev versions.
            - LIB files reconciled between dev, BIN-display, and release
              with README files. notepad.exe still kept in LIB release but
              has been changed to a system call in lumResponse.
            - Updated LLconfig to relative paths.
12/1/13     - Install and Uninstall programs overhauled with the LUTs
              directory now installed in User/Public (W7) or All Users (XP).
              The default path, or that selected, is written to LUTsDir.txt
              in the program installation directory.
12/8/13     - The README file was brought up to date and new sections added
              for the LUT-Library and for EIDS. The QUICKSTART file was
              condensed to just refer to the batch file and otherwise refer to
              the README file for details. THe documentation is now centralized 
              in README-HFHS_pacsDisplay.txt which could be converted to html.
              This readme was originally taken from P. Tchous thesis,
              It should now be considered the core documentation.
            - Updated programs to read the LUTsDir.txt file to get the
              path to the LUTs directory.
            - uLRstats and lutGenerate upgraded with help buttons added.
            - loadLUT utilies shortcuts are now in a sub-folder.
            - Log files are now written to the Users or All Users folder.
              The installer creates the LOGs directory at the same level
              as the LUTs directory.
12/15/2013  - QC16x2 evaluation plots updated. Color u',v' evaluation is now
              limited to luminances above 5 cd/m2 to conform with AAPM TG 196
              and IEC MT51 recommendations.
            - Now packaging pdQC for use in QC evaluations run from USB devices.
              Basic appication launcher included.
            - Executable files in the BIN directory now have folder names
              and program names that do not have the version. The version
              is still shown in the window title. This makes it easier to
              install new versions.
            - Install now generates the default configLL.txt file with the
              LUTs path in the arguement to /LUTsearch

-----------------------------------------------------------------------------
12/20/2013  - Released Package 5A_beta (limited release at HFHS)
-----------------------------------------------------------------------------

12/26/2013  - Revised QUICKSTART.txt
                Added security comment iabout running programs from USB memory.
                Moved the LUT comment at the top of Quickstart to the pacsDisplay section.
            - Section 4.2 on the config file rewritten and  that section placed in
              Current System with a filename of INSTRUCTIONS.txt.
              This documents the need for a dir arguement to /LUTsearch.
              The LUTsearch material was put first and extensively revised.
              The potential problem with Display Numbers and virtual devices was documented.
            - Added meter information in the lumResponse section.
            - Reorganized the README documentation file with separate sections
              for lumResponse and lutGenerate. A QC evaluation section was added
              to the lumResponse section. All INSTRUCTIONS.txt files were updated
              to reflect the revised documentation.
12/27/2013  - Revised gtest. Now at version 1-2.
	        - Corrected bug with hex value formats less that 16
                  by adding a leading 0 to the specifier, %02x.
	        - Adjusting binding on ALT-B1 for focus pattern.
                - Added ability to set or unset pur R,G, or B color.
                - Changed help message so it can stay up for reference.
12/27/2013  - pdLaunch changed to exec the apps in the background using the
              & arguement to the exec command. The process ID is captured
              and assigned to appPID($i). This variable is not presently being used.
            - EDID folder restored in pdQC BIN (folder was missing in beta1).
            - Added reference to EDIDprofile for Display Numbers in config-install.txt
            - iQC updated to version 2.0 with a help button at the upper left.
            - Included LR on the QC dLL plot. Also put similar labeling on the QC LUM plot.
            - Several error conditions in lumResponse trapped'
               - lumResponse save select file cancel.
               - record button when meter was not initialized
            - The modified messageBox was removed from lumResponse.
              It is old and potentially contributing to an execution but.
              However,  this puts the messages in the middle of the window
              which was the purpose for the modified message box.
              The procedure for the modified message Box was left in the tcl directory
            - The new eyeoneUtil.tsp from i1meter was incorporated in lumResponse
              and i1meter moved to lumResponse to wrap and distribute in BIN.
                NOTE: The need for libusb in  BIN-LR was seen on one system when
                      using i1meter. Others didn't need it. With this distribution
                      it will be there if needed.
            - i1meter was revised to incorporate clipboard bindings and INSTRUCTIONs.
              This is now in the install package and pdQC.
            - pdLaunch updated to include i1meter. Button height was reduced.

-----------------------------------------------------------------------------
12/29/2013  - Released Package 5A_beta2 (limited release at HFHS)
-----------------------------------------------------------------------------

01/03/2014  - Corrected error in gnuplot path for uLRstats.

01/21/2014  - Corrected window title for gtest and i1meter instuctions window.

01/21/2014  - gtest bindings on lower right color adjustments now
              turn solid colors on/off as described in the instructions.

01/21/2014  - i1meter now changes the value color to green
              when copied to the clipboard with BUTTON-3.
              Changes back to white when the next value is posted.

02/03/2014  - execLoadLUT can now delay executing loadLUT by a time
              period specified in the config file. Normally set to 0.
              This is provided in case another process is resetting the
              LUT during login or boot.

02/03/2014  - During install, notice is added that the default configLL.txt
              file with the install path needs to be restored.

02/03/2014  - Change the specification of the lumResponse image window size
              to 250 mm (~10 inchs) and the gray region size to 100 mm (~4 inchs)
              based on pixel pitch. Four options for pitch are defined in the
              config file and can be selected with radio buttons in the GEOM window.
              Selecting a new pitch recomputes the width and height in pixels
              which can then be further adjusted in this window.
02/06/2014  - lumResponse QC 16x2 evaluation generates
              a standalong html report withing the results folder.

02/07/2014  - In lumResponse, the help content was revised for the GEOM variables.

02/10/2014  - Corrected problem in W32 uninstall link properties.

02/20/2014  - The ArgyllCMS spotread application was updated from the 1.4 version
              to the 1.6.3 win32 version. A problem was recently reported having to do
              with the EEPROM Checksum evaluation for the device.
              http://www.freelists.org/post/argyllcms/i1-Display-Pro-External-EEPRrom-checksum-doesnt-match-on-162,1

02/20/2014  - Bug in install application corrected that prevented opening LLconfig.
              Now changes to BIN directory so that the config file can be read.

02/20/2014  - Four applications rebuilt with call to showManual for pdf section help.
                  lumResponse  section 3
                  lUTgenerate  section 4
                  LLconfig     section 5
                  uLRstats     section 6
              Install application revised to open pd-manual.pdf.

-----------------------------------------------------------------------------
02/20/2014  - Released Package 5A_beta3 (limited release at HFHS)
-----------------------------------------------------------------------------

02/21/2014  - Resolved a problem in lumResponse and QC-check with the path to the
              html template and logo files. The full path is now defined with the
              apps_path variable used for wrapped applications. The full file path
              is passed to the evalQC procedure in global commons.

02/21/2014  - LUT-Library folders for two Planar models repaired
              so that they conform to getEdid and the search option.

02/22/2014  - Added quotes around the LUTs directory path in the search option line
              of the configLL.txt default file created during installations.
              This is in the makeConfigLL procedure defined in config-install.txt.
              No problems have otherwise been detected with the userDir, logDir and 
              lumFilePath (i.e. path to _NEW) defined in getInstalledPaths.txt.

02/22/2014  - In QC-check, the files path for the getCLR procedure changed
              to make it available in the procedure global space.
              When passed as an arguement, it failed on XP systems because of spaces.

03/05/2014  - Verified byte count equivalence of the package zip downloaded from GitHub
              The .gitattributes has been configured to not export hidden Git files
              and to treat text and log files with CRLF line endings (Windows type).

-----------------------------------------------------------------------------
03/05/2014  - Released Package 5A_beta3b (release outside HFHS)

              This package can be downloaded from pacsdisplay.org
                   The package contents will remain the same,
                   however the devNotes file will be updated
                   with beta feedback shown below.
-----------------------------------------------------------------------------

ToDo        - pdlaunch dependant on _NEW directory. If not found, make it but don't fail.
              Check the message reported if the BIN directory is not found.
            - html table from evalQC: criteria for MEAN JND/GL wrong. Either - or <3 or ~2
            - LLconfig application is not adding the LUT path arguement to the search option line
            - Open the html file at end of evalQC routine and
              consider not showing the gnuplot sequence.
            - verify the equivalence of the NEC & xRite versions of the i1 Display Pro.
            - update LUTlibrary:
                   - review folder names for (n)
                   - verify that names on EA231, EA234 generic files are working
                   - add EA232 to library.
                   - find our from HFHS IT what enterprise monitors need to be included.
            - Update manual:
                   - incorporate screen captures.
                   - i1meter is not in the manual other that the initial application list.
                   - explain the potential need for setting a delay in the loadLUT config file
                     (see NOTE02, README_beta3.txt)


ZIBI ENCOUNTERED BUGs (W7 32b)
ToDo        - lumResponse crash seen on zibi (Win7 32b),
                   "ActiveState basekit has stopped working" error when record button pushed.
              The message box was changed in lumResponse which is where it was failing.
              This needs to be followed to see if the problem continues.
              Changes were made to remove the modified message box which is
              where the failure occurred.
                 -> no problems detected using beta3 version.

ToDo        - loadLUT-dicom executing from the startup folder on zibi (Win7 32b)
              appears to run at login and load the LUT based on the log.txt file,
              but the grayscale comes up linear. When the shortcut is executed
              from that directory it works.  I think another startup process is
              setting a linear LUT after loadLUT. A delay may be needed.
              http://windows.microsoft.com/en-us/windows7/change-color-management-settings.
              Testing to date indicates that it loads with a power shutdown and restart.
              At a minimum, there needs to be documentation about W7 color management settings.
                -> This was resolved in beta3 by using a delay of 1000 mSec (see README_beta3.txt)

-----------------------------------------------------------------------------
BUGS - ACTIVE
-----------------------------------------------------------------------------

.. loadLUT:

4/14/06 - Observed an error after rebooting a system and quickly logging
 in.  LoadLUT could not write to the second backup file and returned
 an error.  Subsequently running LoadLUT did not return an error.
 This error was seen again following a 2nd reboot and log in.
 Waiting an additional minute to log in did not result in the same error.

.. loadLUT, getEDID, LLconfig:
10/21/2008 - Rarely, the monitor number found by getEDID will not
  agree with the monitor numbers show on the Windows display settings
  application. loadLUT may attempt to configure a monitor and find
  that it is not attached. The reasons for this are believed to be 
  associated with virtual displays often found with remote system
  management applications. The fix is to find what display number
  the monitor is found at and manually edit configLL.txt to direct loadLUT
  to the proper monitor number. Note that configLL.txt can specify
  non-contiguous monitor numbers. The EDIDprofile application provided
  with version 4A is a useful tool to do identify the windows display number.

-----------------------------------------------------------------------------
BUGS - RESOLVED:
-----------------------------------------------------------------------------

4/27/06 - Under a user account with less than Administrator privelages,
          the loadLUT program gets stuck during the EDID read process and is
          non-responsive.  Current solution is the /noEDID option.
 
7/24/06 - Solution is to set the "C:\Program Files\HFHS"
          folder to give all users Full Control access.

10/12/06 - Encountered above issue again with a DIRAD network account.
          Had to add security access (Full Control) for the account separately since
          it was not included under the local user accounts.

11/21/06 - 
 loadLUT 2.3, When both /noEDID and /LDTsearch are set in the configLL.txt
          file, loadLUT tries to build a target filename without manufacturer dates.
          /LDTsearch was changed so that it cancels the search if no EDID information
          is available.
 LLconfig 1.1, Fixed a problem involving capitalization of
          "LUTsearch" and "LDTsearch" in the configLL.txt file.

4/27/06 - NVRotate (when a display is in portrait mode) causes an error
          where loadLUT cannot find the EDID for the rotated display in the
          registry.  Since this kind of error is currently treated as a fatal
          error by loadLUT, the LUT for that display is not loaded.
          Currently there is no solution except to skip the EDID read sequence
          using the /noEDID option. The problem has been reported to nVidia
          but we have not received a response.
12/18/06 - Updated NVIDIA drivers (vers 84, 3/2006) no longer have this issue.


-----------------------------------------------------------------------------
TODO:
-----------------------------------------------------------------------------

++++ DOCUMENTATION and HELP ++++

.. Convert the current README-HFHS_pacsDisplay.txt file
   to an HTML help document with images similar to the original
   documentation in P. Tchous thesis.
   The application help button (?) could be set up to
   open the html version at the appropriate section.
   The DOC file was left out of the 5a package, but consider
   including particularly if a few new papers get published.

.. Need a way to easily identify what LUTs have been installed
   by parsing the config log file.

++++ APPLICATIONS ++++

.. In lumResponse, use a more visible way to designate Lamb
   when doing QC measurements.

.. In lumResponse, continue to seek a message box that can be
   placed near the root window rather than in the monitor center.
   First thing to check is tcl 8.6. Then there seems to be some
   user message boxes that others have used (http://doveware.com/txmbox.html)

.. In lumResponse, provide a way to designate the monitor being
   evaluated for multi-monitor systems. Then get the size from
   getEDID and position the test Image with a gray region of a
   designated physical size.

.. lumResponse 256 QC mode for
   256 response acquisition with the data
   to a DICOM verification with statistic results
   equivalent to what we have done with spreadsheet.
   The intent is to obviate the need to go to a spread
   sheet to get results when measuring the calibrated response.
   - have lumResponse write lutmode on first line of uLR/cLR.
   - read this to identify 256 or 16x2
     Might be able to do this by reading first and counting lines.
     Don't need to read the phase file for 256 as in QC-check
   - rewrite evalQClr for 256 rather than 16 pairs.

.. lumResponse/lutGenerate,
   Investigate a color adjusted uncalibrated response
   and color corrected LUT. Might also consider restricting
   low luminance palette entries so that the relative change in
   color tone is less. Color tone changes in 1786 palette should
   be documented and related to just noticable differences.

.. For programs that generate gnuplot files, change
   any transparent options to notransparent so these
   can be used on web sites or for pdf documents.

.. Application support for illuminance measures using the i1Display Pro

++++ PACKAGE and INSTALL ++++

.. put doc files in package.

++++ DEVELOPMENT ENVIRONMENT ++++

.. make_install.tcl script to move new exe files to BIN.
   (only for development use)
   
