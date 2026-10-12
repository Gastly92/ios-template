# Starting a new app

Everything here works on an iPhone: GitHub
in Safari or the GitHub app, App Store
Connect in Safari, and Claude Code. Steps
1–3 make the app and its CI; steps 4–9 set
up TestFlight, and can wait until you want
the app on your phone.

`QuestLog` stands for your app's name below:
one word, starting with a capital letter.
Its bundle ID is `com.gastly92.questlog`
(the name in lower case).

## 1. Create the repo
1. In Safari, open github.com/new.
2. Name it (e.g. `quest-log`), pick Public
   or Private, and tick **Add a README
   file**.
3. Tap **Create repository**.

## 2. Ask Claude to set it up
1. Start a Claude Code session on the new
   repo.
2. Send: "Set this repo up as a new app
   called QuestLog from
   gastly92/ios-template, following its
   docs/NEW-APP.md."

Claude then (step 3 is its part):

## 3. What Claude does
1. Clones gastly92/ios-template (it's
   public) and runs
   `scripts/new-app.sh QuestLog <repo>`:
   the sample app, renamed, pinned to the
   newest template version, with CI,
   TestFlight and Dependabot set up.
2. Fills in the app's CLAUDE.md with what
   you've said the app is for.
3. Opens a PR. CI records the starting
   snapshots in a bot commit (no need to
   tap "Approve and run"). Once green,
   you merge it.

From then on, every session in the repo
fetches the template and its rules
automatically.

## 4. Find your Team ID
Skip if you have it from an earlier app.
1. Open developer.apple.com/account and
   sign in.
2. Scroll to **Membership details** and
   copy the **Team ID** (10 characters,
   like `AB12CD34EF`) into Notes.

## 5. Register the bundle ID
1. Open
   developer.apple.com/account/resources/identifiers.
2. Tap **+** → **App IDs** → Continue →
   **App** → Continue.
3. Description: `QuestLog`. Bundle ID:
   **Explicit**, `com.gastly92.questlog`.
4. Tap Continue → **Register**.

## 6. Create the app in App Store Connect
1. Open appstoreconnect.apple.com →
   **Apps** → **+** → **New App**.
2. Platform **iOS**; name it (if the name
   is taken, add a word; you can change it
   later); pick the bundle ID from step 5;
   SKU: `questlog`; **Full Access**.
3. Tap **Create**.

## 7. Create an API key
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

## 8. Add the four GitHub secrets
1. Open the repo on github.com →
   **Settings** → **Secrets and variables**
   → **Actions**.
2. Tap **New repository secret** for each:

| Name | Value |
|---|---|
| `APPLE_TEAM_ID` | Team ID (step 4) |
| `ASC_ISSUER_ID` | Issuer ID (step 7) |
| `ASC_KEY_ID` | Key ID (step 7) |
| `ASC_KEY_P8` | Key text (step 7) |

Then delete the key file from Files.

## 9. Build and install
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

Later builds: just step 9.2.
