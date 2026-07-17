# RaidHelperReminder

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
- People who responded *anything* (Bench, Late, Tentative, Absence) are left
  alone (configurable).
- Single Python file, standard library only. Nothing to install.
- Runs anywhere a script can run on a schedule: GitHub Actions (free,
  recommended), Windows Task Scheduler, cron.

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
| `.github/workflows/remind.yml` | GitHub Actions schedules (announcements every 15 min; reminders Friday 5PM ET) |
| `run_local.ps1` + `secrets.example.env` | Windows / Task Scheduler alternative |
| `docs/GUIDE.md` | The full how-to and operations guide |
| `tests/` | Unit tests: `python -m unittest discover tests` |
