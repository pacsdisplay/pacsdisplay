package provide app-Install_1-5 1.0

#########################################################################
#  GENERAL PUBLIC LICENSE:                                              #
#  HFHS-pacsDisplay Install 1.5                                         #
#  Copyright (C) 2019  Henry Ford Health System                         #
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
#  CONTACT INFORMATION:                                                 #
#     Nicholas B. Bevins, Henry Ford Health System                      #
#     Henry Ford Hospital                                               #
#     Detroit, MI 48202                                                 #
#     nick@rad.hfh.edu                                                  #
#                                                                       #
#########################################################################
#                     HFHS-pacsDisplay Install 1.5                      #
#  Written by:                                                          #
#    Philip M. Tchou                                                    #
#    Michael J. Flynn                                                   #
#    Nicholas B. Bevins                                                 #
#                                                                       #
#  This program copies the HFHS-pacsDisplay files to their default	#
#  installation directories. 	It is assumed that this file is in the  #
#  "pacsDisplay-BIN/install" directory and the                          #
#  "pacsDisplay_install.bat file"is in the next higher directory.       #
#                                                                       #
#  Version 1.0   Apr 2006   - Initial release.                          #
#  Version 1.1   Sep 2006   - Added a directory check to see if the     #
#                             HFHS and pacsDisplay directories already  #
#                             exist.  If not, they are created and the  #
#                             proper files are copied over.  Dialogue   #
#                             boxes added to facilitate this and give   #
#                             the user the option to cancel.            #
#                           - Added option to open LLconfig at the end  #
#                             to build a configuration file             #
#                Oct 2006   - Added option to not overwrite files in    #
#                             the "Current System" directory.           #
#                           - Added instructions to set HFHS directory  #
#                             to "Full Access" for clients using the    #
#                             loadLUT utilities.                        #
#                           - Added option to remove installation       #
#                             files if installed from someplace other   #
#                             than "C:/Program Files/HFHS".  This still #
#                             leaves behind the (empty) HFHS folder.    #
#                           - Start menu folder, "HFHS ePACS dcmLUTs"   #
#                           - changed to "HFHS Grayscale Tools".        #
#                           - Option provided to install grayscale      #
#                             tools (full install) or not (enterprise). #
#                           - All options compiled into a single        #
#                             interface window.                         #
#                           - Default settings built into a config      #
#                             file, "install_config.txt"                #
#  Version 1.2   Oct 2006   - rearranged directory structure for LUTs,  #
#                             shortcuts, and installation files.        #
#                           - Added option to view the readme file at   #
#                             the end of an installation.               #
#                Nov 2006   - Added license and disclaimer message      #
#                           - Rearranged interface                      #
#                           - Rearranged base directory structure,      #
#                             C:/Program Files/HFHS/pacsDisplay,        #
#                             and moved the shortcuts directory and     #
#                             readme files up.                          #
#                           - Check old version locations for the LUTs  #
#                             directory to be saved and delete the old  #
#                             directory structure.                      #
#                           - Updated the starting disclaimer notice.   #
#                           - Added quickstart and version files.       #
#                           - Moved temporary .bat file out of the      #
#                             pacsDisplay directory to allow the readme #
#                             file to be opened without delaying the    #
#                             deletion of the source directories.       #
#                Dec 2006   - Version included in window title.         #
#  Version 1.3   Dec 2006   - Moved Linear into Current System folder.  #
#                           - Included LUT-Library, and automatically   #
#                             updated.                                  #
#                           - Fixed multiple errors where attempts to   #
#                             copy directories were failing due to the  #
#                             directories already existing.             #
#                           - Removed automatic LUT-Library overwrite,  #
#                             installing it only if it does not already #
#                             exist.                                    #
#  Version 1.4   Nov 2013   - Revised for Windows 7 installation.       #
#                           - bug fixed in Select for change directory. #
#                           - updated for new shortcut filenames.       #
#                           - LUTs now installed is a location          #
#                             compatible with Windows 7 policy.         #
#                             The located is recorded in the LUTsDir.txt#
#                             file written in the install directory.    #
#                           - No longer checking for prior installation #
#                             in locations used in installations prior  #
#                             to 2006.                                  #
#                           - No longer offering an option to delete    #
#                             the distribution files used for install.  #
#                             This eliminates the need to launch a      #
#                             temporary batch file at the end.          #
#                             The readme file is now opened from the.   #
#                             install script with a call to notepad.    #
#                             A batch file is still used to start the   #
#                             Install.exe to use a relative path.       #
#                Dec 2013   - For the /LUTsearch option in configLL,    #
#                             their needs to be a dir arguement for the #
#                             LUT-library otherwise a default is used   #
#                             that is no longer valid for version 5.    #
#                             At the end of the installation, a default #
#                             configLL.txt file is now written to the   #
#                             user dir that is written to LutsDir.txt.  #
#                Feb 2014   - Now moving _pd-Manual folder in           #
#                             pacsDisplay-BIN to Program Files.         #
#                           - README-HFHS_pacsDisplay.txt has now been  #
#                             replaced by the pdf manual.               #
#  Version 1.5   Oct 2019   - Updated for W10 - reflect in winOS        #
#                             variable.                                 #
#                                                                       #
#  NOTE: This is specific to an installation in the default directory.  #
#        If a non-standard installation directory is selected,          #
#        the installer is warned that the shortcuts will invalid.       #
#                                                                       #
#########################################################################
#
option add *background  #E0E0E4    ;# defined consist with xirldefs-v06
#########################################################################
#
#console show
#########################################################################
set title "HFHS pacsDisplay Package Installation"
set copydate ""
# first tell the user what version is running
#
puts "$title"
#
#########################################################################
# GNU GPL Message

