#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$(mktemp -d "${TMPDIR:-/tmp}/weicheng-publications.XXXXXX")"

cd "$repo_root"
hugo --baseURL "https://example.test/" --destination "$output_dir" --cleanDestinationDir --quiet

if ! grep -Fq 'href="/publications"' "$output_dir/index.html"; then
  echo "Expected the English Publications link to point to /publications."
  exit 1
fi

if [[ ! -f "$output_dir/publications/index.html" ]]; then
  echo "Expected a standalone publications page."
  exit 1
fi

if ! grep -Fq 'How to Build Anomalous (3+1)d Topological Quantum Field Theories' "$output_dir/publications/index.html"; then
  echo "Expected the standalone page to contain the publication list."
  exit 1
fi

if ! grep -Fq '<h1 id="publications">📝 Publications</h1>' "$output_dir/index.html"; then
  echo "Expected the existing homepage publication section to remain unchanged."
  exit 1
fi
