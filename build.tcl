#!/usr/bin/env tclsh
#############################################################################
#                          build.tcl                                        #
#   Starkit packaging and distribution builder for pacsDisplay/pdQC         #
#                                                                           #
#   Usage:                                                                  #
#       tclsh build.tcl thin <version>     (pdQC)                           #
#       tclsh build.tcl thick <version>    (pacsDisplay)                    #
#       tclsh build.tcl all <version>                                       #
#                                                                           #
#   Example: tclsh build.tcl thin 6A                                        #
#                                                                           #
#   Requires: sdx, tclkit (paths configured in build_manifest.tcl)          #
#                                                                           #
#       03/2026 - N.B Bevins                                                #
#############################################################################

# --- Load manifest -----------------------------------------------------------
set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir build_manifest.tcl]

# -----------------------------------------------------------------------------
# set absolute paths for tools based on manifest (handles relative paths)
set sdx     $manifest(sdx)
set tclkit  $manifest(tclkit)
set abs_tclkit [file normalize $tclkit]
set abs_sdx    [file normalize $sdx]

# --- Argument handling -------------------------------------------------------
if {$argc < 2} {
    puts "Usage: tclsh build.tcl \[thin|thick|all\] <version>"
    puts "Example: tclsh build.tcl thin 6A"
    exit 1
}

set build_target [lindex $argv 0]
set build_version [lindex $argv 1]

if {$build_target ni {thin thick all}} {
    puts "Error: target must be thin, thick, or all"
    exit 1
}

# --- Helpers -----------------------------------------------------------------

proc log {msg} {
    puts "\[BUILD\] $msg"
}

proc die {msg} {
    puts "\[ERROR\] $msg"
    exit 1
}

# Run a shell command, die on failure
proc run {args} {
    log "Running: $args"
    set rc [catch {exec {*}$args} out]
    if {$rc != 0} {
        die "Command failed: $args\n$out"
    }
    return $out
}

# Wrap a single .vfs directory into a .kit file and copy support files
proc wrap_vfs {vfs_path out_dir module_name} {
    global manifest abs_sdx abs_tclkit

    set src_dir $manifest(source_tcl_dir)

    set vfs_name [file tail $vfs_path]
    set kit_name [string map {.vfs .kit} $vfs_name]

    # Determine source and output locations based on module
    if {$module_name eq "pdLaunch"} {
        # pdLaunch.kit goes in root of staging
        set module_src_dir [file join $src_dir $module_name]
        set kit_src [file join $module_src_dir $kit_name]
        set kit_out [file join $out_dir $kit_name]
        set support_dest_dir $out_dir
    } elseif {$module_name eq "QC-check"} {
        # QC-check is in lumResponse directory
        set module_src_dir [file join $src_dir lumResponse]
        set module_dir [file join $out_dir pacsDisplay-BIN lumResponse]
        file mkdir $module_dir
        set kit_src [file join $module_src_dir $kit_name]
        set kit_out [file join $module_dir $kit_name]
        set support_dest_dir $module_dir
    } else {
        # All other kits go in pacsDisplay-BIN/<module_name>/
        set module_src_dir [file join $src_dir $module_name]
        set module_dir [file join $out_dir pacsDisplay-BIN $module_name]
        file mkdir $module_dir
        set kit_src [file join $module_src_dir $kit_name]
        set kit_out [file join $module_dir $kit_name]
        set support_dest_dir $module_dir
    }

    log "Wrapping $vfs_name -> $kit_name"

    # sdx wrap must be run from the directory containing the .vfs
    set save_dir [pwd]

    cd $module_src_dir
    run $abs_tclkit $abs_sdx wrap $kit_name
    cd $save_dir
    
    # move the .kit to the correct location in staging and delete the batch file
    file copy -force $kit_src $kit_out
    file delete -force $kit_src
    file delete -force [string map {.kit .bat} $kit_src]
    log "  -> $kit_out"

    # Copy INSTRUCTIONS files from inside .vfs to dist directory
    # Files are located in <module>.vfs/lib/app-<module>/
    set vfs_app_dir [file join $vfs_path lib "app-${module_name}"]
    if {[file exists $vfs_app_dir]} {
        foreach file [glob -nocomplain -directory $vfs_app_dir INSTRUCTIONS*.txt] {
            set filename [file tail $file]
            log "  Copying $filename from .vfs"
            file copy -force $file [file join $support_dest_dir $filename]
        }
    }

    # Copy support files from source module dir (next to .vfs, not inside it)
    # Skip for QC-check since it shares lumResponse directory (files already copied)
    # Skip .vfs dirs, .kit files, and .bat files
    if {$module_name ne "QC-check" && [file exists $module_src_dir]} {
        foreach file [glob -nocomplain -directory $module_src_dir *] {
            set filename [file tail $file]
            if {[file isdirectory $file] || [string match "*.kit" $filename] || [string match "*.bat" $filename]} {
                continue
            }
            # Copy all .txt files except INSTRUCTIONS (those come from .vfs)
            if {[string match "*.txt" $filename] && ![string match "INSTRUCTIONS*.txt" $filename]} {
                log "  Copying $filename"
                file copy -force $file [file join $support_dest_dir $filename]
            }
        }
    }
}

