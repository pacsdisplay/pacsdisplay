package provide app-gtest 1.0

# ==============================================================================
# MODULE VERSION: 1.4
# ==============================================================================

# ------------------------------------------------------------
#               gtest.tcl
#
#  Application to present uniform regions with adjustable
#  gray levels to support macro images of lcd pixel structures.
#  All controls are implemented with key bindings.
#
#	Author: M. Flynn, N. Bevins 
#	Date:   Sep 2006
#
#	20060925 - gtest1.0
#	20061001 - gtest1.0a
#	           Changed focus canvas widget to fill with black
#	           so that the pattern is black and gray with gray
#	           being the current gray widget color.
#	20061006 - gtest1.0b
#	           Incorporate tcl call to get path so that
#	           bmp image reads when wrapped with TclApp.
#	20061218 - gtest1.1
#	           Add functions to adjust color balance.
#	20131227 - gtest1.2
#	           Corrected bug with hex value formats less that 16
#	                by adding a leading 0 to the specifier, %02x.
#	           Adjusting binding on ALT-B1 for focus pattern.
#	           Added ability to set or unset pur R,G, or B color.
#	           Changed help message so it can stay up for reference.
#	20210423 - gtest1.3 (NB)
#				Added binding to allow to resize window
#				Remove bmp dependencies
#				Moved procs to .tsp file
#				Simplified procs to remove tweakGray command
#				Modify layout to remove borders
#	20260211 - gtest1.4 (NB)
#				move to starkit version of pd
#				update for high dpi systems
#
# ------------------------------------------------------------
# 
set title "gtest 1.4"

# -----------------------------------------------------------------------
#console show

# get home directory to support scripts from within the vfs
set home [file dirname [info script]]

source   [file join $home tcl gUtil1-0.tsp]

wm title .  "$title"
#
# retrieve the dpi for scaling
#
set dpiscale [expr {[winfo pixels . 1i] / 96.0}]
#
# create a proc to scale all the sizes for the dpi
#
proc scaled {size} {global dpiscale; expr {int($size * $dpiscale)}}
#

set cansize			[scaled 750] ;# initial horiz and vertical size of canvas
set border			35  ;# border along top side for gray level patch
set cborder			0	;# border between the color and gray patches
set canbg			127 ;# canvas background gray value
set grayVal			255 ;# initial gray value
set info			0   ;# on/off state of help message.
set solidClrFlag	0   ;# track whether a solid color is shown
set fstate			1	;# indicates whether focus pattern is shown (alt-click key binding)
set rgbstate		1	;# initialize rgb value display state

set h $cansize
set w $cansize
set x1 0; set y1 0				;# upper left  coords for test square
set x2 [expr $w+2]				;# lower right coords for test square
set y2 [expr $h+2]
set x1c [expr $x1 + $cborder]	;# upper left  coords for color balanced region
set y1c [expr $y1 + $cborder]
set x2c [expr $x2 - $cborder]	;# lower right coords for color balanced region
set y2c [expr $y2 - $cborder]

# set initial color offsets
set dR 0
set dG 0
set dB 0

# ------------------------------------------------------------
#    Build the canvas
# ------------------------------------------------------------

canvas .can -height $h -width $w
.can configure -bg [rgbhex $canbg]  ;# rgbhex calls .can
pack .can

# --- > Create the RGB values indicators
.can create text [expr $w [scaled -120]] 20				\
                      -font {courier 12 bold}	\
                      -text ""					\
                      -fill #FF0000				\
                      -tags {rtext alltext}
.can create text [expr $w [scaled -70]] 20				\
                      -font {courier 12 bold}	\
                      -text ""					\
                      -fill #00FF00				\
                      -tags {gtext alltext}
.can create text [expr $w [scaled -20]] 20				\
                      -font {courier 12 bold}	\
                      -text ""					\
                      -fill #0000FF				\
                      -tags {btext alltext}
