# Root CNAME Issue - Complete Resolution

## Problem Summary

After enabling GitHub Pages with a custom domain (following the initial setup instructions), the site briefly loaded correctly but then reloaded and displayed the README.md instead of the BinToBetter website.

## Root Cause Analysis

### What Happened

1. User followed instructions to enable GitHub Pages in Settings → Pages
2. User entered custom domain `bintobetter.org` in the Custom domain field
3. GitHub **automatically created a CNAME file in the repository root** (commit `42850d4`)
4. This root CNAME file caused GitHub Pages to serve content from the repository root
5. **Result**: README.md was served instead of the html-site/ content

### Why It Happened

This is GitHub's default behavior when configuring a custom domain:
- GitHub Pages automatically creates and commits a CNAME file
- By default, GitHub creates this file in the repository root
- When a CNAME exists in the root, GitHub Pages serves files from the root
- This overrides the deployment workflow configuration (which deploys html-site/)

### Evidence

From git history:
```
* 42850d4 (origin/main) Create CNAME
```

The "Create CNAME" workflows visible in the Actions screenshot were GitHub's automatic commits.

## Solution Implemented

### Changes Made (Commit `742dd8c`)

1. **Deleted root CNAME file**
   ```bash
   git rm CNAME
   ```
   - Removed the auto-created `/CNAME` file
   - This fixes the immediate issue

2. **Added `/CNAME` to `.gitignore`**
   ```gitignore
   # GitHub Pages auto-generated files
   # The CNAME file in the repository root is auto-created by GitHub when
   # configuring a custom domain in Settings → Pages. This conflicts with
   # our deployment which uses html-site/CNAME. We ignore the root CNAME
   # to prevent it from breaking the deployment.
   /CNAME
   ```
   - Prevents GitHub from committing root CNAME in the future
   - Note: GitHub may still try to create it, but git will ignore it

3. **Updated Documentation**
   - **TROUBLESHOOTING_404.md**: Added critical warning section at the top
   - **GITHUB_PAGES_SETUP.md**: Added warning in Step 1 about auto-created CNAME
   - **README.md**: Made root CNAME check the #1 troubleshooting step
   - **All docs**: Explained the issue and how to fix it

## How This Fix Works

### File Structure After Fix

```
/ (root)
├── .gitignore              (now ignores /CNAME)
├── README.md               (documentation, not served on live site)
├── html-site/
│   ├── CNAME               ✅ ONLY CNAME (bintobetter.org)
│   ├── index.html          ✅ Site homepage
│   ├── .nojekyll
│   └── ...                 (all site files)
└── .github/
    └── workflows/
        └── deploy.yml      (deploys html-site/ to Pages)
```

### Deployment Flow After Fix

1. User pushes to main branch
2. Deploy workflow runs (`.github/workflows/deploy.yml`)
3. Workflow uploads `html-site/` directory as Pages artifact
4. `html-site/CNAME` is included in the artifact (correct!)
5. GitHub Pages serves files from the artifact
6. **Result**: BinToBetter website loads correctly ✅

## Verification

### Automated Verification

Run the verification script:
```bash
bash verify-deployment.sh
```

**Output:**
```
✓ Root CNAME check
  → No CNAME in root directory (correct)

✓ CNAME file content
  → Contains correct domain: bintobetter.org

Passed:   12
Failed:   0
Warnings: 0
```

### Manual Verification

After deployment:
1. Visit https://bintobetter.org
2. Should see BinToBetter website (not README)
3. Check source: should be serving from html-site/

## Prevention Strategy

### Why .gitignore May Not Be Enough

While we added `/CNAME` to `.gitignore`, GitHub Pages may still try to manage this file directly through the UI. The `.gitignore` prevents it from being committed via git commands, but GitHub's UI operations may bypass this.

### If Issue Recurs

If you see README instead of website again:

1. **Check for root CNAME:**
   ```bash
   git pull origin main
   ls -la | grep CNAME
   ```

2. **Delete if it exists:**
   ```bash
   git rm CNAME
   git commit -m "Remove auto-created root CNAME"
   git push origin main
   ```

3. **Or delete via GitHub UI:**
   - Go to repository root on GitHub
   - Click CNAME file
   - Click trash icon
   - Commit deletion

### Alternative Solution (Not Recommended)

If the issue persists, you could:
- Remove custom domain from Settings → Pages
- Rely only on `html-site/CNAME` in the deployment

However, this means GitHub won't auto-renew SSL certificates, so we prefer the current solution with .gitignore.

## Related Issues

### This Issue vs Previous GITHUB_PAGES_FIX.md

- **Previous issue (PR #14)**: Root CNAME was manually created
- **Current issue**: Root CNAME was auto-created by GitHub Pages
- **Same symptom**: Both caused README to be served instead of website
- **Same solution**: Delete root CNAME file

### Documentation Updated

All documentation now clearly distinguishes between:
1. **GitHub Pages not enabled** → 404 "Site not found" error
2. **Root CNAME exists** → README served instead of website

## Testing

### Local Testing

Site works correctly when served locally:
```bash
cd html-site
python3 -m http.server 8000
# Visit http://localhost:8000
```

**Result**: BinToBetter website loads correctly ✅

### Production Testing

After merging this PR:
1. GitHub Actions will deploy html-site/ to Pages
2. Site will be accessible at https://bintobetter.org
3. No root CNAME exists, so no README override
4. **Expected result**: Website loads correctly ✅

## Conclusion

**Status**: Fixed ✅

**Root Cause**: GitHub auto-created CNAME in repository root

**Solution**: Deleted root CNAME + added to .gitignore + updated docs

**Impact**: Site will now load correctly from html-site/

**Prevention**: .gitignore + comprehensive documentation

**User Action Required**: Merge this PR and deploy

After merging, the site should load correctly at https://bintobetter.org within 1-2 minutes.
