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
