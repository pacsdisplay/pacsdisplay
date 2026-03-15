#########|#########|#########|#########|#########|#########|#########|#########|
#
#  showManual TCL Procedure
#  M. Flynn, Feb 2014
#  Utility to launch a pdf manual chapter section file.
#########|#########|#########|#########|#########|#########|#########|#########|

proc showManual {sectionNum} {


	;# ---- move to the manual sections directory ----
	set returnDir [pwd]
	cd ../_pd-Manual/sections          ;# for use in release BIN folder
	
	;# ---- Get the section filename and open  ----
	set sectionFile [glob ${sectionNum}_*.pdf]
	
	if {[catch {eval exec [auto_execok start] $sectionFile &} fid]} {
		set msg "Error opening manual\n$fid"
		tk_messageBox -message $msg -type ok -icon warning -title "WARNING"
	}
			
	;# ---- return to the original directory ----
	cd $returnDir
}