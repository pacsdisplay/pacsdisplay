#############################################################
#               gtest.tcl
#
#  Application to present uniform regions with adjustable
#  gray levels to support macro images of lcd pixel structures.
#  All controls are implemented with key bindings.
#
#	Author: M. Flynn 
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
#
#------------------------------------------------------------
# 
#console show
set title "GTEST 1.2"
wm title .  "$title"

package require img::bmp ;# just for the help icon
set home [file dirname [info script]] ;# used for wrapped application

set cansize      500 ;# hor and vertical size of canvas
set border       50  ;# border within 4 sides for gray level square
set canbg        127 ;# canvas background gray value
set grayNum      17  ;# initial gray state, 0 to 17 (18 steps)
set info         0   ;# on/off state of help message.
set solidClrFlag 0   ;# track whether a solid color is shown

set canheight $cansize
set canwidth  $cansize
set fstate 1      ;# indicates whether focus pattern is shown (f key binding)
set xy1 $border                    ;# upper left  coords for test square
set xy2 [expr $cansize - $border]  ;# upper right coords for test square
set xy1c [expr $xy1 + $border]     ;# upper left  coords for color balanced region
set xy2c [expr $xy2 - $border]     ;# lower right coords for color balanced region

set dR 0
set dG 0
set dB 0

#------------------------------------------------------------
#    Utility Procedures
#------------------------------------------------------------

proc bound {num} {
	if {$num > 255} {set num 255}
	if {$num < 0  } {set num 0  }
	return $num
}

proc rgbhex {grayval} {
	global dR dG dB  ;# RGB change values
	global grayHex

	set grayhex [format %02x $grayval]
	set grayHex #$grayhex$grayhex$grayhex

	set rval [bound [expr $grayval + $dR]]
	set gval [bound [expr $grayval + $dG]]
	set bval [bound [expr $grayval + $dB]]
	.can itemconfigure rtext -text "[format %3s $dR]" 
	.can itemconfigure gtext -text "[format %3s $dG]" 
	.can itemconfigure btext -text "[format %3s $dB]" 

	set rhex [format %02x $rval]
	set ghex [format %02x $gval]
	set bhex [format %02x $bval]
	set rgbhex #$rhex$ghex$bhex

	set rgblabel "([format %3s $rval],[format %3s $gval],[format %3s $bval])  $rgbhex"
	.can itemconfigure rgbtext -text $rgblabel

	return $rgbhex
}
proc grayd {gnum} {
	set grayd [expr $gnum * 15]
}
#------------------------------------------------------------
#    Build the canvas
#------------------------------------------------------------

canvas .can -height $canheight -width $canwidth
.can configure -bg [rgbhex $canbg]  ;# rgbhex calls .can
pack .can

# --- > Create the RGB values at the bottom
.can create text [expr $cansize -140] [expr $cansize -25] \
                      -anchor ne                          \
                      -font {arial 14 bold}               \
                      -text ""                            \
                      -fill #FF0000                       \
                      -tags rtext
.can create text [expr $cansize -80] [expr $cansize -25]  \
                      -anchor ne                          \
                      -font {arial 14 bold}               \
                      -text ""                            \
                      -fill #00FF00                       \
                      -tags gtext
.can create text [expr $cansize -20] [expr $cansize -25]  \
                      -anchor ne                          \
                      -font {arial 14 bold}               \
                      -text ""                            \
                      -fill #0000FF                       \
                      -tags btext
.can create text 25 [expr $cansize -25]              \
                      -anchor nw                          \
                      -font {courier 12 bold}               \
                      -text ""                            \
                      -fill #000000                       \
                      -tags rgbtext

# --- > Create the main gray and focus rectangles in the center
set grayVal [grayd $grayNum]
.can create rectangle $xy1 $xy1 $xy2 $xy2        \
                      -fill    [rgbhex $grayVal] \
                      -outline {}                \
                      -tags    {gray both}

.can create rectangle $xy1c $xy1c $xy2c $xy2c    \
                      -fill    [rgbhex $grayVal] \
                      -outline {}                \
                      -tags    {color both}

.can create rectangle $xy1 $xy1 $xy2 $xy2 \
                      -fill    black      \
                      -stipple gray50     \
                      -outline {}         \
                      -tags    focus

# --- > Create the help icon in the upper right
image create photo help -file [file join $home help.bmp]
.can create image     [expr $cansize -24] 28    \
                      -image help             \
                      -tags help

#------------------------------------------------------------
#    Control Bindings
#------------------------------------------------------------
  
.can bind help  <Button-1> {Help_message}

#... control gray level of displayed gray & color squares.
.can bind both  <Button-1> {changeGray down}
.can bind both  <Button-3> {changeGray up}
.can bind both  <Control-Button-1> {tweakGray -5}
.can bind both  <Control-Button-3> {tweakGray  5}
.can bind both  <Shift-Button-1>   {tweakGray -1}
.can bind both  <Shift-Button-3>   {tweakGray  1}

