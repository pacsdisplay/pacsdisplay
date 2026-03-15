# Security Policy

## Overview

pacsDisplay is medical display calibration and quality control software used in clinical environments. While it does not handle patient data directly, security is important for the integrity of display calibration in medical imaging systems.

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 6.x     | :white_check_mark: |
| 5H      | :white_check_mark: |
| 5G      | :x:                |
| 5F      | :x:                |
| < 5F    | :x:                |

**Note:** We recommend always using the latest version available at [pacsdisplay.org](https://pacsdisplay.org).

## Scope

### In Scope

Security issues relevant to pacsDisplay include:

1. **Code Execution Vulnerabilities**
   - Command injection in exec calls
   - Path traversal in file operations
   - Unsafe deserialization

2. **File System Issues**
   - Arbitrary file read/write
   - Directory traversal
   - Unsafe temporary file handling

3. **Privilege Escalation**
   - Unintended privilege elevation
   - Unsafe use of administrator rights (loadLUTsingle)

4. **Configuration Security**
   - Hardcoded credentials or paths
   - Insecure default settings
   - Exposure of sensitive information in logs

5. **Supply Chain**
   - Vulnerabilities in bundled dependencies (Tcl/Tk, Argyll CMS, Gnuplot)
   - Compromised build artifacts

### Out of Scope

The following are outside the scope of security reports:

1. **Physical Security**
   - Physical access to workstations
   - USB device security policies
   - Display hardware tampering

2. **Network Security**
   - Network deployment configuration
   - File share permissions
   - Firewall rules

3. **Social Engineering**
   - User training issues
   - Phishing attempts
   - Credential management

4. **Denial of Service**
   - Resource exhaustion (unless trivially exploitable)
   - Algorithmic complexity attacks

5. **Known Limitations**
   - Windows-only support
   - Administrator requirement for loadLUTsingle
   - Virtual display EDID issues (documented)

## Reporting a Vulnerability

### How to Report

**Do not report security vulnerabilities through public GitHub issues.**

Instead, please report security issues via email to the repository maintainers. Include:

1. **Description** - Clear description of the vulnerability
2. **Impact** - Potential security impact (confidentiality, integrity, availability)
3. **Affected Components** - Which applications or modules
4. **Steps to Reproduce** - Detailed reproduction steps
5. **Proof of Concept** - Code or example demonstrating the issue (if available)
6. **Suggested Fix** - Your recommended mitigation (if you have one)

### What to Expect

**Response Time:**
- **Initial Response:** Within 7 days
- **Status Update:** Within 14 days
- **Resolution Target:** Within 90 days (depending on severity)

**Process:**

1. **Acknowledgment** - We'll confirm receipt of your report
2. **Investigation** - We'll validate and assess the vulnerability
3. **Fix Development** - We'll develop and test a fix
4. **Disclosure** - We'll coordinate disclosure timeline with you
5. **Release** - We'll release the fix and publish a security advisory
6. **Credit** - We'll credit you in the advisory (unless you prefer to remain anonymous)

### Severity Assessment

We use the following severity levels:

**Critical:**
- Remote code execution
- Arbitrary file write as administrator
- Credential exposure

**High:**
- Local privilege escalation
- Sensitive information disclosure
- Authentication bypass

**Medium:**
- Denial of service (easily exploitable)
- Information disclosure (limited)
- Path traversal (limited impact)

**Low:**
- Denial of service (difficult to exploit)
- Minor information disclosure
- Issues with minimal security impact

## Security Best Practices

### For Users

When deploying pacsDisplay/pdQC:

1. **Download from Official Sources**
   - Only download from [pacsdisplay.org](https://pacsdisplay.org) or [GitHub Releases](../../releases)
   - Verify ZIP file integrity if checksums are provided

2. **USB Deployment**
   - Use trusted USB devices
   - Scan USB drive for malware before use
   - Follow organizational USB security policies

3. **File Permissions**
   - Restrict write access to program directory
   - Protect LUT files from unauthorized modification
   - Secure QC result files per organizational policy

4. **Administrator Privileges**
   - loadLUTsingle requires administrator rights (by design)
   - Don't run other applications as administrator unnecessarily
   - Use execLoadLUT for automated loading with proper security context

5. **Configuration Files**
   - Review config files before use
   - Don't use config files from untrusted sources
   - Validate file paths in configuration

6. **Updates**
   - Keep software up to date
   - Review CHANGELOG.md for security-related updates
   - Test updates in non-production environment first

### For Developers

When contributing code:

1. **Input Validation**
   - Validate all user input
   - Sanitize file paths
   - Check file existence and types

2. **Command Execution**
   - Use `exec` with list form, never string concatenation
   - Never pass unsanitized user input to exec
   - Validate executable paths

3. **File Operations**
   - Use absolute paths when possible
   - Validate paths before file operations
   - Close file handles properly
   - Use appropriate file permissions

4. **Error Handling**
   - Don't expose sensitive information in error messages
   - Log security-relevant events
   - Fail securely (safe defaults)

5. **Dependencies**
   - Keep bundled components updated
   - Review dependency security advisories
   - Document dependency versions

**Example - Safe exec:**
```tcl
# Good - list form prevents injection
set args [list -yn -N]
exec $spotread_path {*}$args

# Bad - string concatenation vulnerable to injection
exec "$spotread_path -yn -N $userInput"
```

**Example - Path validation:**
```tcl
# Validate user-provided paths
if {![file isdirectory $userPath]} {
    error "Invalid directory"
}
if {[string match "*../*" $userPath]} {
    error "Path traversal detected"
}
```

## Known Security Considerations

### Administrator Privileges

**loadLUTsingle.exe** requires administrator privileges to program video card hardware LUTs. This is by design and necessary for the application to function.

**Mitigation:**
- Use execLoadLUT wrapper for automated loading
- Review LUT files before loading
- Restrict access to LUT directory
- Audit LUT loading operations

### EDID Reading

**getEDID.exe** reads display EDID from Windows registry. No direct I2C access is performed.

**Consideration:**
- Virtual displays may cause EDID mismatches (documented, not a security issue)
- EDID information is logged and may include display serial numbers

### External Dependencies

pacsDisplay bundles:
- **Argyll CMS spotread.exe** - Photometer interface (AGPL/GPL)
- **Gnuplot** - Plotting (custom permissive license)
- **basekit.exe** - Tcl interpreter

**Mitigation:**
- Dependencies are versioned and documented
- Update bundled components with new releases
- Monitor upstream security advisories

## Disclosure Policy

### Coordinated Disclosure

We follow coordinated disclosure:

1. **Private Notification** - Reporter notifies maintainers privately
2. **Investigation** - Maintainers investigate and develop fix
3. **Fix Release** - Security fix released in update
4. **Public Disclosure** - Security advisory published after fix is available
5. **Credit** - Reporter credited (if desired)

### Public Disclosure Timeline

- **Day 0:** Vulnerability reported privately
- **Day 7:** Initial response to reporter
- **Day 14:** Status update to reporter
- **Day 90:** Target for fix release (extended for complex issues)
- **After fix:** Public advisory published

We appreciate reporter patience and will work to resolve issues promptly.

## Security Advisories

Published security advisories will be available:
- GitHub Security Advisories (when available)
- CHANGELOG.md with [SECURITY] prefix
- pacsdisplay.org website

## Compliance

pacsDisplay is used in medical environments subject to:
- HIPAA (patient data protection, though pacsDisplay doesn't handle PHI directly)
- FDA regulations (for display calibration in medical imaging)
- State and local regulations

While pacsDisplay doesn't directly handle patient data, proper display calibration is critical for diagnostic accuracy.

## Contact

For security issues: Use GitHub repository maintainer contact information

For general questions: [GitHub Issues](../../issues) (non-security topics only)

## Acknowledgments

We appreciate responsible disclosure from security researchers and will acknowledge contributors (unless they prefer anonymity) in:
- Security advisories
- CHANGELOG.md
- Project documentation

Thank you for helping keep pacsDisplay and its users secure!
