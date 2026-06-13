# Metro Networking Under Cloud-Mac NAT

## Symptom
Simulator/device can't reach Metro on a rented/cloud Mac. Red screen "Could not connect to development server", or the bundler advertises a LAN/private IP the client can't route to.

## Root cause
- Cloud Macs sit behind NAT; the Mac's primary interface IP is not reachable from where the simulator thinks it is, and Expo auto-detects that unreachable LAN IP as the packager host.
- `expo start --localhost` does NOT fix this: it binds the packager to `localhost`, which on macOS resolves to IPv6 `[::1]` only. React Native's client connects over IPv4 `127.0.0.1`, so it gets connection-refused even when "localhost" looks right.

## Fix
Force the advertised host to the IPv4 loopback explicitly:

```bash
REACT_NATIVE_PACKAGER_HOSTNAME=127.0.0.1 npx expo start
```

- Use `REACT_NATIVE_PACKAGER_HOSTNAME`, never `--localhost`. The env var controls the host baked into the bundle URL the client fetches; `127.0.0.1` is what the on-Mac simulator can actually reach.
- This is for the simulator running ON the same Mac. A physical device over the network needs a tunnel (`--tunnel`) or a reachable public host instead — `127.0.0.1` only works for the local simulator.
- Set it in the shell/profile or the start script on the Mac so every `expo start` inherits it.