#... control color space adjustments.
.can bind rtext  <Button-1>         {tweakColor red -5}
.can bind rtext  <Button-3>         {tweakColor red  5}
.can bind rtext  <Shift-Button-1>   {tweakColor red -1}
.can bind rtext  <Shift-Button-3>   {tweakColor red  1}
.can bind gtext  <Button-1>         {tweakColor grn -5}
.can bind gtext  <Button-3>         {tweakColor grn 5}
.can bind gtext  <Shift-Button-1>   {tweakColor grn -1}
.can bind gtext  <Shift-Button-3>   {tweakColor grn 1}
.can bind btext  <Button-1>         {tweakColor blu -5}
.can bind btext  <Button-3>         {tweakColor blu 5}
.can bind btext  <Shift-Button-1>   {tweakColor blu -1}
.can bind btext  <Shift-Button-3>   {tweakColor blu 1}

#... solid color bindings (set and unset)
.can bind rtext  <Control-Button-1>        {solidColor red}
.can bind rtext  <Control-Button-3>        {tweakGray 0}
.can bind gtext  <Control-Button-1>        {solidColor grn}
.can bind gtext  <Control-Button-3>        {tweakGray 0}
.can bind btext  <Control-Button-1>        {solidColor blu}
.can bind btext  <Control-Button-3>        {tweakGray 0}

#... show/hide focus pattern, bind on both tag=focus,gray
.can bind focus <Button-1>         showFocus
.can bind focus <Alt-Button-1>     showFocus
.can bind both  <Alt-Button-1>     showFocus
#------------------------------------------------------------
#    Callback Procedures
#------------------------------------------------------------
proc changeGray {direction} {
	global grayNum grayVal grayHex
	if {$direction == "up" && $grayNum < 17} {
		incr grayNum
	} elseif {$direction == "down" && $grayNum > 0} {
		incr grayNum -1
	}
	set grayVal [grayd $grayNum]
	.can itemconfigure color -fill  [rgbhex $grayVal]
	.can itemconfigure gray  -fill  $grayHex
}
proc tweakGray {delta} {
	global grayNum grayVal grayHex
	set grayVal [bound [expr $grayVal + $delta]]
	set grayNum [expr round($grayVal/15.0)]
	.can itemconfigure color -fill  [rgbhex $grayVal]
	.can itemconfigure gray  -fill  $grayHex
}
proc tweakColor {color delta} {
	global dR dG dB grayVal grayHex
	if {$color == "red"} {
		set dR [expr $dR + $delta]
	} elseif {$color == "grn"} {
		set dG [expr $dG + $delta]
	} elseif {$color == "blu"} {
		set dB [expr $dB + $delta]
	} else {
		return
	}
	.can itemconfigure color -fill  [rgbhex $grayVal]
	.can itemconfigure gray  -fill  $grayHex
}
proc solidColor {color} {
	# sets pure colors but does not change grayVal or grayHex
	# so that the pure color can be easily removed with tweakGray 0.
	global solidClrFlag
	if {$solidClrFlag == 0} {
		if {$color == "red"} {
			.can itemconfigure color -fill  #ff0000
			set rgblabel "(255,  0,  0)  #ff0000"
		} elseif {$color == "grn"} {
			.can itemconfigure color -fill  #00ff00
			set rgblabel "(  0,255,  0)  #00ff00"
		} elseif {$color == "blu"} {
			.can itemconfigure color -fill  #0000ff
			set rgblabel "(  0,  0,255)  #0000ff"
		} else {
			return
		}
		.can itemconfigure rgbtext -text $rgblabel
		set solidClrFlag 1
	} elseif {$solidClrFlag == 1} {
		tweakGray 0
		set solidClrFlag 0
	} else {
		puts "Invalid call to solidColor"
		return
	}
}
proc showFocus {} {
	global fstate
	if {$fstate == 1} {
		.can lower focus
		set fstate 0
	} else {
		.can raise focus
		set fstate 1
	}

}
#------------------------------------------------------------
#  procedure to put up the information message
#
proc Help_message {}  {
	global info

	if {$info == 0}  {
		# open file for reading
		set input "INSTRUCTIONS.txt"
		if [catch {open $input r} hfilein] {
			puts stderr "Cannnot open $input $hfilein"
			tk-MessageBoxMod -type ok -message "Cannot open $input $hfilein"
			return
		}
		
		set w .help
		toplevel $w
		wm title $w "Instructions for gtest"
		wm iconname $w "Instructions"

		text $w.text -bg white \
				-height 30 -width 42  \
				-relief sunken -setgrid 1 \
				-font {Courier 10}  \
				-yscrollcommand "$w.scroll set"

		scrollbar $w.scroll -command "$w.text yview"

		pack $w.scroll -side right -fill y
		pack $w.text -expand yes -fill both

		foreach line [split [read $hfilein] \n] {
			$w.text insert end "$line\n"
		}
		close $hfilein

		$w.text configure -state disabled

		set info 1
	} else  {
		set info 0
		destroy .help
	}
}

