proc LUMtoJND {lum} {
	;# The DICOM JND indice is computed from the luminance in cd/m2
	;# Polynomial fit taken from DICOM part 3.14, Gray Scale Display Function.
	;# Tcl expression taken from lutGenerate.

	set LogL [expr log10($lum)]
	set JND [expr 71.498068 + 94.593053*$LogL + 41.912053*pow($LogL,2) +   \
	               9.82470040*pow($LogL,3) +  0.281754070*pow($LogL,4) +   \
	              -1.18784550*pow($LogL,5) + -0.180143490*pow($LogL,6) +   \
	               0.14710899*pow($LogL,7) + -0.017046845*pow($LogL,8)]
	return $JND
}

proc JNDtoLUM {jnd} {
	;# the luminance in cd/m2 is computed from the the JND indice.
	;# Polynomial fit taken from DICOM part 3.14, Gray Scale Display Function.
	;# Tcl expression taken from lutGenerate.

	set LnJND [expr log($jnd)] ;# natural log of JND indice
	set LogL [expr (-1.3011877                  + 0.080242636*$LnJND         + \
	                 0.1364669900*pow($LnJND,2) + -0.025468404*pow($LnJND,3) + \
	                 0.0013635334*pow($LnJND,4))                             / \
	               ( 1.0                        + -0.025840191*$LnJND        + \
	                -0.1032022900*pow($LnJND,2) + 0.02874562*pow($LnJND,3)   + \
	                -0.0031978977*pow($LnJND,4) + 0.00012992634*pow($LnJND,5)  )  ]
	set LUM [expr pow(10,$LogL)]
	return $LUM
}

