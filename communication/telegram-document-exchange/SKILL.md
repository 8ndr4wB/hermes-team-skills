---
name: telegram-document-exchange
description: "Standardized procedure for sending and receiving PDF and Markdown documents via the Hermes Gateway. Use this skill whenever you need to deliver a report, a research document, or any collaborative file to Andrew on Telegram, even if he doesn't explicitly ask for a specific file format."
version: 1.1.0
author: T'Pol
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [communication, delivery, pdf, markdown, media, telegram]
---

# Telegram Document Exchange Protocol

## Purpose
To ensure a consistent, professional, and reliable method for exchanging documents between agents and Andrew. This eliminates ambiguity regarding file formats and prevents delivery failures due to path errors.

## Decision Matrix: Format Selection
Before creating a document, the agent must determine the intent:

| Intent | Required Format | Reason |
|----------|-----------------|--------|
| **Final Report** | **PDF** | Non-editable, professional, preserves layout. |
| **Collaborative Work** | **.md (Markdown)** | Editable, allows Andrew to modify and return. |

## Procedure

### 1. File Generation
- **PDFs**: Use the `reportlab` library to generate the document.
- **Markdown**: Write the content using standard markdown syntax.
- **Naming**: Use a unique, descriptive filename to avoid collisions. 
  - *Pattern*: `[agent]_[timestamp]_[description].[ext]`
  - *Example*: `tpol_20260527_hardening_plan.md`

### 2. Path Validation
- **Absolute Paths Only**: Never use relative paths.
- **Location**: Save files to a designated delivery folder (e.g., `/home/tpol/outbox/` or the agent's specific mapped volume).
- **Verification**: Use `os.path.exists()` or a terminal check to confirm the file is on disk before attempting to send.

### 3. Delivery Execution
Use the `send_message` tool with the `MEDIA:` prefix. The Gateway requires the absolute path to the file.

**Correct Syntax:**
`send_message(target='telegram', message='Here is the document: MEDIA:/home/tpol/outbox/file.pdf')`

**Incorrect Syntax:**
`send_message(target='telegram', message='Here is the document: /home/tpol/outbox/file.pdf')` (Missing MEDIA prefix)

## Pitfalls & Safeguards
- **Relative Paths**: The Gateway runs on the host; it cannot resolve `../` or `~/` paths sent from a container. Always provide the full absolute path.
- **Permissions**: Ensure the file is world-readable or owned by the user running the Gateway, otherwise the upload will fail with a "Permission Denied" error.
- **Shared Profiles**: If using a shared profile, ensure filename uniqueness to prevent agents from overwriting each other's files.

## Verification
A delivery is successful only when the Gateway confirms the message was sent. If a "File Not Found" error occurs, verify the absolute path and the volume mapping between the container and host.
