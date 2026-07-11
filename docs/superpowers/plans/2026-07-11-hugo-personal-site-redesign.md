# Hugo Personal-Site Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the starter Hugo theme with a repository-owned, bilingual academic profile featuring a concise homepage and dedicated Blog, Contact, and Publications pages, then deploy it through GitHub Pages.

**Architecture:** Hugo renders Markdown content and structured publication data through small local templates. A shared base layout owns metadata, responsive navigation, footer, and the repository-owned stylesheet; section layouts own Blog, Contact, and Publications presentation. The rendered site has no client framework, no required JavaScript, and no runtime CDN dependencies.

**Tech Stack:** Hugo Extended 0.164.0, Go templates, Markdown, YAML, CSS, Bash contract tests, GitHub Actions Pages.

## Global Constraints

- Production URL is `https://weicheng-ye.github.io/`.
- English is the default language; Chinese routes remain under `/zh/`.
- Desktop section navigation contains exactly Blog, Contact, and Publications; mobile uses the same links in a native `<details>` disclosure.
- The Chinese Blog link is the explicit root route `/blogs/` and is labelled `Blog（英文）`.
- The public email is `victorye963@gmail.com`; never expose the CV phone number.
- Preserve all 14 publications and existing DOI, arXiv, and project links.
- Use `static/images/profile.jpg`; its filename and JPEG data must agree.
- Use platform font stacks and repository-owned CSS/markup only; no runtime CDN fonts, icons, scripts, or styles.
- Primary homepage content must fit without scrolling at 1366×768; the footer is permitted below the fold.
- Content is visible without JavaScript and motion is disabled under `prefers-reduced-motion`.
- Generated `public/` output is never committed; GitHub Actions produces the deployment artifact.

## File Map

- `hugo.toml` — production URL, languages, menus, profile metadata, and social links.
- `content/_index.md`, `content/_index.zh.md` — approved concise homepage biography copy.
- `content/contact/_index.md`, `content/contact/_index.zh.md` — localized Contact introductions.
- `content/publications/_index.md`, `content/publications/_index.zh.md` — localized Publications headings/descriptions.
- `content/blogs/_index.md` — English Blog section metadata.
- `data/publications.yaml` — canonical ordered publication groups and links.
- `layouts/_default/baseof.html` — shared page shell.
- `layouts/_default/list.html`, `layouts/_default/single.html` — safe fallbacks and blog-post rendering.
- `layouts/index.html` — concise profile homepage.
- `layouts/blogs/list.html` — blog index.
- `layouts/contact/list.html` — contact page.
- `layouts/publications/list.html` — structured publication archive.
- `layouts/partials/head.html` — metadata and fingerprinted local stylesheet.
- `layouts/partials/navigation.html` — desktop sidebar plus no-JavaScript mobile disclosure.
- `layouts/partials/social-links.html` — accessible text links.
- `layouts/partials/footer.html` — localized copyright line.
- `assets/css/site.css` — complete visual system, responsive behavior, focus, reduced motion, and print styles.
- `static/images/profile.jpg` — correctly named existing JPEG portrait.
- `tests/site_contract.sh` — deterministic build/output/repository contract.
- `.gitignore`, `.github/workflows/hugo.yaml`, `README.md` — repository and deployment hygiene.

---

### Task 1: Build Contract and Local Hugo Shell

**Files:**
- Create: `tests/site_contract.sh`
- Modify: `hugo.toml`
- Create: `layouts/_default/baseof.html`
- Create: `layouts/_default/list.html`
- Create: `layouts/_default/single.html`
- Create: `layouts/partials/head.html`
- Create: `layouts/partials/navigation.html`
- Create: `layouts/partials/social-links.html`
- Create: `layouts/partials/footer.html`
- Create: `layouts/index.html`
- Create: `layouts/blogs/list.html`
- Create: `layouts/contact/list.html`
- Create: `content/_index.md`
- Modify: `content/_index.zh.md`
- Create: `content/blogs/_index.md`
- Create: `content/contact/_index.md`
- Create: `content/contact/_index.zh.md`
- Create: `assets/css/site.css`

**Interfaces:**
- Consumes: existing English blog posts and the `images/profile.jpg` route that Task 3 will create.
- Produces: `.Site.Menus.main`, `.Site.Params.author`, `.Site.Params.role`, `.Site.Params.affiliation`, `.Site.Params.researchStatement`, `.Site.Params.social`, and shared HTML class names used by later tasks and tests.

- [ ] **Step 1: Write the failing site contract**

Create `tests/site_contract.sh` with this complete content:

```bash
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
```

- [ ] **Step 2: Run the structure contract to verify it fails**

Run: `bash tests/site_contract.sh structure`

Expected: non-zero exit from the old theme build or a `FAIL` for the missing new shell/classes.

- [ ] **Step 3: Replace the starter configuration**

Rewrite `hugo.toml` with exact production metadata and menus:

