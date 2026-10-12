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
the template." Claude sets up the app in a
PR, then walks you through steps 3–8 one at
a time. They're here for reference; steps
3–8 can wait until you want the app on your
phone.

## 3. Find your Team ID
Skip if you have it from an earlier app.
1. Open developer.apple.com/account and
   sign in.
2. Scroll to **Membership details** and
   copy the **Team ID** (10 characters,
   like `AB12CD34EF`) into Notes.

## 4. Register the bundle ID
1. Open
   developer.apple.com/account/resources/identifiers.
2. Tap **+** → **App IDs** → Continue →
   **App** → Continue.
3. Description: `QuestLog`. Bundle ID:
   **Explicit**, `com.gastly92.questlog`.
4. Tap Continue → **Register**.

## 5. Create the app in App Store Connect
1. Open appstoreconnect.apple.com →
   **Apps** → **+** → **New App**.
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
1. In App Store Connect: **Users and
   Access** → **Integrations** → **App
   Store Connect API** → **Team Keys** →
   **+**.
2. Name: the app's name. Access:
   **Admin**. Tap **Generate**.
3. Copy the **Issuer ID** (above the list;
   the same for every key) and the new
   key's **Key ID** into Notes.
4. Tap **Download** next to the key.
5. In the **Files** app → Downloads, rename
   `AuthKey_….p8` to end in `.txt`, open
   it, and copy all its text (including the
   `-----BEGIN` and `-----END` lines).

## 7. Add the four GitHub secrets
1. Open the repo on github.com →
   **Settings** → **Secrets and variables**
   → **Actions**.
2. Tap **New repository secret** for each:

| Name | Value |
|---|---|
| `APPLE_TEAM_ID` | Team ID (step 3) |
| `ASC_ISSUER_ID` | Issuer ID (step 6) |
| `ASC_KEY_ID` | Key ID (step 6) |
| `ASC_KEY_P8` | Key text (step 6) |

Then delete the key file from Files.

## 8. Build and install
1. In App Store Connect, open the app →
   **TestFlight** → **Internal Testing** →
   **+**, name the group `Me`, and add
   yourself.
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
   `scripts/setup-app.sh QuestLog`. It
   replaces the template's files with the
   app (the sample renamed, pinned to the
   newest template version) and fetches
   the template into `.template/`.
3. Fill in CLAUDE.md's "This app" section,
   run `.template/scripts/swiftlint.sh`,
   commit, push and open a PR. CI records
   the starting snapshots in a bot commit
   (no need to approve the duplicate run).
   Get CI green; the user merges.
4. Ask whether to set up TestFlight now.
   If so, walk the user through steps 3–8
   above one at a time, waiting
   for each to be done; never ask for the
   secrets' values. Then trigger the
   TestFlight workflow and check the log
   for "Upload succeeded".
