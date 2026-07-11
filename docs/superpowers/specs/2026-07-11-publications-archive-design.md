# Publications Archive Redesign

## Goal

Turn `/publications/` into a full-width, filterable publication archive while leaving the homepage, blog, navigation, footer, and all other pages unchanged.

## Scope

1. Remove the desktop profile card only from `/publications/`; keep it on every other page.
2. Render the 14 existing publications as individual cards across the full available page width.
3. Replace the `Mathematics` category name with `Mathematical Physics`.
4. Add filter buttons: `All (14)`, `Mathematical Physics (6)`, `Machine Learning (1)`, and `Physics (7)`.
5. Filter cards in the browser without a page reload. `All` displays all cards; each subject button displays only its category.
6. Remove the visible `Result.` label. Preserve each existing description as italic text with visual separation from the bibliographic information and link buttons.
7. Replace icon/badge-only publication links with accessible text pills: `arXiv`, the actual publisher or journal name for published papers, and the existing repository names where available.

## Architecture

- Add a section-specific Hugo base layout under `layouts/publications/` that reuses the site header, mobile navigation, and footer but omits the profile-card aside.
- Add a section-specific list template under `layouts/publications/` that owns the publication archive markup and filter controls.
- Store the existing publication metadata in the Publications page source, then render it into cards from the custom template. Preserve title, authors, venue, status, description, arXiv URL, published URL, and repository URL.
- Add publication-scoped CSS and JavaScript assets. The base layout loads them only for the Publications section.
- Use `data-category` attributes on cards and accessible `<button>` controls with `aria-pressed` for filtering. If JavaScript is unavailable, all cards remain visible.

## Visual design

- Keep the existing site typography and light/dark-mode variables.
- Use a restrained academic-card treatment inspired by the supplied reference: compact outlined filter pills, generous spacing, a subtle background contrast for each card, a thin border, and a clear title hierarchy.
- Make the link pills look like deliberate controls rather than external badges. The publisher pill displays the actual venue name, such as `Nature Physics` or `SciPost Physics`.
- On narrow screens, cards and filters wrap naturally and preserve touch-friendly targets.

## Data and category mapping

| Category | Count | Papers |
| --- | ---: | --- |
| Mathematical Physics | 6 | Anomalous TQFTs; global topological defects; withdrawn conformal-boundary manuscript; crystallography/LSM; bosonization/anomaly indicators; approximate QEC complexity. |
| Machine Learning | 1 | Universal quantum phase classification. |
| Physics | 7 | Fermionic topological holography; symmetry-enriched spin liquids; anomaly indicators; sign structure; LSM constraints; marginal Fermi liquids; Gauss–Bonnet quasinormal modes. |

## Accessibility and behavior

- Every filter control has a clear accessible name and reflects its selected state with `aria-pressed`.
- Hidden cards use the `hidden` attribute so keyboard and screen-reader users do not encounter filtered-out items.
- Published-version and repository links retain descriptive labels; the visible journal button is not icon-only.
- The withdrawn status remains visible on its card.

## Verification

- Extend the existing publication regression test to verify the page-specific full-width markers, filter labels/counts, all 14 cards, category assignments, italic descriptions without `Result.`, and publisher-name link pills.
- Build with Hugo using a temporary destination, then inspect the rendered HTML.
- Test filtering and responsive layouts in a local browser at desktop, tablet, and mobile widths.
- Confirm that non-publication pages still render the profile card.

## Non-goals

- Do not alter publication titles, citations, source links, research descriptions, or the homepage’s separate representative-publications block.
- Do not change global fonts, the overall site theme, the navigation, the footer, or the Chinese homepage.