```toml
baseURL = "https://weicheng-ye.github.io/"
title = "Weicheng (Victor) Ye"
defaultContentLanguage = "en"
enableGitInfo = true
enableRobotsTXT = true
disableKinds = ["taxonomy", "term", "RSS"]

[params]
  author = "Weicheng (Victor) Ye"
  email = "victorye963@gmail.com"
  profilePicture = "images/profile.jpg"

  [[params.social]]
    name = "Email"
    url = "mailto:victorye963@gmail.com"
  [[params.social]]
    name = "Google Scholar"
    url = "https://scholar.google.com/citations?user=sUNQUA0AAAAJ&hl=en"
  [[params.social]]
    name = "GitHub"
    url = "https://github.com/Weicheng-Ye"
  [[params.social]]
    name = "LinkedIn"
    url = "https://www.linkedin.com/in/ye-weicheng-241626243"

[languages]
  [languages.en]
    languageCode = "en"
    languageDirection = "ltr"
    label = "English"
    weight = 1
    title = "Weicheng (Victor) Ye"
    [languages.en.params]
      author = "Weicheng (Victor) Ye"
      role = "Postdoctoral Fellow"
      affiliation = "University of British Columbia"
      description = "Postdoctoral fellow studying quantum phases through mathematical physics, algebraic topology, and machine learning."
      researchStatement = "I study quantum phases through mathematical physics, algebraic topology, and machine learning."
      footerText = "Academic website of Weicheng (Victor) Ye"
    [[languages.en.menus.main]]
      name = "Blog"
      pageRef = "/blogs"
      weight = 10
    [[languages.en.menus.main]]
      name = "Contact"
      pageRef = "/contact"
      weight = 20
    [[languages.en.menus.main]]
      name = "Publications"
      url = "/publications/"
      weight = 30

  [languages.zh]
    languageCode = "zh-Hans"
    languageDirection = "ltr"
    label = "中文"
    weight = 2
    title = "叶伟成"
    [languages.zh.params]
      author = "叶伟成"
      role = "博士后研究员"
      affiliation = "加拿大不列颠哥伦比亚大学"
      description = "研究量子相、数学物理、代数拓扑与机器学习。"
      researchStatement = "我运用数学物理、代数拓扑与机器学习研究量子相。"
      footerText = "叶伟成的学术主页"
    [[languages.zh.menus.main]]
      name = "Blog（英文）"
      url = "/blogs/"
      weight = 10
    [[languages.zh.menus.main]]
      name = "联系方式"
      pageRef = "/contact"
      weight = 20
    [[languages.zh.menus.main]]
      name = "发表论文"
      url = "/zh/publications/"
      weight = 30

[markup]
  [markup.goldmark]
    [markup.goldmark.renderer]
      unsafe = false
```

- [ ] **Step 4: Add concise localized content**

Use these exact bodies:

```markdown
<!-- content/_index.md -->
---
title: "Weicheng (Victor) Ye"
description: "Postdoctoral fellow studying quantum phases through mathematical physics, algebraic topology, and machine learning."
---

I am a postdoctoral fellow at the University of British Columbia. My research focuses on the mathematical theory, characterization, and identification of quantum phases, and on applying ideas from quantum phases to other statistical systems.

I use interdisciplinary methods, especially algebraic topology and machine learning. Beyond research, I enjoy travelling and meeting new people—please get in touch if our paths cross.
```

```markdown
<!-- content/_index.zh.md -->
---
title: "叶伟成"
description: "研究量子相、数学物理、代数拓扑与机器学习。"
---

我目前是加拿大不列颠哥伦比亚大学的博士后研究员。我的研究关注量子相的数学理论、表征与识别，并探索如何将量子相的概念应用于其他统计系统。

我的研究融合多种学科方法，尤其是代数拓扑与机器学习。研究之外，我喜欢旅行和结识新朋友；如果我们恰好在同一座城市，欢迎联系我。
```

```markdown
<!-- content/blogs/_index.md -->
---
title: "Blog"
description: "Notes on research, mathematics, physics, and academic life."
---
```

```markdown
<!-- content/contact/_index.md -->
---
title: "Contact"
description: "Contact Weicheng (Victor) Ye."
---

For research discussions, collaborations, or simply to say hello, email is the best way to reach me.
```

```markdown
<!-- content/contact/_index.zh.md -->
---
title: "联系方式"
description: "联系叶伟成。"
---

如果你想讨论研究、合作，或只是打个招呼，电子邮件是联系我的最佳方式。
```

- [ ] **Step 5: Add the complete shared templates**

Implement `layouts/_default/baseof.html`:

```html
<!doctype html>
<html lang="{{ site.Language.LanguageCode }}" dir="{{ site.Language.LanguageDirection }}">
  <head>{{ partial "head.html" . }}</head>
  <body class="kind-{{ .Kind }} section-{{ .Section | default "home" }}">
    <div class="site-shell">
      {{ partial "navigation.html" . }}
      <main id="main-content" class="site-main">{{ block "main" . }}{{ end }}</main>
      {{ partial "footer.html" . }}
    </div>
  </body>
</html>
```

Implement `layouts/partials/head.html`:

```html
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
{{- $description := .Description | default site.Params.description -}}
<title>{{ if .IsHome }}{{ site.Title }}{{ else }}{{ .Title }} · {{ site.Title }}{{ end }}</title>
<meta name="description" content="{{ $description }}">
<meta name="author" content="{{ site.Params.author }}">
<link rel="canonical" href="{{ .Permalink }}">
<meta property="og:type" content="{{ if .IsHome }}website{{ else }}article{{ end }}">
<meta property="og:title" content="{{ .Title | default site.Title }}">
<meta property="og:description" content="{{ $description }}">
<meta property="og:url" content="{{ .Permalink }}">
<meta property="og:image" content="{{ site.Params.profilePicture | absURL }}">
<meta name="twitter:card" content="summary">
{{- $style := resources.Get "css/site.css" | minify | fingerprint -}}
<link rel="stylesheet" href="{{ $style.RelPermalink }}" integrity="{{ $style.Data.Integrity }}">
```

Implement `layouts/partials/social-links.html`:

```html
<ul class="social-links" aria-label="{{ if eq site.Language.Lang "zh" }}个人链接{{ else }}Profile links{{ end }}">
  {{ range site.Params.social }}
    <li><a href="{{ .url }}"{{ if not (hasPrefix .url "mailto:") }} rel="me"{{ end }}>{{ .name }}</a></li>
  {{ end }}
</ul>
```

Implement `layouts/partials/navigation.html`:

```html
<a class="skip-link" href="#main-content">{{ if eq site.Language.Lang "zh" }}跳至正文{{ else }}Skip to content{{ end }}</a>
<aside class="site-sidebar">
  <a class="site-name" href="{{ site.Home.RelPermalink }}">{{ site.Params.author }}</a>
  <nav class="desktop-nav" aria-label="{{ if eq site.Language.Lang "zh" }}主导航{{ else }}Primary navigation{{ end }}">
    {{ range site.Menus.main }}<a href="{{ .URL }}">{{ .Name }}</a>{{ end }}
  </nav>
  <div class="sidebar-meta">
    {{ partial "social-links.html" . }}
    <div class="language-links">
      {{ range .AllTranslations }}{{ if ne .Lang $.Lang }}<a href="{{ .RelPermalink }}">{{ .Language.Label }}</a>{{ end }}{{ end }}
      {{ if and (eq .Section "blogs") (eq .Lang "en") }}<a href="/zh/">中文首页</a>{{ end }}
    </div>
  </div>
</aside>
<header class="mobile-header">
  <a class="site-name" href="{{ site.Home.RelPermalink }}">{{ site.Params.author }}</a>
  <details class="mobile-menu">
    <summary>{{ if eq site.Language.Lang "zh" }}菜单{{ else }}Menu{{ end }}</summary>
    <nav aria-label="{{ if eq site.Language.Lang "zh" }}主导航{{ else }}Primary navigation{{ end }}">
      {{ range site.Menus.main }}<a href="{{ .URL }}">{{ .Name }}</a>{{ end }}
    </nav>
  </details>
</header>
```

Implement `layouts/partials/footer.html`:

```html
<footer class="site-footer"><p>© {{ now.Year }} {{ site.Params.author }} · {{ site.Params.footerText }}</p></footer>
```

- [ ] **Step 6: Add homepage, blog, contact, and fallback layouts**

Implement `layouts/index.html`:

```html
{{ define "main" }}
<article class="profile-page">
  <div class="profile-header">
    <figure class="portrait-wrap"><img class="portrait" src="{{ site.Params.profilePicture | relURL }}" width="327" height="384" alt="{{ if eq site.Language.Lang "zh" }}叶伟成的插画头像{{ else }}Illustrated portrait of Weicheng Ye{{ end }}"></figure>
    <div class="profile-identity">
      <p class="eyebrow">{{ site.Params.role }}</p>
      <h1>{{ site.Params.author }}</h1>
      <p class="affiliation">{{ site.Params.affiliation }}</p>
      <p class="research-statement">{{ site.Params.researchStatement }}</p>
      {{ partial "social-links.html" . }}
    </div>
  </div>
  <div class="profile-bio">{{ .Content }}</div>
</article>
{{ end }}
```

Implement `layouts/blogs/list.html`:

```html
{{ define "main" }}
<header class="page-header"><p class="eyebrow">Writing</p><h1>{{ .Title }}</h1>{{ with .Description }}<p>{{ . }}</p>{{ end }}</header>
<ol class="post-list">
  {{ range .RegularPages.ByDate.Reverse }}
    <li><article><time datetime="{{ .Date.Format "2006-01-02" }}">{{ .Date.Format "2 January 2006" }}</time><h2><a href="{{ .RelPermalink }}">{{ .Title }}</a></h2>{{ with .Summary }}<p>{{ . }}</p>{{ end }}</article></li>
  {{ end }}
</ol>
{{ end }}
```

Implement `layouts/contact/list.html`:

```html
{{ define "main" }}
<article class="contact-page"><header class="page-header"><p class="eyebrow">{{ if eq .Lang "zh" }}保持联系{{ else }}Get in touch{{ end }}</p><h1>{{ .Title }}</h1></header><div class="prose">{{ .Content }}</div><a class="email-link" href="mailto:{{ site.Params.email }}">{{ site.Params.email }}</a>{{ partial "social-links.html" . }}</article>
{{ end }}
```

Implement `layouts/_default/single.html`:

```html
{{ define "main" }}
<article class="article-page"><header class="page-header"><p class="eyebrow">{{ .Section | humanize }}</p><h1>{{ .Title }}</h1>{{ with .Date }}<time datetime="{{ .Format "2006-01-02" }}">{{ .Format "2 January 2006" }}</time>{{ end }}</header><div class="prose">{{ .Content }}</div>{{ if eq .Section "blogs" }}<p class="back-link"><a href="{{ "/blogs/" | relURL }}">← Back to Blog</a></p>{{ end }}</article>
{{ end }}
```

Implement `layouts/_default/list.html` as a safe fallback:

```html
{{ define "main" }}
<header class="page-header"><h1>{{ .Title }}</h1>{{ with .Content }}<div class="prose">{{ . }}</div>{{ end }}</header>
<ol class="post-list">{{ range .RegularPages.ByDate.Reverse }}<li><a href="{{ .RelPermalink }}">{{ .Title }}</a></li>{{ end }}</ol>
{{ end }}
```

Create the initial `assets/css/site.css` baseline:

```css
:root { --color-bg: #f7f6f2; --color-text: #1d252d; --color-accent: #0b5f8a; }
* { box-sizing: border-box; }
body { margin: 0; background: var(--color-bg); color: var(--color-text); }
.site-shell { min-height: 100vh; }
```

