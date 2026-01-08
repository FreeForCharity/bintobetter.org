# GitHub Pages Deployment Fix

## Issue Description

When navigating to `https://bintobetter.org`, users were seeing the rendered README.md file instead of the actual BinToBetter HTML website.

![Issue Screenshot](https://github.com/user-attachments/assets/707e90b1-13c7-4b02-8889-82f735a503e1)

## Root Cause

A duplicate `CNAME` file existed in the repository root directory (`/CNAME`), which was conflicting with the correct `CNAME` file located in the deployment directory (`/html-site/CNAME`).

This caused GitHub Pages to serve content from the repository root instead of the intended `html-site/` directory, resulting in the README.md being displayed as the homepage.

## Solution

**Removed the root CNAME file** to ensure GitHub Pages serves content exclusively from the `html-site/` directory as configured in the deployment workflow.

### File Structure Before Fix
```
/ (root)
├── CNAME                    ❌ PROBLEM: Conflicting CNAME
├── README.md
├── html-site/
│   ├── CNAME                ✅ Correct CNAME for deployment
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── ...
└── .github/
    └── workflows/
        └── deploy.yml       (deploys from ./html-site)
```

### File Structure After Fix
```
/ (root)
├── README.md
├── html-site/
│   ├── CNAME                ✅ Only CNAME (bintobetter.org)
│   ├── index.html
│   ├── .nojekyll            (prevents Jekyll processing)
│   ├── css/
│   ├── js/
│   └── ...
└── .github/
    └── workflows/
        └── deploy.yml       (deploys from ./html-site)
```

## Technical Details

### Deployment Workflow Configuration
The `.github/workflows/deploy.yml` is correctly configured to deploy from the `html-site/` directory:

```yaml
- name: Upload artifact for Pages
  uses: actions/upload-pages-artifact@v4
  with:
    path: ./html-site  # Deploys HTML site, not root
```

### CNAME Configuration
- **Location**: `html-site/CNAME`
- **Content**: `bintobetter.org`
- **Purpose**: Configures GitHub Pages to serve the site at the custom apex domain

### Jekyll Processing
The `html-site/.nojekyll` file prevents GitHub Pages from processing the site with Jekyll, ensuring the pure HTML files are served as-is.

## Verification

After this fix is deployed:

1. **Deployment will succeed**: GitHub Actions workflow will upload only the `html-site/` directory
2. **Website will load correctly**: `https://bintobetter.org` will serve `html-site/index.html`
3. **README won't be served**: Only content from `html-site/` will be accessible on the live site

## Testing

To verify the fix works locally:

```bash
# Check only one CNAME exists in html-site/
find . -name "CNAME" -type f
# Expected output: ./html-site/CNAME (and ./assets-backup/public/CNAME)

# Verify html-site has required files
ls -la html-site/
# Should see: index.html, CNAME, .nojekyll, css/, js/, images/, etc.
```

## Related Issues

This issue was previously addressed in PR #10 ("Fix GitHub Pages deployment - remove root CNAME causing README to be served") on 2026-01-02, but the root CNAME file was re-added after that merge, causing the problem to recur.

## Prevention

To prevent this issue from happening again:

1. **Never add a CNAME file to the repository root**
2. **Keep CNAME only in `html-site/` directory**
3. **Deployment workflow is already correctly configured** - do not modify the `path: ./html-site` setting

## Deployment Timeline

- **Fix committed**: This PR
- **Deployment trigger**: Automatic on merge to `main` branch
- **Expected resolution time**: 1-2 minutes after merge (GitHub Pages propagation)