# ...window settings
wm title . $title

# ...remove window
wm withdraw .

# ...specify license terms
set gpl_title "HFHS-pacsDisplay"
set gpl_copydate "Feb. 2014"
set gpl_author "Henry Ford Health System"
set gpl_filename "GNU-GPL.txt"
set gpl_directory "pacsDisplay"

set textmsg    "$gpl_title"
append textmsg "\nCopyright (C) $gpl_copydate"
append textmsg "\n$gpl_author"
append textmsg "\n\n$gpl_title comes with ABSOLUTELY NO WARRANTY."
append textmsg "\n\nThis software is freely provided for non-commercial use by the"
append textmsg "\nauthors and HFHS.  The authors and HFHS cannot provide support"
append textmsg "\nand assume no responsibility for its use."
append textmsg "\n\nYou are welcome to redistribute it under the conditions of"
append textmsg "\nthe GNU General Public License version 2 or any later version."
append textmsg "\nSee $gpl_filename in the $gpl_directory directory for details."
append textmsg "\n\nDo you accept these terms?"

# ...ask user to accept the license agreement
set answer [tk_messageBox -type yesno \
	-title "$title - License & Disclaimer" \
	-message $textmsg ]

if {$answer == "no"} {
	exit
}

#########################################################################
# Check Windows OS Verson and 32b/64b
# set target directories accordingly

set errorMsg1 "
Windows OS Version $tcl_platform(osVersion) not valid.

Installation of pacDisplay is valid for:
  5.1 - Windows XP 32 bit
  6.1 - Windows 7  32 or 64 bit"

if {$tcl_platform(osVersion) == "6.1" || $tcl_platform(osVersion) == "6.2" || $tcl_platform(osVersion) == "10.0"} {
	set winOS W7orW10
	set target_defaultLUTs_dir "C:/Users/Public/HFHS/pacsDisplay"
} elseif {$tcl_platform(osVersion) == "5.1"} {
	set winOS XP
	set target_defaultLUTs_dir "C:/Documents and Settings/All Users/HFHS/pacsDisplay"
} else {
	tk_messageBox -type ok               \
	              -message $errorMsg1    \
	              -title "Install Error"
	exit
}

set errorMsg2 "
'Program Files' directory not found on C drive
    XP & W7(32b) - Program Files
    W7 & W10(64b) - Program Files (x86)"

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
} elseif {$winOS == "W7orW10"} {	
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
		              -message "Invalid winOS"            \
		              -title "Install Error"
		exit
}

set target_default_dir "C:/${programFiles}/HFHS/pacsDisplay"

#make the LOGs directory (no action if it exists)
file mkdir [file join $target_defaultLUTs_dir LOGs]

#########################################################################
# Define Program Files and directory paths

set target_pacsDisplay_dir     $target_default_dir
set target_pacsDisplayLUTs_dir $target_defaultLUTs_dir
set temp_filename              "pacsDisplay_temp.bat"

