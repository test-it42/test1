**Class:** ABSTAINED
**Outcome:** blocked

One-line: Feature request requires building a Windows-only PowerShell/WinForms GUI tool with Active Directory integration — cannot build or test on Linux, no existing Python project exists for `pip install -e .`, and scope exceeds single-bug mandate.
Files: 0  Diff: +0/-0  Commits: 0  Tool-calls: 5
PR: none
Notes: Issue #3 is a greenfield feature request (not a bug fix). It asks for a full PowerShell GUI application targeting Windows-only APIs (WinForms/WPF, Active Directory). The repo contains only README.md and license.md with no Python project, so `pip install -e .` would also fail. This issue should be handled by a human developer with a Windows + AD environment, or re-scoped to a smaller deliverable (e.g., just a .ps1 script with no GUI).
