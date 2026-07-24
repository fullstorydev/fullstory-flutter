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
dyld_exports="$RUNNER_TEMP/provider-dyld-exports.txt"

grep -oE "'[a-z][a-z0-9_]*'" "$bindings" \
  | tr -d "'" | sed 's/^/_/' | sort -u > "$required_symbols" || true
if [[ ! -s "$required_symbols" ]]; then
  echo "No FFI symbols found in $bindings"
  exit 1
fi
symbol_count="$(wc -l < "$required_symbols" | tr -d '[:space:]')"
if [[ "$symbol_count" -ne 38 ]]; then
  echo "Expected 38 generated FFI lookups, found $symbol_count"
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
done < <(find "$app/Frameworks" -type f -print0)

if [[ ${#providers[@]} -ne 1 ]]; then
  echo "Expected exactly one Mach-O image to export every FFI symbol."
  printf 'Providers found (%s):\n' "${#providers[@]}"
  printf '  %s\n' "${providers[@]}"
  exit 1
fi

provider="${providers[0]}"
if [[ "$provider" != "$app"/Frameworks/*.framework/* ]]; then
  echo "FFI provider is not an embedded framework: $provider"
  exit 1
fi
if ! xcrun otool -hv "$provider" \
  | grep -Eq '(^|[[:space:]])(MH_)?DYLIB([[:space:]]|$)'; then
  echo "FFI symbols are not provided by a dynamic library: $provider"
  exit 1
fi

if ! xcrun dyld_info -exports "$provider" 2>/dev/null \
  | awk '$1 ~ /^0x[0-9A-Fa-f]+$/ { print $2 }' \
  | sort -u > "$dyld_exports"; then
  echo "Could not read the dyld export trie: $provider"
  exit 1
fi
missing_symbols="$(comm -23 "$required_symbols" "$dyld_exports")"
if [[ -n "$missing_symbols" ]]; then
  echo "FFI symbols missing from the dyld export trie:"
  echo "$missing_symbols"
  exit 1
fi

framework_dir="$(dirname "$provider")"
bundle_id="$(
  /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' \
    "$framework_dir/Info.plist"
)"
if [[ -z "$bundle_id" ]]; then
  echo "FFI provider has no bundle identifier: $provider"
  exit 1
fi

install_name="$(
  xcrun otool -D "$provider" \
    | awk 'NR > 1 && $0 ~ /^[[:space:]]*@rpath\// {
        sub(/^[[:space:]]+/, "")
        print
        exit
      }'
)"
if [[ -z "$install_name" ]]; then
  echo "FFI provider has no @rpath install name: $provider"
  exit 1
fi

app_executable_name="$(
  /usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$app/Info.plist"
)"
app_executable="$app/$app_executable_name"
if ! xcrun otool -l "$app_executable" | awk -v wanted="$install_name" '
  $1 == "cmd" {
    command = $2
  }
  $1 == "name" && $2 == wanted && command == "LC_LOAD_DYLIB" {
    found = 1
  }
  END {
    exit(found ? 0 : 1)
  }
'; then
  echo "The app does not load the FFI provider: $provider"
  exit 1
fi

echo "Verified $symbol_count FFI exports in ${provider#"$app/"}"
echo "Bundle identifier: $bundle_id"
echo "Install name: $install_name"