.can create text [expr $w/2] 20					\
                      -font {courier 12 bold}	\
                      -text ""					\
                      -fill #000000				\
                      -tags {rgbtext alltext}
# create help icon
.can create text 20 20						\
					-text "?"				\
					-font {courier 12 bold}	\
					-fill grey20			\
					-activefill black		\
					-tags {help alltext}

# --- > Create the textbar rectangle
.can create rectangle 0	0 $x2 $border				\
                      -fill    [rgbhex $canbg]		\
                      -outline {}					\
                      -tags    textbar

# --- > Create the main gray, color, and focus rectangles
.can create rectangle $x1 $y1 $x2 $y2				\
                      -fill    [rgbhex $grayVal]	\
                      -outline {}					\
                      -tags    {gray both}

.can create rectangle $x1c $y1c $x2c $y2c			\
                      -fill    [rgbhex $grayVal]	\
                      -outline {}					\
                      -tags    {color both}

.can create rectangle $x1 $y1 $x2 $y2	\
                      -fill    black	\
                      -stipple gray50	\
                      -outline {}		\
                      -tags    focus

# put the textbar rectangle over the focus pattern
.can raise textbar
# put the text objects over the textbar rectangle 
.can raise alltext


# ------------------------------------------------------------
#    Control Bindings
# ------------------------------------------------------------
  
.can bind help  <Button-1> {Help_message}

#... control gray level of displayed gray & color squares.
.can bind both  <Button-1>			{changeGray -15}
.can bind both  <Button-3>			{changeGray  15}
.can bind both  <Control-Button-1>	{changeGray -5}
.can bind both  <Control-Button-3>	{changeGray  5}
.can bind both  <Shift-Button-1>	{changeGray -1}
.can bind both  <Shift-Button-3>	{changeGray  1}

#... control color space adjustments.
.can bind rtext  <Button-1>			{changeColor red -15}
.can bind rtext  <Button-3>         {changeColor red  15}
.can bind rtext  <Control-Button-1>	{changeColor red -5}
.can bind rtext  <Control-Button-3>	{changeColor red  5}
.can bind rtext  <Shift-Button-1>   {changeColor red -1}
.can bind rtext  <Shift-Button-3>   {changeColor red  1}
.can bind gtext  <Button-1>			{changeColor grn -15}
.can bind gtext  <Button-3>         {changeColor grn  15}
.can bind gtext  <Control-Button-1>	{changeColor grn -5}
.can bind gtext  <Control-Button-3>	{changeColor grn  5}
.can bind gtext  <Shift-Button-1>   {changeColor grn -1}
.can bind gtext  <Shift-Button-3>   {changeColor grn  1}
.can bind btext  <Button-1>         {changeColor blu -15}
.can bind btext  <Button-3>         {changeColor blu  15}
.can bind btext  <Control-Button-1>	{changeColor blu -5}
.can bind btext  <Control-Button-3>	{changeColor blu  5}
.can bind btext  <Shift-Button-1>   {changeColor blu -1}
.can bind btext  <Shift-Button-3>   {changeColor blu  1}

#... solid color bindings (set and unset)
.can bind rtext  <Alt-Button-1>        {solidColor red}
.can bind rtext  <Alt-Button-3>        {changeGray 0}
.can bind gtext  <Alt-Button-1>        {solidColor grn}
.can bind gtext  <Alt-Button-3>        {changeGray 0}
.can bind btext  <Alt-Button-1>        {solidColor blu}
.can bind btext  <Alt-Button-3>        {changeGray 0}

#... show/hide focus pattern, bind on both tag=focus,gray
.can bind focus <Button-1>         showFocus
.can bind focus <Alt-Button-1>     showFocus
.can bind both  <Alt-Button-1>     showFocus

#... hide the rgb values and help icon bar (for full screen eval)
.can bind both  <Control-Shift-Button-1>	hidergb

#... display help file
.can bind help  <Button-1> {Help_message}

# create a binding to resize everything when the window size changes
bind . <Configure> {resize %w %h}
