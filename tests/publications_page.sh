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
publication_body="${publication_body//&#43;/+}"

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

if ! grep -Fq 'class="light-mode publications-layout"' "$publication_page"; then
  echo "Expected the Publications page to use its full-width layout shell."
  exit 1
fi

if grep -Fq 'class="profile-card' <<< "$publication_body"; then
  echo "Did not expect the profile card on the Publications page."
  exit 1
fi

if ! grep -Fq 'class="publications-page"' <<< "$publication_body"; then
  echo "Expected the publications archive page marker."
  exit 1
fi

for filter_label in 'All (14)' 'Mathematical Physics (6)' 'Machine Learning (1)' 'Physics (7)'; do
  if ! grep -Fq ">$filter_label</button>" <<< "$publication_body"; then
    echo "Expected publication filter ${filter_label}."
    exit 1
  fi
done

card_count="$( { grep -oF 'class="publication-card"' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$card_count" -ne 14 ]]; then
  echo "Expected 14 publication cards; found ${card_count}."
  exit 1
fi

for category_and_count in 'mathematical-physics:6' 'machine-learning:1' 'physics:7'; do
  category="${category_and_count%%:*}"
  expected_count="${category_and_count##*:}"
  actual_count="$( { grep -oF "data-publication-category=\"${category}\"" <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
  if [[ "$actual_count" -ne "$expected_count" ]]; then
    echo "Expected ${expected_count} ${category} cards; found ${actual_count}."
    exit 1
  fi
done

description_count="$( { grep -oF 'class="publication-card__description"' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$description_count" -ne 14 ]]; then
  echo "Expected 14 italic publication descriptions; found ${description_count}."
  exit 1
fi

if grep -Fq 'Result.' <<< "$publication_body"; then
  echo "Did not expect the Result. label on publication cards."
  exit 1
fi

if ! grep -Fq 'Withdrawn' "$publication_page"; then
  echo "Expected the withdrawn manuscript to be labelled Withdrawn."
  exit 1
fi

arxiv_link_count="$( { grep -oF 'publication-pill--arxiv' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$arxiv_link_count" -ne 14 ]]; then
  echo "Expected fourteen arXiv link pills; found ${arxiv_link_count}."
  exit 1
fi

published_link_count="$( { grep -oF 'publication-pill--journal' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$published_link_count" -ne 9 ]]; then
  echo "Expected nine journal link pills; found ${published_link_count}."
  exit 1
fi

for journal_label in 'SciPost Physics' 'Communications in Mathematical Physics' 'Nature Physics' 'Physical Review X' 'Quantum' 'Physical Review Letters' 'Journal of High Energy Physics'; do
  if ! grep -Fq ">$journal_label</a>" <<< "$publication_body"; then
    echo "Expected visible journal link pill ${journal_label}."
    exit 1
  fi
done

for repository_label in SpaceGroupCohomology Classification-of-QSL Classification-of-Stiefel-Liquid; do
  if ! grep -Fq ">$repository_label</a>" <<< "$publication_body"; then
    echo "Expected the repository link label ${repository_label}."
    exit 1
  fi
done

if grep -Fq 'img.shields.io/badge' <<< "$publication_body"; then
  echo "Did not expect badge images on publication cards."
  exit 1
fi

if ! grep -Eq 'SciPost Physics[[:space:]]+18,[[:space:]]*161[[:space:]]*\(2025\)' "$publication_page"; then
  echo "Expected the corrected SciPost Physics 18, 161 (2025) citation."
  exit 1
fi

if ! grep -Eq '(Journal of High Energy Physics|JHEP)[[:space:]]+0?1[[:space:]]*\(2016\)[[:space:]:,]*0?85' "$publication_page"; then
  echo "Expected the corrected JHEP 01 (2016) 085 citation."
  exit 1
fi

if ! grep -Fq 'sign-free stabilizer states and sign-free two-qubit wavefunctions' "$repo_root/content/publications/_index.md"; then
  echo "Expected the sign-structure result to state the proven scope precisely."
  exit 1
fi

if ! grep -Fq 'Editors’ Suggestion' "$repo_root/content/publications/_index.md"; then
  echo "Expected the APS designation Editors’ Suggestion."
  exit 1
fi