- [ ] **Step 7: Run the structure contract**

Run: `bash tests/site_contract.sh structure`

Expected: `PASS: structure contract`. The missing portrait file is intentionally checked only by presentation mode in Task 3.

- [ ] **Step 8: Commit the local shell**

```bash
git add hugo.toml content layouts assets/css/site.css tests/site_contract.sh docs/superpowers/plans/2026-07-11-hugo-personal-site-redesign.md
git commit -m "feat(site): add local Hugo profile shell"
```

---

### Task 2: Structured Publications Archive

**Files:**
- Create: `data/publications.yaml`
- Create: `content/publications/_index.md`
- Create: `content/publications/_index.zh.md`
- Create: `layouts/publications/list.html`

**Interfaces:**
- Consumes: base layout and `.publication-entry` test contract from Task 1.
- Produces: `site.Data.publications`, an ordered array of `{year, papers}`, where every paper has `title`, `url`, `authors`, `venue`, and `links`.

- [ ] **Step 1: Run the publication contract to verify it fails**

Run: `bash tests/site_contract.sh publications`

Expected: `FAIL: missing file .../publications/index.html`.

- [ ] **Step 2: Add localized section metadata**

```markdown
<!-- content/publications/_index.md -->
---
title: "Publications"
description: "Research publications by Weicheng (Victor) Ye."
---
```

```markdown
<!-- content/publications/_index.zh.md -->
---
title: "发表论文"
description: "叶伟成的研究论文。"
---
```

- [ ] **Step 3: Transcribe all 14 publications into structured data**

Create `data/publications.yaml` with groups in this exact order and preserve the current citation wording:

```yaml
- year: 2025
  papers:
    - title: "How to Build Anomalous (3+1)d Topological Quantum Field Theories"
      url: "https://arxiv.org/abs/2510.24834"
      authors: [{name: "Arun Debray"}, {name: "Weicheng Ye", me: true}, {name: "Matthew Yu"}]
      venue: "arXiv preprint (2025)."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2510.24834"}]
    - title: "Universal quantum phase classification on quantum computers from machine learning"
      url: "https://arxiv.org/abs/2508.04774"
      authors: [{name: "Weicheng Ye", me: true}, {name: "Shuwei Liu"}, {name: "Shiyu Zhou"}, {name: "Yijian Zou"}]
      venue: "arXiv preprint (2025)."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2508.04774"}]
    - title: "Global structure in the presence of a topological defect"
      url: "https://arxiv.org/abs/2501.18399"
      authors: [{name: "Arun Debray"}, {name: "Weicheng Ye", me: true}, {name: "Matthew Yu"}]
      venue: "arXiv preprint (2025)."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2501.18399"}]
    - title: "Crystallography, Group Cohomology, and Lieb-Schultz-Mattis Constraints"
      url: "https://doi.org/10.21468/SciPostPhys.18.5.161"
      authors: [{name: "Chunxiao Liu"}, {name: "Weicheng Ye", me: true}]
      venue: "SciPost Physics 18.5 (2025): 161."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2410.03607"}, {label: "GitHub", url: "https://github.com/chxliu/Space-Group-Cohomology-and-LSM"}]
    - title: "Bosonization and Anomaly Indicators of (2+1)-D Fermionic Topological Orders"
      url: "https://arxiv.org/abs/2312.13341"
      authors: [{name: "Arun Debray"}, {name: "Weicheng Ye", me: true}, {name: "Matthew Yu"}]
      venue: "Communications in Mathematical Physics 406, 178 (2025)."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2312.13341"}]
- year: 2024
  papers:
    - title: "Higher obstructions to conformal boundary conditions and lattice realizations"
      url: "https://arxiv.org/abs/2411.11757"
      authors: [{name: "Ruizhi Liu"}, {name: "Weicheng Ye", me: true}]
      venue: "arXiv preprint (2024)."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2411.11757"}]
    - title: "Topological Holography for fermions"
      url: "https://arxiv.org/abs/2404.19004"
      authors: [{name: "Rui Wen"}, {name: "Weicheng Ye", me: true}, {name: "Andrew C. Potter"}]
      venue: "arXiv preprint (2024)."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2404.19004"}]
    - title: "Complexity and order in approximate quantum error-correcting codes"
      url: "https://doi.org/10.1038/s41567-024-02621-x"
      authors: [{name: "Jinmin Yi"}, {name: "Weicheng Ye", me: true}, {name: "Daniel Gottesman"}, {name: "Zi-Wen Liu"}]
      venue: "Nature Physics 20.11 (2024): 1798-1803."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2310.04710"}]
    - title: "Classification of symmetry-enriched topological quantum spin liquids"
      url: "https://doi.org/10.1103/PhysRevX.14.021053"
      authors: [{name: "Weicheng Ye", me: true}, {name: "Liujun Zou"}]
      venue: "Physical Review X 14.2 (2024): 021053."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2309.15118"}, {label: "GitHub", url: "https://github.com/Weicheng-Ye/Classification-of-QSL"}]
- year: 2023
  papers:
    - title: "Anomaly of (2+1)-Dimensional Symmetry-Enriched Topological Order from (3+1)-Dimensional Topological Quantum Field Theory"
      url: "https://doi.org/10.21468/SciPostPhys.15.1.004"
      authors: [{name: "Weicheng Ye", me: true}, {name: "Liujun Zou"}]
      venue: "SciPost Physics 15.1 (2023): 004."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2210.02444"}]
    - title: "Probing sign structure using measurement-induced entanglement"
      url: "https://doi.org/10.22331/q-2023-02-02-910"
      authors: [{name: "Cheng-Ju Lin"}, {name: "Weicheng Ye", me: true}, {name: "Yijian Zou"}, {name: "Shengqi Sang"}, {name: "Timothy H. Hsieh"}]
      venue: "Quantum 7 (2023): 910."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2205.05692"}]
- year: 2022
  papers:
    - title: "Topological characterization of Lieb-Schultz-Mattis constraints and applications to symmetry-enriched quantum criticality"
      url: "https://doi.org/10.21468/SciPostPhys.13.3.066"
      authors: [{name: "Weicheng Ye", me: true}, {name: "Meng Guo"}, {name: "Yin-Chen He"}, {name: "Chong Wang"}, {name: "Liujun Zou"}]
      venue: "SciPost Physics 13.3 (2022): 066."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2111.12097"}, {label: "GitHub", url: "https://github.com/Weicheng-Ye/Classification-of-Stiefel-Liquid"}]
    - title: "Ultraviolet-Infrared Mixing in Marginal Fermi Liquids"
      url: "https://doi.org/10.1103/PhysRevLett.128.106402"
      authors: [{name: "Weicheng Ye", me: true}, {name: "Sung-Sik Lee"}, {name: "Liujun Zou"}]
      venue: "Physical Review Letters 128.10 (2022): 106402. [Editor's Suggestion]"
      links: [{label: "arXiv", url: "https://arxiv.org/abs/2109.00004"}]
- year: 2016
  papers:
    - title: "Quasinormal modes of Gauss-Bonnet black holes at large D"
      url: "https://doi.org/10.1007/JHEP01(2016)085"
      authors: [{name: "Bin Chen"}, {name: "Zhong-Ying Fan"}, {name: "Pengcheng Li"}, {name: "Weicheng Ye", me: true}]
      venue: "Journal of High Energy Physics 2016.1 (2016): 1-27."
      links: [{label: "arXiv", url: "https://arxiv.org/abs/1511.08706"}]
```

