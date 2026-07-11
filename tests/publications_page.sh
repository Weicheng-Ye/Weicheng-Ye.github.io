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

publication_page="$output_dir/publications/index.html"

if ! grep -Fq 'How to Build Anomalous (3+1)d Topological Quantum Field Theories' "$publication_page"; then
  echo "Expected the standalone page to contain the publication list."
  exit 1
fi

if ! grep -Fq '<h1 id="publications">📝 Publications</h1>' "$output_dir/index.html"; then
  echo "Expected the existing homepage publication section to remain unchanged."
  exit 1
fi

mathematics_line="$(grep -nE '<h2[^>]*>Mathematics</h2>' "$publication_page" | head -n 1 | cut -d: -f1 || true)"
machine_learning_line="$(grep -nE '<h2[^>]*>Machine Learning</h2>' "$publication_page" | head -n 1 | cut -d: -f1 || true)"
physics_line="$(grep -nE '<h2[^>]*>Physics</h2>' "$publication_page" | head -n 1 | cut -d: -f1 || true)"

if [[ -z "$mathematics_line" || -z "$machine_learning_line" || -z "$physics_line" ]] \
  || ! (( mathematics_line < machine_learning_line && machine_learning_line < physics_line )); then
  echo "Expected Mathematics, Machine Learning, and Physics headings in that order."
  exit 1
fi

result_count="$( { grep -oF 'Result.' "$publication_page" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$result_count" -ne 14 ]]; then
  echo "Expected 14 publication Result. descriptions; found $result_count."
  exit 1
fi

if ! grep -Fq 'Withdrawn' "$publication_page"; then
  echo "Expected the withdrawn manuscript to be labelled Withdrawn."
  exit 1
fi

published_version_link_count="$( { grep -oE '<a[^>]*aria-label="Published version"[^>]*>' "$publication_page" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$published_version_link_count" -ne 9 ]]; then
  echo "Expected nine published-version icon links; found $published_version_link_count."
  exit 1
fi

for repository_label in SpaceGroupCohomology Classification-of-QSL Classification-of-Stiefel-Liquid; do
  if ! grep -Eq ">[[:space:]]*${repository_label}[[:space:]]*</a>" "$publication_page"; then
    echo "Expected the GitHub link label ${repository_label}."
    exit 1
  fi
done

for obsolete_label in LSM3D TQSL StiefelLiquid; do
  if grep -Fq "$obsolete_label" "$publication_page"; then
    echo "Did not expect obsolete GitHub label ${obsolete_label}."
    exit 1
  fi
done

if ! grep -Eq 'SciPost Physics[[:space:]]+18,[[:space:]]*161[[:space:]]*\(2025\)' "$publication_page"; then
  echo "Expected the corrected SciPost Physics 18, 161 (2025) citation."
  exit 1
fi

if ! grep -Eq '(Journal of High Energy Physics|JHEP)[[:space:]]+0?1[[:space:]]*\(2016\)[[:space:]:,]*0?85' "$publication_page"; then
  echo "Expected the corrected JHEP 01 (2016) 085 citation."
  exit 1
fi
