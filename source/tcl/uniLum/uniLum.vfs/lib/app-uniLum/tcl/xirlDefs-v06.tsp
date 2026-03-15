##########################XIRL-STANDARD-DEFS#############################
#                            2006 version
#	define standard styles for colors and font
#	for now use internal option definitions rather that a Pref_Init
#**********************************************************************
	set platform   1  ;# 1 for Win, 2 for Xwindows
	set hostEndian 1  ;# 1 for little (intel), 2 for big (sun)
#**********************************************************************
#
	option add *foreground           black
	option add *background           #D0D0D4    ;# was gray70
	option add *highlightBackground  #D0D0D4    ;# was gray70
#
	option add *activeBackground     slateblue3
	option add *activeForeground     #F0F0F4    ;# was gray85
#
	option add *Entry.background     #E0E0E4    ;# was gray80
#**********************************************************************
#	Define styles for the buttons 
#	(NOTE1: WinNT and Xwindows behave differently )
#	(NOTE2: Define platform in config.txt file    )
#
	if {$platform == 1} {
#
#	... Definitions for WinNT implementations

#		tk_focusFollowsMouse  ;# not used in 2006 version

		option add    *font     {arial 10 bold}
#
		option add    *Button.anchor center
		option add    *Button.relief   raised
		option add    *Button.width    5
		option add    *Button.height   1
		option add    *Button.borderWidth   3
		option add    *Button.padX    2
		option add    *Button.padY    0
#
		option add    *Menubutton.anchor center
		option add    *Menubutton.relief    raised
		option add    *Menubutton.width  12
		option add    *Menubutton.height  1
		option add    *Menubutton.borderWidth   3
		option add    *Menubutton.padX    2
		option add    *Menubutton.padY   5

#
	} elseif {$platform == 2} {
#
#	Definitions for Unix Xwindows implementations

#		tk_focusFollowsMouse  ;# not used in 2006 version
#
		option add    *font     {arial 12 bold}
#
		option add    *Button.anchor center
		option add    *Button.relief    raised
		option add    *Button.width    5
		option add    *Button.height   1
		option add    *Button.borderWidth   4
		option add    *Button.padX    2
		option add    *Button.padY    .5
#
		option add    *Menubutton.anchor center
		option add    *Menubutton.relief    raised
		option add    *Menubutton.width  12
		option add    *Menubutton.height  1
		option add    *Menubutton.borderWidth   4
		option add    *Menubutton.padX    2
		option add    *Menubutton.padY   2
#
	} else {
		puts "WARNING: platform definition unrecognized"
	}
#
#**********************************************************************
#	Define format variable for binary scan operations
	if {$hostEndian == 1} {
#		... little endian definitions for 2/4 byte integers
		set i2 s
		set i4 i
	} elseif {$platform == 2} {
#		... big endian definitions for 2/4 byte integers
		set i2 S
		set i4 I
	} else {
		puts "WARNING: hostEndian definition unrecognized"
	}
#########################END-STANDARD-DEFS###############################
