#**********************************************************************
#
#             select_files {}
#
# Procedure that opens a window to enter or select the directory
# and filenames for a set of files
#   {glob_list} is called from a button (GLOB) to build the listbox.
#               bindings on the listbox are used to select the
#               objects for load
#   {file_list} is called from the "OK" button to build the
#               fileName array for loading.
#   {get_path} is called from the "Find" button to get a new
#              directory path and a filename to use for globbing.
#
#  Results are returned in the following global variables;
#	fileCount fileName() fileSize() 
#
#	Author: M. Flynn 
#	Date:   Dec 2006
#**********************************************************************
#	...procedure to concatenate file names
#
proc ConCat args {
	regsub -all {[      \.]+} $args . args
	return $args
}
#**********************************************************************
# Utility to get the position of a window
proc windowGeom {win} {
	global winPosX winPosY
	set geom [wm geometry $win]
	set first [string first + $geom]
	set last [string last + $geom]
	set length [string length $geom]
	set winPosX [string range $geom [expr $first+1] [expr $last-1]]
	set winPosY [string range $geom [expr $last+1] $length]
}
#**********************************************************************
#		... get a new directory and filename for globbing
#
proc get_path { } {

	global filePath selectFiles

	set filePath [tk_chooseDirectory \
					-initialdir $filePath        \
					-title "Select Image"        \
					-parent $selectFiles         \
					-mustexist true              ]
	cd $filePath
}
#**********************************************************************
#	...get the file list and insert in the listbox.
#			bindings will permit selection of entries for load
#
proc glob_list {listWidget} {

	global globName filePath

#	... change to image directory to keep file list short for list insertion
	cd $filePath

#	... get the file names
	set filenameList [lsort [glob $globName] ]

#	... build the listbox entries
	$listWidget delete 0 end 
	foreach file $filenameList {
		$listWidget insert end $file
	}
}
#**********************************************************************
#		... build the fileNames for load from the selected list
#
proc file_list {listWidget} {

	global  fileCount fileName fileSize filePath selectFiles

	set selectlist [$listWidget curselection]

	set fileCount 0

	foreach index $selectlist {
		set fileCount [expr $fileCount +1]
		set file [$listWidget get $index]
		set fileName($fileCount) [file join $filePath $file]
		set fileSize($fileCount) [file size [file join $filePath $file]]
	}

	.inits.load configure -text "ANALYZE $fileCount FILES"
	puts "$fileCount files found"

#	... for this version, kill the select window after this call.
#		for multiple window versions, this can be left up.
	destroy $selectFiles
}
#**********************************************************************
#
proc select_files {window} {

	global filePath globName selectFiles
	global winPosX winPosY 

	set selectFiles [ConCat $window selectFiles]
	destroy $selectFiles ;# in case it is already up
	set listbox   [ConCat $selectFiles listbox]
	set scroll [ConCat $selectFiles scroll]
	toplevel $selectFiles

	set cmd  [ConCat $selectFiles cmd]
	frame $cmd -relief raised -borderwidth 2
	button $cmd.quit -text "Quit" \
			-command [list destroy $selectFiles ]
	button $cmd.get -text "Glob"  \
			-command [list glob_list $listbox]
	button $cmd.find -text "Path" \
			-command { get_path }
#	... For this version, kill the window after OK
#	    For multiple window version, leave this window open.
	button $cmd.ok -text "OK"     \
			-command [list file_list $listbox]
	pack $cmd.quit  -side right -fill y -padx 4 -pady 4
	pack $cmd.get $cmd.find $cmd.ok \
				-side left -fill y  \
				-padx 4 -pady 4
	pack $cmd -side top -fill both

#	... build the path/name entries. width will set the window size
	foreach ID {filePath  \
				globName}          {
		set box  [ConCat $selectFiles $ID]
		frame $box -relief raised -borderwidth 2
		label $box.label -text "$ID:"
		entry $box.value \
					-width 40   \
					-relief sunken \
					-textvariable $ID
		pack $box.label -side left  -fill y
		pack $box.value -side right -fill y
		pack $box -side top -fill both -padx 10 -pady 10
	}
#
#
#	... make a listbox for the filenames
	scrollbar $scroll -command "$listbox yview" -troughcolor #E0E0E4    
	listbox $listbox -yscroll "$scroll set" \
					-setgrid 1 -height 12  \
					-bg #E0E0E4                \
					-selectmode extended
	pack $scroll -side right -fill y
	pack $listbox   -side left  -fill both -expand 1

#
#	... get the parent window position and place this window
	windowGeom $window
	set PosX [expr $winPosX +  50]
	set PosY [expr $winPosY + 240]
	catch {wm geometry $selectFiles +$PosX+$PosY}
	wm title $selectFiles "Select uLR files"
	wm attributes $selectFiles -topmost
}
#**********************************************************************