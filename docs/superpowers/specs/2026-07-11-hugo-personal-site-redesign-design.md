# Hugo Personal-Site Redesign

## Objective

Reorganize Weicheng (Victor) Ye's Hugo website into a concise academic profile inspired by the visual clarity of Max Welling's AMLab page. The result will retain Hugo and GitHub Pages while replacing the current starter-theme presentation with a small, repository-owned design system.

## Scope

The redesign includes:

- a short homepage whose primary profile content fits without scrolling at a 1366×768 desktop viewport; the footer does not need to fit within that viewport;
- persistent navigation containing Home, Blog, Contact, and Publications, with only Blog, Contact, and Publications presented as section links;
- dedicated Blog, Contact, and Publications pages;
- responsive desktop and mobile layouts;
- preserved English and Chinese experiences for the homepage, contact information, and publications;
- repository and deployment cleanup needed for reliable Hugo builds on GitHub Pages.

Joining and People pages are explicitly excluded. Detailed education, talks, and news will not remain on the homepage. The existing CV file and source content will remain available in the repository, but the redesign will not add a public CV link.

## Chosen Architecture

The project will use local Hugo templates and assets rather than the current remote `zero-academic-page` theme module. Local ownership is preferred because the requested navigation, restrained layout, and page-specific information architecture differ substantially from the existing theme. A small local implementation also removes network dependency from normal builds and makes future edits understandable from this repository alone.

The main units are:

1. **Base layout** — document metadata, shared sidebar/header, content region, and footer.
2. **Navigation partial** — desktop sidebar and mobile header generated from Hugo menus and translations.
3. **Homepage layout** — compact profile composition with portrait, identity, research summary, biography, and external links.
4. **List and single layouts** — consistent rendering for Blog, Contact, Publications, and blog posts.
5. **Site stylesheet** — typography, color variables, layout, responsive behavior, accessibility states, and print rules.

Content remains in Markdown. Presentation logic remains in Hugo layouts. No client framework or runtime package manager is introduced.

## Information Architecture

### Desktop navigation

A slim left sidebar contains:

- the researcher's name as the Home link;
- Blog;
- Contact;
- Publications;
- a compact language switcher and social links below the primary navigation.

The section-link list contains exactly Blog, Contact, and Publications, matching the request. The sidebar remains visible while the main document scrolls.

### Mobile navigation

Below the desktop breakpoint, the sidebar becomes a compact top header. A native `<details>`/`<summary>` disclosure reveals the same three section links and remains operable from the keyboard and without JavaScript. No navigation script is required; following a link loads the destination document with the disclosure closed.

### Homepage

The homepage contains:

- the existing illustrated portrait, shown as a softly rounded rectangular image rather than a circular card avatar;
- `Weicheng (Victor) Ye`;
- `Postdoctoral Fellow at the University of British Columbia`;
- the research statement: “I study quantum phases through mathematical physics, algebraic topology, and machine learning.”;
- a compact biography edited only from existing homepage facts: “I am a postdoctoral fellow at the University of British Columbia. My research focuses on the mathematical theory, characterization, and identification of quantum phases, and on applying ideas from quantum phases to other statistical systems. I use interdisciplinary methods, especially algebraic topology and machine learning. Beyond research, I enjoy travelling and meeting new people—please get in touch if our paths cross.”;
- direct links to email, Google Scholar, GitHub, and LinkedIn.

News, the full publication list, education, and invited talks are removed from the landing page. Their source information is retained through the publication page, CV, or repository history.

### Publications

The Publications page preserves all 14 existing entries and their DOI, arXiv, and project-repository links. Entries are grouped by year in reverse chronological order. Each entry uses semantic citation markup with the title as the primary link, authors, venue/status, and compact text links for supporting resources. Weicheng Ye's name is visually emphasized without relying on badge images.

The implementation will preserve the source's bibliographic wording except for unambiguous typographical fixes. Suspected factual inconsistencies, including the SciPost volume/issue text, will not be silently rewritten without a trustworthy source.

### Contact

The Contact page publishes `victorye963@gmail.com` as confirmed by the user. It also links to Google Scholar, GitHub, and LinkedIn. It will not expose the phone number found in the CV or add a contact form.

### Blog

The Blog page remains at `/blogs/` to preserve existing links and lists the two existing English posts in reverse chronological order with title, date, and summary. Blog post pages use the same reading width and typography as the rest of the site. Contact and Publications use `/contact/` and `/publications/`; their Chinese translations use `/zh/contact/` and `/zh/publications/`. The Chinese Blog navigation item uses the explicit root-relative URL `/blogs/`, not a localized URL, and is labelled `Blog（英文）`. On English-only blog routes, the language control links to `/zh/` and is labelled `中文首页` rather than implying that a translated post exists.

## Visual Direction

The design is editorial academic minimalism: quiet, precise, and content-led.

