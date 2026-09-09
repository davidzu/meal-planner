---
description: Pre-flight checks and deploy to Render via the release manager.
agent: release-manager
---
Run the full pre-release checklist, then deploy to Render and verify the
live site. First verify docs/test-report.md says READY-FOR-RELEASE and
docs/review-report.md says APPROVED — if either gate fails, STOP and report
exactly what is missing. $ARGUMENTS
