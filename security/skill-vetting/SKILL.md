---
name: skill-vetting
description: "Vet community skills before installing. Use before running hermes skills install on any skills.sh, github, or community-source skill. Checks repo ownership, maintainer identity, stars, recent commits, and suspicious patterns. A SAFE scanner verdict alone is NOT sufficient."
---

# Community Skill Vetting

## Rule

Never install a community skill without vetting it first. The Hermes automated scan checks for code patterns only — it does not check who wrote the skill, whether the repo is legitimate, or whether the maintainer is trustworthy.

## Quick Vetting Process

### 1. Get the repo URL

From `hermes skills inspect <name>`, note the `Repo:` field.

### 2. Check repo metadata

```bash
curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/OWNER/REPO" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(f'Owner: {d[\"owner\"][\"login\"]} ({d[\"owner\"][\"type\"]})')
print(f'Stars: {d[\"stargazers_count\"]}, Forks: {d[\"forks_count\"]}')
print(f'Created: {d[\"created_at\"]}, Updated: {d[\"updated_at\"]}')
print(f'License: {d.get(\"license\",{}).get(\"spdx_id\",\"N/A\")}')
print(f'Archived: {d.get(\"archived\")}')
"
```

### 3. Check recent commits

```bash
curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/OWNER/REPO/commits?per_page=10" | python3 -c "
import json, sys
for c in json.load(sys.stdin)[:10]:
    print(f'{c[\"commit\"][\"author\"][\"date\"][:10]} {c[\"sha\"][:8]} {c[\"commit\"][\"author\"][\"name\"]}: {c[\"commit\"][\"message\"].split(chr(10))[0][:70]}')
"
```

## Red Flags

| Flag | Action |
|------|--------|
| Owner is unknown individual, not org | Investigate further |
| Repo created very recently | Caution |
| Very few stars (under 10) | Caution |
| No recent activity (over 6 months) | Caution |
| Force-push evidence in commit history | Skip |
| Different author names in recent commits | Investigate |
| Archived repo | Skip |

## Green Flags

| Flag | Action |
|------|--------|
| Owned by known company or org | Good |
| Maintained by known individual | Good |
| Active development (commits within last week) | Good |
| High star count (over 100) | Good |
| Multiple contributors | Good |

## Decision

- All green, no red: proceed to `hermes skills install`
- Any red flag: investigate deeper or skip
- Mixed signals: present findings to Andrew for decision

## Remember

The Hermes scanner verdict (SAFE/CAUTION/DANGEROUS) is a separate check. Even if a skill passes vetting, it must still return SAFE from the scanner to be installed.