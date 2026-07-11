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

blogs_page="$output_dir/blogs/index.html"
if [[ ! -f "$blogs_page" ]]; then
  echo "Expected a Blogs page."
  exit 1
fi

for section_page in "$publication_page" "$blogs_page"; do
  if ! grep -Fq 'href="/#about-me" class="nav-link">About Me</a>' "$section_page"; then
    echo "Expected About Me navigation to return to the homepage anchor."
    exit 1
  fi
done

publication_titles=(
  'How to Build Anomalous (3+1)d Topological Quantum Field Theories'
  'Global structure in the presence of a topological defect'
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

hidden_publication_title='Higher obstructions to conformal boundary conditions and lattice realizations'
if grep -Fq "$hidden_publication_title" <<< "$publication_body"; then
  echo "Did not expect the hidden Higher obstructions paper on the Publications page."
  exit 1
fi

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

expected_intro='A selection of research papers across mathematical physics, quantum physics, machine learning, and theoretical physics.'
if ! grep -Fq "<p class=\"publications-page__intro\">${expected_intro}</p>" "$publication_page"; then
  echo "Expected the Publications introduction to be rendered as one sentence."
  exit 1
fi

intro_style="$(sed -n '/^\.publications-page__intro {/,/^}/p' "$repo_root/assets/css/publications.css")"
if ! grep -Fq 'max-width: none;' <<< "$intro_style"; then
  echo "Expected the Publications introduction to use the full content width."
  exit 1
fi

if ! rg -Fq '@media screen and (min-width: 1100px)' "$repo_root/assets/css/publications.css" \
  || ! rg -Fq 'white-space: nowrap;' "$repo_root/assets/css/publications.css"; then
  echo "Expected the Publications introduction to remain on one line at desktop widths."
  exit 1
fi

journal_style="$(sed -n '/^\.publication-pill--journal {/,/^}/p' "$repo_root/assets/css/publications.css")"
if ! grep -Fq 'background: rgba(181, 71, 62, 0.14);' <<< "$journal_style" \
  || ! grep -Fq 'border-color: rgba(181, 71, 62, 0.35);' <<< "$journal_style" \
  || ! grep -Fq 'color: #b5473e;' <<< "$journal_style"; then
  echo "Expected journal pills to use the red publication color."
  exit 1
fi

journal_hover_style="$(sed -n '/^\.publication-pill--journal:hover {/,/^}/p' "$repo_root/assets/css/publications.css")"
if ! grep -Fq 'background: #b5473e;' <<< "$journal_hover_style" \
  || ! grep -Fq 'color: #fff;' <<< "$journal_hover_style"; then
  echo "Expected journal-pill hover styling to remain red."
  exit 1
fi

for filter_label in 'All (13)' 'Mathematical Physics (5)' 'Quantum Physics (4)' 'Machine Learning (1)' 'Theoretical Physics (7)'; do
  if ! grep -Fq ">$filter_label</button>" <<< "$publication_body"; then
    echo "Expected publication filter ${filter_label}."
    exit 1
  fi
done

filter_markup="$(awk '
  /class="publication-filters"/ { in_filters = 1 }
  in_filters { print }
  in_filters && /<\/div>/ { exit }
' <<< "$publication_body")"

filter_position() {
  grep -boF ">$1</button>" <<< "$filter_markup" | sed -n '1s/:.*//p'
}

mathematical_physics_position="$(filter_position 'Mathematical Physics (5)')"
quantum_physics_position="$(filter_position 'Quantum Physics (4)')"
machine_learning_position="$(filter_position 'Machine Learning (1)')"
theoretical_physics_position="$(filter_position 'Theoretical Physics (7)')"

if ! (( mathematical_physics_position < quantum_physics_position && quantum_physics_position < machine_learning_position && machine_learning_position < theoretical_physics_position )); then
  echo "Expected filters in Mathematical Physics, Quantum Physics, Machine Learning, Theoretical Physics order."
  exit 1
fi

card_count="$( { grep -oF 'class="publication-card"' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$card_count" -ne 13 ]]; then
  echo "Expected 13 publication cards; found ${card_count}."
  exit 1
fi

