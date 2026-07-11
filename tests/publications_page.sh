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
publication_body="$(sed '1,/<\/head>/d' "$publication_page")"

publication_titles=(
  'How to Build Anomalous (3+1)d Topological Quantum Field Theories'
  'Global structure in the presence of a topological defect'
  'Higher obstructions to conformal boundary conditions and lattice realizations'
  'Crystallography, Group Cohomology, and Lieb-Schultz-Mattis Constraints'
  'Bosonization and Anomaly Indicators of (2+1)-D Fermionic Topological Orders'
  'Complexity and order in approximate quantum error-correcting codes'
  'Universal quantum phase classification on quantum computers from machine learning'
  'Topological Holography for fermions'
  'Classification of symmetry-enriched topological quantum spin liquids'
  'Anomaly of (2+1)-Dimensional Symmetry-Enriched Topological Order from (3+1)-Dimensional Topological Quantum Field Theory'
  'Probing sign structure using measurement-induced entanglement'
  'Topological characterization of Lieb-Schultz-Mattis constraints and applications to symmetry-enriched quantum criticality'
  'Ultraviolet-Infrared Mixing in Marginal Fermi Liquids'
  'Quasinormal modes of Gauss-Bonnet black holes at large D'
)

for publication_title in "${publication_titles[@]}"; do
  title_count="$( { grep -oF "$publication_title" <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
  if [[ "$title_count" -ne 1 ]]; then
    echo "Expected publication title once: ${publication_title}; found ${title_count}."
    exit 1
  fi
done

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

result_count="$( { grep -oF 'Result.' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$result_count" -ne 14 ]]; then
  echo "Expected 14 publication Result. descriptions; found $result_count."
  exit 1
fi

if ! grep -Fq 'Withdrawn' "$publication_page"; then
  echo "Expected the withdrawn manuscript to be labelled Withdrawn."
  exit 1
fi

published_version_link_count="$( { grep -oE '<a[^>]*aria-label="Published version"[^>]*>' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$published_version_link_count" -ne 9 ]]; then
  echo "Expected nine published-version icon links; found $published_version_link_count."
  exit 1
fi

published_version_urls=(
  'https://doi.org/10.21468/SciPostPhys.18.5.161'
  'https://doi.org/10.1007/s00220-025-05344-z'
  'https://doi.org/10.1038/s41567-024-02621-x'
  'https://doi.org/10.1103/PhysRevX.14.021053'
  'https://doi.org/10.21468/SciPostPhys.15.1.004'
  'https://doi.org/10.22331/q-2023-02-02-910'
  'https://doi.org/10.21468/SciPostPhys.13.3.066'
  'https://doi.org/10.1103/PhysRevLett.128.106402'
  'https://doi.org/10.1007/JHEP01(2016)085'
)

for published_url in "${published_version_urls[@]}"; do
  if ! grep -Fq "href=\"${published_url}\"" <<< "$publication_body"; then
    echo "Expected published-version link ${published_url}."
    exit 1
  fi
done

for repository_label in SpaceGroupCohomology Classification-of-QSL Classification-of-Stiefel-Liquid; do
  if ! grep -Fq "alt=\"GitHub-${repository_label}\"" <<< "$publication_body"; then
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
