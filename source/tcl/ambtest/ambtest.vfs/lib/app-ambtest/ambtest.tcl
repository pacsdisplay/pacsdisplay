package provide app-ambtest 1.0

# ==============================================================================
# MODULE VERSION: 1.2
# ==============================================================================

# -----------------------------------------------------------------------
#
#					ambtest.tcl
#
# script to determine user's ability to detect low contrast object in a
# random location on a uniform black canvas
#
#	v1.0 - NB - Apr 2021	- Move into pddev env
#							- Move procs into separate doc
#	v1.1 - NB - Jul 2022	- Update object to bar pattern
#	v1.2 - NB - Feb 2026	- Update to run from starkit
#                                                                      
# -----------------------------------------------------------------------

set title "ambtest 1.2 - Ambient Light Verification"

# -----------------------------------------------------------------------
# console show

# get home directory to support scripts from within the vfs
set home [file dirname [info script]]

source   [file join $home tcl ambUtil1-1.tsp]

# specify initial gray level (0-255)
set gl 3
# specify variables for bar pattern
set objh 100 
set objw 100
set objp 6	;# object period in pixels
# half of object period (simplifies script later)
set objhp [expr {$objp/2}] 

# -----------------------------------------------------------------------
# initialize the main canvas based on the display size
set w [expr [winfo screenwidth .]-100]
set h [expr [winfo screenheight .]-100]
set can .c
canvas $can -width $w -height $h
#wm geometry . -0+0
#wm attributes . -fullscreen 1

# generate a rectangle to cover the whole canvas
# this will capture clicks in the background
set bkgd [$can create rectangle 0 0 $w $h -fill black -tag bkgd]

# generate a low contrast object that will be moved around
image create photo bar -width $objw -height $objh
bar put [patgen $gl]
set lowc [$can create image 0 0 -image bar -tag obj]

# reposition the object randomly on the canvas (within edge padding)
position $lowc

# create a binding to the low contrast object that displays a success message
$can bind $lowc <Button-1>  {success $lowc}

# create a binding to the background if the low contrast object is not clicked
# display a failure message to adjust lighting and retry
# pass along the object name so it can be moved for the retry
$can bind $bkgd <Button-1>  {failure $lowc}

# create bindings to raise/lower the contrast of the object
# bindings need to be on both the object and the background
$can bind $bkgd <Shift-Button-1> {changecontrast up}
$can bind $bkgd <Shift-Button-3> {changecontrast down}
$can bind $lowc <Shift-Button-1> {changecontrast up}
$can bind $lowc <Shift-Button-3> {changecontrast down}

# create a binding to resize everything when the window size changes
bind . <Configure> {resize %w %h}

# -----------------------------------------------------------------------
# create the canvas with grid
grid $can -row 0 -column 0 -pady 0 -padx 0

# -----------------------------------------------------------------------
# create help icon
$can create text 20 20 \
					-text "?"				\
					-font {courier 16 bold}	\
					-fill grey40			\
					-activefill grey60		\
					-tags help
$can bind help  <Button-1> {Help_message}

# create text to move the object around
$can create text [expr $w/2] 20 \
					-text "Move"			\
					-font {courier 12 bold}	\
					-fill grey40			\
					-activefill grey60		\
					-tags resz
$can bind resz  <Button-1> {position $lowc}

# create text to display the current gray level
$can create text [expr $w-20] 20 \
					-text "Current Conrast: ${gl} GLs"	\
					-font {courier 12 bold}	\
					-fill grey40			\
					-activefill grey60		\
					-anchor e				\
					-tags graylvl
# move the contrast up/down to account for odd kerning behavior
changecontrast up
changecontrast down
# create bindings for the contrast label
$can bind graylvl <Button-1> {changecontrast up}
$can bind graylvl <Button-3> {changecontrast down}
					

# display the instruction/welcome message
set textmsg "Ambient Luminance Settings Test\n\n"
	#append textmsg "Move the window to the diagnostic display\n\n"
	append textmsg "Please ensure the following:\n\n"
	append textmsg "Ambient lighting set to reading levels\n"
	append textmsg " -Close/cover nearby windows\n"
	append textmsg " -Reduce overhead lighting\n"
	append textmsg " -Avoid lights reflecting on the display"
tk_messageBox -type ok -icon info -message $textmsg
