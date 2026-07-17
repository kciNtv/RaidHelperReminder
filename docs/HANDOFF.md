# Handoff Checklist

This document is the complete handover: what's done, what's left to do, what's
left to test, and exactly where every secret and variable goes. Work through
it top to bottom. For background on *how* anything works, see
[GUIDE.md](GUIDE.md) — but this checklist stands on its own.

**Verifying the original asks were met?** [GUIDE.md section 1](GUIDE.md)
restates the five original requirements verbatim (recurring signups, Friday
5PM non-signer reminders, gear/consumes DM on signup, the 8:15PM "invites
started" post, attendance tracking) and traces each one to exactly how and
where it is addressed — which ones are Raid-Helper Premium configuration and
which ones this project provides. Section 3 of the guide explains how the
automation works in plain language, with a diagram.

---

## 1. Current state (nothing here needs re-doing)

| Item | Status |
|---|---|
| Reminder script (`remind.py`) | Complete. 27 unit tests pass. |
| Digest DMs (one DM listing all unsigned raids) | Complete, tested. |
| Per-team audiences (roles / user lists / channel access) | Complete, tested. |
| Raid-time announcements ("invites started", @role ping) | Complete, tested. |
| Duplicate prevention (`state.json`) | Complete, tested. |
| GitHub Actions schedules (announcements every 15 min; reminders Fri 5PM ET) | In place, **manually disabled** (step 5 enables it). |
| Windows Task Scheduler alternative (`run_local.ps1`) | Complete. |
| Live test against a real Discord server | **NOT done yet** — needs the credentials below. That is what sections 3-5 walk through. |

Nothing has ever been sent to anyone. The workflow is disabled specifically
so it cannot run (and fail) before the secrets exist.

---

## 2. Values to collect (do this first)

Gather these eight values before touching anything else.

| # | Value | Where to get it | Where it goes |
|---|---|---|---|
| 1 | **Discord bot token** | discord.com/developers/applications -> New Application (name it e.g. "Raid Reminder") -> Bot -> Reset Token. While there: enable **Server Members Intent** (same page, Privileged Gateway Intents). Then OAuth2 -> URL Generator -> check `bot` + permission **Send Messages** -> open the URL to invite it to the server. | Secret `DISCORD_BOT_TOKEN` (section 3) |
| 2 | **Raid-Helper API key** | In your Discord server type `/apikey`, pick **show**. Raid-Helper replies privately. | Secret `RAIDHELPER_API_KEY` (section 3) |
| 3 | **Server ID** | Discord: User Settings -> Advanced -> enable Developer Mode. Then right-click the server name -> Copy Server ID. | `config.json`: `discord.guild_id` AND `raidhelper.server_id` (same value in both) |
| 4 | **Team A role ID** | Server Settings -> Roles -> right-click the role -> Copy Role ID | `config.json`: `audiences.teamA.role_ids` |
| 5 | **Team B role ID** | same | `config.json`: `audiences.teamB.role_ids` |
| 6 | **@raiders role ID** (the role the 8:15 announcement pings) | same | `config.json`: `announcements[0].mention_role_ids` |
| 7 | **Team A + Team B signup channel IDs** | Right-click each signup channel -> Copy Channel ID | `config.json`: `audience_rules` (routes each event to the right team) |
| 8 | *(optional)* **Fallback channel ID** (public ping for members whose DMs are closed) | same | `config.json`: `discord.fallback_channel_id` ("" = feature off) |

> If channel access does NOT line up with team roles, an audience can instead
> use `"channel_access": "<channelId>"` — everyone who can see that channel
> counts as expected. Caveats (admins match everywhere; the bot needs access
> to that channel) in [GUIDE.md section 4](GUIDE.md).

---

## 3. Where the SECRETS go (values 1 and 2 - never in files)

**GitHub (the hosting we set up):**

1. Open the repo on github.com
2. **Settings** (repo settings, not account) **-> Secrets and variables -> Actions -> New repository secret**
3. Create exactly these two, names must match character-for-character:
   - Name: `DISCORD_BOT_TOKEN` - Value: the bot token
   - Name: `RAIDHELPER_API_KEY` - Value: the API key

That's the only place secrets live. They are write-only (nobody can read them
back, not even the owner) and are NOT copied if the repo is transferred - a
new owner re-adds them (2 minutes, by design).

**Only if running on a PC instead of GitHub:** copy `secrets.example.env` to
`secrets.local.env` next to the script and fill in the two lines. That file
is gitignored and never leaves the machine.

Never put either value in `config.json`, in a commit, or in Discord chat.
If a value ever leaks: bot token -> developer portal -> Bot -> Reset Token;
API key -> `/apikey` -> refresh. Then update the secret.