# Copy a list of exe filenames from the cpp build dir into out_dir/LIB
proc copy_exes {exe_list out_dir} {
    global manifest

    set lib_dir [file join $out_dir pacsDisplay-BIN LIB]
    file mkdir $lib_dir

    foreach exe $exe_list {
        # Special case: loadLUTsingle.exe comes from loadLUTtest.exe
        if {$exe eq "loadLUTsingle.exe"} {
            set src [file join $manifest(source_cpp_loadLUT) "loadLUTtest.exe"]
            if {[file exists $src]} {
                log "Copying loadLUTtest.exe -> pacsDisplay-BIN/LIB/loadLUTsingle.exe"
                file copy -force $src [file join $lib_dir "loadLUTsingle.exe"]
                continue
            } else {
                die "loadLUTtest.exe not found in $manifest(source_cpp_loadLUT)"
            }
        }

        # Try multiple source locations for other exes
        set found 0
        foreach src_dir [list \
            $manifest(source_cpp_getEDID) \
            $manifest(source_cpp_loadLUT) \
            $manifest(vendor_bin)] {

            set src [file join $src_dir $exe]
            if {[file exists $src]} {
                log "Copying $exe -> pacsDisplay-BIN/LIB/"
                file copy -force $src [file join $lib_dir $exe]
                set found 1
                break
            }
        }
        if {!$found} {
            die "Exe not found: $exe (searched cpp and vendor bins)"
        }
    }
}

# Extract version from a module's main TCL file
proc extract_module_version {module_name} {
    global manifest

    set src_tcl $manifest(source_tcl_dir)

    # Handle special case for QC-check which is in lumResponse subdir
    if {$module_name eq "QC-check"} {
        set tcl_file [file join $src_tcl lumResponse "${module_name}.vfs" lib "app-${module_name}" "${module_name}.tcl"]
    } else {
        set tcl_file [file join $src_tcl $module_name "${module_name}.vfs" lib "app-${module_name}" "${module_name}.tcl"]
    }

    if {![file exists $tcl_file]} {
        log "Warning: Could not find TCL file for $module_name at $tcl_file"
        return "?.?"
    }

    # Read the file and look for the MODULE VERSION comment block
    set f [open $tcl_file r]
    set content [read $f]
    close $f

    # Match the version block format: # MODULE VERSION: X.X
    if {[regexp {\s*MODULE VERSION:\s*([0-9.]+)} $content -> version]} {
        return $version
    }

    log "Warning: Could not extract version from $tcl_file"
    return "?.?"
}

