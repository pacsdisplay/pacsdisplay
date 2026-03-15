package provide app-Uninstall_1-5 1.0

#########################################################################
#              HFHS-pacsDisplay Uninstall 1.5                           #
#  Copyright (C) 2019  Henry Ford Health System                         #
#  Written by:                                                          #
#    Philip M. Tchou (pmtchou@umich.edu)                                #
#    Michael Flynn (mikef@rad.hfh.edu)                                  #
#    Nicholas B. Bevins (nick@rad.hfh.edu)                              #
#                                                                       #
#  This program deletes the HFHS-pacsDisplay files and directories from #
#  their default locations including the Start Menu.                    #
#                                                                       #
#  Version 1.1   Oct 2006   - Initial release.  Version matched to      #
#                             install program.                          #
#  Version 1.2   Oct 2006   - rearranged directory structure for LUTs,  #
#                             shortcuts, and installation files.        #
#                           - Rearranged base directory structure,      #
#                             C:/Program Files/HFHS/pacsDisplay,        #
#                             and moved the shortcuts directory and     #
#                             readme files up.                          #
#  Version 1.3   Dec 2006   - Version matched to install program.       #
#                           - Added version file to be removed.         #
#  Version 1.4   Jun 2013   - Windows 7 support                         #
#  Version 1.5   Oct 2019   - Windows 10 support                        #
#                                                                       #
#  NOTE: This is specific to an installation in C:\Program Files        #
#        (or C:\Program Files (x86) for Windows 7/10 64bit) and for     #
#        the LUTs directory recorded in the LUTsDir.txt file written    #
#        in the install directory.                                      #
#        If a non-standard installation directory is used,              #
#        change the definition of target_HFHS_dir in the first          #
#        tcl script line of the directory paths section.                #
#                                                                       #
#########################################################################
#
#
#console show
wm withdraw .

#########################################################################
set title "HFHS-pacsDisplay Uninstall 1.5"
set copydate "October 2019"
# first tell the user what version is running
#
puts "$title"
#
#########################################################################
# Check Windows OS Verson

set errorMsg1 "
Windows OS Version $tcl_platform(osVersion) not valid.

Installation of pacDisplay is valid for:
  5.1 - Windows XP 32 bit
  6.1 - Windows 7  32 or 64 bit
  10.0 - Windows 10 "

if {$tcl_platform(osVersion) == "6.1" || $tcl_platform(osVersion) == "6.2" || $tcl_platform(osVersion) == "10.0"} {
	set winOS W7
} elseif {$tcl_platform(osVersion) == "5.1"} {
	set winOS XP
} else {
	tk_messageBox -type ok               \
	              -message $errorMsg1    \
	              -title "Install Error"
	exit
}

set errorMsg2 "
'Program Files' directory not found on C drive
    XP & W7(32b) - Program Files
    W7(64b) & W10 - Program Files (x86)"

if {$winOS == "XP"} {
	if {[file isdirectory "C:/Program Files"] == 1} {
		set programFiles "Program Files"
		set winOSbits 32b
	} else {
		tk_messageBox -type ok               \
		              -message $errorMsg2    \
		              -title "Install Error"
		exit
	}
} elseif {$winOS == "W7"} {	
	if {[file isdirectory "C:/Program Files (x86)"] == 1} {
		set programFiles "Program Files (x86)"
		set winOSbits 64b
	} elseif {[file isdirectory "C:/Program Files"] == 1} {
		set programFiles "Program Files"
		set winOSbits 32b
	} else {
		tk_messageBox -type ok               \
		              -message $errorMsg2    \
		              -title "Install Error"
		exit
	}
} else {
		tk_messageBox -type ok                           \
		              -message "Invalid winOS: $winOS"    \
		              -title "Install Error"
		exit
}

#########################################################################
# Define Program Files directory paths

set target_pacsDisplay_dir "C:/${programFiles}/HFHS/pacsDisplay"

set license_filename "GNU-GPL.txt"
set lutsDir_filename "LUTsDir.txt"
set install_batch_filename "pacsDisplay_INSTALL.bat"
set Uninstall_batch_filename "pacsDisplay_uninstall.bat"
set readme_filename "README-HFHS_pacsDisplay.txt"
set version_filename "VERSION_INFO.txt"
set temp_filename "pacsDisplay_temp.bat"

# temporary batch file needs backslashes for the file delete command
set temp_filename_delete "C:\\${programFiles}\\HFHS\\${temp_filename}"

#-------
# get the LUTs path
set ldFID [open [file join $target_pacsDisplay_dir $lutsDir_filename] r]
gets $ldFID
set target_pacsDisplayLUTs_dir [gets $ldFID]
close $ldFID

#########################################################################
#  misc variables that need to be initialized
#
# set starting values

set keep_LUTs 0
set error 0

#*********************************************************************
#  construct file and directory names to be removed
#

# ...target directories and files
set install_file [file join $target_pacsDisplay_dir $install_batch_filename]
set license_file [file join $target_pacsDisplay_dir $license_filename]
set readme_file  [file join $target_pacsDisplay_dir $readme_filename]
set version_file [file join $target_pacsDisplay_dir $version_filename]
set lutsDir_file [file join $target_pacsDisplay_dir $lutsDir_filename]
set target_BIN_dir [file join $target_pacsDisplay_dir pacsDisplay-BIN]
	set target_gtest_dir [file join $target_BIN_dir gtest]
	set target_install_dir [file join $target_BIN_dir install]
	set target_iQC_dir [file join $target_BIN_dir iQC]
	set target_LLconfig_dir [file join $target_BIN_dir LLconfig]
	set target_loadLUT_dir [file join $target_BIN_dir loadLUT]
	set target_lumResponse_dir [file join $target_BIN_dir lumResponse]
	set target_lutGenerate_dir [file join $target_BIN_dir lutGenerate]
	set target_Icons_dir [file join $target_BIN_dir _ICONS]
	set target_EDIDprofile_dir [file join $target_BIN_dir EDIDprofile]
	set target_install_dir [file join $target_BIN_dir install]
	set target_LIB_dir [file join $target_BIN_dir LIB]
	set target_uLRstats_dir [file join $target_BIN_dir uLRstats]
