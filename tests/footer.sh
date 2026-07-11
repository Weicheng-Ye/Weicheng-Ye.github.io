#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$(mktemp -d "${TMPDIR:-/tmp}/weicheng-footer.XXXXXX")"

cd "$repo_root"
hugo --baseURL "https://example.test/" --destination "$output_dir" --cleanDestinationDir --quiet

homepage="$output_dir/index.html"

if grep -Fq 'Built with <a href=' "$homepage"; then
  echo "Expected the starter-theme attribution to be absent from the footer."
  exit 1
fi

if grep -Fq 'Copyright ©' "$homepage"; then
  echo "Expected the starter copyright wording to be absent from the footer."
  exit 1
fi

if ! grep -Fq '© Weicheng Ye' "$homepage"; then
  echo "Expected the footer copyright to read © Weicheng Ye."
  exit 1
fi

for expected_link in \
  'href="https://scholar.google.com/citations?user=sUNQUA0AAAAJ&amp;hl=zh-TW" target="_blank" rel="noopener noreferrer">Scholar</a>' \
  'href="https://github.com/Weicheng-Ye" target="_blank" rel="noopener noreferrer">GitHub</a>' \
  'href="mailto:evictorye963@gmail.com">Email</a>' \
  'href="https://www.linkedin.com/in/ye-weicheng-241626243" target="_blank" rel="noopener noreferrer">LinkedIn</a>'; do
  if ! grep -Fq "$expected_link" "$homepage"; then
    echo "Expected footer link: ${expected_link}."
    exit 1
  fi
done
