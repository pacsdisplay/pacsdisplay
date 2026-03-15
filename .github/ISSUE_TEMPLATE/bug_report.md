---
name: Bug Report
about: Report a bug or issue with pacsDisplay
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description

A clear and concise description of the bug.

## Environment

**System Information:**
- Windows Version: [e.g., Windows 10 21H2, Windows 11]
- pacsDisplay Version: [e.g., 6A - check window title or pdLaunch]
- Package Type: [pdQC or pacsDisplay full install]

**Hardware:**
- Photometer: [e.g., i1Display Pro, NEC SpectraSensor Pro]
- Display Configuration: [single monitor / multi-monitor]
- Display Model(s): [e.g., Dell U2410, NEC EA241WM]

**Application:**
Which application has the issue?
- [ ] lumResponse
- [ ] lutGenerate
- [ ] loadLUTsingle
- [ ] uniLum
- [ ] iQC
- [ ] i1meter
- [ ] EDIDprofile
- [ ] QC-check
- [ ] uLRstats
- [ ] gtest
- [ ] ambtest
- [ ] pdLaunch
- [ ] Other: _______

## Steps to Reproduce

1. Launch [application name]
2. Configure [settings/options]
3. Click [button/menu item]
4. Observe error at [specific step]

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Screenshots

If applicable, add screenshots to help explain the problem.

## Error Messages

If there were any error messages, paste them here:

```
[paste error messages here]
```

## Log Files

If available, attach or paste relevant log file contents (from LOGs directory or application output).

## Application-Specific Details

### For lumResponse issues:
- Measurement Mode: [e.g., Palette 1786, QC 18x1, QC 16x2, External 18]
- Phase: [initialization / meter connection / recording / saving / evaluation]
- Number of measurements completed: [e.g., 5 of 18]

### For lutGenerate issues:
- uLR file: [attach or describe]
- Ambient luminance (Lamb): [e.g., 1.5 cd/m²]
- Target luminance range: [e.g., 1.0 to 400 cd/m²]
- LUT size: [256 / 512 / 1024]

### For loadLUTsingle issues:
- LUT file: [filename]
- Display Number: [e.g., 1, 2]
- EDID information: [from EDIDprofile]
- Running as administrator: [Yes / No]

### For uniLum issues:
- Measurement mode: [Internal / External]
- Number of levels: [1 / 3 / 18]
- Position when error occurred: [e.g., position 5 of 9]
- Lamb value: [e.g., 1.5]

### For iQC issues:
- Pattern type: [e.g., TG270-pQC, TG18-LN, ULN12]
- Display mode: [Full screen / Windowed]
- Pattern size: [if applicable]

## Known Issue Checklist

Have you checked these common issues?

- [ ] Virtual display devices causing EDID mismatch (use EDIDprofile to verify)
- [ ] Windows color management resetting LUT after loadLUT
- [ ] Photometer not properly connected
- [ ] Display power saver settings interfering with measurements

## Additional Context

Add any other context about the problem here.

## Workaround

If you found a workaround, please describe it here to help others.