set license_filename           "GNU-GPL.txt"
set lutsDir_filename           "LUTsDir.txt"
set install_config_filename    "config-install.txt"
set install_batch_filename     "pacsDisplay_INSTALL.bat"
set Uninstall_batch_filename   "pacsDisplay_uninstall.bat"
set Uninstall86_batch_filename "pacsDisplay_uninstall(x86).bat"
set version_filename           "VERSION_INFO.txt"
set quickstart_filename        "QUICKSTART.txt"
set LLconfig_filename          "LLconfig.exe"
set pdManual_filename          "pd-Manual.pdf"

# ...restore window
wm state . normal
wm resizable . 0 0
focus -force .


#########################################################################
#  misc variables that need to be initialized
#  error quit if config file is not present or can't be sourced
#
# set starting values
set basefont "arial 10"
set basefont_bold "arial 10 bold"


# ...check for config file and read
if {[file exists pacsDisplay-BIN/install/$install_config_filename]} {
	set config_error 0

	# ...open config file
	if [catch {source pacsDisplay-BIN/install/$install_config_filename} error-cLL] {
		incr config_error
		set    errorConfig "Cannnot source $install_config_filename \n\n"
		append errorConfig "$error-cLL\n\n"
		puts stderr $errorConfig
		tk_messageBox -type ok                 \
		              -message $errorConfig    \
		              -title "Config Error"
		exit
	}
} else {
	incr config_error
	set errorConfig "Error: $install_config_filename not present. \n"
	tk_messageBox -type ok                 \
		              -message $errorConfig    \
		              -title "Config Error"
	exit
}

#########################################################################
#  Build graphic application window
#########################################################################

frame .title_bar -relief raised -borderwidth 2

frame .dir1 -relief sunken -borderwidth 6
frame .dir1.targetdir_bar1 -relief raised -borderwidth 2
frame .dir1.targetdir_bar2 -relief raised -borderwidth 2
pack  .dir1.targetdir_bar1 .dir1.targetdir_bar2 -side top -fill both

frame .dir2 -relief sunken -borderwidth 6
frame .dir2.targetdirLUTs_bar1 -relief raised -borderwidth 2
frame .dir2.targetdirLUTs_bar2 -relief raised -borderwidth 2
pack  .dir2.targetdirLUTs_bar1 .dir2.targetdirLUTs_bar2 -side top -fill both

frame .options -relief sunken -borderwidth 6
frame .options.title_bar -relief raised -borderwidth 2
frame .options.overwrite_bar -relief raised -borderwidth 2
frame .options.saveconfig_bar -relief raised -borderwidth 2
frame .options.tools_bar -relief raised -borderwidth 2
frame .options.buildconfig_bar -relief raised -borderwidth 2
pack  .options.title_bar      .options.overwrite_bar \
      .options.saveconfig_bar .options.tools_bar    \
      .options.buildconfig_bar -side top -fill both

frame .runquit_bar -relief raised -borderwidth 2

pack .title_bar .dir1 .dir2 .options .runquit_bar -side top -fill both
#
#**********************************************************************
#   Program Title
#**********************************************************************
#
#  Title for the program with copy date
#
label .title_bar.label \
			-font {arial 12 bold} \
			-text "$title: ${winOS},$winOSbits"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .title_bar.label  \
                    -side left -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Target Installation Directory
#**********************************************************************
#
#  text variable for the target pacsDisplay directory
#
label .dir1.targetdir_bar1.label \
			-font $basefont_bold \
			-text "The defaut directory for pacsDisplay programs is:"
label .dir1.targetdir_bar2.label \
			-font $basefont_bold \
			-justify left \
			-width 40 \
			-text $target_pacsDisplay_dir
#
#  select target directory
#
button .dir1.targetdir_bar2.selectdir \
			-font $basefont \
			-text "Change" \
			-command "SelectInstallDir"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .dir1.targetdir_bar1.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .dir1.targetdir_bar2.selectdir  \
                    -side right -padx 1m -pady 1m -fill x
pack   \
           .dir1.targetdir_bar2.label  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Target LUTs Directory
#**********************************************************************
#
#  text variable for the target LUTs directory
#
label .dir2.targetdirLUTs_bar1.label \
			-font $basefont_bold \
			-text "The defaut directory for the LUTs folder is:"
label .dir2.targetdirLUTs_bar2.label \
			-font $basefont_bold \
			-justify left \
			-width 40 \
			-text $target_pacsDisplayLUTs_dir
