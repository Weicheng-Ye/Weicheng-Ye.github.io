# Publications Archive Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild `/publications/` as a full-width, filterable academic-card archive without changing any other rendered page.

**Architecture:** Keep the 14 records in `content/publications/_index.md` as structured front matter and render them through a section-specific Hugo layout. A publications-only base template removes the profile-card aside; a small CSS asset controls the card treatment and a dependency-free JavaScript asset filters cards by `data-publication-category`.

**Tech Stack:** Hugo 0.145-compatible Go templates, Goldmark, CSS custom properties, vanilla browser JavaScript, Bash regression tests.

## Global Constraints

- Preserve all 14 existing titles, authors, citations, URLs, descriptions, withdrawal status, and repository links.
- The only visible redesign target is `/publications/`; homepage, blog, navigation, footer, Chinese home page, and global styling must not change.
- Filter labels and counts are exact: `All (14)`, `Mathematical Physics (6)`, `Machine Learning (1)`, `Physics (7)`.
- Use `Mathematical Physics`, never `Mathematics`, in new Publications-page UI and tests.
- Do not render the literal text `Result.`.
- Keep the existing theme’s light/dark variables and use no third-party JavaScript.
- Do not stage or modify generated `public/` files.

---

## File Structure

| File | Responsibility |
| --- | --- |
| `content/publications/_index.md` | Canonical publication metadata: category, bibliographic copy, description, and all external URLs. |
| `layouts/publications/baseof.html` | Publications-only page shell without the desktop profile card. |
| `layouts/publications/list.html` | Accessible filter controls and a card for each front-matter publication record. |
| `layouts/partials/publications-head.html` | Section-only head markup that loads the module CSS/JS plus publication CSS/JS. |
| `assets/css/publications.css` | Scoped full-width, card, pill, and responsive styles. |
| `assets/js/publications.js` | Accessible category filtering with no-JavaScript fallback. |
| `tests/publications_page.sh` | Rendered HTML regression contract for the archive structure and content. |

### Task 1: Extend the rendered-page contract

**Files:**
- Modify: `tests/publications_page.sh`

**Interfaces:**
- Consumes: Hugo’s generated `publications/index.html`.
- Produces: a non-zero exit when the redesign loses full-width layout markers, filter behavior markup, card count/category mapping, italic descriptions, or publisher pills.

- [ ] **Step 1: Add failing assertions before changing templates**

Replace the current `Mathematics` / `Machine Learning` / `Physics` heading-order block, `assert_titles_in_section` helper calls, and the `Result.` count assertion. Add these checks after `publication_body` is defined:

```bash
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

if grep -Fq 'Result.' <<< "$publication_body"; then
  echo "Did not expect the Result. label on publication cards."
  exit 1
fi
```

- [ ] **Step 2: Add category and link-pill assertions**

Add exact category checks and representative real-link labels:

```bash
for category_and_count in 'mathematical-physics:6' 'machine-learning:1' 'physics:7'; do
  category="${category_and_count%%:*}"
  expected_count="${category_and_count##*:}"
  actual_count="$( { grep -oF "data-publication-category=\"${category}\"" <<< "$publication_body" || true; } | wc -l | tr -d '[:space:]')"
  if [[ "$actual_count" -ne "$expected_count" ]]; then
    echo "Expected ${expected_count} ${category} cards; found ${actual_count}."
    exit 1
  fi
done

for journal_label in 'SciPost Physics' 'Communications in Mathematical Physics' 'Nature Physics' 'Physical Review X' 'Quantum' 'Physical Review Letters' 'Journal of High Energy Physics'; do
  if ! grep -Fq ">$journal_label</a>" <<< "$publication_body"; then
    echo "Expected visible journal link pill ${journal_label}."
    exit 1
  fi
done
```

- [ ] **Step 3: Run the contract and confirm RED**

Run:

```bash
bash tests/publications_page.sh
```

Expected: fail because the current flat list has neither `publications-page` nor the requested controls/cards.

- [ ] **Step 4: Commit the test-only contract**

```bash
git add tests/publications_page.sh
git commit -m "test(publications): cover card archive"
```

### Task 2: Convert Publications data to structured front matter

**Files:**
- Modify: `content/publications/_index.md`

