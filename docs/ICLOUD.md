# Adding iCloud sync (CloudKit)

How to make an app's SwiftData store sync
through the user's own private iCloud,
from an iPhone only (no Mac). Learned
building One Hundo 1.1 (gastly92/one-hundo:
its `docs/ICLOUD.md` and `docs/CLOUDKIT.md`
are the worked example, with the code).
`Sample` doesn't sync, so nothing here is
in the template's code: copy the pieces
when an app needs them.

Plan it as a short PR series: signing,
duplicates and schema, sync on, the
CloudKit schema, the first-launch wait,
then the release docs.

## 1. Signing (owner, then a PR)
1. In the developer portal
   (developer.apple.com/account →
   Identifiers), open the app's ID and
   tick **iCloud** (with CloudKit) and
   **Push Notifications**. Under iCloud,
   create and tick a container,
   `iCloud.<bundle ID>`.
2. Add `<App>/<App>.entitlements` with
   `aps-environment` (`development`),
   `com.apple.developer.icloud-container-identifiers`
   (the container) and
   `com.apple.developer.icloud-services`
   (`CloudKit`), and point
   `CODE_SIGN_ENTITLEMENTS` at it in
   `project.yml`.
3. Add `remote-notification` to
   `UIBackgroundModes` so changes arrive
   while the app is closed. That key
   can't be an `INFOPLIST_KEY_*`: put it
   in `<App>/Info.plist` (`INFOPLIST_FILE`
   in `project.yml`; the generated keys
   still merge in).
4. The TestFlight workflow archives with
   `CODE_SIGNING_ALLOWED=NO`, so the app
   has no entitlements. After archiving,
   sign it ad hoc with them
   (`codesign --force --sign -
   --entitlements <file>
   --generate-entitlement-der <app>`);
   export keeps what it finds and
   re-signs for the App Store, setting
   iCloud and push to Production.
5. Check it: a small script runs
   `codesign -d --entitlements - --xml`
   on the app and fails without the
   container, `CloudKit` and
   `aps-environment`. Run it after
   signing, and on the exported `.ipa`
   with an `upload: false` workflow input
   (build and check, no upload). CI's
   unsigned builds can't tell.

## 2. The store
- `ModelConfiguration(cloudKitDatabase:
  .automatic)` for the on-disk store
  (`.automatic` is the default, so a
  signed build syncs unless told not
  to); `.none` for in-memory stores (UI
  and snapshot tests).
- No entitlement (CI), no iCloud account,
  iCloud off for the app, or iCloud full:
  the store works on the phone alone, no
  code needed.
- CloudKit's rules for models: every
  property optional or with a default, no
  `@Attribute(.unique)`, relationships
  optional. Production can only grow:
  add fields, never rename or remove.

## 3. Duplicates
Two devices, or a restored backup, can
hold the same record twice. Merge them on
every change and when the store opens:
- Give each record a `copyID` (a UUID
  that never changes). Every device keeps
  the lowest and deletes the rest. Two
  devices keeping different copies would
  each delete the other's, losing both.
  Copies with no tag, or sharing one, are
  left alone.
- Add the tag in the schema version that
  turns sync on, and tag existing data in
  its migration on each device, before it
  can sync, so two devices' copies never
  share a tag.
- To decide which edit wins, store when
  it was made (`loggedAt`); same moment:
  a fixed rule (e.g. the higher count).
- Unit test it with two copies in an
  in-memory store.

## 4. Watching for changes
- Listen for `NSPersistentStoreRemoteChange`
  and `NSPersistentCloudKitContainer
  .eventChangedNotification` in an object
  `AppLaunch` keeps for the app's life:
  merge duplicates and redo anything
  derived (e.g. reschedule reminders),
  in the background too.
- Both are posted from background
  threads: the handler is `@Sendable`
  and hops to the main actor itself. A
  main-actor handler crashed under Swift
  6.
- Tests can't make a real
  `NSPersistentCloudKitContainer.Event`:
  read its `type` and `endDate` by
  key-value coding, and post an
  `NSObject` with the same `@objc`
  properties in tests.