#
#  select target directory
#
button .dir2.targetdirLUTs_bar2.selectdir \
			-font $basefont \
			-text "Change" \
			-command "SelectLUTsDir"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .dir2.targetdirLUTs_bar1.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .dir2.targetdirLUTs_bar2.selectdir  \
                    -side right -padx 1m -pady 1m -fill x
pack   \
           .dir2.targetdirLUTs_bar2.label  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   OPTIONS
#**********************************************************************

label .options.title_bar.label1 \
			-font $basefont \
			-text "OPTIONS:"
label .options.title_bar.label2 \
			-font $basefont \
			-text "Typical Setting"
pack   \
           .options.title_bar.label1  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .options.title_bar.label2  \
                    -side right -padx 1m -pady 1m -fill x

#**********************************************************************
#   OPTION: Overwrite Previous Installation
#**********************************************************************
#
#  Option to overwrite previous pacsDisplay installation
#
label .options.overwrite_bar.label \
			-font $basefont \
			-text "1. Overwrite an existing installation?  "
radiobutton .options.overwrite_bar.radio1 \
			-font $basefont \
			-text Yes \
			-variable overwrite \
			-value 1
radiobutton .options.overwrite_bar.radio2 \
			-font $basefont \
			-text No \
			-variable overwrite \
			-value 0
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .options.overwrite_bar.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .options.overwrite_bar.radio2   \
                    -side right -padx 1m -pady 1m -fill x
pack   \
           .options.overwrite_bar.radio1   \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   OPTION: Overwrite previous LUTs directory with current system
#**********************************************************************
#
#  Option to save the LUTs directory
#
label .options.saveconfig_bar.label \
			-font $basefont \
			-text "2. Overwrite an existing LUTs directory?  "
radiobutton .options.saveconfig_bar.radio1 \
			-font $basefont \
			-text Yes \
			-variable overwriteLUTs \
			-value 1
radiobutton .options.saveconfig_bar.radio2 \
			-font $basefont \
			-text No \
			-variable overwriteLUTs \
			-value 0
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .options.saveconfig_bar.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .options.saveconfig_bar.radio2   \
                    -side right -padx 1m -pady 1m -fill x
pack   \
           .options.saveconfig_bar.radio1   \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   OPTION: Grayscale Toolset (Full Installation)
#**********************************************************************
#
#  Option to install the grayscale calibration toolset
#
label .options.tools_bar.label \
			-font $basefont \
			-text "4. Install grayscale calibration toolset?  "
radiobutton .options.tools_bar.radio1 \
			-font $basefont \
			-text Yes \
			-variable full_install \
			-value 1
radiobutton .options.tools_bar.radio2 \
			-font $basefont \
			-text No \
			-variable full_install \
			-value 0
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .options.tools_bar.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .options.tools_bar.radio2   \
                    -side right -padx 1m -pady 1m -fill x
pack   \
           .options.tools_bar.radio1   \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   OPTION: Build Config File
#**********************************************************************
#
#  Option to run LLconfig after installation
#
label .options.buildconfig_bar.label \
			-font $basefont \
			-text "5. Run config file builder (LLconfig) after install?  "
radiobutton .options.buildconfig_bar.radio1 \
			-font $basefont \
			-text Yes \
			-variable run_LLconfig \
			-value 1
radiobutton .options.buildconfig_bar.radio2 \
			-font $basefont \
			-text No \
			-variable run_LLconfig \
			-value 0
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .options.buildconfig_bar.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .options.buildconfig_bar.radio2   \
                    -side right -padx 1m -pady 1m -fill x
pack   \
           .options.buildconfig_bar.radio1   \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Install and Quit.
#**********************************************************************
#
# install button
#
button .runquit_bar.inst  \
			-font $basefont_bold \
			-text "INSTALL" \
			-command "Install"
#
#  quit button
#
button .runquit_bar.quit  \
			-font $basefont_bold \
			-text "QUIT" \
			-command  "Quit"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack  \
           .runquit_bar.inst  \
                    -side left -padx 1m -pady 1m -fill x
pack  \
           .runquit_bar.quit  \
                    -side right -padx 1m -pady 1m -fill x


