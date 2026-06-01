# Contributing Guidelines

Thank you for your interest in contributing to this project.

We welcome bug reports, feature requests, documentation improvements, and code contributions that help improve the quality, security, and usability of this software.

## Before You Start

Please review the following documents before contributing:

* README.md
* LICENSE.md
* SECURITY.md
* CODE_OF_CONDUCT.md (if applicable)

By contributing to this repository, you agree that your contributions may be incorporated into the project and distributed under the repository license.

---

# Reporting Issues

Before creating a new issue:

1. Search existing issues to avoid duplicates.
2. Verify that the issue still exists in the latest version.
3. Provide sufficient information for reproduction.

Please include:

* Software version
* Operating system
* Steps to reproduce
* Expected behavior
* Actual behavior
* Screenshots or logs (if applicable)

---

# Suggesting Features

Feature requests should clearly describe:

* The problem being solved
* The proposed solution
* Alternative solutions considered
* Expected benefits

Feature requests may be accepted, modified, postponed, or declined based on project priorities.

---

# Development Workflow

## 1. Fork the Repository

Create a personal fork of the repository.

## 2. Create a Feature Branch

Use descriptive branch names:

```text
feature/add-ad-user-report
feature/export-to-csv
bugfix/fix-null-reference
security/improve-encryption
```

## 3. Make Changes

Keep changes focused and limited to a single purpose whenever possible.

## 4. Test Thoroughly

Verify:

* Existing functionality remains operational.
* New functionality behaves as expected.
* No security regressions are introduced.

## 5. Submit a Pull Request

Provide:

* Clear title
* Summary of changes
* Testing performed
* Screenshots (if applicable)

---

# Coding Standards

## General Principles

* Keep code simple and maintainable.
* Prefer readability over cleverness.
* Avoid unnecessary dependencies.
* Follow the existing project structure.

## PowerShell

* Use approved PowerShell verbs.
* Follow standard PowerShell naming conventions.
* Include comment-based help for public functions.
* Use proper error handling.
* Avoid hardcoded credentials and secrets.

Example:

```powershell
function Get-DisabledAdUser {
    [CmdletBinding()]
    param()

    try {
        # Logic here
    }
    catch {
        Write-Error $_
    }
}
```

---

# Security Requirements

Security-related contributions are especially welcome.

Please ensure:

* No credentials are committed.
* No secrets are stored in source code.
* Input validation is implemented where applicable.
* Logging does not expose sensitive information.

Do not create public GitHub issues for security vulnerabilities.

Refer to SECURITY.md for responsible disclosure procedures.

---

# Documentation

Documentation improvements are encouraged.

When adding new features, update:

* README.md
* User documentation
* Configuration examples
* Relevant diagrams

---

# Pull Request Review

All pull requests are subject to review.

Review criteria include:

* Functionality
* Security
* Maintainability
* Documentation quality
* Project alignment

The maintainers reserve the right to request changes before approval.

---

# Contributor License

By submitting a contribution, you grant IT42 d.o.o. a perpetual, worldwide, non-exclusive, royalty-free license to use, modify, distribute, sublicense, and commercialize your contribution as part of this project.

---

Thank you for helping improve this project.
