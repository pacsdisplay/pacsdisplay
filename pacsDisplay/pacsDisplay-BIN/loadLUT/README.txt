The basic functions of the programs in this directory
are summarized below. Use of the loadLUT program is
highly dependant on entries in the configLL.txt file
which is read when the program runs.
For details on the entries in the configLL.txt file,
see:
       README-HFHS_pacsDisplay.txt

            M. Flynn & P. Tchou
            Jan, 2006
---------------------------------------------------------------------------


loadLUT.exe  (console application) execLoadLUT.tcl(exe)

   This is a basic utility to load LUTs to a monitor based
   on the information in the configLL.txt file.
   A directory is expected as an arguement
   (defaults to current directory if not present).
   The directory should contain the configLL.txt file and appropriate LUTs.
   This is generally invoked with a shortcut having the directory arguement.

execLoadLUT.tcl(.exe)

   The execLoadLUT program uses tcl exec to run the
   loadLUT program. This takes an arguement of either
   'linear' or 'system' to determine which LUT to load.
   The directory path is built accordingly.
   This is the preferred way to install LUTs in that
   artifacts from the console window flashing do not occur
   and the error message can be customized using the
   execLL-messages.txt file which must be in the same directory.

verifyLUT.exe (console application)

   This is a test utility that reads the currently installed LUT
   and compares it to the LUT designated in the configLL.txt file.
   It expects a directory as an arguement
   (defaults to current directory if not present).
   The directory should contain the configLL.txt file
   and the appropriate LUTs.
   This is generally used with a shortcut having the directory arguement.
   It does not report a dialoque if successful but writes
   a log file in the LUT directory documenting a successful test.
   If an error is found, a dialoque box reports the error found
   and the log file has the details.

loadLUTtest.exe (console application) loadLUTdemo.tcl(exe)

   loadLUTtest.exe should only be invoked by loadLUTdemo.tcl(.exe).
   loadLUTdemo requests a display number and LUT file
   and loads the specified LUT file to that monitor.
   It Writes the old lut and a log in the same directory
   as the loadLUTtest.exe.


changeLUT.tcl(.exe)

    tk application that invokes loadLUT.exe to change
    between LINEAR and DICOM grayscale LUTs.
    Must be in the same directory as loadLUT.exe.
    LUTs/Current System and LUTS/Linear must also
    be in the directory with the exe files.

