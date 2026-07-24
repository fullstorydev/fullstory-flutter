#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <Runner.app> <generated FFI bindings>"
  exit 2
fi

app="$1"
bindings="$2"

if [[ ! -d "$app" ]]; then
  echo "Archived app not found: $app"
  exit 1
fi
if [[ ! -f "$bindings" ]]; then
  echo "Generated FFI bindings not found: $bindings"
  exit 1
fi

required_symbols="$RUNNER_TEMP/required-ffi-symbols.txt"
candidate_symbols="$RUNNER_TEMP/candidate-ios-symbols.txt"

grep -oE "'[a-z][a-z0-9_]*'" "$bindings" \
  | tr -d "'" | sed 's/^/_/' | sort -u > "$required_symbols" || true
if [[ ! -s "$required_symbols" ]]; then
  echo "No FFI symbols found in $bindings"
  exit 1
fi

providers=()
while IFS= read -r -d '' candidate; do
  if ! file "$candidate" | grep -q 'Mach-O'; then
    continue
  fi
  if ! xcrun nm -gjU "$candidate" > "$candidate_symbols" 2>/dev/null; then
    continue
  fi
  sort -u -o "$candidate_symbols" "$candidate_symbols"
  missing_symbols="$(comm -23 "$required_symbols" "$candidate_symbols")"
  if [[ -z "$missing_symbols" ]]; then
    providers+=("$candidate")
  fi
done < <(find "$app" -type f -print0)

if [[ ${#providers[@]} -ne 1 ]]; then
  echo "Expected exactly one Mach-O image to export every FFI symbol."
  printf 'Providers found (%s):\n' "${#providers[@]}"
  printf '  %s\n' "${providers[@]}"
  exit 1
fi

provider="${providers[0]}"
if ! xcrun otool -hv "$provider" \
  | grep -Eq '(^|[[:space:]])(MH_)?DYLIB([[:space:]]|$)'; then
  echo "FFI symbols are not provided by a dynamic library: $provider"
  exit 1
fi

app_executable_name="$(
  /usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$app/Info.plist"
)"
app_executable="$app/$app_executable_name"
if ! xcrun otool -L "$app_executable" | grep -Fq "$(basename "$provider")"; then
  echo "The app does not load the FFI provider: $provider"
  exit 1
fi

symbol_count="$(wc -l < "$required_symbols" | tr -d ' ')"
echo "Verified $symbol_count FFI exports in ${provider#"$app/"}"