# Copy directories (like gnuplot46-bin) from vendor/bin to LIB
proc copy_lib_dirs {dir_list out_dir} {
    global manifest

    set lib_dir [file join $out_dir pacsDisplay-BIN LIB]
    file mkdir $lib_dir

    foreach dir $dir_list {
        set src [file join $manifest(vendor_bin) $dir]
        if {[file exists $src]} {
            log "Copying $dir -> pacsDisplay-BIN/LIB/"
            file copy -force $src [file join $lib_dir $dir]
        } else {
            die "Directory not found: $src"
        }
    }
}

# Assemble a staging area and zip it for a given target (thin or thick)
proc build_package {target version} {
    global manifest

    log "=============================="
    log "Building: $target (version $version)"
    log "=============================="

    # Resolve manifest lists for this target
    set modules  $manifest(${target}_modules)
    set exes     $manifest(${target}_exes)
    set dirs     $manifest(${target}_dirs)
    set src_tcl  $manifest(source_tcl_dir)
    set dist_dir $manifest(dist_dir)

    # Staging area - temporary assembly folder
    set staging [file join $dist_dir "_staging_${target}"]
    if {[file exists $staging]} {
        file delete -force $staging
    }
    file mkdir $staging

    # Wrap each module's .vfs into a .kit in staging
    foreach mod $modules {
        # Handle special case for QC-check which is in lumResponse subdir
        if {$mod eq "QC-check"} {
            set vfs_path [file join $src_tcl lumResponse "${mod}.vfs"]
        } else {
            set vfs_path [file join $src_tcl $mod "${mod}.vfs"]
        }

        if {![file exists $vfs_path]} {
            die "VFS not found: $vfs_path"
        }
        wrap_vfs $vfs_path $staging $mod
    }

    # Copy exes into staging/pacsDisplay-BIN/LIB
    if {[llength $exes] > 0} {
        copy_exes $exes $staging
    }

    # Copy directories into staging/pacsDisplay-BIN/LIB
    if {[llength $dirs] > 0} {
        copy_lib_dirs $dirs $staging
    }

    # Copy vendor license files to LIB
    set lib_dir [file join $staging pacsDisplay-BIN LIB]
    set license_src_dir [file join vendor licenses]
    file mkdir [file join $lib_dir licenses]
    if {[file exists $license_src_dir]} {t
        foreach license_file [glob -nocomplain -directory $license_src_dir *.txt] {
            set filename [file tail $license_file]
            log "Copying vendor license: $filename"
            file copy -force $license_file [file join $lib_dir licenses $filename]
        }
    }

    # Copy basekit.exe to staging root
    set basekit_src [file join $manifest(vendor_bin) basekit.exe]
    if {[file exists $basekit_src]} {
        log "Copying basekit.exe to root"
        file copy -force $basekit_src [file join $staging basekit.exe]
    } else {
        die "basekit.exe not found in $manifest(vendor_bin)"
    }

    # Copy support files to staging root
    set support_files {
        {pdLaunch pdLaunch-config.txt}
    }

    foreach item $support_files {
        set subdir [lindex $item 0]
        set filename [lindex $item 1]
        set dest_subdir [expr {[llength $item] > 2 ? [lindex $item 2] : ""}]

        set src [file join $src_tcl $subdir $filename]
        if {[file exists $src]} {
            if {$dest_subdir ne ""} {
                set dest [file join $staging $dest_subdir $filename]
                file mkdir [file join $staging $dest_subdir]
            } else {
                set dest [file join $staging $filename]
            }
            log "Copying $filename"
            file copy -force $src $dest
        }
    }

    # Copy getInstalledPaths - use pdqc version for thin, full version for thick
    set installed_paths_src ""
    if {$target eq "thin"} {
        set installed_paths_src [file join $manifest(misc_dir) "getInstalledPaths_pdqc.txt"]
    } else {
        set installed_paths_src [file join $manifest(misc_dir) "getInstalledPaths_full.txt"]
    }
    if {[file exists $installed_paths_src]} {
        set dest_dir [file join $staging pacsDisplay-BIN]
        file mkdir $dest_dir
        log "Copying getInstalledPaths.txt"
        file copy -force $installed_paths_src [file join $dest_dir "getInstalledPaths.txt"]
    } else {
        die "getInstalledPaths file not found: $installed_paths_src"
    }

    # Copy misc files to staging root
    set misc_files {GNU-GPL.txt QUICKSTART_pdQC.txt pdLaunch.bat}
    foreach file $misc_files {
        set src [file join $manifest(misc_dir) $file]
        if {[file exists $src]} {
            log "Copying $file"
            file copy -force $src [file join $staging $file]
        }
    }

    # Create _NEW directory and copy README
    set new_dir [file join $staging _NEW]
    file mkdir $new_dir
    set readme_src [file join $manifest(misc_dir) _README_pdNEW.txt]
    if {[file exists $readme_src]} {
        log "Copying _README_pdNEW.txt to _NEW"
        file copy -force $readme_src [file join $new_dir _README_pdNEW.txt]
    }

    # Generate VERSION_INFO.txt
    log "Generating VERSION_INFO.txt"
    set version_file [file join $staging VERSION_INFO.txt]
    set vf [open $version_file w]
    set date [clock format [clock seconds] -format "%d-%b-%Y" -gmt 1]
    puts $vf "Package Version: $version,   $date"
    puts $vf ""
    puts $vf "|---------------------------------|"
    puts $vf "|      pacsDisplay Versions       |"
    puts $vf "|                                 |"
    puts $vf "|    Authors:     M. Flynn        |"
    puts $vf "|                 P. Tchou        |"
    puts $vf "|                 N. Bevins       |"
    puts $vf "|---------------------------------|"
    puts $vf ""
    puts $vf "INCLUDED PROGRAM VERSIONS:"
    puts $vf ""

    # Extract versions from each module's TCL file
    foreach mod $modules {
        set ver [extract_module_version $mod]
        # Format with tabs for alignment
        set tabs "\t\t\t"
        if {[string length $mod] >= 8} {
            set tabs "\t\t"
        }
        if {[string length $mod] >= 16} {
            set tabs "\t"
        }
        puts $vf "${mod}${tabs}${ver}"
    }
    puts $vf ""
    close $vf

    # Zip staging into dist
    set package_name [expr {$target eq "thin" ? "pdQC" : "pacsDisplay"}]
    set zip_name "${package_name}_v${version}.zip"
    set zip_path [file join $dist_dir $zip_name]

    log "Creating archive: $zip_name"

    # Remove old zip if present
    if {[file exists $zip_path]} {
        file delete $zip_path
    }

    # Create zip with contents at root (cd into staging, then zip)
    set zipper $manifest(zip_tool)
    set save_dir [pwd]
    cd $staging
    run $zipper a [file join $save_dir $zip_path] *
    cd $save_dir

    # Clean up staging
    file delete -force $staging

    log "Done: $zip_path"
    log ""
}

# --- Main --------------------------------------------------------------------

# Ensure dist dir exists
file mkdir $manifest(dist_dir)

switch $build_target {
    thin  { build_package thin $build_version }
    thick {
        log ""
        log "======================================================================"
        log "  THICK PACKAGE (pacsDisplay) - NOT YET IMPLEMENTED"
        log "======================================================================"
        log ""
        log "The thick package build is planned for a future release."
        log ""
        log "The thick package will include:"
        log "  - Full pacsDisplay installation with all modules"
        log "  - Windows installer"
        log "  - Start Menu shortcuts"
        log "  - Registry entries for proper uninstallation"
        log "  - Documentation and manual"
        log ""
        log "For now, please use the thin package (pdQC):"
        log "  tclsh build.tcl thin $build_version"
        log "  or download a previous release from the github releases page."
        log ""
        log "======================================================================"
        log ""
        exit 0
    }
    all   {
        build_package thin $build_version
        log "Skipping thick package - not yet implemented"
    }
}

log "Build complete."
