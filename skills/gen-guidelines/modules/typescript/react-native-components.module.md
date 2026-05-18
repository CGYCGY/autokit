---
module: react-native-components
language: typescript
category: framework
requires: [typescript-conventions]
conflicts: []
---

# React Native Components Module

For React Native projects (Expo or bare). Use **instead of** `react-components` — RN has no DOM, different primitives, and different perf model. Both can co-exist in a monorepo where they apply to different packages.

## Detection

```bash
grep "\"react-native\":" package.json
grep "\"expo\":" package.json
find . -maxdepth 3 -name "app.json" -o -name "app.config.*" -o -name "metro.config.*" 2>/dev/null
find . -name "*.ios.tsx" -o -name "*.android.tsx" -o -name "*.native.tsx" 2>/dev/null | head -5
```

## Pattern Extraction Commands

```bash
# Primitive usage
echo "View:"; grep -rn "<View" --include="*.tsx" | wc -l
echo "Text:"; grep -rn "<Text" --include="*.tsx" | wc -l
echo "Pressable:"; grep -rn "<Pressable" --include="*.tsx" | wc -l
echo "TouchableOpacity (legacy):"; grep -rn "<TouchableOpacity" --include="*.tsx" | wc -l

# List rendering audit
echo "FlatList:"; grep -rn "<FlatList" --include="*.tsx" | wc -l
echo "ScrollView with map:"; grep -rB2 "\.map(" --include="*.tsx" | grep -c "ScrollView"

# Platform splits
find . -name "*.ios.tsx" -o -name "*.android.tsx" -o -name "*.native.tsx" 2>/dev/null
grep -rn "Platform\.OS\|Platform\.select" --include="*.tsx" | head -10

# Reanimated worklets
grep -rn "useSharedValue\|useAnimatedStyle\|runOnJS\|runOnUI" --include="*.tsx"
grep -rn "'worklet'" --include="*.tsx"

# Safe area
grep -rn "useSafeAreaInsets\|SafeAreaView" --include="*.tsx"
```

## Standards

| Pattern | Standard |
|---------|----------|
| Touch target | `Pressable` (not `TouchableOpacity`/`Button`) |
| Lists > 20 items | `FlatList` / `FlashList` / `SectionList` (never `ScrollView` + `.map`) |
| Long-press / gestures | `react-native-gesture-handler` `Pressable`/`GestureDetector` |
| Images (Expo) | `expo-image` (caching) — fall back to `Image` for static assets |
| Safe area | `useSafeAreaInsets()` — avoid `SafeAreaView` (no per-edge control) |
| Platform branch | `Platform.select({ ios, android })` over `if (Platform.OS === ...)` |
| Platform-only file | `*.ios.tsx` / `*.android.tsx` for >20 lines of divergence |

## Non-Obvious Anti-Patterns

```tsx
// ScrollView + .map for long lists (renders all items, no recycling)
<ScrollView>
  {items.map(i => <Row key={i.id} item={i} />)}  // ❌ Memory + jank
</ScrollView>
// Fix: FlatList
<FlatList
  data={items}
  keyExtractor={i => i.id}
  renderItem={({ item }) => <Row item={item} />}  // ✅ Virtualized
/>

// Inline renderItem (re-creates fn each render → breaks FlatList memo)
<FlatList renderItem={({ item }) => <Row item={item} />} />  // ❌
// Fix: stable reference
const renderItem = useCallback(({ item }) => <Row item={item} />, [])
<FlatList renderItem={renderItem} />  // ✅

// FlatList without keyExtractor (uses index → broken updates on reorder)
<FlatList data={items} renderItem={renderItem} />  // ❌
<FlatList data={items} keyExtractor={i => i.id} renderItem={renderItem} />  // ✅

// runOnJS forgotten — worklet calls JS function directly (crashes)
const tap = Gesture.Tap().onEnd(() => {
  setCount(c => c + 1)  // ❌ JS fn on UI thread
})
// Fix:
const tap = Gesture.Tap().onEnd(() => {
  'worklet'
  runOnJS(setCount)(count + 1)  // ✅
})

// SafeAreaView wrapping the whole screen on Android (adds extra padding)
<SafeAreaView style={{ flex: 1 }}>...</SafeAreaView>  // ❌ Android already handles status bar
// Fix: useSafeAreaInsets for per-edge control
const insets = useSafeAreaInsets()
<View style={{ flex: 1, paddingTop: insets.top }}>...</View>  // ✅

// Image without cachePolicy on remote URI (refetches every mount)
<Image source={{ uri }} />  // ❌
<Image source={{ uri }} cachePolicy="memory-disk" />  // ✅ expo-image

// Text outside <Text> on Android (silent crash on RN < 0.73, warning after)
<View>Hello</View>  // ❌ String not wrapped
<View><Text>Hello</Text></View>  // ✅

// KeyboardAvoidingView with wrong behavior per platform
<KeyboardAvoidingView behavior="padding">  // ❌ Works iOS, broken Android
// Fix:
<KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>  // ✅
```

## List Component Template

```tsx
import { FlatList, type ListRenderItem } from 'react-native'

interface Item { id: string; title: string }

const renderItem: ListRenderItem<Item> = ({ item }) => <Row item={item} />
const keyExtractor = (item: Item) => item.id

export function ItemList({ items }: { items: Item[] }) {
  return (
    <FlatList
      data={items}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      initialNumToRender={10}
      maxToRenderPerBatch={10}
      windowSize={5}
      removeClippedSubviews
    />
  )
}
```

## Platform-Specific Files

```
Button.tsx         # fallback (web/native)
Button.ios.tsx     # iOS override
Button.android.tsx # Android override
Button.native.tsx  # both native, distinct from web (when monorepo with web)
```

Metro resolves automatically. Import as `./Button` — no `.platform` extension.

## Validation Checklist

- [ ] No `ScrollView` + `.map` for lists with >20 items → `FlatList`
- [ ] All `FlatList` have stable `keyExtractor` and memoized `renderItem`
- [ ] `Pressable` over `TouchableOpacity`/`Button` for new code
- [ ] Gesture handlers using `runOnJS` to bridge to JS state
- [ ] `useSafeAreaInsets` over `SafeAreaView` for per-edge padding
- [ ] All text nodes wrapped in `<Text>`
- [ ] `KeyboardAvoidingView` `behavior` branches on `Platform.OS`
- [ ] `expo-image` with `cachePolicy` for remote URIs

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/rn-performance.md` — JS thread, UI thread, InteractionManager, profiling
- `reference/rn-animations.md` — Reanimated worklets, shared values, layout animations
- `reference/rn-gestures.md` — Gesture Handler composition, Pan/Pinch/Rotate
