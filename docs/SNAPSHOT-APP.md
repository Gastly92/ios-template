# Snapshot app

When CI records new snapshot images, it
pushes them to the PR branch. A push made
with CI's own token (`GITHUB_TOKEN`) starts
no CI run; since June 2026 GitHub instead
holds one behind "Approve and run". So CI
pushes with a token from a small GitHub App
installed on the repo: that push starts CI
like any other. Each run gets a one-hour
token from the app's key
(`actions/create-github-app-token`).

Without the app's secrets (or on Dependabot
PRs, which can't read them),
`save-snapshots.sh` pushes with CI's own
token and starts the run itself, and
GitHub's held run shows "Approve and run":
it needs no approval.

One app serves every repo: create it once,
then add each repo to it.

## Creating the app (once)
1. Open github.com/settings/apps/new.
2. Name: your username and what it does,
   e.g. `gastly92-snapshots` (names are
   unique across GitHub). Homepage URL:
   your GitHub profile.
3. Webhook: untick **Active**.
4. Repository permissions → **Contents**:
   **Read and write**. Leave the rest.
5. Where can it be installed: **Only on
   this account**. Tap **Create GitHub
   App**.

## Adding a repo
1. Give the app access to the repo:
   - The first time: on the app's page
     (github.com/settings/apps → the
     app), **Install App** → **Install** →
     **Only select repositories** → pick
     the repo → **Install**.
   - Once it's installed: open
     github.com/settings/installations,
     tap **Configure** next to the app,
     and under **Repository access** →
     **Select repositories**, add the repo,
     then tap **Save**.
2. On the app's page
   (github.com/settings/apps → the app),
   note its **App ID** on **General**,
   then open **Credentials** → **Key
   pairs** → **New key** (a `.pem` file
   downloads). Each repo gets its own
   key, so one can be deleted without
   touching the others.
3. In the repo: Settings → Secrets and
   variables → Actions → New repository
   secret:
   - `SNAPSHOT_APP_ID`: the App ID.
   - `SNAPSHOT_APP_KEY`: all the text of
     the `.pem` file (in Files, rename it to
     end in `.txt` to open it), including
     the `-----BEGIN` and `-----END` lines.
4. Delete the `.pem` file from Files.

If a key is ever lost or leaked, make a
new one (**Credentials** → **Key pairs**
on the app's page), update that
repo's `SNAPSHOT_APP_KEY`, and delete the
old key.
