---
module: rn-storage-crypto
language: typescript
category: platform
requires: []
conflicts: []
---

# RN Storage & Crypto Module

Storage and crypto on React Native: pick the right primitive per data class. The wrong choice is a security or perf bug, not just a style issue.

## Detection

```bash
grep "\"react-native-mmkv\":" package.json
grep "\"expo-secure-store\":" package.json
grep "\"react-native-quick-crypto\":" package.json
grep "\"expo-crypto\":" package.json
grep "\"@react-native-async-storage/async-storage\":" package.json
```

## Pattern Extraction Commands

```bash
# Storage usage
grep -rn "from ['\"]react-native-mmkv['\"]" --include="*.ts" --include="*.tsx"
grep -rn "from ['\"]expo-secure-store['\"]" --include="*.ts" --include="*.tsx"
grep -rn "from ['\"]@react-native-async-storage/async-storage['\"]" --include="*.ts" --include="*.tsx"  # legacy

# What's being stored where (audit)
grep -rEn "(setItem|set)\(['\"](token|jwt|secret|password|refresh|apiKey)" --include="*.ts" --include="*.tsx"

# Crypto usage
grep -rn "from ['\"]react-native-quick-crypto['\"]" --include="*.ts" --include="*.tsx"
grep -rn "from ['\"]expo-crypto['\"]" --include="*.ts" --include="*.tsx"
```

## Decision Matrix

| Data class | Use | Why |
|------------|-----|-----|
| Auth tokens (JWT, refresh) | `expo-secure-store` | Keychain (iOS) / Keystore (Android) hardware-backed |
| PII (email if not in token, payment refs) | `expo-secure-store` | Same |
| Encryption keys | `expo-secure-store` | Same |
| User prefs (theme, locale) | `react-native-mmkv` | Sync, fast, non-sensitive |
| Onboarding flags, last-seen | `react-native-mmkv` | Sync, no `await` in render paths |
| Form draft cache | `react-native-mmkv` | Sync write on each keystroke is fine |
| Zustand persist | `react-native-mmkv` adapter | Sync; matches Zustand's sync model |
| Bulk data (offline cache, query cache) | `react-native-mmkv` or file system | MMKV up to ~MBs; FileSystem for >10MB |
| Large blobs (images, downloads) | `expo-file-system` | Filesystem, not key-value |

| Crypto need | Use | Why |
|-------------|-----|-----|
| Hot path (per-message hash, KDF) | `react-native-quick-crypto` | Sync, JSI, no bridge cost |
| Async / one-shot (random bytes, hash) | `expo-crypto` | Simpler API, Expo SDK |
| Random IDs | `expo-crypto.randomUUID()` | Use this over `Math.random()` |

## Standards

| Pattern | Standard |
|---------|----------|
| Tokens | `SecureStore.setItemAsync` + `getItemAsync` — never MMKV |
| User prefs | MMKV sync API — no `await` |
| Zustand persist on RN | MMKV-backed `StateStorage` adapter |
| Web fallback | Guard with `Platform.OS !== 'web'` for SecureStore |
| Random | `expo-crypto.randomUUID()` / `getRandomBytes()` |
| Hashing | `quick-crypto` for repeated, `expo-crypto.digestStringAsync` for one-shots |

## Non-Obvious Anti-Patterns