- [ ] **Step 4: Render semantic publication entries**

Create `layouts/publications/list.html`:

```html
{{ define "main" }}
<article class="publications-page">
  <header class="page-header"><p class="eyebrow">{{ if eq .Lang "zh" }}研究成果{{ else }}Research archive{{ end }}</p><h1>{{ .Title }}</h1>{{ with .Description }}<p>{{ . }}</p>{{ end }}</header>
  <div class="publication-groups">
    {{ range site.Data.publications }}
      <section class="publication-year" aria-labelledby="year-{{ .year }}">
        <h2 id="year-{{ .year }}">{{ .year }}</h2>
        <ol>
          {{ range .papers }}
            <li class="publication-entry">
              <article>
                <h3><a href="{{ .url }}">{{ .title }}</a></h3>
                <p class="publication-authors">{{ range $index, $author := .authors }}{{ if $index }}, {{ end }}{{ if $author.me }}<strong>{{ $author.name }}</strong>{{ else }}{{ $author.name }}{{ end }}{{ end }}</p>
                <p class="publication-venue">{{ .venue }}</p>
                <ul class="publication-links">{{ range .links }}<li><a href="{{ .url }}">{{ .label }}</a></li>{{ end }}</ul>
              </article>
            </li>
          {{ end }}
        </ol>
      </section>
    {{ end }}
  </div>
</article>
{{ end }}
```

- [ ] **Step 5: Run the publication contract**

Run: `bash tests/site_contract.sh publications`

Expected: `PASS: publications contract` with exactly 14 `.publication-entry` elements.

- [ ] **Step 6: Commit the archive**

```bash
git add data/publications.yaml content/publications layouts/publications/list.html
git commit -m "feat(publications): add structured archive"
```

---

### Task 3: Editorial Responsive Design and Correct Portrait Asset

**Files:**
- Move: `assets/images/profile.png` → `static/images/profile.jpg`
- Modify: `assets/css/site.css`

**Interfaces:**
- Consumes: stable class names from Tasks 1–2.
- Produces: responsive desktop sidebar, mobile disclosure, profile composition, long-form layouts, visible focus, reduced motion, and print presentation.

- [ ] **Step 1: Run the presentation contract to verify it fails**

Run: `bash tests/site_contract.sh presentation`

Expected: `FAIL: missing file .../images/profile.jpg`.

- [ ] **Step 2: Correct the portrait filename and route**

Run:

```bash
mkdir -p static/images
mv assets/images/profile.png static/images/profile.jpg
file static/images/profile.jpg
```

Expected: `JPEG image data` for `static/images/profile.jpg`.

- [ ] **Step 3: Implement the complete restrained visual system**

Replace `assets/css/site.css` with a cohesive implementation containing these exact tokens and selector contracts; values may only be adjusted during Task 5 visual verification:

```css
:root {
  --color-bg: #f4f3ee;
  --color-surface: #fbfaf7;
  --color-text: #17212b;
  --color-muted: #63707a;
  --color-accent: #0b638f;
  --color-accent-dark: #084967;
  --color-rule: #d8d8d1;
  --font-serif: Charter, "Bitstream Charter", "Sitka Text", Cambria, serif;
  --font-sans: "Avenir Next", Avenir, "Segoe UI", "PingFang SC", "Hiragino Sans GB", sans-serif;
  --sidebar-width: 15rem;
  --content-width: 46rem;
  --space-1: .375rem;
  --space-2: .75rem;
  --space-3: 1.125rem;
  --space-4: 1.75rem;
  --space-5: 2.75rem;
  --space-6: 4.5rem;
}

* { box-sizing: border-box; }
html { color-scheme: light; scroll-behavior: smooth; }
body { margin: 0; background: var(--color-bg); color: var(--color-text); font-family: var(--font-sans); font-size: 1rem; line-height: 1.65; text-rendering: optimizeLegibility; }
img { display: block; max-width: 100%; }
a { color: var(--color-accent); text-decoration-thickness: .08em; text-underline-offset: .18em; }
a:hover { color: var(--color-accent-dark); }
a:focus-visible, summary:focus-visible { outline: 3px solid color-mix(in srgb, var(--color-accent) 45%, transparent); outline-offset: 4px; border-radius: 2px; }
.skip-link { position: fixed; top: .75rem; left: .75rem; z-index: 100; transform: translateY(-200%); padding: .6rem .85rem; background: var(--color-text); color: white; }
.skip-link:focus { transform: translateY(0); }
.site-shell { min-height: 100vh; display: grid; grid-template-columns: var(--sidebar-width) minmax(0, 1fr); grid-template-rows: 1fr auto; }
.site-sidebar { grid-row: 1 / -1; min-height: 100vh; position: sticky; top: 0; align-self: start; display: flex; flex-direction: column; padding: var(--space-5) var(--space-4); border-right: 1px solid var(--color-rule); background: var(--color-surface); }
.site-name { color: var(--color-text); font-family: var(--font-serif); font-size: 1.3rem; font-weight: 700; line-height: 1.2; text-decoration: none; }
.desktop-nav { display: flex; flex-direction: column; gap: .25rem; margin-top: var(--space-6); }
.desktop-nav a { width: fit-content; padding: .28rem 0; color: var(--color-text); text-decoration: none; }
.desktop-nav a:hover { color: var(--color-accent); }
.sidebar-meta { margin-top: auto; padding-top: var(--space-5); color: var(--color-muted); font-size: .78rem; }
.social-links { display: flex; flex-wrap: wrap; gap: .35rem .8rem; padding: 0; margin: 0; list-style: none; }
.sidebar-meta .social-links { display: grid; grid-template-columns: 1fr 1fr; }
.language-links { margin-top: var(--space-3); }
.mobile-header { display: none; }
.site-main { width: min(100%, calc(var(--content-width) + 2 * var(--space-5))); padding: var(--space-6) var(--space-5) var(--space-5); }
.site-footer { grid-column: 2; padding: var(--space-3) var(--space-5) var(--space-4); color: var(--color-muted); font-size: .78rem; }
.site-footer p { margin: 0; }
.profile-page { max-width: var(--content-width); }
.profile-header { display: grid; grid-template-columns: 13.5rem minmax(0, 1fr); gap: var(--space-5); align-items: center; }
.portrait-wrap { margin: 0; }
.portrait { width: 100%; aspect-ratio: 327 / 384; object-fit: cover; border: 1px solid var(--color-rule); border-radius: 8px; background: white; box-shadow: 0 14px 35px rgba(23, 33, 43, .08); }
.eyebrow { margin: 0 0 var(--space-2); color: var(--color-accent); font-size: .75rem; font-weight: 700; letter-spacing: .11em; text-transform: uppercase; }
h1, h2, h3 { font-family: var(--font-serif); line-height: 1.18; text-wrap: balance; }
h1 { margin: 0; font-size: clamp(2.35rem, 5vw, 4rem); letter-spacing: -.035em; }
.affiliation { margin: var(--space-1) 0 0; color: var(--color-muted); }
.research-statement { max-width: 31rem; margin: var(--space-3) 0; font-family: var(--font-serif); font-size: 1.18rem; line-height: 1.48; }
.profile-identity .social-links { margin-top: var(--space-3); }
.profile-bio { max-width: 43rem; margin-top: var(--space-5); padding-top: var(--space-4); border-top: 1px solid var(--color-rule); }
.profile-bio p { margin: 0 0 .8rem; }
.page-header { max-width: 40rem; margin-bottom: var(--space-5); padding-bottom: var(--space-4); border-bottom: 1px solid var(--color-rule); }
.page-header h1 { font-size: clamp(2.4rem, 6vw, 4.8rem); }
.page-header > p:last-child { color: var(--color-muted); }
.prose { max-width: 68ch; font-family: var(--font-serif); font-size: 1.08rem; }
.prose h2, .prose h3 { margin-top: 2.2em; }
.prose p, .prose ul, .prose ol { margin: 0 0 1.2em; }
.post-list, .publication-groups ol { padding: 0; margin: 0; list-style: none; }
.post-list li { padding: var(--space-4) 0; border-bottom: 1px solid var(--color-rule); }
.post-list time { color: var(--color-muted); font-size: .8rem; letter-spacing: .04em; }
.post-list h2 { margin: .25rem 0 .5rem; font-size: 1.55rem; }
.post-list h2 a, .publication-entry h3 a { color: var(--color-text); text-decoration: none; }
.post-list h2 a:hover, .publication-entry h3 a:hover { color: var(--color-accent); }
.post-list p { max-width: 62ch; margin: 0; color: var(--color-muted); }
.contact-page .email-link { display: inline-block; margin: var(--space-3) 0 var(--space-4); font-family: var(--font-serif); font-size: clamp(1.25rem, 3vw, 2rem); }
.publication-year { display: grid; grid-template-columns: 4rem minmax(0, 1fr); gap: var(--space-4); margin-bottom: var(--space-5); }
.publication-year > h2 { position: sticky; top: 1.5rem; align-self: start; margin: 0; color: var(--color-muted); font-family: var(--font-sans); font-size: .82rem; letter-spacing: .08em; }
.publication-entry { padding: 0 0 var(--space-4); margin-bottom: var(--space-4); border-bottom: 1px solid var(--color-rule); }
.publication-entry h3 { margin: 0 0 .45rem; font-size: 1.18rem; }
.publication-authors, .publication-venue { margin: .2rem 0; color: var(--color-muted); font-size: .91rem; }
.publication-authors strong { color: var(--color-text); }
.publication-links { display: flex; gap: .55rem; padding: 0; margin: .65rem 0 0; list-style: none; }
.publication-links a { display: inline-block; padding: .12rem .45rem; border: 1px solid var(--color-rule); border-radius: 3px; font-size: .75rem; text-decoration: none; }
.back-link { margin-top: var(--space-5); padding-top: var(--space-3); border-top: 1px solid var(--color-rule); }

@media (max-width: 800px) {
  .site-shell { display: block; }
  .site-sidebar { display: none; }
  .mobile-header { display: flex; position: sticky; top: 0; z-index: 20; align-items: center; justify-content: space-between; min-height: 4rem; padding: .8rem 1.1rem; border-bottom: 1px solid var(--color-rule); background: color-mix(in srgb, var(--color-surface) 94%, transparent); backdrop-filter: blur(12px); }
  .mobile-menu { position: relative; }
  .mobile-menu summary { cursor: pointer; color: var(--color-text); font-size: .85rem; font-weight: 700; list-style: none; }
  .mobile-menu summary::-webkit-details-marker { display: none; }
  .mobile-menu nav { position: absolute; top: 2.45rem; right: 0; min-width: 12rem; display: grid; padding: .65rem; border: 1px solid var(--color-rule); border-radius: 5px; background: var(--color-surface); box-shadow: 0 18px 45px rgba(23, 33, 43, .12); }
  .mobile-menu nav a { padding: .65rem .75rem; color: var(--color-text); text-decoration: none; }
  .site-main { width: 100%; padding: var(--space-5) 1.2rem; }
  .site-footer { padding: var(--space-3) 1.2rem var(--space-4); }
  .profile-header { grid-template-columns: minmax(8.5rem, 11rem) minmax(0, 1fr); gap: var(--space-4); }
  h1 { font-size: clamp(2.1rem, 8vw, 3.3rem); }
}

@media (max-width: 540px) {
  .site-main { padding-top: var(--space-4); }
  .profile-header { grid-template-columns: 1fr; align-items: start; }
  .portrait-wrap { width: min(11.5rem, 54vw); }
  .profile-bio { margin-top: var(--space-4); }
  .publication-year { grid-template-columns: 1fr; gap: var(--space-3); }
  .publication-year > h2 { position: static; padding-bottom: .4rem; border-bottom: 1px solid var(--color-rule); }
}

@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
  *, *::before, *::after { scroll-behavior: auto !important; transition-duration: .01ms !important; }
}

@media print {
  body { background: white; }
  .site-shell { display: block; }
  .site-sidebar, .mobile-header, .site-footer { display: none; }
  .site-main { width: 100%; padding: 0; }
  a { color: inherit; }
}
```