#*********************************************************************
#  procedure to select the target installation directory
#
proc SelectInstallDir {} {
	global title target_pacsDisplay_dir target_default_dir

	# ...select directory
	set select_dir [tk_chooseDirectory \
				-title "Select installation directory for HFHS-pacsDisplay" \
				-initialdir $target_pacsDisplay_dir]

	if {$select_dir == ""} {
		return
	}

	if {$select_dir != $target_default_dir} {
		# ...non-standard installation directory
		set    textmsg "You have chosen a non-standard directory.\n"
	      append textmsg "Installed shortcuts will not function properly.\n\n"
	      append textmsg "Do you wish to continue?"
		set answer [tk_messageBox -type yesno \
						-title "$title - Non-standard Directory" \
						-message $textmsg ]

		if {$answer == "yes"} {
			set target_pacsDisplay_dir $select_dir
			.dir1.targetdir_bar2.label configure -text $target_pacsDisplay_dir
		}
	}
}
#*********************************************************************
#  procedure to select the target installation directory
#
proc SelectLUTsDir {} {
	global title target_pacsDisplayLUTs_dir target_defaultLUTs_dir

	# ...select directory
	set select_dir [tk_chooseDirectory \
				-title "Select installation directory for HFHS-pacsDisplay" \
				-initialdir $target_pacsDisplayLUTs_dir]

	if {$select_dir == ""} {
		return
	}

	if {$select_dir != $target_defaultLUTs_dir} {
		# ...non-standard installation directory
		set    textmsg "You have chosen a non-standard directory.\n"
	      append textmsg "    If the folder is manually moved later,\n"
	      append textmsg "    edit LUTsDir.txt in the install folder.\n\n"
	      append textmsg "Do you wish to continue?"
		set answer [tk_messageBox -type yesno \
						-title "$title - Non-standard Directory" \
						-message $textmsg ]

		if {$answer == "yes"} {
			set target_pacsDisplayLUTs_dir $select_dir
			.dir2.targetdirLUTs_bar2.label configure -text $target_pacsDisplayLUTs_dir
		}
	}
}
#########################################################################
# BEGIN Install
#########################################################################

