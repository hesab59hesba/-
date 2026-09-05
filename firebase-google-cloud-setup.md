# Firebase + Google Cloud + EAS — full setup runbook

Rebuild this exact backend step by step. Values for our project are inline;
replace them when reusing this for another project. Secrets are referenced,
never pasted.

Our values: project `individual-marketplace` (#626375321105) · package
`com.modather.individualmarketplace` · owner `modather` · Expo project id
`e46e6404-2aff-46c4-8d12-6be4f6723de1`.

---

## Part A — Firebase console (console.firebase.google.com)

### A1. Create the project + apps
1. Add project → name `individual-marketplace` → Spark plan, no Analytics needed.
2. Project settings → Add app → **Web** (`</>`), nickname anything → copy the
   `firebaseConfig` into `.env` as `EXPO_PUBLIC_FIREBASE_*` (see §Env below).
3. Add app → **Android**: package `com.modather.individualmarketplace`.
   Add the SHA-1 (Part C) here too once known → download
   **`google-services.json`** → place at **project root** (required at build
   time; keep untracked). Rebuild after adding/changing it — it bakes in.

### A2. Authentication → Sign-in method
1. Enable **Email/Password**.
2. Enable **Google** (no extra config here; OAuth lives in Google Cloud).

### A3. Firestore Database
1. Create database → **production mode** → region closest to users (`nam5`).
2. Rules tab → paste `firestore.rules` → Publish (or CLI below).
3. Storage: **skip** — new projects require Blaze billing for buckets; photos
   use Cloudinary instead (Part D).

### A4. Deploy rules/indexes from CLI (repo root)
```bash
firebase login --no-localhost
firebase deploy --only firestore:rules --non-interactive
firebase deploy --only firestore:indexes --non-interactive
```
`firebase.json` already maps both files. Verify: console → Firestore →
Rules/Indexes, or watch app logs for permission errors.

## Part B — Google Cloud console (console.cloud.google.com, same project)

### B1. Auth Platform → Branding
Fill app name, support email, authorized domains (`expo.io`,
`individual-marketplace.firebaseapp.com`), developer contact. No logo needed
(uploading one forces verification).

### B2. Auth Platform → Audience
Publishing status **In Production** from day one (avoids test-user lockout).
External user type. No action later unless going to verification.

### B3. Auth Platform → Clients
1. **Web client** (auto-created by Google Service) → copy ID →
   `EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID`. Used by the expo-auth-session fallback.
2. **Create client → Android**: name anything, package
   `com.modather.individualmarketplace`, SHA-1 from Part C → copy the client
   ID → `EXPO_PUBLIC_GOOGLE_ANDROID_CLIENT_ID`. Used by the native SDK
   (primary path on dev builds).
3. After any client change: Google warns of multi-hour propagation — retest
   later before debugging further.

### B4. Auth Platform → Data Access
Add scopes the app requests (`openid`, `.../userinfo.email`,
`.../userinfo.profile`) so consent is clean. Unverified + Production shows an
"unverified app" notice — expected until verification (store launch track).

### B5. APIs & Services → Credentials (API keys)
The web/browser key used by the app must stay **unrestricted**: Android/iOS
app restrictions break the Firebase JS SDK on native (it cannot send cert
headers → `...-are-blocked` errors). Real protection = Firestore rules +
App Check (roadmap), not key restrictions.

### B6. IAM → Service accounts (push only)
1. Service account `firebase-adminsdk-fbsvc` → Keys → Add key → JSON.
   Private key stays in `~/ashared/` only — never chat, never repo.
2. Upload it via `eas credentials` → Android → push setup (interactive).
3. Login screen → Continue with Google → approve → lands in feed signed in.

### Verification checklist (dev build)
- `[auth] native google pressed` → account sheet → `[auth] google sign-in ok`
- `[push] token ok {hasToken: true}` + `[push] token saved`
- Cold restart restores the session (AsyncStorage persistence)

---

## Part G — Google sign-in: browser flow failed, native SDK fixed it

**Symptom (dev build, expo-auth-session browser flow):** tapping Continue with
Google opened the browser and died with bare `Error 400: invalid_request`
(Arabic UI included). No useful error detail.

**Ruled out with evidence** (request diagnostics logged from the app):
package `com.modather.individualmarketplace` ✓, standard native redirect
`com.modather.individualmarketplace:/oauthredirect` ✓, `responseType: code` ✓,
correct Android + Web client IDs ✓, clients exist ✓, branding/audience
(In Production) ✓.

**Root cause:** the browser-redirect OAuth handshake itself (SHA/cert matching
at the redirect step). Console config was correct throughout.

**Fix that worked:** `@react-native-google-signin/google-signin` (native SDK,
`lib/google-native.ts`, `GoogleSignInButton` tries native first, session
fallback second). Native one-tap sheet → ID token → `signInWithCredential`.
Requires a dev build (native module). Verified: `hasIdToken: true` →
credential ok → session + push token, first try.

**Rule of thumb:** on Expo, prefer the native Google SDK on dev builds; keep
expo-auth-session only as a fallback. Never debug a bare `invalid_request`
past config verification — switch transports instead.

## Appendix — values record

```text
FIREBASE_API_KEY=AIzaSyA8Aa4j_VY6ax9FMwH_N08WsxVQNWArimg
FIREBASE_AUTH_DOMAIN=individual-marketplace.firebaseapp.com
FIREBASE_PROJECT_ID=individual-marketplace
FIREBASE_STORAGE_BUCKET=individual-marketplace.firebasestorage.app
FIREBASE_SENDER_ID=626375321105
FIREBASE_APP_ID=1:626375321105:web:f5149844030380030cb3b0
GOOGLE_WEB_CLIENT_ID=626375321105-qm6dioiq42ush2tc07vemttbqic4a23r.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=626375321105-5pmjvdcpc5skri5m56d8m9br69nr2cke.apps.googleusercontent.com
ANDROID SHA-1=26:4A:70:31:86:CD:45:EB:84:FF:8B:C3:1D:AA:1F:B7:09:C2:5E:D1
CLOUDINARY_CLOUD=bfi8wsl7 / PRESET=Individual marketplace (unsigned, images ≤10 MB)
```

## Security notes

- Cloudinary API secret was pasted in chat once → regenerate at Cloudinary
  dashboard → API Keys. App uses the unsigned preset only.
- FCM private key: `~/ashared/` only, uploaded to Expo, never repo/chat.
- `google-services.json`: project root, untracked, rebuild to take effect.
1. IAM & Admin → Service accounts → `firebase-adminsdk-fbsvc` → Keys →
   Add key → JSON. **Private key: `~/ashared/` only, never chat/repo.**
2. It is consumed via `eas credentials` → Android → push setup (interactive).

## Part C — EAS (builds, credentials, OTA)

### C1. One-time CLI setup (repo root)
```bash
npm install -g eas-cli
eas login            # interactive, Expo account (owner must match app.json)
```
`eas.json` (committed): development (dev-client APK) / preview (APK) /
production (AAB). Root `.npmrc` pins `legacy-peer-deps=true` — cloud
`npm ci` fails without it (EASERORED the first build in "Install dependencies").

### C2. SHA-1 fingerprint (needed by B3 + Firebase Android app)
expo.dev → project → Credentials → Android keystore → copy SHA-1.
(Command line can't fetch it — the credentials command is prompt-only.)

### C3. Trigger builds
```bash
eas build --profile development --platform android --non-interactive --no-wait
eas build:list --limit 2        # watch status
```
Free quota: 15 Android + 15 iOS / month. Daily work stays in Expo Go;
rebuild only for native changes (deps, permissions, google-services, icons).

### C4. Install + connect
Install the APK → `npx expo start --dev-client` → open the dev build
(not Expo Go). First launch after native changes always needs `--clear` on
the Metro side? No — dev builds load JS from Metro; only `.env`/config edits
need it.

### C5. OTA channels (created: development/preview/production)
```bash
eas update --branch preview --message "what changed"
```
Requires `runtimeVersion` policy (set: `appVersion`) + updates URL from
`eas init` linkage. Drill once on the dev build before relying on it.

## Part D — Cloudinary photos (why + how)

Firebase Storage needs Blaze on new projects → photos use Cloudinary free
(25 credits/mo, no card): dashboard → Settings → Upload → Add preset
(**Unsigned**) → restrict formats jpg/png/webp, size ≤10 MB → cloud name +
preset name into `.env`. App uploads base64 data-URIs (FormData parts and
`fetch().blob()` are broken on RN 0.86 — verified). Secret never ships.

## Part E — `.env` shape (`.env.example` is the template)

```text
EXPO_PUBLIC_FIREBASE_API_KEY=...
EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN=...
EXPO_PUBLIC_FIREBASE_PROJECT_ID=...
EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET=...
EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
EXPO_PUBLIC_FIREBASE_APP_ID=...
EXPO_PUBLIC_CLOUDINARY_CLOUD_NAME=...
EXPO_PUBLIC_CLOUDINARY_UPLOAD_PRESET=...
EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID=...
EXPO_PUBLIC_GOOGLE_ANDROID_CLIENT_ID=...
EXPO_PUBLIC_SENTRY_DSN=...        # optional, activates crash reporting
```
Always restart Metro with `--clear` after editing (vars inline at bundle).

## Part F — First-run verification (dev build, from Metro logs)

1. Boot: `[auth] RN persistence helper {hasHelper: true}`,
   `[auth] storage probe {ok: true}`, branded splash.
2. Email login → session uid, profile doc + public mirror sync.
3. Google button → `[auth] native google pressed` → sheet →
   `[auth] google sign-in ok` → feed, signed in.
4. Publish with photo → `[cloudinary] status 200` → `[firestore] published ok`
   → appears in feed (`· live`).
5. Second device → chat → messages both ways → meetup propose/accept.
6. Push: `[push] token ok {hasToken: true}` + `[push] token saved
