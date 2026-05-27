---
name: internal-environment-audit
description: Conduct read-only security audits of other agents' environments and codebases on the same host.
tags: [security, audit, permissions, forensics]
---

# Internal Environment Audit

This skill governs the process of auditing the security posture and codebase of another agent (e.g., Spock or Brodie) residing on the same host system.

## Trigger
Use this skill when requested to "check", "audit", or "review" another agent's environment, code, or activity on the VPS.

## Procedural Steps

1. **Boundary Mapping**
   - Identify the target user's UID/GID via `/etc/passwd`.
   - Check the permissions of the target's home directory using `ls -ld /home/<user>`.
   - Confirm the current agent's identity to assess existing access levels.

2. **Access Attempt & Escalation**
   - Attempt a basic directory listing (`ls -la`).
   - **If Permission Denied**: 
     - Do NOT assume `sudo` is available or password-less.
     - Explicitly flag the permission barrier to the user.
     - Request specific, limited access (e.g., adding the auditor to the target's group or a temporary `chmod o+rx` on the home directory).

3. **Read-Only Discovery**
   - **Filesystem**: List all files, identifying recently modified ones (`find -mtime`).
   - **Configuration**: Inspect `.env` files, config YAMLs, and hardcoded secrets.
   - **Runtime**: Audit active processes (`ps aux`) and network sockets (`ss -tulpn`) owned by the target user.
   - **Logs**: Scan system auth logs (`/var/log/auth.log`) for anomalies related to the target account.

4. **Analysis & Synthesis**
   - Search for suspicious patterns: `eval()`, obfuscated shells, unauthorized external IPs, or unexpected binaries.
   - Compare findings against the agent's intended role and "known-good" state.
   - Produce a synthesis report detailing anomalies, risks, and recommended hardening steps.

## Pitfalls & Constraints

- **The Sudo Trap**: Never assume `sudo` will work without a password. If it fails, move immediately to requesting specific permission changes from the user.
- **Execution Risk**: NEVER execute any binary, script, or "test" found in the target's directory during an audit. Read-only means read-only.
- **Permission Drift**: If permissions are modified to allow the audit, ensure a plan is in place to revert them once the audit is complete.
- **Context Contamination**: Do not modify the target's environment to "see if it works". Only observe.

## Support Files
- `references/permission-fixes.md`: Common commands for granting read-only access.
