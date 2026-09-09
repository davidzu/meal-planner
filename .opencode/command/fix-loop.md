---
description: Route the latest test/UI failures back through developer → review gate → tester until green.
agent: orchestrator
---
Read docs/test-report.md and docs/ui-review.md, collect every open failure,
dispatch the developer with the exact failures verbatim, then re-run the
architect review gate and the failing stage. Repeat until all gates pass.
$ARGUMENTS
