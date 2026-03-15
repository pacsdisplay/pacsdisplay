#########################################################################
#                      ChangeLUT  1.4                                   #
#  Written by:                                                          #
#    Philip M. Tchou (pmtchou@umich.edu)                                #
#                                                                       #
#  X-ray Imaging Lab, Henry Ford Health Systems, Detroit, MI            #
#                                                                       #
#  This program is a basic user interface for the loadLUT program.      #
#  loadLUT is a program to read display LUTs and load it into the       #
#  display card to set the luminance response.  ChangeLUT allows a user #
#  to load a preset linear LUT or system LUT configuration.             #
#                                                                       #
#  Version 1.0   May 2005   - Initial release.                          #
#  Version 1.1   Oct 2006   - Adjusted to new directory structure.      #
#                Nov 2006   - Adjusted to new directory structure.      #
#                             C:/Program Files/HFHS/pacsDisplay         #
#                Dec 2006   - Version included in window title.         #
#  Version 1.2   Dec 2006   - Adjusted to new LUT-Library structure.    #
#  Version 1.3   Jun 2011   - Added labels with version information.    #
#  Version 1.4   Nov 2013   - Read LUTs path from LUTsDir.txt file.     #
#                                                                       #
#########################################################################
#
#console show
#########################################################################
set title "ChangeLUT 1.4"
set copydate "Jun 2013"
# first tell the user what version he is using
#
puts "$title" 
#puts "Copyright:       Xray Imaging Research Laboratory"
#puts "                         Henry Ford Health System"
#puts "                         Detroit, MI"
#puts "                                         $copydate"
#
#########################################################################
#
option add *background  #E0E0E4    ;# defined consist with xirldefs-v06
#########################################################################
#  misc variables that need to be initialized
#
# set starting values

set info "NEMA publishes medical imaging standards\nthrough it's DICOM \
Committee (medical.nema.org).\nA grayscale standard display function\n \
is defined in DICOM part 3.14."

set warning "WARNING - GRAYSCALE LUT NOT INSTALLED"

#**********************************************************************
# Get the common paths.
#
source getInstalledPaths.txt
#
#**********************************************************************
# Get the paths to the current system and linear folders.

set systemDir   [file join $userDir LUTs "Current System"]    ;# System LUT configuration
set linearDir   [file join $systemDir Linear]                 ;# Linear LUT configuration

#**********************************************************************
# configure window settings
#
#
wm title .  "$title"
wm resizable . 0 0

# ---------------------------
# get the version information
set pkgVersFile [file join $installPath VERSION_INFO.txt]
set lutVersFile [file join $userDir LUTs LUT-Library VERSION_INFO.txt]

if [file isfile $pkgVersFile] {
	set FID [open $pkgVersFile r]
	set pkgVersion [gets $FID]
	close $FID
} else {
	set pkgVersion ""
}

if [file isfile $lutVersFile] {
	set FID [open $lutVersFile r]
	set lutVersion [gets $FID]
	close $FID
} else {
	set lutVersion ""
}
# ----------------------
# set up the command bar
#
frame .cmdbar1  -borderwidth 2 -padx 5m
frame .cmdbar2  -borderwidth 2 -padx 5m
frame .cmdbar3  -borderwidth 2 -relief sunken
frame .cmdbar4  -borderwidth 2
pack  .cmdbar1 .cmdbar2 .cmdbar3 .cmdbar4 -side top -fill both

#**********************************************************************
#   COMMAND BAR 1-3: select system LUT, linear LUT, and quit.
#**********************************************************************
#
# Load Current System LUT button
#
button .cmdbar1.system \
			-font {arial 12 bold} \
			-text  "DICOM GRAYSCALE" \
			-width 20  \
			-command "load_LUT \"$systemDir\""
#
# Load Linear LUT button
#
button .cmdbar2.linear  \
			-font {arial 12 bold} \
			-text  "LINEAR GRAYSCALE" \
			-width 20  \
			-command "load_LUT \"$linearDir\""
#
#  text label
#
label .cmdbar3.label   \
			-font {arial 10} \
			-text $info \
			-width 40
#
#  quit button
#
button .cmdbar4.quit  \
			-font {arial 12 bold} \
			-text Quit \
			-command  "Quit"
#
label .cmdbar4.ver \
			-font {arial 8} \
			-text ${pkgVersion}\n${lutVersion} \
			-justify left
pack  \
           .cmdbar1.system  \
                    -padx 1m -pady 1m
#
pack  \
           .cmdbar2.linear  \
                    -padx 1m -pady 1m
#
pack  \
           .cmdbar3.label  \
                    -padx 1m -pady 1m
#
pack  \
           .cmdbar4.ver   \
                    -padx 1m -pady 1m -side left
pack  \
           .cmdbar4.quit  \
                    -padx 1m -pady 1m -side right

#*********************************************************************
#  procedure to run loadLUT.exe
#
proc load_LUT {input} {
	global warning
	# run loadLUT.exe
	if { [catch {exec loadLUT.exe $input} output]} {
		;# $output contains the same information as written to log.
		tk_messageBox -type "ok" \
		              -icon "error"          \
		              -title "loadLUT ERROR" \
		              -message $warning
	} else {
		;# no message for a successful load
	}
}

#**********************************************************************
# procedure to close open files and quit
#
proc Quit {} {
	exit
}

#************************************************************************
# END ChangeLUT
#************************************************************************