set target_shortcuts_dir [file join $target_pacsDisplay_dir shortcuts]

set target_LUTs_dir [file join $target_pacsDisplayLUTs_dir LUTs]
	set target_CurrentSystem_dir [file join $target_LUTs_dir "Current System"]


# ...target Start Menu directories
if {$winOS == "W7"} {
	set target_StartMenu "C:/ProgramData/Microsoft/Windows/Start Menu"
	set target_Programs "C:/ProgramData/Microsoft/Windows/Start Menu/Programs"
	set target_Programs_grayscale [file join $target_Programs "HFHS ePACS grayscale"]
	set target_Programs_tools [file join $target_Programs "HFHS Grayscale Tools"]
	set target_Startup "C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup"
} elseif {$winOS == "XP"} {
	set target_StartMenu "C:/Documents and Settings/All Users/Start Menu"
	set target_Programs "C:/Documents and Settings/All Users/Start Menu/Programs"
	set target_Programs_grayscale [file join $target_Programs "HFHS ePACS grayscale"]
	set target_Programs_tools [file join $target_Programs "HFHS Grayscale Tools"]
	set target_Startup "C:/Documents and Settings/All Users/Start Menu/Programs/Startup"
} else {
	tk_messageBox -type ok               \
	              -message $errorMsg1    \
	              -title "Install Error"
	exit
}

# ...target Start Menu shortcut filenames
set target_StartMenu_iQC_lnk [file join $target_StartMenu iQC.lnk]
set target_Startup_loadLUT_lnk [file join $target_Startup loadLUT-dicom.lnk]

# ...temporary batch file for uninstall.
set temp_batch_file [file join [file dirname $target_pacsDisplay_dir] $temp_filename]


#*********************************************************************
#  Option to delete the LUTs
#

# ...delete LUTs directory?
set textmsg    "You have chosen to uninstall pacsDisplay."
append textmsg "\n\nA LUTs folder was installed in:"
append textmsg "\n\n  ${target_LUTs_dir}"
append textmsg "\n\nDo you want to delete this LUTs directory?"

set answer [tk_messageBox -type yesno \
				-title "$title - Delete LUTs?" \
				-message $textmsg ]

if {$answer == "no"} {
	set keep_LUTs 1
}

#*********************************************************************
#  Warning and confirmation message
#

# ...confirm uninstall?
set textmsg    "All files associated with a pacsDisplay installation "
append textmsg "in $target_pacsDisplay_dir will be removed."
if {$keep_LUTs} {
	append textmsg "\n\n$target_LUTs_dir will be kept."
} else {
	append textmsg "\n\n$target_LUTs_dir will be DELETED."
}
append textmsg "\n\nDo you wish to continue?"

set answer [tk_messageBox -type yesno \
				-title "$title - Confirm Uninstall" \
				-message $textmsg ]

if {$answer == "no"} {
	incr error
}


#*********************************************************************
#  <CAUTION!> DELETE installed files and directories
#

if {$error == 0} {

	# ...DELETE directories from previous installation

	file delete -force $target_StartMenu_iQC_lnk
	file delete -force $target_Startup_loadLUT_lnk
	file delete -force $target_Programs_grayscale
	file delete -force $target_Programs_tools

	if {$keep_LUTs == 0} {
		file delete -force $target_LUTs_dir
		file delete -force $target_pacsDisplayLUTs_dir
	}

	file delete -force $license_file
	file delete -force $readme_file
	file delete -force $version_file
	file delete -force $lutsDir_file

	file delete -force $target_gtest_dir
	file delete -force $target_iQC_dir
	file delete -force $target_LLconfig_dir
	file delete -force $target_loadLUT_dir
	file delete -force $target_lumResponse_dir
	file delete -force $target_lutGenerate_dir
	file delete -force $target_shortcuts_dir
	file delete -force $target_Icons_dir
	file delete -force $target_EDIDprofile_dir
	file delete -force $target_LIB_dir
	file delete -force $target_uLRstats_dir

#	file delete -force $target_install_dir
#	file delete -force $install_file
}


#*********************************************************************
#  Finished
#     Build a batch file to delete final files

if {$error == 0} {
	# ...<CAUTION!> setup batch file to delete source directories
	file delete -force $temp_batch_file
	set fileout [open $temp_batch_file w]
	puts $fileout "@echo off"
	puts $fileout "rem"
	puts $fileout "rem This is a temporary file for pacsDisplay uninstall."
	puts $fileout "rem"
	puts $fileout "rd /S /Q \"$target_pacsDisplay_dir\""
	puts $fileout "del /F /Q \"$temp_filename_delete\""
	;#puts $fileout "PAUSE"  ;# used for debug
	close $fileout
}


# ...uninstall incomplete
if {$error} {

	# ...installation incomplete
	tk_messageBox \
		-type ok \
		-title "$title - INCOMPLETE" \
		-message "HFHS pacsDisplay was not uninstalled."
} else {

	# ...uninstall complete
	tk_messageBox -type ok \
		-title "$title - Uninstall Complete" \
		-message "HFHS pacsDisplay uninstalled."
}

# ...clean up and exit

exit
#************************************************************************
# END Install
#************************************************************************