**Interfaces:**
- Consumes: the current 14 publication records in Markdown.
- Produces: `.Params.publications`, an array of records with `category`, `title`, `title_url`, `authors`, `citation`, `description`, `status`, `arxiv`, `published`, and `repository` fields.

- [ ] **Step 1: Replace the Markdown list with the following data schema**

Use YAML front matter with this exact shape for each record:

```yaml
---
title: "Publications"
intro: "A selection of research papers across mathematical physics, machine learning, and physics."
publications:
  - category: mathematical-physics
    title: "How to Build Anomalous (3+1)d Topological Quantum Field Theories"
    title_url: "https://arxiv.org/abs/2510.24834"
    authors: "Arun Debray, **Weicheng Ye**, and Matthew Yu"
    citation: "arXiv preprint (2025)."
    description: "We develop a fermionic framework for constructing (3+1)-dimensional topological quantum field theories that realize prescribed finite-symmetry anomalies. It establishes realizability for supercohomology anomalies while identifying an obstruction beyond supercohomology."
    arxiv:
      url: "https://arxiv.org/abs/2510.24834"
      label: "arXiv"
---
```

- [ ] **Step 2: Migrate every existing record without changing its scholarly content**

Use these exact category assignments, in current newest-first order:

```text
mathematical-physics:
  2510.24834, 2501.18399, 2411.11757, 2410.03607, 2312.13341, 2310.04710
machine-learning:
  2508.04774
physics:
  2404.19004, 2309.15118, 2210.02444, 2205.05692, 2111.12097, 2109.00004, 1511.08706
```

For published records, add:

```yaml
published:
  url: "https://doi.org/10.21468/SciPostPhys.18.5.161"
  label: "SciPost Physics"
```

For code records, add:

```yaml
repository:
  url: "https://github.com/chxliu/SpaceGroupCohomology"
  label: "SpaceGroupCohomology"
```

For the withdrawn manuscript, add `status: "Withdrawn"`. Keep the complete current text of every citation and description; do not add `Result.`.

- [ ] **Step 3: Validate front matter parsing**

Run:

```bash
output_dir=$(mktemp -d /tmp/publications-data.XXXXXX)
hugo --baseURL "https://example.test/" --destination "$output_dir" --cleanDestinationDir --quiet
```

Expected: exit status 0; template output remains unchanged until Task 3 consumes the data.

### Task 3: Add the full-width Publications shell and card renderer

**Files:**
- Create: `layouts/publications/baseof.html`
- Create: `layouts/publications/list.html`
- Create: `layouts/partials/publications-head.html`
- Create: `assets/css/publications.css`

**Interfaces:**
- Consumes: `.Params.publications` from Task 2.
- Produces: 14 `.publication-card` elements with `data-publication-category`, full-width page structure, and text link pills.

- [ ] **Step 1: Create `layouts/publications/baseof.html`**

Copy the module base layout while changing only the page shell:

```go-html-template
<!DOCTYPE html>
<html lang="{{ .Site.Language.Lang }}">
{{ partial "publications-head.html" . }}
<body class="light-mode publications-layout">
  <header class="navbar">{{ partial "navbar.html" . }}</header>
  <div id="navscreen" class="navscreen hide-in-desktop">{{ partial "navscreen.html" . }}</div>
  <div class="container publications-container">
    <main class="main-content publications-main-content">{{ block "main" . }}{{ end }}</main>
  </div>
  <footer class="footer">{{ partial "footer.html" . }}</footer>
</body>
</html>
```

- [ ] **Step 2: Create the section-specific head partial**

Copy the module head partial exactly, then add these two assets before `</head>`:

```go-html-template
{{ $publicationStyles := resources.Get "css/publications.css" | minify }}
<link rel="stylesheet" href="{{ $publicationStyles.RelPermalink }}">
{{ $publicationScript := resources.Get "js/publications.js" | minify }}
<script src="{{ $publicationScript.RelPermalink }}" defer></script>
```

This preserves current SEO tags, Font Awesome, Lato, theme CSS, and theme JavaScript while loading the new assets only for Publications.

- [ ] **Step 3: Render controls and cards in `layouts/publications/list.html`**

Use Hugo collection filtering for counts and exact button semantics:

