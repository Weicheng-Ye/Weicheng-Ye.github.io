#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mode="${1:-all}"
output="$(mktemp -d)"
trap 'rm -rf -- "$output"' EXIT

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
assert_file() { [[ -f "$1" ]] || fail "missing file $1"; }
assert_contains() { rg -q --fixed-strings -- "$2" "$1" || fail "$1 does not contain $2"; }
assert_not_contains() { ! rg -q "$2" "$1" || fail "$1 unexpectedly contains $2"; }
assert_not_contains_fixed() { ! rg -q --fixed-strings -- "$2" "$1" || fail "$1 unexpectedly contains $2"; }

build_site() {
  hugo --source "$repo_root" --destination "$output" --environment production --cleanDestinationDir --panicOnWarning
}

check_structure() {
  for path in index.html blogs/index.html contact/index.html zh/index.html zh/contact/index.html; do
    assert_file "$output/$path"
  done
  assert_contains "$output/index.html" 'class="site-sidebar"'
  assert_contains "$output/index.html" '>Blog<'
  assert_contains "$output/index.html" '>Contact<'
  assert_contains "$output/index.html" '>Publications<'
  assert_contains "$output/index.html" 'I study quantum phases through mathematical physics, algebraic topology, and machine learning.'
  assert_contains "$output/contact/index.html" 'mailto:victorye963@gmail.com'
  assert_contains "$output/zh/index.html" 'lang="zh-Hans"'
  assert_contains "$output/zh/index.html" 'href="/blogs/"'
  assert_contains "$output/zh/index.html" 'Blog（英文）'
  assert_not_contains "$output/index.html" 'id="news"'
  assert_not_contains "$output/index.html" 'id="educations"'
  assert_not_contains "$output/index.html" 'localhost|livereload|googleapis|cdnjs|jsdelivr'
}

check_publications() {
  assert_file "$output/publications/index.html"
  assert_file "$output/zh/publications/index.html"
  count="$(rg -o 'class="publication-entry"' "$output/publications/index.html" | wc -l | tr -d ' ')"
  [[ "$count" = 14 ]] || fail "expected 14 publication entries, found $count"
  assert_contains "$output/publications/index.html" 'How to Build Anomalous (3+1)d Topological Quantum Field Theories'
  assert_contains "$output/publications/index.html" 'Quasinormal modes of Gauss-Bonnet black holes at large D'
  assert_contains "$output/publications/index.html" 'https://github.com/Weicheng-Ye/Classification-of-QSL'
  assert_contains "$output/publications/index.html" 'SciPost Physics 18.5 (2025): 161.'
  assert_not_contains_fixed "$output/publications/index.html" 'SciPost Physics 18.1 (2025): 005.'
}

check_presentation() {
  assert_file "$output/images/profile.jpg"
  assert_contains "$output/index.html" 'src="/images/profile.jpg"'
  css_file="$(rg --files "$output" -g '*.css' | head -n 1)"
  assert_file "$css_file"
  assert_contains "$css_file" '--color-accent:'
  assert_contains "$css_file" '.site-sidebar'
  assert_contains "$css_file" ':focus-visible'
  assert_contains "$css_file" 'prefers-reduced-motion'
  assert_contains "$css_file" '@media(max-width:800px)'
  assert_contains "$css_file" 'a:focus-visible,summary:focus-visible{outline:3px solid var(--color-accent);outline-offset:4px;border-radius:2px}'
  assert_contains "$css_file" 'border-bottom:1px solid var(--color-rule);background:var(--color-surface);background:color-mix(in srgb,var(--color-surface) 94%,transparent);backdrop-filter:blur(12px)'
  assert_contains "$css_file" '.site-main{width:100%;padding:var(--space-5)1.2rem;scroll-margin-top:4.5rem}'
  assert_contains "$css_file" 'h1{font-size:clamp(2.1rem,8vw,3.3rem)}.publication-year>h2{position:static}}@media(max-width:540px){.site-main{padding-top:var(--space-4)}'
}

check_repository() {
  [[ ! -e "$repo_root/go.mod" ]] || fail 'go.mod should be removed with the theme module'
  [[ ! -e "$repo_root/go.sum" ]] || fail 'go.sum should be removed with the theme module'
  [[ ! -e "$repo_root/.gitmodules" ]] || fail '.gitmodules should be removed'
  [[ -z "$(git -C "$repo_root" ls-files 'public/**')" ]] || fail 'public output is still tracked'
  assert_contains "$repo_root/.gitignore" '/public/'
  assert_contains "$repo_root/.github/workflows/hugo.yaml" 'HUGO_VERSION: 0.164.0'
  assert_not_contains "$repo_root/.github/workflows/hugo.yaml" 'dart-sass|npm ci|submodules:'
}

case "$mode" in
  structure) build_site; check_structure ;;
  publications) build_site; check_publications ;;
  presentation) build_site; check_presentation ;;
  repository) check_repository ;;
  all) build_site; check_structure; check_publications; check_presentation; check_repository ;;
  *) fail "unknown mode $mode" ;;
esac

printf 'PASS: %s contract\n' "$mode"