proc Install {} {
	global set target_pacsDisplay_dir target_pacsDisplayLUTs_dir LLconfig_filename
	global install_batch_filename Uninstall_batch_filename Uninstall86_batch_filename
	global lutsDir_filename overwriteLUTs full_install run_LLconfig overwrite
	global license_filename version_filename quickstart_filename
	global target_oldLUTs_dir target_oldBIN_dir target_oldLinear_dir
	global winOS winOSbits temp_filename title copydate pdManual_filename

	set prior_install          0
	set prior_LUTs             0
	set prior_BIN_exists       0
	set prior_config_exists    0
	set prior_library_exists   0
	set prior_shortcuts_exists 0
	set error 0

	#************
	# create the LUTsDir.txt file with the path to the LUTs folder.

	set ldFID [open $lutsDir_filename w]
	puts $ldFID "# Directory to the LUTs folder"
	puts $ldFID $target_pacsDisplayLUTs_dir
	close $ldFID

	#*********************************************************************
	#  construct file and directory names to be copied
	#*********************************************************************

	#***********************
	# ...source directories and files

	set source_pacsDisplay_dir [pwd]
		set license_file     [file join $source_pacsDisplay_dir $license_filename]
		set lutsDir_file     [file join $source_pacsDisplay_dir $lutsDir_filename]
		set install_file     [file join $source_pacsDisplay_dir $install_batch_filename]
		set uninstall_file   [file join $source_pacsDisplay_dir $Uninstall_batch_filename]
		set uninstall86_file [file join $source_pacsDisplay_dir $Uninstall86_batch_filename]
		set version_file     [file join $source_pacsDisplay_dir $version_filename]
		set source_LUTs_dir  [file join $source_pacsDisplay_dir LUTs]
			;# these are not currently being used
			;#set source_CurrentSystem_dir [file join $source_LUTs_dir "Current System"]
				;#set source_Linear_dir [file join $source_CurrentSystem_dir "Linear"]
			;#set source_LUTLibrary_dir [file join $source_LUTs_dir "LUT-Library"]
		set source_BIN_dir [file join $source_pacsDisplay_dir pacsDisplay-BIN]
			;# these are not currently being used
			;#set source_gtest_dir       [file join $source_BIN_dir gtest]
			;#set source_install_dir     [file join $source_BIN_dir install]
			;#set source_iQC_dir         [file join $source_BIN_dir iQC]
			;#set source_LLconfig_dir    [file join $source_BIN_dir LLconfig]
			;#set source_loadLUT_dir     [file join $source_BIN_dir loadLUT]
			;#set source_lumResponse_dir [file join $source_BIN_dir lumResponse]
			;#set source_lutGenerate_dir [file join $source_BIN_dir lutGenerate]
		if {$winOSbits == "32b"} {
			set source_shortcuts_dir [file join $source_pacsDisplay_dir Links 32b_W7-XP shortcuts]
		} elseif {$winOSbits == "64b"} {
			set source_shortcuts_dir [file join $source_pacsDisplay_dir Links 64b_W7 shortcuts]
		} else {
			tk_messageBox -type ok                           \
		     	         -message "Invalid winOSbits: $winOSbits"  \
		     	         -title "Install Error"
			exit
		}


	#***********************
	# ...source Start Menu shortcut filenames

	set source_StartMenu_iQC_lnk [file join $source_shortcuts_dir allUsers_startMenu iQC.lnk]
	set source_Startup_loadLUT_lnk [file join $source_shortcuts_dir allUsers_startMenu_programs_startup loadLUT-dicom.lnk]

	# ...source Start Menu directories
	set source_Programs_grayscale_dir [file join $source_shortcuts_dir allUsers_startMenu_programs "HFHS ePACS Grayscale"]
	set source_Programs_tools_dir [file join $source_shortcuts_dir allUsers_startMenu_programs "HFHS Grayscale Tools"]

	#***********************
	# ...target directories and files

	set target_LUTs_dir [file join $target_pacsDisplayLUTs_dir LUTs]
		set target_CurrentSystem_dir [file join $target_LUTs_dir "Current System"]
			set target_Linear_dir [file join $target_CurrentSystem_dir "Linear"]
		set target_LUTLibrary_dir [file join $target_LUTs_dir "LUT-Library"]
	set target_BIN_dir [file join $target_pacsDisplay_dir pacsDisplay-BIN]
		set target_loadLUT_dir [file join $target_BIN_dir loadLUT]
	set target_shortcuts_dir [file join $target_pacsDisplay_dir shortcuts]
	
	set target_version_file [file join $target_pacsDisplay_dir $version_filename]
	set target_LLconfig_file [file join $target_BIN_dir LLconfig $LLconfig_filename]
	set pdManualDir [file join $target_BIN_dir _pd-Manual]

	#***********************
	# ...target Start Menu directories

	if {$winOS == "W7orW10"} {
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

	#***********************
	# ...temporary files and directories
	cd ..
	set source_HFHS_dir [pwd]
	cd $source_pacsDisplay_dir
	set temp_batch_file [file join $source_HFHS_dir $temp_filename]


	#*********************************************************************
	#  check currently existing directories and build root paths if needed
	#*********************************************************************

	# ...Be sure that a new directory is being requested.
	if {$source_pacsDisplay_dir == $target_pacsDisplay_dir} {
		set    errorSrc "Distribution directory \n\n $source_pacsDisplay_dir\n\n"
		append errorSrc "is the same as the target directory \n\n $target_pacsDisplay_dir\n\n"
		append errorSrc "Installation will be aborted."

		tk_messageBox -type ok               \
		              -message $errorMsg1    \
		              -title "Install Error"
		exit
	}

	# ... Check for prior installations.

	if {[file isdirectory $target_pacsDisplay_dir]} {

		# ..."pacsDisplay-BIN" directoy
		if {[file isdirectory $target_BIN_dir]} {
			set prior_install 1
			set prior_BIN_exists 1
		}
		# ..."shortcuts" directoy
		if {[file isdirectory $target_shortcuts_dir]} {
			set prior_install 1
			set prior_shortcuts_exists 1
		}
	} else {
		# ...create "pacsDisplay" directory
		file mkdir $target_pacsDisplay_dir            ;# <=== New installation, no prior
	}

	# ..."HFHS ePACs grayscale" Start Menu directory
	if {[file isdirectory $target_Programs_grayscale]} {
		set prior_install 1
	}

	# ..."HFHS Grayscale Tools" Start Menu directory
	if {[file isdirectory $target_Programs_tools]} {
		set prior_install 1
	}

	# ... Check for prior LUTs installations.
	if {[file isdirectory $target_pacsDisplayLUTs_dir]} {

		# ..."LUTs" directoy (may have been left after an uninstall)
		if {[file isdirectory $target_LUTs_dir]} {
			set prior_LUTs 1
			set prior_config_exists 1
		}
	} else {
		# ...create "LUTs" directory
		file mkdir $target_pacsDisplayLUTs_dir        ;# <=== New installation, no prior
	}

	#*********************************************************************
	#  check write options
	#
	if {$prior_install} {
		if {$overwrite == 0} {
			incr error

			# ...installation incomplete
			set    textmsg "HFHS-pacsDisplay files were not installed.\n\n"
			append textmsg "  - Previous installation found.\n"
			append textmsg "  - Overwrite not enabled.\n"
			append textmsg "Installation will be aborted."
			tk_messageBox \
				-type ok \
				-title "$title - INCOMPLETE" \
				-message $textmsg

			exit
		}
	}

	if {$prior_LUTs != 1} {
		if {$overwriteLUTs == 0} {
			incr error

			# ...installation incomplete
			set    textmsg "Keep prior LUTs folder was requested,\n"
			append textmsg "but no LUT folder was found.\n\n"
			append textmsg "Installation will be aborted."
			tk_messageBox \
				-type ok \
				-title "$title - INCOMPLETE" \
				-message $textmsg

			exit
		}
	}

	#*********************************************************************
	#  delete old files and directories
	#

	if {$error == 0} {

		# ... DELETE directories from previous installation
		if {$prior_BIN_exists} {
			file delete -force $target_BIN_dir
		}

		if {$prior_config_exists} {
			if {$overwriteLUTs == 1} {
				file delete -force $target_LUTs_dir
			}
		}

		if {$prior_shortcuts_exists} {
			file delete -force $target_shortcuts_dir
		}

		# ... DELETE folders from the Start Menu
		file delete -force $target_Programs_grayscale
		file delete -force $target_Programs_tools
	}

	#*********************************************************************
	#  copy files and directories to their appropriate destinations
	#

	if {$error == 0} {

		# ...copy source files to target directory

		file copy -force $source_BIN_dir $target_pacsDisplay_dir
		file copy -force $source_shortcuts_dir $target_pacsDisplay_dir
		file copy -force $license_file $target_pacsDisplay_dir
		file copy -force $lutsDir_file $target_pacsDisplay_dir
#		file copy -force $install_file $target_pacsDisplay_dir    ;# Don't want install in Program Files.
		file copy -force $uninstall_file $target_pacsDisplay_dir
		file copy -force $uninstall86_file $target_pacsDisplay_dir
		file copy -force $version_file $target_pacsDisplay_dir

		if {($prior_config_exists == 0) || ($overwriteLUTs == 1)} {
			file copy -force $source_LUTs_dir $target_pacsDisplayLUTs_dir
		}

		# ...create Start Menu directories and copy shortcuts
		file copy -force $source_StartMenu_iQC_lnk $target_StartMenu
		file copy -force $source_Programs_grayscale_dir $target_Programs
		file copy -force $source_Startup_loadLUT_lnk $target_Startup

		# Tools programs are always there, option only loads the links.
		if {$full_install} {
			file copy -force $source_Programs_tools_dir $target_Programs
		}
	}
	#*********************************************************************
	#  Make the configLL.txt file with a correct LUT-library path
        #  based on the installation system type and any user modifications.

	makeConfigLL $target_pacsDisplayLUTs_dir

	#*********************************************************************
	#  Finished
	#

	# ...installation incomplete
	if {$error} {

		# ...installation incomplete
		tk_messageBox \
			-type ok \
			-title "$title - INCOMPLETE" \
			-message "HFHS pacsDisplay files were not installed."
	} else {
	
		# ...message and option to view the Manual
		set    textmsg "HFHS pacsDisplay files installed."
		append textmsg "\n\nWould you like to view the Reference Manual?"
		set answer [tk_messageBox -type yesno \
			-title "$title - File Installation Complete" \
			-message $textmsg ]

		if {$answer == "yes"} {
			cd $pdManualDir ;# the start command below is fussy about being in the document directory
			if {[catch {eval exec [auto_execok start] $pdManual_filename &} fid]} {
				set msg "Error opening manual\n$fid"
				tk_messageBox -message $msg -type ok -icon warning -title "WARNING"
			}
		}

		# ...run LLconfig
		if {$run_LLconfig} {
			cd [file dirname $target_LLconfig_file] ;# move dir so config can be read.
			exec $target_LLconfig_file &
		}
	}

	#*********************************************************************
	# ...That's all!

	exit
}


#**********************************************************************
# procedure to close open files and quit
#
proc Quit {} {
	global title copydate

	exit
}

#************************************************************************
# END Install
#************************************************************************
