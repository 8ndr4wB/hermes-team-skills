---
name: telegram-document-exchange
description: "Send documents (PDF, Markdown, and other files) via Telegram using the Hermes MEDIA: delivery system. Covers path validation, the three trust mechanisms, and proper agent workflow."
version: 3.0.0
author: T'Pol
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [communication, delivery, pdf, markdown, media, telegram, documents]
---

# Telegram Document Exchange

## Purpose

This skill provides the correct procedure for agents to send files (PDFs, Markdown documents, images, etc.) as native attachments via Telegram. The gateway validates file paths through a multi-layer security system before delivery.

## How MEDIA: Delivery Works

When an agent includes `MEDIA:<path>` in its response, the gateway:

1. **Extracts** the MEDIA: tag from the response text
2. **Validates** the file path against allowed directories
3. **Delivers** the file as a native Telegram attachment (document, photo, audio, etc.)

### Path Validation (Three Mechanisms)

The gateway uses three mechanisms to determine if a file path is safe for delivery:

#### Mechanism 1: Hermes Cache Directories (Always Allowed)

Files under these directories are always permitted:

- `~/.hermes/cache/images/`
- `~/.hermes/cache/audio/`
- `~/.hermes/cache/video/`
- `~/.hermes/cache/documents/`
- `~/.hermes/cache/screenshots/`
- `~/.hermes/image_cache/`
- `~/.hermes/audio_cache/`

#### Mechanism 2: Configured Allow Directories

Additional directories can be specified in `config.yaml`:

```yaml
gateway:
  media_delivery_allow_dirs:
    - /home/tpol
    - /home/tpol/.hermes/cache/documents
```

The gateway reads this at startup and sets the `HERMES_MEDIA_ALLOW_DIRS` environment variable.

#### Mechanism 3: Recency-Based Trust (Fallback)

If a file is NOT in the above directories, the gateway checks:

1. Is `gateway.trust_recent_files` set to `true`? (Default: true)
2. Was the file created within `gateway.trust_recent_files_seconds`? (Default: 600 seconds = 10 minutes)
3. Is the file NOT under a denied prefix? (e.g., `~/.ssh`, `~/.aws`, `~/.gnupg`)

If all three conditions are met, the file is allowed.

**This is how agents can send files from `/tmp/` or their working directory** — as long as the file was recently created (within 10 minutes), it will be delivered.

## Agent Workflow for Sending Documents

### Step 1: Generate the Document

**For PDFs:**
```python
# Use reportlab, pandoc, or any PDF generator
# Save to a recent, accessible location
output_path = "/tmp/report.pdf"
# or
output_path = "/home/tpol/report.pdf"
```

**For Markdown:**
```python
# Write markdown content to a file
output_path = "/home/tpol/report.md"
```

### Step 2: Include MEDIA: Tag in Response

In your final response, include the MEDIA: tag with the absolute path:

```
Here is the report you requested.

MEDIA:/home/tpol/report.pdf
```

The gateway will:
- Extract `MEDIA:/home/tpol/report.pdf` from your response
- Validate the path (it's under `/home/tpol` which is in `media_delivery_allow_dirs`)
- Send the file as a native Telegram document
- Strip the MEDIA: tag from the visible message text

### Step 3: Verify Delivery

Check the gateway logs if needed:
```bash
grep "MEDIA" ~/.hermes/logs/gateway.log | tail -10
```

## The send_message Tool Alternative

You can also use the `send_message` tool explicitly:

```python
send_message(
    target="telegram",
    message="Here is the report MEDIA:/home/tpol/report.pdf"
)
```

This is useful when:
- Sending to a specific channel (not just replying)
- Sending to a different platform
- Sending multiple files in one message

## Special Directives

### [[as_document]]

Force image files to be sent as documents (not photos):

```
[[as_document]]
MEDIA:/home/tpol/diagram.png
```

This prevents Telegram from recompressing the image.

### [[audio_as_voice]]

Force audio files to be sent as voice messages:

```
[[audio_as_voice]]
MEDIA:/home/tpol/narration.ogg
```

## Supported File Types

The gateway recognizes these extensions for MEDIA: delivery:

| Type | Extensions |
|------|-----------|
| Documents | `.pdf`, `.md`, `.txt`, `.csv`, `.json`, `.xml`, `.yaml`, `.yml`, `.toml`, `.docx`, `.xlsx`, `.pptx` |
| Images | `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp` |
| Video | `.mp4`, `.mov`, `.avi`, `.mkv` |
| Audio | `.ogg`, `.opus`, `.mp3`, `.wav`, `.m4a`, `.flac` |
| Archives | `.zip`, `.rar`, `.7z` |

## Common Pitfalls

### 1. File Not Recently Created

If you create a file and wait more than 10 minutes before sending, the recency trust will fail. Either:
- Send immediately after creation
- Or save to an allowed directory (`/home/tpol/` or `~/.hermes/cache/`)

### 2. Wrong Path Format

- Always use absolute paths: `/home/tpol/report.pdf` not `~/report.pdf` or `./report.pdf`
- No quotes around the path in the MEDIA: tag

### 3. File Doesn't Exist

The gateway checks `path.is_file()` — the file must exist on disk before the agent's response is processed.

### 4. Denied Prefix Paths

Files under these directories are BLOCKED even if recently created:
- `~/.ssh/`
- `~/.aws/`
- `~/.gnupg/`
- `~/.kube/`
- `~/.docker/`
- `~/.config/`

## Configuration Reference

In `~/.hermes/config.yaml`:

```yaml
gateway:
  # Directories where MEDIA: files are always allowed
  media_delivery_allow_dirs:
    - /home/tpol
    - /home/tpol/.hermes/cache/documents
  
  # Enable recency-based trust for recently created files
  trust_recent_files: true
  
  # How recently the file must have been created (seconds)
  trust_recent_files_seconds: 600
```

## Troubleshooting

### "Skipping unsafe MEDIA directive path outside allowed roots"

The file path is not in any allowed directory and the file is not recent enough. Solutions:
1. Save the file to `/home/tpol/` or `~/.hermes/cache/documents/`
2. Send the file immediately after creation (within 10 minutes)
3. Add the directory to `media_delivery_allow_dirs` in config.yaml

### File arrives as text, not attachment

The MEDIA: tag was not properly formatted. Use:
```
MEDIA:/absolute/path/to/file.pdf
```
Not:
```
MEDIA: "/absolute/path/to/file.pdf"
MEDIA:~/file.pdf
```

### Gateway restart required after config changes

After modifying `gateway.media_delivery_allow_dirs`, restart the gateway:
```bash
hermes gateway restart
```
