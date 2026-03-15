
set platform 1
##########################XIRL-STANDARD-DEFS#############################
#	define standard styles for colors and font
#	for now use internal option definitions rather that a Pref_Init
#
	option add *foreground black
	option add *background gray65
	option add *highlightBackground gray65
	option add *troughColor gray75
#
	option add *activeBackground slateblue3
	option add *activeForeground gray80
#
	option add *highlightColor     slateblue4

	option add *Entry.background gray67
#**********************************************************************
#	Define styles for the buttons 
#	(NOTE1: WinNT and Xwindows behave differently )
#	(NOTE2: Define platform in config.txt file    )
#
	if {$platform == 1} {
#
#	... Definitions for WinNT implementations

		tk_focusFollowsMouse

		option add    *font     {arial 10 bold}
#
		option add    *Button.anchor center
		option add    *Button.relief   raised
		option add    *Button.width    6
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

		tk_focusFollowsMouse
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
#########################END-STANDARD-DEFS###############################
