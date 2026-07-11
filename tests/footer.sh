#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$(mktemp -d "${TMPDIR:-/tmp}/weicheng-footer.XXXXXX")"

cd "$repo_root"
hugo --baseURL "https://example.test/" --destination "$output_dir" --cleanDestinationDir --quiet

homepage="$output_dir/index.html"
footer_markup="$(sed -n '/<footer class="footer">/,/<\/footer>/p' "$homepage")"

if grep -Fq 'Built with <a href=' "$homepage"; then
  echo "Expected the starter-theme attribution to be absent from the footer."
  exit 1
fi

if grep -Fq 'Copyright ©' "$homepage"; then
  echo "Expected the starter copyright wording to be absent from the footer."
  exit 1
fi

if grep -Fq '© Weicheng Ye' <<< "$footer_markup"; then
  echo "Did not expect the old copyright footer text."
  exit 1
fi

if ! grep -Fq 'class="footer-content__owner">@Weicheng Ye</span>' <<< "$footer_markup"; then
  echo "Expected @Weicheng Ye on the left side of the footer."
  exit 1
fi

if ! grep -Fq 'class="footer-content__links" aria-label="Footer links"' <<< "$footer_markup"; then
  echo "Expected a dedicated right-side footer link group."
  exit 1
fi

if grep -Fq '<br>' <<< "$footer_markup"; then
  echo "Did not expect a line break in the footer content."
  exit 1
fi

for footer_layout_rule in \
  'display: flex;' \
  'justify-content: space-between;' \
  'gap: 2.5rem;' \
  '@media screen and (max-width: 845px)'; do
  if ! grep -Fq "$footer_layout_rule" <<< "$footer_markup"; then
    echo "Expected footer layout rule: ${footer_layout_rule}."
    exit 1
  fi
done

for expected_link in \
  'href="https://scholar.google.com/citations?user=sUNQUA0AAAAJ&amp;hl=zh-TW" target="_blank" rel="noopener noreferrer">Scholar</a>' \
  'href="https://github.com/Weicheng-Ye" target="_blank" rel="noopener noreferrer">GitHub</a>' \
  'href="mailto:evictorye963@gmail.com">Email</a>' \
  'href="https://www.linkedin.com/in/ye-weicheng-241626243" target="_blank" rel="noopener noreferrer">LinkedIn</a>'; do
  if ! grep -Fq "$expected_link" <<< "$footer_markup"; then
    echo "Expected footer link: ${expected_link}."
    exit 1
  fi
done
