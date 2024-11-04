#!/bin/bash

# Outputs markdown with all of the files from the example/lib folder for display at https://pub.dev/packages/fullstory_flutter/example
# Otherwise the contents of lib/main.dart are displayed instead, which isn't particularly helpful.
# See https://dart.dev/tools/pub/package-layout#examples

# Usage: ./generate_example_md.sh > example/example.md
# (This is automatically run by .github/workflows/ci.yml when publishing a new release to pub.dev)

# this assumes the script is run from the root of the project
cd example/lib/

echo '<!-- this file is generated, see ../generate_example_md.sh -->'
echo ''
echo '# fullstory_flutter Examples'
echo 'From https://github.com/fullstorydev/fullstory-flutter/tree/main/example/lib'
echo ''

# table of contents
for file in *; do
    if [ -f "$file" ]; then
        # remove dots so that the anchor link matches what pub.dev's markdown parser will create
        echo "* [$file](#`echo $file | sed 's/\.//'`)"
    fi
done

# files

for file in *; do
    if [ -f "$file" ]; then
        echo ''
        echo "## $file"
        echo '```dart'
        cat "$file"
        echo '```'
    fi
done

echo ''
