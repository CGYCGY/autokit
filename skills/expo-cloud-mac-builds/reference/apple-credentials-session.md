# Apple Credentials From a Cloud Mac (IP block + headless session)

Two distinct failures share the cloud-Mac root cause. They are independent — you can hit either or both.

## A. Datacenter IP blocked by Apple, disguised as "wrong password"
### Symptom
Apple Developer / App Store Connect login, or `eas credentials` Apple auth, reports an incorrect username/password — but the credentials are correct and work from your laptop.

### Root cause
Apple silently blocks/risk-flags logins from datacenter/hosting IP ranges (where rented Macs live) and surfaces it as a generic password failure rather than an explicit block. No amount of re-typing fixes it.

### Fix
- Run any step that authenticates to Apple (Apple ID login, `eas credentials`, fetching/creating certs & provisioning profiles through Apple) from a residential/home IP — your own machine — not from the cloud Mac.
- Generate/sync the credentials elsewhere, then let EAS use the stored credentials for the actual build on the Mac. The build itself doesn't re-authenticate to Apple interactively.

## B. SSH session has no macOS keychain / security session
### Symptom
Cert import, `security` keychain operations, or `eas build --local` fail — frequently at the `PREPARE_CREDENTIALS` step — when run over plain SSH/Termius.

### Root cause
A bare SSH login is not a full macOS GUI login session: it lacks an unlocked login keychain and the Security Server session that signing/credential import require. The tooling can't reach the keychain, so credential prep aborts.

### Fix
- Run cert import and `eas build --local` from a GUI Terminal inside a graphical session — AnyDesk / VNC / Screen Sharing into the Mac's desktop — not from SSH.
- Inside the GUI session the login keychain is unlocked and the security session exists, so `PREPARE_CREDENTIALS` and local signing succeed.
- Reserve SSH for non-keychain work (editing, `expo start`, log tailing).