```go-html-template
{{ define "main" }}
{{ $publications := .Params.publications }}
{{ $mathematicalPhysics := where $publications "category" "mathematical-physics" }}
{{ $machineLearning := where $publications "category" "machine-learning" }}
{{ $physics := where $publications "category" "physics" }}
<article class="publications-page">
  <header class="publications-page__header">
    <h1>{{ .Title }}</h1>
    {{ with .Params.intro }}<p class="publications-page__intro">{{ . }}</p>{{ end }}
  </header>
  <div class="publication-filters" role="group" aria-label="Filter publications by field">
    <button class="publication-filter is-active" type="button" data-publication-filter="all" aria-pressed="true">All ({{ len $publications }})</button>
    <button class="publication-filter" type="button" data-publication-filter="mathematical-physics" aria-pressed="false">Mathematical Physics ({{ len $mathematicalPhysics }})</button>
    <button class="publication-filter" type="button" data-publication-filter="machine-learning" aria-pressed="false">Machine Learning ({{ len $machineLearning }})</button>
    <button class="publication-filter" type="button" data-publication-filter="physics" aria-pressed="false">Physics ({{ len $physics }})</button>
  </div>
  <div class="publication-list">
    {{ range $publications }}
    <article class="publication-card" data-publication-category="{{ .category }}">
      <h2 class="publication-card__title"><a href="{{ .title_url }}" class="no-trailing-icon">{{ .title }}</a></h2>
      {{ with .status }}<p class="publication-card__status">{{ . }}</p>{{ end }}
      <p class="publication-card__authors">{{ .authors | markdownify }}</p>
      <p class="publication-card__citation">{{ .citation }}</p>
      <p class="publication-card__description">{{ .description }}</p>
      <div class="publication-card__links" aria-label="Publication links">
        {{ with .arxiv }}<a class="publication-pill publication-pill--arxiv no-trailing-icon" href="{{ .url }}">{{ .label }}</a>{{ end }}
        {{ with .published }}<a class="publication-pill publication-pill--journal no-trailing-icon" href="{{ .url }}">{{ .label }}</a>{{ end }}
        {{ with .repository }}<a class="publication-pill publication-pill--repository no-trailing-icon" href="{{ .url }}">{{ .label }}</a>{{ end }}
      </div>
    </article>
    {{ end }}
  </div>
</article>
{{ end }}
```

- [ ] **Step 4: Add scoped CSS**

Implement these required selectors in `assets/css/publications.css`:

```css
.publications-layout .publications-container { display: block; max-width: 1440px; }
.publications-layout .publications-main-content { max-width: none; padding: 2rem 0 3rem; }
.publication-filters { display: flex; flex-wrap: wrap; gap: .65rem; margin: 1.75rem 0 2rem; }
.publication-filter { border: 1px solid var(--border-color); border-radius: 999px; background: transparent; color: var(--text-color); cursor: pointer; min-height: 2.7rem; padding: .5rem 1rem; }
.publication-filter.is-active { background: var(--primary-color); border-color: var(--primary-color); color: #fff; }
.publication-card { background: var(--background-color-light); border: 1px solid var(--border-color); border-radius: 14px; box-shadow: var(--card-shadow); margin-bottom: 1.25rem; padding: clamp(1.2rem, 2vw, 2rem); }
.dark-mode .publication-card { background: #242424; }
.publication-card__description { border-top: 1px solid var(--border-color); font-style: italic; margin-top: 1rem; padding-top: 1rem; }
.publication-card__links { display: flex; flex-wrap: wrap; gap: .55rem; margin-top: 1.1rem; }
.publication-pill { border-radius: 8px; display: inline-flex; font-weight: 700; padding: .45rem .7rem; }
@media (max-width: 845px) { .publications-layout .publications-main-content { padding-inline: 1rem; } .publication-filter { flex: 1 1 auto; } }
```

Complete the CSS with visible keyboard focus, title/author/citation spacing, status treatment, and a light-mode card color that contrasts softly with the page background.

- [ ] **Step 5: Run the contract and confirm GREEN**

Run:

```bash
bash tests/publications_page.sh
```

Expected: pass with 14 cards, all four filter labels, the 6/1/7 category split, italic descriptions, and journal-name pills.

- [ ] **Step 6: Commit the server-rendered archive**

```bash
git add content/publications/_index.md layouts/publications/baseof.html layouts/publications/list.html layouts/partials/publications-head.html assets/css/publications.css tests/publications_page.sh
git commit -m "feat(publications): add card archive"
```

