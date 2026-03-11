# ERRORS.md

## [ERR-20260311-001] daily-close-cron

**Logged**: 2026-03-11T07:37:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
Daily close cron failed due to missing delivery.channel when multiple channels configured.

### Error
Channel is required when multiple channels are configured: telegram, slack.

### Context
Cron job 13e5c0f5-c81c-4cd7-b58b-652ea5e5db28 attempted to announce without explicit channel.

### Suggested Fix
Always set delivery.channel explicitly in cron jobs.

### Metadata
- Reproducible: yes
- Related Files: cron job configuration

---
