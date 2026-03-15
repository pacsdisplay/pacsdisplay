#############################################################################
#                       build_manifest.tcl                                  #
#   Build configuration and package contents                                #
#                                                                           #
#   Edit this file to:                                                      #
#       - Add/remove modules from thin or thick packages                    #
#       - Point to local toolchain paths                                    #
#                                                                           #
#       03/2026 - N.B Bevins                                                #
#############################################################################

# Toolchain paths (update to match your local setup)
set manifest(sdx)      [file join vendor bin sdx.kit]
set manifest(tclkit)   [file join vendor bin basekitsh.exe]
set manifest(zip_tool) "C:/Program Files/7-Zip/7z.exe"    ;# or use "zip" if in PATH

# Source directories
set manifest(source_tcl_dir)      [file join source tcl]
set manifest(source_cpp_getEDID)  [file join source cpp getEDID bin]
set manifest(source_cpp_loadLUT)  [file join source cpp loadLUT bin]
set manifest(vendor_bin)          [file join vendor bin]
set manifest(misc_dir)            [file join misc]

# Output directory
set manifest(dist_dir) "_dist"

# Thin package contents (pdQC) - Minimal install, portable, no extra tools
set manifest(thin_modules) {
    pdLaunch
    ambtest
    EDIDprofile
    gtest
    i1meter
    iQC
    loadLUTsingle
    lumResponse
    QC-check
    lutGenerate
    uLRstats
    uniLum
}

set manifest(thin_exes) {
    getEDID.exe
    loadLUTsingle.exe
    spotread.exe
}

set manifest(thin_dirs) {
    gnuplot46-bin
}

# Thick package contents (pacsDisplay) - Full install with all modules and supporting tools
set manifest(thick_modules) {
    ambtest
    EDIDprofile
    gtest
    i1meter
    iQC
    lumResponse
    QC-check
    lutGenerate
    uLRstats
    uniLum
    # incomplete list (work in progress) - add all remaining modules here
}

set manifest(thick_exes) {
    getEDID.exe
    loadLUTsingle.exe
    spotread.exe
}

set manifest(thick_dirs) {
    gnuplot46-bin
}