## 5. The CloudKit schema (owner)
TestFlight and App Store builds always use
CloudKit's **Production** environment,
which only takes record types and fields
first made in **Development** and
deployed. Without that, sync quietly does
nothing. A Mac build normally makes them;
TestFlight can't (its export always sets
Production, even when asked for
Development). An ad hoc ("Release
Testing") build can:
1. A separate app ID,
   `<bundle ID>.schema`, with the same
   container: iOS won't install an ad hoc
   build over the TestFlight app without
   deleting it and its data.
2. Register the iPhone: ad hoc builds
   install only on registered devices,
   and iPhones don't show their UDID. A
   tiny web page with a configuration
   profile service reads it (One Hundo's
   `tools/udid`, a Cloudflare Worker;
   Cloudflare's own preview builds ignore
   watch paths, so preview it from CI
   instead).
3. A workflow builds it ad hoc for
   Development with
   `initializeCloudKitSchema` compiled in
   (it sends a sample of every field, so
   fields still empty are made too),
   checks it signed for Development, and
   publishes it as a release. The device
   page serves it as an `itms-services`
   install link.
4. On the phone: install, turn on
   **Developer Mode** (Settings → Privacy
   & Security; iOS opens ad hoc apps only
   with it, after a restart), open it on
   Wi-Fi for a minute.
5. In the CloudKit Console
   (icloud.developer.apple.com, desktop
   site via **aA**), check the record
   types in Development, then **Deploy
   Schema Changes**. Delete the schema
   app.
Again whenever a schema version adds a
field. Data on a phone uploads only once
the schema is in Production and the app
runs.

## 6. The first launch on a new phone
A reinstall or a new phone opens with an
empty store while iCloud brings the data
in, so the app's first-run screen
(welcome, "create your first…") shows
for a second or two and invites a
returning user to start over. One Hundo
1.1.1:
- With an empty store at launch, ask
  iCloud whether this account has used
  the app: account status `.available`,
  then look up the zone
  `com.apple.coredata.cloudkit.zone`
  (owner `CKCurrentUserDefaultName`). It
  exists once the app has synced.
- Meanwhile keep the launch screen's
  picture over the app. "No" (or offline,
  signed out, an error): the first-run
  screen at once, no message. "Yes": the
  picture stays until the first import
  ends (an import event with an end
  date).
- Limits so it never hangs: 3 s for the
  answer, 4 s for the data; past those,
  the first-run screen with a quiet
  "Still checking iCloud…" note when the
  answer was yes (gone after 30 s).
- Users found a message and buttons
  ("Restore" / "Start new") odd; most
  apps say nothing for a second or two.
- `CKContainer` crashes builds without
  the entitlement, like CI's: only builds
  with an Info.plist flag set by the
  TestFlight archive (`MYAPP_CLOUDKIT=YES`
  on the `xcodebuild` line, `NO` in
  `project.yml`) ask. Tests pass fake
  accounts through two small protocols
  that `CKContainer` and `CKDatabase`
  already meet (empty extensions), so no
  app line needs real iCloud.

The launch picture:
- The launch screen (`UILaunchScreen` in
  Info.plist, `UIImageName`) centres its
  picture at its own size, never
  stretched. For a full-screen look, make
  it as big as the largest iPhone
  (440×956 pt, @2x and @3x); smaller
  phones crop the edges. Draw it in the
  app the same way: `Color.clear
  .overlay { Image(...) }
  .ignoresSafeArea()`.
- Light and dark variants go in one
  image set. Turn on
  `ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS`
  for `Image(.name)` (SwiftLint's
  `prefer_asset_symbols`).
- iOS keeps an old launch screen until
  the app is reinstalled.
- It shows on every cold start, like
  Spotify's. A bold picture makes that
  visible; the generated blank one hides
  it.

## 7. Release
- App Privacy can stay "Data Not
  Collected": the data is in the user's
  private database, which the developer
  can't see.
- Update `site/privacy.html` (where the
  data lives, how to stop syncing and
  delete it), the App Store description,
  What's New and the review notes, and
  publish the privacy page before App
  Review reads it.
- Settings: iCloud is on by default and
  turned off in iOS Settings (your name →
  iCloud); no switch in the app needed.

## Checking by hand
- CloudKit Console → container →
  **Prod** → **Act As iCloud Account…**
  (the phone's Apple ID) → **Records** →
  **Private Database**, zone
  `com.apple.coredata.cloudkit.zone`,
  then **Fetch Changes**. Query Records
  fails ("Field 'recordName' is not
  marked queryable").
- On the phone: old data opens with sync
  on; a change survives reopening;
  deleting and reinstalling brings it all
  back; two phones on one Apple ID see
  each other's changes, including the
  same day changed on both while one is
  offline.
- iCloud sync isn't the phone's iCloud
  backup: it uploads within seconds,
  while the backup runs overnight.
