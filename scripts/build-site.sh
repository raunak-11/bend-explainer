#!/bin/sh
# Assemble the GitHub Pages site in _site/.
#   index.html               -> _site/index.html     (the version index)
#   BEND-EXPLAINER_vN.html   -> _site/vN/index.html  (one folder per version)
# Every version is a single self-contained HTML file, so versions never share
# files and one can't break another.
set -eu
cd "$(dirname "$0")/.."

rm -rf _site
mkdir -p _site
cp index.html _site/index.html
touch _site/.nojekyll

count=0
for f in BEND-EXPLAINER_v*.html; do
  [ -e "$f" ] || continue
  v=${f#BEND-EXPLAINER_}
  v=${v%.html}
  mkdir -p "_site/$v"
  cp "$f" "_site/$v/index.html"
  echo "  $f -> _site/$v/index.html"
  count=$((count + 1))
done
[ "$count" -gt 0 ] || { echo "error: no BEND-EXPLAINER_v*.html files found" >&2; exit 1; }

# Every version the index links to must exist, or the build fails.
for v in $(grep -o 'href="v[0-9][0-9]*/"' index.html | sed 's/href="//; s/\/"//' | sort -u); do
  [ -f "_site/$v/index.html" ] || { echo "error: index.html links to $v/ but BEND-EXPLAINER_$v.html is missing" >&2; exit 1; }
done

echo "Built _site/ with $count version(s)."
