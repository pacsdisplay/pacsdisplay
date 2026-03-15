---
name: QC Measurement Issue
about: Report problems with QC measurements or calibration results
title: '[QC] '
labels: qc, question
assignees: ''
---

## QC Issue Summary

Brief description of the QC measurement issue.

## Display Information

**Display Details:**
- Manufacturer: [e.g., Eizo, Dell, Barco]
- Model: [e.g., EA241WM, U2410]
- Serial Number: [if available]
- Display Age: [e.g., 2 years, 5 years, unknown]
- Technology: [LCD, OLED, etc.]

**EDID Information:**
Paste output from EDIDprofile (if available):
```
[paste EDID info here]
```

## Calibration History

**Current Calibration Status:**
- [ ] Uncalibrated (linear LUT)
- [ ] DICOM calibrated
- [ ] Other calibration
- [ ] Unknown

**Last Calibration:**
- Date: [e.g., 2025-01-15]
- Method: [lumResponse + lutGenerate, vendor software, etc.]
- Target Lamb: [e.g., 1.5 cd/m²]

## Measurement Setup

**Photometer:**
- Model: [e.g., i1Display Pro]
- Calibration date: [if known]
- Calibration factor (iLcalVal): [e.g., 1.0]

**Environment:**
- Room lighting: [typical exam room / dark room / bright office]
- Measured ambient: [e.g., 20 lux, unknown]
- Time of day: [affects display warm-up]
- Display warm-up time: [e.g., 30 minutes]

**lumResponse Settings:**
- Mode: [e.g., 1786 Palette, 766 Palette, QC 18x1, QC 16x2, External 18]
- Averaging (avgN): [e.g., 2]
- Integration time: [if changed from default]

## Issue Type

What type of QC issue are you experiencing?

- [ ] Calibration failed - target luminance out of range
- [ ] QC evaluation failed - exceeds tolerance
- [ ] Measurement variability - inconsistent readings
- [ ] Color tracking issues - grey scale not neutral
- [ ] Uniformity problems - LUDM/MLD too high
- [ ] LUT loading problems
- [ ] Other: _______

## Measurement Results

### Luminance Range

**uLR Measurements (uncalibrated):**
- Minimum luminance (Lmin): [e.g., 0.8 cd/m²]
- Maximum luminance (Lmax): [e.g., 380 cd/m²]
- Luminance ratio (LR): [Lmax/Lmin, e.g., 475]

**cLR Measurements (calibrated):**
- Minimum luminance: [e.g., 1.1 cd/m²]
- Maximum luminance: [e.g., 395 cd/m²]

### QC Results

**For QC 18x1 or QC 16x2:**
- Maximum deviation from GSDF: [e.g., +15% at DDL 45]
- Overall pass/fail: [Pass 10% / Pass 20% / Fail]
- Failing DDL ranges: [e.g., DDL 30-60]

**For Uniformity (uniLum):**
- Maximum LUDM: [e.g., 18%]
- Maximum MLD: [e.g., 12%]
- Problematic region: [e.g., lower right corner]

## Files

If possible, attach relevant files:

- [ ] uLR file (uncalibrated luminance response)
- [ ] cLR file (calibrated luminance response)
- [ ] LUT file
- [ ] QC-lr.txt evaluation report
- [ ] QC plots (PNG files)
- [ ] uniLum results

**Attach files or paste key values:**
```
[paste relevant data here]
```

## Questions

**Specific questions about the results:**

1. [Your question here]
2. [Additional questions]

**What guidance are you seeking?**

- [ ] Is this display acceptable for clinical use?
- [ ] How to improve calibration results?
- [ ] Recommended corrective actions
- [ ] Measurement technique validation
- [ ] Understanding QC metrics
- [ ] Compliance with specific standards
- [ ] Other: _______

## Acceptance Criteria

**Intended use:**
- [ ] Primary diagnostic interpretation (strict 10% tolerance)
- [ ] Secondary diagnostic review (20% tolerance)
- [ ] Clinical review (general use)
- [ ] Non-diagnostic (education, admin)

**Organizational requirements:**
[Any specific QC requirements from your institution]

## Troubleshooting Attempted

What have you tried?

- [ ] Re-measured with longer warm-up
- [ ] Re-calibrated display
- [ ] Checked photometer positioning
- [ ] Verified ambient light level
- [ ] Tested with different Lamb value
- [ ] Checked display settings (brightness, contrast)
- [ ] Other: _______

## Additional Context

Add any other context, observations, or questions about the QC measurements.

## Timeline

- [ ] Urgent - blocking clinical operations
- [ ] Important - scheduled QC deadline
- [ ] Routine - general guidance
