# GitHub Basics — read this first if GitHub is new to you

You do NOT need to know programming or "git" to own this project. Everything
you will ever do happens **in your web browser, on this website, with normal
buttons**. Nothing to install. This page is the only GitHub knowledge you
need — five minutes, once.

---

## What is GitHub, for our purposes?

Think of this GitHub page as two things in one:

1. **A shared folder** holding the project's files (the script, the settings,
   the guides you're reading now), with a full history of every change ever
   made — who changed what, when, and you can always undo.
2. **A robot that runs the script on a schedule** (GitHub calls this
   "Actions"). GitHub's computers wake up, run our reminder script, write
   down what happened, and go back to sleep. Your computer is never involved.

That's it. GitHub does many other things for programmers — you can ignore
all of them.

## The five words you'll see

| Word | What it actually means here |
|---|---|
| **Repository / "repo"** | The project folder. This whole page. |
| **Commit** | "Save." Every save gets a note describing the change, forever visible in the history. When a guide says "edit and commit," it means "edit and click Save." |
| **Actions** | The tab where the robot lives. Every run is listed with a full log of what it did. |
| **Workflow** | The robot's schedule ("run every 15 minutes", "run Friday 5PM"). Already written — you just switch it on or off. |
| **Secret** | A password-style value (like the bot token) stored in a locked box the robot can use but nobody — not even you — can read back out. |

## The only four things you'll ever do

### 1. Read files
Click a file's name to read it. Folders open like folders. (You're probably
reading `docs/GITHUB-BASICS.md` right now.)

### 2. Edit a file (this is how ALL settings changes work)
1. Click the file (you'll only ever edit `config.json`).
2. Click the **pencil icon** (top-right of the file view).
3. Make your change in the text box.
4. Click the green **Commit changes...** button, optionally type a short note
   ("changed reminder time"), confirm.

Done — the robot uses the new settings on its next run. If you ever make a
mistake, the **History** button on any file shows every old version.

### 3. Add the two secrets (one time)
1. Click **Settings** (the tab on THIS project page, with a gear icon — not
   your account settings).
2. Left sidebar: **Secrets and variables → Actions**.
3. Green **New repository secret** button. Name: `DISCORD_BOT_TOKEN`, paste
   the value, save. Repeat for `RAIDHELPER_API_KEY`.

### 4. Use the Actions tab (check on the robot / test safely)
- Click **Actions** (top tab) → "Send signup reminders" on the left.
- Every past run is listed. Click one, click the job, and read the log —
  it says in plain words what it did ("3 missing, DM sent to ...").
- **Run workflow** (right side, grey button) starts a run *right now* —
  tick **dry_run** and it only *prints* what it would send, sending nothing.
  This is your safe test button; use it as often as you like.
- The "..." menu next to the workflow enables/disables the schedule
  (it starts disabled until setup is finished).

## Getting an account (if you don't have one)

github.com → Sign up → free account. Then the current owner adds you or
transfers the project to you (Settings → Collaborators, or Settings →
Transfer ownership). Everything above works the same either way.

## Can I break something?

Practically no:
- Every change is saved in history and can be undone.
- Secrets can't be leaked by reading the site — they're write-only.
- The robot can't send duplicate messages (it keeps a logbook, `state.json`).
- Worst realistic mistake: a typo in `config.json` makes a run fail — the
  Actions log shows a clear error message, you fix the typo, done. Nobody
  gets spammed by a failure; a failed run sends nothing.

**Next step:** open [HANDOFF.md](HANDOFF.md) — the full checklist of what's
left to do, in order.
