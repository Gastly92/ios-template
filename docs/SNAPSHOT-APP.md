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
1. Open https://github.com/settings/apps/new
2. Name: your username and what it does,
   e.g. `gastly92-snapshots` (names are
   unique across GitHub). Homepage URL:
   your GitHub profile.
3. Webhook: untick **Active**.
4. Repository permissions → **Contents**:
   **Read and write**, and **Pull
   requests**: **Read and write** (to open
   the iOS update PRs,
   docs/IOS-UPDATES.md). Leave the rest.
5. Where can it be installed: **Only on
   this account**. Tap **Create GitHub
   App**.

## Adding a repo
1. Give the app access to the repo:
   - The first time: on the app's page
     (https://github.com/settings/apps →
     the app), **Install App** →
     **Install** → **Only select
     repositories** → pick the repo →
     **Install**.
   - Once it's installed: open
     https://github.com/settings/installations,
     tap **Configure** next to the app,
     and under **Repository access** →
     **Select repositories**, add the repo,
     then tap **Save**.
2. Make the repo its own key: on the app's
   page (https://github.com/settings/apps
   → the app) → **Credentials** → **Key
   pairs** → **New key** (a `.pem` file
   downloads). In Files, rename it to end
   in `.txt`. Each repo gets its own key,
   so one can be deleted without touching
   the others.
3. Add two secrets at
   `https://github.com/<owner>/<repo>/settings/secrets/actions/new`,
   copying each value just before pasting
   it:

   Name:
   ```
   SNAPSHOT_APP_ID
   ```
   Value: the **App ID**, on the app's
   page under **General**.

   Name:
   ```
   SNAPSHOT_APP_KEY
   ```
   Value: all the text of the `.pem` file,
   including the `-----BEGIN` and
   `-----END` lines.
4. Delete the `.pem` file from Files.

## Adding a permission later
On the app's page
(https://github.com/settings/apps → the
app → **Permissions & events**),
change the permission and tap **Save
changes**. Then open
https://github.com/settings/installations, tap
**Configure** next to the app and accept
the new permissions: until then, the app's
tokens don't have them.

If a key is ever lost or leaked, make a
new one (**Credentials** → **Key pairs**
on the app's page), update that
repo's `SNAPSHOT_APP_KEY`, and delete the
old key.
