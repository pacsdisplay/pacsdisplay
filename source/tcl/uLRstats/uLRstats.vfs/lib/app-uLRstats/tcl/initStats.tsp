#**********************************************************************
#	... Procedure to build the select/analyze window

proc initStats { } {

	global window study title copydate fileCount

#... title and copyright message
	set bgClr #204080  ;# 'blueprint' blue
	set fgClr #f0f0f0  ;# near white
	set title "\n$title\n\n"
	append title "Copyright $copydate\n"
	append title "Radiology Research\n"
	append title "Henry Ford Health"

	frame .cmdBar -relief raised -borderwidth 2
	frame .title  -height 120 -width 250 -relief sunken -bg $bgClr \
	            -highlightthickness 2 -highlightbackground $fgClr
	label .title.text  -text $title -bg $bgClr -fg $fgClr -padx 1 -pady 1
	pack .title.text -in .title -anchor center	
#	place .title.text -in .title -anchor center -relx .5 -rely .5

#    ------------------------
#	... command bar buttons for select.
	button .cmdBar.select -text "SELECT" \
 							-width 7 \
							-command {select_files .}

#    ------------------------
#    ...HELP command
	button .cmdBar.help        \
		-text ?                 \
		-font {arial 8 bold} \
		-width 1 \
		-cursor hand2                   \
		-command Help_message
#

#    ------------------------
#    ...QUIT command
	button .cmdBar.quit -text "QUIT" \
				-command {destroy .; exit}

#	... pack the command bar
	pack .cmdBar.quit .cmdBar.help  -side right -padx 4 -pady 4
	pack .cmdBar.select             -side left  -padx 4 -pady 4
#
#... framed button bar to load images to a new window

	set loadStatus 0
	frame .inits   -relief raised -borderwidth 2
	button .inits.load -text "0 FILES SELECTED" \
                                          -command {analyzeUlrFiles}
	pack .inits.load -padx 1m -pady 1m -fill x
#
# ... pack up the load window

	wm geometry . +25+200
	pack .cmdBar .title .inits -side top -fill x
}