- Background: warm off-white with white content surfaces used sparingly.
- Text: near-black charcoal with softer gray metadata.
- Accent: one restrained research-blue used for links, active states, and small rules.
- Typography: a characterful platform serif stack for primary headings and a highly readable platform sans-serif stack for navigation and body copy, with robust Chinese fallbacks.
- Composition: generous negative space, a 65–75-character reading measure, modest heading scale, and subtle one-pixel dividers.
- Image treatment: softly rounded corners and a light border/shadow, echoing the reference without copying its Bootstrap styling.
- Motion: short disclosure and link-state transitions only, disabled when `prefers-reduced-motion` is active. Page content is visible in its base state and does not animate into view.

The design will not use gradients, glass cards, decorative badges, oversized hero text, or ornamental animations.

The rendered site will have no runtime font, icon, JavaScript, or stylesheet dependencies on third-party CDNs. Social links use accessible text and repository-owned inline SVG where an icon adds value.

## Responsive and Accessibility Requirements

- Sidebar and profile composition must adapt cleanly from wide desktop through tablet and narrow mobile widths.
- Navigation, language switcher, and all links must be keyboard accessible and have visible focus styles.
- The mobile menu must use native disclosure semantics, remain available without JavaScript, and expose accurate expanded state.
- Text and interactive colors must meet WCAG AA contrast against their backgrounds.
- Images require useful alternative text and fixed dimensions or aspect ratios to reduce layout shift.
- External links that open a new context must be identified consistently; unnecessary new-tab behavior will be avoided.
- The site must remain readable with JavaScript disabled and with reduced motion requested.

## Content and Localization

English remains the default language. Existing Chinese homepage and publication content will be reorganized into the same page structure rather than discarded. Navigation labels, profile metadata, Contact copy, and footer text will be translated through Hugo's content and data mechanisms.

The canonical public email is `victorye963@gmail.com`. Existing links to Google Scholar, GitHub, and LinkedIn remain canonical. The illustrated portrait remains the profile image unless the user later supplies a photograph.

The current portrait contains JPEG data despite its `.png` suffix. Implementation will rename it to `.jpg` and update every template and metadata reference so the filename and media type agree.

## Repository and Deployment Changes

- Correct the production base URL and site titles in Hugo configuration.
- Pin CI to Hugo Extended 0.164.0, matching the local version used for implementation verification.
- Remove the unused remote theme module and vestigial submodule declarations when local layouts are in place.
- Add a focused `.gitignore` for Hugo build output and operating-system metadata.
- Commit the deletion of the currently tracked `public/` development output, then ignore `public/` so regenerated build artifacts are not added again. GitHub Actions remains the sole producer of deployment artifacts.
- Simplify the GitHub Pages workflow to the dependencies actually required by the site.
- Update the README so local development and Pages deployment instructions match reality.

Pushing the implementation commit to `main` triggers the existing GitHub Pages workflow. Before the final commit, verify that Git credentials can reach the configured origin. The GitHub CLI token is currently invalid, so deployment monitoring will use the repository's public Actions and Pages endpoints unless the push itself requires the user to re-authenticate. Deployment is considered successful only after the Pages workflow completes and the live site responds with the new structure.

## Verification

Before implementation is committed and pushed:

1. Run a clean production Hugo build using the CI-pinned version or verify compatibility with that version.
2. Treat build errors, missing translations, duplicate output paths, and broken template references as failures.
3. Inspect generated HTML to confirm canonical URLs, language links, navigation destinations, metadata, and absence of localhost/livereload references.
4. Check all internal links and the existence of referenced local assets.
5. Visually inspect homepage, Publications, Contact, Blog, and one blog post at 1366×768 desktop, tablet, and narrow mobile viewport sizes; confirm the desktop profile content fits without scrolling at 1366×768.
6. Verify keyboard navigation, mobile-menu state, focus visibility, reduced-motion behavior, and no-JavaScript readability.
7. Review the final Git diff to ensure the intentional deletion of previously tracked `public/` files is present while regenerated build output and unrelated files are absent.
8. Push to `main`, monitor the GitHub Pages workflow, and verify the deployed URL.

## Acceptance Criteria

- The homepage is concise and no longer presents the full CV-style content stream.
- The homepage's primary profile content fits without scrolling at 1366×768; the footer is permitted to fall below the fold.
- Desktop navigation presents Blog, Contact, and Publications in a slim sidebar; mobile presents equivalent navigation in a compact header.
- Dedicated Blog, Contact, and Publications routes render correctly in English, with appropriate Chinese equivalents or a clearly labelled English-blog fallback.
- All 14 publications and their existing resource links remain accessible.
- The Contact page uses `victorye963@gmail.com` and does not expose private phone data.
- The site is responsive, keyboard accessible, readable without JavaScript, and respectful of reduced-motion preferences.
- The portrait is served as a `.jpg` with matching JPEG content, and the rendered site has no third-party CDN dependencies.
- A production Hugo build succeeds without localhost or livereload references in generated output.
- GitHub Pages deploys the implementation from `main`, and the live site reflects the redesign.