---

## 4. Where the VARIABLES go (values 3-8 - the config file)

Copy `config.example.json` to `config.json` (in the repo root), replace the
placeholder IDs with values 3-8, and commit it. The example file is already
shaped for this exact setup - two teams, Friday digest reminders, the 8:15
"invites started" announcement with the Kcin wording - so it's fill-in-the-
blanks, not authoring. Every field is explained in
[GUIDE.md section 7](GUIDE.md); the ones you will actually touch:

- `discord.guild_id` + `raidhelper.server_id` <- value 3 (same ID, both places)
- `audiences.teamA` / `teamB` `role_ids` <- values 4, 5
- `audience_rules` channel IDs <- value 7 (maps each signup channel to its team)
- `announcements[0].mention_role_ids` <- value 6
- `announcements[0].text` <- already contains the requested wording; edit freely
- `discord.fallback_channel_id` <- value 8 or leave `""`
- `reminder_windows_hours: [168]` + the Friday cron = weekly Friday-5PM-ET
  reminders. Don't change unless the cadence changes.

Changing anything later = edit `config.json`, commit. That's the whole
deployment process.

---

## 5. What's left to TEST (in this order)

Each step has a pass condition. Stop at any failure and check the
troubleshooting table in [GUIDE.md section 8](GUIDE.md).

**5.1 - Enable the workflow.** Actions tab -> "Send signup reminders" ->
"..." menu -> Enable workflow.
*Pass: the workflow shows as enabled.*

**5.2 - Dry run (sends nothing, ever).** Actions tab -> Send signup
reminders -> **Run workflow** -> mode `all`, tick **dry_run** -> Run. Open
the run's log.
*Pass: the log lists each upcoming event with "N expected, N responded,
N missing" using numbers that match reality, and "[dry-run] would DM ..."
lines name the right people. Both secrets and all IDs are proven correct at
this point. Nothing was sent.*

**5.3 - Live DM smoke test (one person only).** In `config.json`, temporarily
change ONE audience to `{ "user_ids": ["YOUR_OWN_DISCORD_USER_ID"] }` (right-
click your name -> Copy User ID), commit, and Run workflow with mode
`reminders`, dry_run OFF, while you are not signed up to that team's event.
*Pass: exactly one DM arrives, to you, with correct event title, local time,
and a working signup link. The run's final commit updates `state.json`.*

**5.4 - Duplicate suppression.** Run the workflow again with the same settings.
*Pass: log says nothing new to send; no second DM.*

**5.5 - Announcement smoke test.** Within 15 minutes before a raid start
(or create a throwaway test event starting in ~10 minutes), Run workflow with
mode `announcements`, dry_run OFF.
*Pass: one message appears in the event's signup channel pinging @raiders
with the "Raid invites has started..." text. Re-running posts no duplicate.*

**5.6 - Restore the real config.** Revert the 5.3 audience change, commit.
*Pass: `config.json` matches section 4 again.*

**5.7 - Done.** Leave the workflow enabled. From here on: signups create
themselves (Raid-Helper recurring events), Friday 5PM ET the non-signers get
their digest DM, 8:15 PM the invite announcement posts, attendance tracks
in Raid-Helper. Zero manual steps per event.

*(Optional 5.8 - fallback ping: have a member disable "Direct Messages from
server members", leave them unsigned, run reminders. Pass: they get publicly
pinged in the fallback channel instead.)*

---

## 6. Also verify in Raid-Helper itself (no code - probably already done)

- [ ] Each raid night exists as a **weekly recurring event** posting into the
      right team's signup channel (premium feature).
- [ ] Events have `< response: ... >` set so sign-ups get the gear/consumes DM
      (premium advanced setting).
- [ ] `attendance` is on (default) - optionally tag per team
      (`< attendance: teamA >`) for per-team `/attendance` stats.

Details for all three: [GUIDE.md section 2](GUIDE.md).

---

## 7. Ownership transfer (when handing the repo over)

1. Repo -> Settings -> General -> Danger Zone -> **Transfer ownership** to the
   new owner's GitHub account.
2. New owner: re-add the two secrets (section 3) - secrets do not transfer.
3. New owner: confirm the workflow is still enabled (Actions tab) and click
   Run workflow -> dry_run as a sanity check.
4. Optional: previous owner deletes their local clone; nothing secret is in it.

Day-to-day ownership = editing `config.json` (roles, times, wording) and
reading the Actions log when curious. The operations reference, including
pausing, secret rotation, and the troubleshooting table, is
[GUIDE.md section 8](GUIDE.md).
