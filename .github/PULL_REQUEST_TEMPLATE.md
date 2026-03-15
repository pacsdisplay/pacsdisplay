# Pull Request

## Description

Brief description of the changes in this pull request.

## Related Issues

Closes #[issue number]
Related to #[issue number]

## Type of Change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Build system change
- [ ] LUT library addition

## Applications Affected

Which applications are modified by this PR?

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
- [ ] Build system
- [ ] Documentation only

## Changes Made

Detailed description of what was changed:

### Code Changes
- [List specific changes to code]
- [Include file paths and brief description]

### Configuration Changes
- [Any changes to Config.txt files]
- [New configuration options added]

### Documentation Changes
- [INSTRUCTIONS.txt updates]
- [README or docs/ updates]
- [CHANGELOG.md entry]

## Standards Compliance

Does this change relate to medical display standards?

- [ ] DICOM Part 14 - GSDF implementation
- [ ] AAPM Report 270 - QC procedures
- [ ] AAPM TG-18 - Test patterns or measurements
- [ ] IEC 62563-1 - Medical electrical equipment
- [ ] Not applicable

**Standard reference:**
[Cite specific sections if applicable]

## Testing Performed

### Build Testing
- [ ] Successfully builds with `tclsh build.tcl thin 6A` (or current version)
- [ ] Resulting executables run without errors
- [ ] No build warnings

### Functional Testing
- [ ] Tested on Windows 10
- [ ] Tested on Windows 11
- [ ] Tested with i1Display Pro photometer (if hardware-related)
- [ ] Tested in single-monitor configuration
- [ ] Tested in multi-monitor configuration (if relevant)

### Test Scenarios

Describe specific test scenarios performed:

1. **Scenario 1:**
   - Setup: [configuration]
   - Steps: [what was done]
   - Result: [expected vs actual]

2. **Scenario 2:**
   - [additional scenarios]

### Regression Testing

- [ ] Existing functionality still works
- [ ] No new error messages
- [ ] Output file formats unchanged (or documented)
- [ ] Configuration files backward compatible

## Version Update

- [ ] Version number updated in MODULE block
- [ ] Date updated in MODULE block
- [ ] Entry added to CHANGELOG.md
- [ ] MODULES.md updated (if user-facing changes)

**New version:** [e.g., 2.6]

## Documentation Updates

- [ ] INSTRUCTIONS.txt updated (if applicable)
- [ ] README.md updated (if needed)
- [ ] docs/MODULES.md updated (if needed)
- [ ] Code comments added/updated
- [ ] Help text updated (if applicable)

## Breaking Changes

Does this PR introduce any breaking changes?

- [ ] Yes
- [ ] No

**If yes, describe:**
- What breaks: [description]
- Migration path: [how to update]
- Backward compatibility: [any compatibility mode?]

## Screenshots

If applicable, add screenshots showing:
- UI changes
- New features
- Test results
- QC plots

## Files Changed

List of files modified:
```
[paste output of git diff --name-only or list manually]
```

## Checklist

Before submitting, verify:

### Code Quality
- [ ] Code follows project style guidelines
- [ ] Comments explain WHY, not just WHAT
- [ ] No hardcoded paths or credentials
- [ ] Error handling is robust
- [ ] File handles are properly closed

### Security
- [ ] No command injection vulnerabilities
- [ ] File paths validated
- [ ] Safe use of `exec` (list form, not string concatenation)
- [ ] No exposed sensitive information

### Portability
- [ ] Works from USB deployment (no install needed)
- [ ] Uses relative paths where appropriate
- [ ] No dependencies on specific drive letters
- [ ] Compatible with pdQC portable package

### Standards
- [ ] Follows DICOM/AAPM standards (if applicable)
- [ ] Equations match published standards
- [ ] Terminology consistent with medical physics usage

### Audit Trail
- [ ] Measurements include timestamps
- [ ] Configuration saved with results
- [ ] Changes logged appropriately

## Additional Notes

Any additional information for reviewers:

## Reviewer Checklist

For maintainers reviewing this PR:

- [ ] Code review completed
- [ ] Testing verified
- [ ] Documentation adequate
- [ ] Version update appropriate
- [ ] CHANGELOG entry clear
- [ ] No security concerns
- [ ] Follows project conventions

## Post-Merge Tasks

Tasks to complete after merge (if any):

- [ ] Update website documentation
- [ ] Notify users of breaking changes
- [ ] Update LUT library (if needed)
- [ ] Other: _______
