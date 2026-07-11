# AGENTS.md

## Project overview

This repository is a multilingual Hugo personal website. It uses the external Hugo module [`github.com/geekifan/zero-academic-page`](https://github.com/geekifan/zero-academic-page) at v1.0.1; there is no local application code, Node project, or hand-written site layout in this repository.

Treat `hugo.toml`, the content files, `go.mod`, the focused test, and the GitHub Actions workflow as the operational source of truth. `README.md` is inherited starter-template documentation and contains stale deployment guidance.

## Repository map

| Path | Role |
| --- | --- |
| `hugo.toml` | Hugo configuration: languages, menus, site parameters, social links, module import, and markup policy. |
| `content/_index.md` | English home page (`/`): About, News, representative publications, Education, and Invited Talks. |
| `content/_index.zh.md` | Chinese home page (`/zh/`). |
| `content/publications/_index.md` | Standalone English publications archive (`/publications/`). |
| `content/blogs/*.md` | English blog posts (`/blogs/<slug>/`); Hugo creates the section list automatically. |
| `assets/images/profile.png` | Profile asset processed by Hugo Pipes and emitted as `/images/profile.png`. The file contains JPEG data despite its extension. |
| `tests/publications_page.sh` | Regression contract for the English homepage link and the standalone publications archive. |
| `.github/workflows/hugo.yaml` | GitHub Pages build and deployment workflow. |
| `go.mod`, `go.sum` | Hugo-module dependency definition and checksum lock. |
| `Resume_WY_Postdoc.pdf` | Tracked CV source at the repository root; it is not currently referenced or emitted by Hugo. |
| `public/` | Generated Hugo output. Some historical output is tracked, but it is not the authoritative site source. |

## Routing and content rules

- English is the default language. The English navigation sends **Publications** to `/publications`.
- Chinese has a translated home page only. Its Publications menu currently targets the `#publications` anchor on `/zh/`; there is no translated standalone publications page.
- `disableKinds = ["taxonomy", "term", "RSS"]` in `hugo.toml`; do not expect category/tag listing pages or an RSS feed unless the configuration changes.
- The homepage's representative-publications block and `content/publications/_index.md` are separate, manually maintained content. Update both only when the requested scope includes both.
- Homepage anchors such as `{#about-me}`, `{#news}`, and `{#publications}` are navigation contracts with `hugo.toml`. Change their matching menu links if an anchor is renamed.
- Goldmark is configured with `unsafe = true`, so raw HTML in Markdown is intentional. The publications archive uses it for line breaks, accessibility labels, badges, and icons; retain valid, accessible HTML when editing it.

## Theme and styling

- The external module supplies the base, home, list, and single layouts; navbar/mobile navigation; profile card; head/footer; CSS; and JavaScript. It also loads Font Awesome and Lato from CDNs.
- There are no local `layouts/`, `themes/`, `static/`, `data/`, `i18n/`, or `archetypes/` directories. To override theme behavior, add a local file at the same relative path as the module template or asset rather than editing generated files.
- `hugo.toml` includes `customCSS = ["css/custom.css"]`, but this module version does not consume that setting and no such asset exists. Adding `assets/css/custom.css` alone will not affect the page; override the theme head partial or the relevant theme asset deliberately.
- `enableDarkMode` is likewise not read by this theme version; the theme's JavaScript always provides the theme toggle.

## Build, test, and preview

Use the smallest relevant command before handing off a change:

```bash
# Focused contract for the publications page
bash tests/publications_page.sh

# Isolated local build without overwriting repository output
output_dir=$(mktemp -d /tmp/hugo-site.XXXXXX)
hugo --minify --baseURL "https://example.test/" --destination "$output_dir" --cleanDestinationDir

# Local development preview (writes generated output and can dirty public/)
hugo server -D --baseURL "http://localhost:1313/"
```

`hugo.toml` still has the starter base URL, so pass an explicit base URL for a root-local preview or an isolated build. The local Hugo version may also be newer than CI. CI currently pins Hugo Extended 0.145.0, while local Hugo can report deprecation warnings for `languages.*.languageName`. Keep changes compatible with the CI version and do not treat existing warnings as a reason to make unrelated configuration changes.

## Deployment

Pushing to `main` triggers `.github/workflows/hugo.yaml`; manual dispatch is also available. The workflow checks out recursively, installs Hugo Extended and Dart Sass, sets `HUGO_ENVIRONMENT=production` and `HUGO_ENV=production`, builds with `hugo --gc --minify` using the GitHub Pages base URL, uploads `./public`, and deploys it using GitHub Pages actions.

There is no package manifest, Makefile, or project-specific script runner. The workflow has no pull-request trigger, so run the focused test and a local build before merging or pushing.

## Working-tree and Git hygiene

- Do **not** hand-edit or bulk-stage `public/`. Local preview output may contain `localhost`, live-reload, or starter-base-URL references and is often intentionally dirty.
- Preserve existing uncommitted files unless the user explicitly asks to change or discard them. In particular, inspect `git status` before any Git operation.
- The local `.gitignore` in this checkout is itself untracked and ignored. It ignores new Markdown, test, PDF, docs, temp, and worktree files. Check `git check-ignore -v <path>` when a new file does not appear in `git status`.
- A newly created Markdown file may require `git add -f <path>` to share it. Do not alter the local ignore policy unless that is part of the requested work.
- `.gitmodules` names legacy themes, but the current Git tree has no theme gitlinks or `themes/` directory. The active theme is the Go module in `go.mod`.
- Follow the repository's recent Conventional Commit-style messages (`feat:`, `fix:`, `test:`, `chore:`) and stage only the files intended for the change.