- [ ] **Step 4: Run the presentation contract**

Run: `bash tests/site_contract.sh presentation`

Expected: `PASS: presentation contract`.

- [ ] **Step 5: Commit the visual system**

```bash
git add -A assets/css/site.css assets/images/profile.png static/images/profile.jpg
git commit -m "style(site): add editorial responsive design"
```

---

### Task 4: Repository and GitHub Pages Hygiene

**Files:**
- Modify and force-add: `.gitignore`
- Delete: `.gitmodules`, `go.mod`, `go.sum`, `.DS_Store`, `.github/.DS_Store`, `.hugo_build.lock`, tracked `public/`
- Modify: `.github/workflows/hugo.yaml`
- Modify: `README.md`

**Interfaces:**
- Consumes: dependency-free local Hugo site from Tasks 1–3.
- Produces: clean source-only repository and a deterministic Pages workflow on Hugo 0.164.0.

- [ ] **Step 1: Run the repository contract to verify it fails**

Run: `bash tests/site_contract.sh repository`

Expected: failure because module files and tracked `public/` still exist.

- [ ] **Step 2: Replace `.gitignore` while retaining local assistant exclusions**

Use this exact content and remove the prior rule that ignores `.gitignore` itself:

```gitignore
# Hugo output
/public/
/resources/_gen/
.hugo_build.lock

# Local planning and assistant state
.claude/
.agent/
.agents/
.codex/
.worktrees/
.superpowers/
CLAUDE.md
AGENTS.md
notes.md
task_plan.md

# Operating systems and editors
.DS_Store
.AppleDouble
.LSOverride
._*
Thumbs.db
ehthumbs.db
Desktop.ini
.vscode/
.idea/
*.swp
*.swo
*~
*.bak
```

- [ ] **Step 3: Remove stale dependencies and generated output**

Run the explicitly approved cleanup:

```bash
git rm -r public .gitmodules go.mod go.sum .DS_Store .github/.DS_Store .hugo_build.lock
git add -f .gitignore
```

Expected: tracked deletions for stale output/module metadata and staged `.gitignore`; source content remains untouched.

- [ ] **Step 4: Simplify the Pages workflow**

Replace `.github/workflows/hugo.yaml` with:

```yaml
name: Deploy Hugo site to Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      HUGO_VERSION: 0.164.0
    steps:
      - name: Install Hugo CLI
        run: |
          wget -O "${{ runner.temp }}/hugo.deb" "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
          sudo dpkg -i "${{ runner.temp }}/hugo.deb"
      - name: Checkout
        uses: actions/checkout@v7
        with:
          fetch-depth: 0
      - name: Configure Pages
        id: pages
        uses: actions/configure-pages@v6
      - name: Build with Hugo
        env:
          HUGO_ENVIRONMENT: production
        run: hugo --gc --minify --panicOnWarning --baseURL "${{ steps.pages.outputs.base_url }}/"
      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v5
        with:
          path: public

  deploy:
    environment:
      name: github-pages
      url: "${{ steps.deployment.outputs.page_url }}"
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v5
```

- [ ] **Step 5: Replace starter README**

Write `README.md` with exact project commands and deployment ownership:

````markdown
# Weicheng (Victor) Ye — Academic Website

Personal academic website built with Hugo and deployed to GitHub Pages.

## Local development

Requires Hugo Extended 0.164.0.

```bash
hugo server
```

Open `http://localhost:1313/`.

## Verification

```bash
bash tests/site_contract.sh all
```

The contract performs a clean production build and validates routes, localized navigation, publication count, local assets, and repository hygiene.

## Deployment

Pushes to `main` trigger `.github/workflows/hugo.yaml`. GitHub Actions builds the `public/` artifact and deploys it through GitHub Pages; generated output is not committed.
````

- [ ] **Step 6: Run repository and full contracts**

Run:

```bash
bash tests/site_contract.sh repository
bash tests/site_contract.sh all
```

Expected: both commands print `PASS` and exit zero.

- [ ] **Step 7: Commit repository cleanup**

```bash
git add .github/workflows/hugo.yaml README.md tests/site_contract.sh
git commit -m "chore(site): simplify Hugo deployment"
```

---

### Task 5: Visual, Accessibility, and Production Verification

**Files:**
- Modify only when verification exposes a defect: `assets/css/site.css`, templates, or localized content.
- Do not add generated `public/` output.

**Interfaces:**
- Consumes: complete source site and contract suite.
- Produces: verified responsive site ready to push.

- [ ] **Step 1: Run fresh automated verification**

Run:

```bash
bash tests/site_contract.sh all
hugo --environment production --destination /tmp/weicheng-site-verify --cleanDestinationDir --panicOnWarning
if rg -n 'localhost|livereload|googleapis|cdnjs|jsdelivr' /tmp/weicheng-site-verify; then exit 1; fi
git diff --check
```

Expected: contract `PASS`, Hugo exit 0 with no warnings, forbidden-origin scan empty, and diff check empty.

- [ ] **Step 2: Start the local preview**

Run: `hugo server --bind 127.0.0.1 --port 1313 --disableFastRender`

Expected: server reports the English and Chinese site and listens on `http://127.0.0.1:1313/`.

- [ ] **Step 3: Inspect representative pages at exact viewport sizes**

Using the in-app browser, inspect:

- `/` at 1366×768: profile content visible without vertical scroll; sidebar shows Blog, Contact, Publications.
- `/` at 768×1024 and 390×844: no horizontal overflow; native Menu disclosure exposes the same links.
- `/publications/` and `/zh/publications/`: 14 readable entries grouped by year.
- `/contact/` and `/zh/contact/`: correct confirmed email and no phone number.
- `/blogs/` plus one post: readable metadata/prose; Chinese fallback behaviour is truthful.

Also tab through navigation and links, toggle the native disclosure, emulate reduced motion, and disable JavaScript to confirm navigation remains available.

- [ ] **Step 4: Fix only observed defects and re-run their proving checks**

For each defect, record the viewport and symptom, change the smallest responsible selector/template, then rerun `bash tests/site_contract.sh all` plus the exact visual interaction. Do not add ornamental features.

- [ ] **Step 5: Review the full implementation diff**

Run:

```bash
git status --short --branch
git diff --stat origin/main...HEAD
git diff --check origin/main...HEAD
git ls-files public
```

Expected: only intended source/spec/plan changes, no whitespace errors, and no tracked `public` files.

- [ ] **Step 6: Commit verification fixes only if files changed**

```bash
git add assets/css/site.css layouts content
git commit -m "fix(site): address responsive verification"
```

Skip this commit when verification required no code changes.

---

### Task 6: Push and Verify GitHub Pages Deployment

**Files:** None unless deployment reveals a source defect.

**Interfaces:**
- Consumes: verified commits on local `main`.
- Produces: updated `origin/main` and live `https://weicheng-ye.github.io/`.

- [ ] **Step 1: Verify origin and push credentials**

Run:

```bash
git remote get-url origin
git ls-remote --exit-code origin HEAD
git push --dry-run origin main
```

Expected: remote is `https://github.com/Weicheng-Ye/Weicheng-Ye.github.io.git`; read and dry-run succeed. If push authentication fails, request user re-authentication rather than changing the remote or credentials.

- [ ] **Step 2: Push main**

Run: `git push origin main`

Expected: remote advances to the final local commit.

- [ ] **Step 3: Monitor the public Pages workflow**

Because `gh auth status` is currently invalid, use the public repository Actions endpoint or GitHub web source to identify the workflow run for the pushed commit and wait until both build and deploy complete successfully.

- [ ] **Step 4: Verify the live site**

Fetch `https://weicheng-ye.github.io/`, `/publications/`, `/contact/`, and `/zh/`. Confirm HTTP 200, new sidebar/navigation copy, new stylesheet, confirmed email, and no starter-theme or localhost references.

- [ ] **Step 5: Report final commit and deployment evidence**

Include the final commit hash, automated test result, Pages workflow result, and live URL in the user handoff.