```ts
// Storing auth tokens in MMKV / AsyncStorage (no keychain protection)
storage.set('jwt', token)  // ❌ Plaintext on disk
await SecureStore.setItemAsync('jwt', token)  // ✅ Hardware-backed

// Awaiting MMKV (it's sync — adds no safety, breaks render paths)
const value = await storage.getString('key')  // ❌ Returns Promise<undefined>
const value = storage.getString('key')  // ✅ Sync

// SecureStore for large values (silently truncates / fails — keychain has limits)
await SecureStore.setItemAsync('userProfile', JSON.stringify(bigObj))  // ❌ >2KB on iOS unreliable
// Fix: keep tokens in SecureStore, profile in MMKV

// SecureStore on web (throws — not implemented in expo-secure-store web)
const t = await SecureStore.getItemAsync('jwt')  // ❌ on Expo Web
// Fix: platform guard or use a web-safe wrapper
const t = Platform.OS === 'web'
  ? localStorage.getItem('jwt')   // separate web strategy
  : await SecureStore.getItemAsync('jwt')

// Math.random() for any security-sensitive value
const id = Math.random().toString(36)  // ❌ Predictable
const id = Crypto.randomUUID()  // ✅ expo-crypto

// AsyncStorage for perf-sensitive new code (not deprecated, but slower bridge)
await AsyncStorage.setItem('key', 'val')  // ⚠ Async bridge per call
storage.set('key', 'val')  // ✅ MMKV sync via JSI — preferred for new code

// Storing object directly in MMKV (no serialization → "[object Object]")
storage.set('user', { name: 'X' })  // ❌
storage.set('user', JSON.stringify({ name: 'X' }))  // ✅
const u = JSON.parse(storage.getString('user') ?? '{}')

// Re-creating MMKV instance per call (cheap but wasteful)
function read() {
  const s = createMMKV()  // ❌ New instance each read
  return s.getString('x')
}
// Fix: module-level singleton
export const storage = createMMKV()
```

## MMKV Setup

```ts
// lib/storage.ts — react-native-mmkv v4 (current). Requires react-native-nitro-modules.
import { createMMKV } from 'react-native-mmkv'

export const storage = createMMKV()
export const secureStorage = createMMKV({
  id: 'secure',
  encryptionKey: 'derived-at-runtime-from-keychain',  // not literal
})

// Delete a key with `.remove(key)` (v4), not `.delete(key)`.
// v3 used `new MMKV()` + `.delete()`; older projects on v3 keep that syntax.
```

## SecureStore Wrapper (web-safe)

```ts
import * as SecureStore from 'expo-secure-store'
import { Platform } from 'react-native'

export const secrets = {
  async get(key: string) {
    if (Platform.OS === 'web') return localStorage.getItem(key)
    return SecureStore.getItemAsync(key)
  },
  async set(key: string, value: string) {
    if (Platform.OS === 'web') {
      localStorage.setItem(key, value)
      return
    }
    return SecureStore.setItemAsync(key, value, {
      keychainAccessible: SecureStore.AFTER_FIRST_UNLOCK_THIS_DEVICE_ONLY,
    })
  },
  async delete(key: string) {
    if (Platform.OS === 'web') {
      localStorage.removeItem(key)
      return
    }
    return SecureStore.deleteItemAsync(key)
  },
}
```

## Zustand + MMKV Adapter

```ts
import { create } from 'zustand'
import { persist, createJSONStorage, type StateStorage } from 'zustand/middleware'
import { storage } from '@/lib/storage'

const mmkvStorage: StateStorage = {
  setItem: (name, value) => storage.set(name, value),
  getItem: (name) => storage.getString(name) ?? null,
  removeItem: (name) => storage.remove(name),  // v4: .remove() (v3 was .delete())
}

export const useAppStore = create<AppState>()(
  persist(
    (set) => ({ ... }),
    { name: 'app', storage: createJSONStorage(() => mmkvStorage), version: 1 }
  )
)
```

## Validation Checklist

- [ ] No tokens / refresh tokens / passwords in MMKV or AsyncStorage
- [ ] No `await` on MMKV calls
- [ ] SecureStore values stay small (<2KB) — large data → MMKV / FileSystem
- [ ] SecureStore calls guarded for web (or use a wrapper)
- [ ] No `Math.random()` for security values — use `expo-crypto`
- [ ] Zustand persist on RN uses MMKV adapter, not AsyncStorage
- [ ] MMKV instance is a module-level singleton
- [ ] Objects JSON-stringified before MMKV storage

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/rn-encryption.md` — MMKV encryption key derivation, key rotation
- `reference/rn-filesystem.md` — expo-file-system, downloads, scoped storage
