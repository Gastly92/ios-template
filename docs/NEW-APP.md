# Starting a new app

Everything here works on an iPhone: GitHub
in Safari or the GitHub app, App Store
Connect in Safari, and Claude Code.

`QuestLog` stands for your app's name below:
one word, starting with a capital letter.
Its bundle ID is `com.gastly92.questlog`
(the name in lower case).

## 1. Make the repo from the template
1. In Safari, open
   github.com/gastly92/ios-template.
2. Tap **Use this template** → **Create a
   new repository**. (If it's missing, the
   template's Settings → General →
   **Template repository** isn't ticked.)
3. Name it (e.g. `quest-log`), pick Public
   or Private, and tap **Create
   repository**.

## 2. Ask Claude
Start a Claude Code session on the new repo
and send: "Help me set this repo up using
the template." Claude sets up the app, walks
you through the GitHub settings (step 3)
one at a time, mostly before opening the
setup PR, then opens it; the steps are
here for reference.
Steps 4–8 (TestFlight) can wait until you
want the app on your phone.

## 3. GitHub settings
GitHub doesn't copy a template's settings,
so each new repo needs these once. Do the
first three before the setup PR is pushed:
they don't need CI, and missing them shows
up on that PR (an "Approve and run" button,
a failed Pages publish when it merges). The
last needs the setup PR's CI to have run
once: its check only shows in the list
after that.

First, so snapshot images CI records start
CI by themselves (no "Approve and run"):
install the snapshot app on the repo and
add its two secrets
([SNAPSHOT-APP.md](SNAPSHOT-APP.md)).
Without it CI still works, but every
recording holds a run behind "Approve and
run" (it needs no approval).

Then have merged PRs' branches deleted and
allow auto-merge:
1. **Settings** → **General** → the **Pull
   Requests** section (Find on page:
   "delete head").
2. Tick **Automatically delete head
   branches** and **Allow auto-merge**
   (each saves at once). Auto-merge lets
   a PR merge by itself once CI passes.

Then turn on the support pages (the App
Store asks for a support and a privacy
policy link):
1. **Settings** → **Pages** → Source:
   **GitHub Actions**.
2. Once the setup PR is merged, the pages
   are at `https://gastly92.github.io/quest-log/`
   and `.../privacy.html` (your repo's
   name in place of `quest-log`). If
   Pages was off when it merged, the
   publish failed: run it once by hand
   (**Actions** → **Pages** → **Run
   workflow**).

Last, once the setup PR's CI has run,
protect the main branch:
1. Open the repo on github.com →
   **Settings** → **Rules** → **Rulesets**
   → **New ruleset** → **New branch
   ruleset**.
2. Name: `main`. Enforcement status:
   **Active**.
3. Target branches: **Add target** →
   **Include default branch**.
4. Under Rules, keep **Restrict
   deletions** and **Block force pushes**
   ticked, and tick:
   - **Require a pull request before
     merging** (required approvals: 0).
   - **Require status checks to pass** →
     **Add checks** → type `Gate` and pick
     **CI Gate**.
5. Tap **Create**.

Every change to `main` then goes through a
PR, and a PR merges only when CI passes.

Renaming the repo later: GitHub redirects
the old name, but the support pages move
to the new one, so update the issue links
in `site/` and the URLs in App Store
Connect. A Claude Code cloud session
started under the old name can only push
through the old name.

## 4. Register the bundle ID
1. Open
   https://developer.apple.com/account/resources/identifiers/list
2. Tap **+** → **App IDs** → Continue →
   **App** → Continue.
3. Description: `QuestLog`. Bundle ID:
   **Explicit**, `com.gastly92.questlog`.
   Check the spelling: it can never
   change once the app exists.
4. Tap Continue → **Register**.

## 5. Create the app in App Store Connect
1. Open https://appstoreconnect.apple.com/apps
   and tap **+** → **New App**.
2. Platform **iOS**; name it (if the name
   is taken, add a word; you can change it
   later); pick the bundle ID from step 4;
   SKU: `questlog`; **Full Access**.
3. Tap **Create**.

## 6. Create an API key
GitHub can't copy secrets between repos,
and Apple lets you download a key only
once, so each app gets its own key. (That
also means one app's key can be revoked
without touching the others.)
1. Open
   https://appstoreconnect.apple.com/access/integrations/api
   → **Team Keys** → **+**.
2. Name: the app's name. Access:
   **Admin**. Tap **Generate**.
3. Tap **Download** next to the new key
   (only once). In the **Files** app →
   Downloads, rename `AuthKey_….p8` to
   end in `.txt`.

Nothing to copy yet: each value is copied
in step 7, just before it's pasted. Keep
this page open.

## 7. Add the four GitHub secrets
Add each one at
`https://github.com/<owner>/<repo>/settings/secrets/actions/new`
(Settings → Secrets and variables →
Actions → New repository secret): copy the
name below, then the value from where it
says, and tap **Add secret**. Don't paste
them anywhere else, a chat included.

Name:
```
APPLE_TEAM_ID
```
Value: the **Team ID**, from
https://developer.apple.com/account →
**Membership details** (10 characters,
like `AB12CD34EF`).

Name:
```
ASC_ISSUER_ID
```
Value: the **Issuer ID**, above the list
on the API keys page (step 6; the same
for every key).

Name:
```
ASC_KEY_ID
```
Value: the new key's **Key ID**, in its
row on that page.

Name:
```
ASC_KEY_P8
```
Value: all the text of the key file
(step 6), including the `-----BEGIN` and
`-----END` lines.

Then delete the key file from Files.

## 8. Build and install
1. In App Store Connect
   (https://appstoreconnect.apple.com/apps),
   open the app → **TestFlight** →
   **Internal Testing** → **+**, name the
   group `Me`, and add yourself.
2. Ask Claude to ship to TestFlight (or in
   the GitHub app: repo → **Actions** →
   **TestFlight** → **Run workflow**).
3. About 5 minutes for the run, then 5–15
   for Apple to process the build. Install
   it from the **TestFlight** app.

Later builds: just step 8.2.

## Setting up a new repo (for Claude)
When a repo made with "Use this template"
still holds the sample (the session start
hook says so):
1. Name the app from the repo name in
   UpperCamelCase (`quest-log` →
   `QuestLog`) and say what you chose; ask
   only if the repo name doesn't make a
   good app name. Ask in one line what the
   app is for.
2. On a new branch, run
   `.github/scripts/setup-app.sh QuestLog`.
   It renames the sample to the app,
   removes what only the template needs,
   and draws an icon from the name's first
   letter.
3. Fill in CLAUDE.md's "This app" section
   and the support page (`site/`) with
   what the app is for. Offer to redraw
   the icon (`app-icon.sh`). Run
   `.github/scripts/swiftlint.sh` and
   commit.
4. Before pushing, walk the user through
   the first three parts of step 3 (the
   snapshot app, branch deletion and
   auto-merge, Pages) in the chat, one at
   a time, waiting for each to be done.
   Listing them in the PR description is
   not walking through them. If the user
   would rather wait, say what skipping
   each costs, and carry on.
5. Push and open a PR. CI records the
   starting snapshots in a bot commit
   (with the snapshot app, its push
   starts CI; without it, the duplicate
   run held behind "Approve and run"
   needs no approval). Get CI green.
6. Once CI has run, walk the user through
   the main-branch ruleset (the last part
   of step 3), then the user merges. If
   Pages was on, check its publish
   succeeded after the merge.
7. Ask whether to set up TestFlight now.
   If so, walk the user through steps 4–8
   above one at a time, waiting for each
   to be done; never ask for the secrets'
   values. As in the guide: give each
   page's direct link, ask the user to
   copy a value only in the step that
   pastes it, and put every name or value
   they copy in its own code block (a
   table cell can't be copied on its
   own). Then trigger the
   TestFlight workflow and check the log
   for "Upload succeeded".
   No app made from the template has
   uploaded to TestFlight yet: watch the
   first run closely, and once it works,
   remove this note (here and in the
   template).
