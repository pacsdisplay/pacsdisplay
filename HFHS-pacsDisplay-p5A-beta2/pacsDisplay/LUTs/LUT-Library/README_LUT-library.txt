README-HFHS_pacsDisplay.txt
------------------------------------------------------------------------
      5.1 LUT-Library directories
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