publication_category_attributes="$( { grep -oE 'data-publication-categories="[^"]+"' <<< "$publication_body" || true; } )"

for category_and_count in 'mathematical-physics:5' 'quantum-physics:4' 'machine-learning:1' 'theoretical-physics:7'; do
  category="${category_and_count%%:*}"
  expected_count="${category_and_count##*:}"
  actual_count="$(awk -v category="$category" '
    {
      categories = $0
      sub(/^.*="/, "", categories)
      sub(/"$/, "", categories)
      category_count = split(categories, values, " ")
      for (entry = 1; entry <= category_count; entry++) {
        if (values[entry] == category) {
          matches++
        }
      }
    }
    END { print matches + 0 }
  ' <<< "$publication_category_attributes")"
  if [[ "$actual_count" -ne "$expected_count" ]]; then
    echo "Expected ${expected_count} ${category} cards; found ${actual_count}."
    exit 1
  fi
done

source_categories_for() {
  awk -v publication_title="$1" '
    /^  - categories:/ {
      categories = ""
      next
    }
    /^      - / {
      categories = categories == "" ? $2 : categories " " $2
      next
    }
    /^    title: / {
      if ($0 == "    title: \"" publication_title "\"") {
        print categories
        exit
      }
    }
  ' "$repo_root/content/publications/_index.md"
}

for paper_and_categories in \
  'Complexity and order in approximate quantum error-correcting codes|mathematical-physics quantum-physics' \
  'Universal quantum phase classification on quantum computers from machine learning|machine-learning quantum-physics' \
  'Topological Holography for fermions|theoretical-physics' \
  'Classification of symmetry-enriched topological quantum spin liquids|quantum-physics theoretical-physics' \
  'Anomaly of (2+1)-Dimensional Symmetry-Enriched Topological Order from (3+1)-Dimensional Topological Quantum Field Theory|theoretical-physics' \
  'Topological characterization of Lieb-Schultz-Mattis constraints and applications to symmetry-enriched quantum criticality|theoretical-physics' \
  'Ultraviolet-Infrared Mixing in Marginal Fermi Liquids|theoretical-physics' \
  'Crystallography, Group Cohomology, and Lieb-Schultz-Mattis Constraints|mathematical-physics theoretical-physics'; do
  paper_title="${paper_and_categories%%|*}"
  expected_categories="${paper_and_categories##*|}"
  actual_categories="$(source_categories_for "$paper_title")"
  if [[ "$actual_categories" != "$expected_categories" ]]; then
    echo "Expected ${paper_title} to use ${expected_categories}; found ${actual_categories:-none}."
    exit 1
  fi
done

hidden_in_source="$(awk -v publication_title="$hidden_publication_title" '
  /^  - categories:/ { hidden = "false"; next }
  /^    hidden: / { hidden = $2; next }
  /^    title: / {
    if ($0 == "    title: \"" publication_title "\"") {
      print hidden
      exit
    }
  }
' "$repo_root/content/publications/_index.md")"
if [[ "$hidden_in_source" != "true" ]]; then
  echo "Expected the Higher obstructions paper to be retained as hidden source data."
  exit 1
fi

if rg -q '^  - category:' "$repo_root/content/publications/_index.md"; then
  echo "Expected all publication records to use the multi-label categories field."
  exit 1
fi

description_count="$( { grep -oF 'class="publication-card__description"' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$description_count" -ne 13 ]]; then
  echo "Expected 13 italic publication descriptions; found ${description_count}."
  exit 1
fi

link_group_count="$( { grep -oF 'class="publication-card__links" role="group" aria-label="Publication links"' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$link_group_count" -ne 13 ]]; then
  echo "Expected 13 labelled publication link groups; found ${link_group_count}."
  exit 1
fi

if grep -Fq 'Result.' <<< "$publication_body"; then
  echo "Did not expect the Result. label on publication cards."
  exit 1
fi

if grep -Fq 'Withdrawn' "$publication_page"; then
  echo "Did not expect a withdrawn manuscript on the visible Publications page."
  exit 1
fi

arxiv_link_count="$( { grep -oF 'publication-pill--arxiv' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$arxiv_link_count" -ne 13 ]]; then
  echo "Expected thirteen arXiv link pills; found ${arxiv_link_count}."
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

repository_link_count="$( { grep -oE 'class="publication-pill publication-pill--repository[^"]*"[^>]*>GitHub</a>' <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
if [[ "$repository_link_count" -ne 3 ]]; then
  echo "Expected three GitHub repository link pills; found ${repository_link_count}."
  exit 1
fi

for repository_label in SpaceGroupCohomology Classification-of-QSL Classification-of-Stiefel-Liquid; do
  if grep -Fq ">$repository_label</a>" <<< "$publication_body"; then
    echo "Did not expect the repository name ${repository_label} to be displayed."
    exit 1
  fi
  if ! grep -Fq "aria-label=\"Open GitHub repository ${repository_label}\"" <<< "$publication_body"; then
    echo "Expected the repository accessibility label for ${repository_label}."
    exit 1
  fi
done

for repository_url in \
  'https://github.com/chxliu/SpaceGroupCohomology' \
  'https://github.com/Weicheng-Ye/Classification-of-QSL' \
  'https://github.com/Weicheng-Ye/Classification-of-Stiefel-Liquid'; do
  if ! grep -Fq "href=\"${repository_url}\"" <<< "$publication_body"; then
    echo "Expected the GitHub repository URL ${repository_url}."
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

if [[ ! -f "$repo_root/assets/js/publications.js" ]] \
  || ! rg -Fq 'data-publication-categories' "$repo_root/assets/js/publications.js" \
  || ! rg -Fq '!categories.includes(category)' "$repo_root/assets/js/publications.js"; then
  echo "Expected client-side publication filtering to match multi-label cards."
  exit 1
fi

for publication_layout_rule in \
  'max-width: 1200px;' \
  'padding: var(--navbar-height) 20px 3.5rem;' \
  'padding: 15px;' \
  'font-size: 2rem;' \
  'font-weight: 500;' \
  'letter-spacing: normal;' \
  'line-height: 1.6;' \
  'margin: 20px 0;'; do
  if ! rg -Fq "$publication_layout_rule" "$repo_root/assets/css/publications.css"; then
    echo "Expected Publications layout rule: ${publication_layout_rule}"
    exit 1
  fi
done
