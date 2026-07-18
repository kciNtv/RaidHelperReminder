# RaidHelperReminder

> **First time here? Never used GitHub before? No problem — start with
> [docs/GITHUB-BASICS.md](docs/GITHUB-BASICS.md)** (5 minutes: the only four
> things you'll ever do on this site, all in the browser, nothing to
> install). Then [docs/HANDOFF.md](docs/HANDOFF.md) is the step-by-step
> checklist to get this running, and [docs/GUIDE.md](docs/GUIDE.md) explains
> how everything works and how it meets the original requirements.

Automates the two things [Raid-Helper](https://raid-helper.dev) can't do by
itself:

1. **Reminds people who HAVEN'T signed up.** DMs every member who is expected
   at a raid but hasn't responded — e.g. every Friday at 5PM ET, one digest
   DM listing all their unsigned raids for the week.
2. **Raid-time announcements.** Posts a custom message (e.g. "Raid invites
   has started - whisper Kcin or an Officer!") into the signup channel,
   pinging a role, N minutes before each raid.

Everything else — recurring weekly signups, the "bring your consumes" DM on
sign-up, attendance tracking — is native Raid-Helper (Premium) configuration,
covered step-by-step in the guide.

Features:

- **Audiences per team**: any set of Discord roles, explicit user lists, or
  "everyone who can see this channel" (computed from channel permissions —
  the workaround when channels don't map to roles). Rules route each event
  to the right team's audience.
- Configurable reminder windows — fixed weekly ("Friday 5PM") or escalating
  relative ones (48h/24h/2h before each event).
- Digest mode: one DM listing all unsigned raids instead of a pile of pings.
- Never sends anything twice (`state.json` audit trail).
- Run reports in Discord: after any run that sent something, posts a summary
  (who was DMed, what was announced) to a channel of your choice
  (`log_channel_id`) — day-to-day visibility without opening GitHub.
- People who responded *anything* (Bench, Late, Tentative, Absence) are left
  alone (configurable).
- Single Python file, standard library only. Nothing to install.
- Runs anywhere a script can run on a schedule: GitHub Actions (free,
  recommended), Windows Task Scheduler, cron.

## Status

**Fully built and live-tested on the real server (July 17, 2026)** — every
feature has fired for real: reminder DMs, digests, duplicate suppression,
raid-time announcements, per-raid officer run reports, the settings console.
Two things remain, both decisions rather than work:

1. **Go-live switch** — audiences currently point at one test user; flipping
   them to the real team roles arms the weekly reminders for everyone.
   Exact steps: [docs/HANDOFF.md section 2](docs/HANDOFF.md).
2. **Ownership transfer** to the guild leader — complete step-by-step
   runbook: [docs/HANDOFF.md](docs/HANDOFF.md).

## Settings GUI

**https://kcintv.github.io/raid-console/** — a browser page for editing
every setting in `config.json` (teams, routing, wording, timings, report
channels) with friendly forms instead of raw JSON, plus a dry-run button.
First use needs a one-time GitHub token (2 minutes; the page walks you
through it). Source: [raid-console](https://github.com/kcintv/raid-console)
(public repo, code only — all settings stay in this private repo).

## Quick start

1. Read **[docs/GUIDE.md](docs/GUIDE.md)** — the complete setup and operations
   guide, written for non-programmers (~15 minutes of one-time setup), plus
   the Raid-Helper Premium settings for recurring events, sign-up DMs, and
   attendance.
2. Copy `config.example.json` → `config.json`, fill in your IDs.
3. Provide the two secrets (`DISCORD_BOT_TOKEN`, `RAIDHELPER_API_KEY`) as
   environment variables — GitHub Actions secrets or `secrets.local.env`.
4. Test safely: `python remind.py --dry-run` prints who *would* get what,
   without sending anything.

## Project layout

| File | Purpose |
|---|---|
| `remind.py` | The whole program — heavily commented, readable top to bottom |
| `config.json` | All behavior: audiences, rules, windows, messages, announcements |
| `state.json` | Auto-managed memory of everything already sent |
| `.github/workflows/remind.yml` | GitHub Actions schedule: reminder DMs, Friday 5PM ET |
| `.github/workflows/announce.yml` | GitHub Actions schedule: raid-time announcements (every 15 min during evening raid hours) |
| `run_local.ps1` + `secrets.example.env` | Windows / Task Scheduler alternative |
| `docs/GITHUB-BASICS.md` | GitHub for first-timers — the four browser-only actions you'll ever need |
| `docs/HANDOFF.md` | The go-live/handover checklist: values, secrets, ordered test plan |
| `docs/GUIDE.md` | The full how-to and operations guide |
| `tests/` | Unit tests: `python -m unittest discover tests` |