### Task 4: Add and verify client-side filtering

**Files:**
- Create: `assets/js/publications.js`
- Test: `tests/publications_page.sh`

**Interfaces:**
- Consumes: `[data-publication-filter]` buttons and `[data-publication-category]` cards emitted by Task 3.
- Produces: category filtering that updates `hidden`, `.is-active`, and `aria-pressed` without navigation.

- [ ] **Step 1: Add the filter behavior**

Create `assets/js/publications.js`:

```js
(() => {
  const filters = Array.from(document.querySelectorAll("[data-publication-filter]"));
  const cards = Array.from(document.querySelectorAll("[data-publication-category]"));

  const applyFilter = (category) => {
    cards.forEach((card) => {
      card.hidden = category !== "all" && card.dataset.publicationCategory !== category;
    });
    filters.forEach((filter) => {
      const isActive = filter.dataset.publicationFilter === category;
      filter.classList.toggle("is-active", isActive);
      filter.setAttribute("aria-pressed", String(isActive));
    });
  };

  filters.forEach((filter) => {
    filter.addEventListener("click", () => applyFilter(filter.dataset.publicationFilter));
  });
})();
```

- [ ] **Step 2: Add a static asset assertion**

Append to `tests/publications_page.sh`:

```bash
if ! rg -q 'card\.hidden = category !== "all"' assets/js/publications.js; then
  echo "Expected client-side publication filtering to hide nonmatching cards."
  exit 1
fi
```

- [ ] **Step 3: Run unit-level and rendered-page checks**

Run:

```bash
bash -n tests/publications_page.sh
bash tests/publications_page.sh
output_dir=$(mktemp -d /tmp/publications-final.XXXXXX)
HUGO_ENVIRONMENT=production HUGO_ENV=production hugo --gc --minify --baseURL "https://example.test/" --destination "$output_dir" --cleanDestinationDir --quiet
```

Expected: all commands exit 0.

- [ ] **Step 4: Visually inspect filtering and responsive layout**

Run a local Hugo server with the root-local base URL, then use browser automation:

```bash
hugo server -D --baseURL "http://localhost:1314/" --bind 127.0.0.1 --port 1314 --disableFastRender
```

Inspect `/publications/` at 1280px, 768px, and 375px. Click each filter and confirm only its cards are visible; verify no profile card appears. Visit `/` and confirm its profile card still appears.

- [ ] **Step 5: Commit behavior and verification**

```bash
git add assets/js/publications.js tests/publications_page.sh
git commit -m "feat(publications): filter archive cards"
```

### Task 5: Final review, merge, and deploy

**Files:**
- Verify: `content/publications/_index.md`
- Verify: `layouts/publications/baseof.html`
- Verify: `layouts/publications/list.html`
- Verify: `layouts/partials/publications-head.html`
- Verify: `assets/css/publications.css`
- Verify: `assets/js/publications.js`
- Verify: `tests/publications_page.sh`

**Interfaces:**
- Consumes: the completed archive and regression contract.
- Produces: a reviewed, deployable `main` branch with no generated output staged.

- [ ] **Step 1: Review the source diff for scope**

Run:

```bash
git diff --check main...HEAD -- content/publications/_index.md layouts/publications layouts/partials/publications-head.html assets/css/publications.css assets/js/publications.js tests/publications_page.sh
git diff --name-only main...HEAD
```

Expected: only the planned source, template, asset, and test paths appear.

- [ ] **Step 2: Run final verification**

Run:

```bash
bash tests/publications_page.sh
output_dir=$(mktemp -d /tmp/publications-release.XXXXXX)
HUGO_ENVIRONMENT=production HUGO_ENV=production hugo --gc --minify --baseURL "https://example.test/" --destination "$output_dir" --cleanDestinationDir --quiet
```

Expected: both commands exit 0.

- [ ] **Step 3: Merge and push without generated output**

Run from the primary checkout:

```bash
git switch main
git merge --no-ff codex/publications-archive-cards -m "feat(publications): add filterable card archive"
git push origin main
```

- [ ] **Step 4: Verify deployment**

Use GitHub Actions to confirm the Pages workflow succeeds, then inspect the live `/publications/` page for all four filter buttons, card layout, and publication link pills.
