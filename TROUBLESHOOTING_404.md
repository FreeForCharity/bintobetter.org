# Troubleshooting 404 Error on GitHub Pages

## Problem Description

When navigating to `https://bintobetter.org`, users may see:
- **"Site not found - GitHub Pages"** error, OR
- **README.md content** instead of the BinToBetter website

This document provides step-by-step troubleshooting to resolve these issues.

---

## ⚠️ CRITICAL ISSUE: Auto-Created Root CNAME File

**IF YOU SEE THE README INSTEAD OF THE WEBSITE**, the most common cause is an auto-created CNAME file in the repository root.

### What Happens

When you configure a custom domain in **Settings** → **Pages** → **Custom domain**, GitHub automatically:
1. Creates a `CNAME` file in the **repository root**
2. Commits it with message "Create CNAME"
3. This causes GitHub Pages to serve files from the root (including README.md) instead of from `html-site/`

### Quick Fix

```bash
# Delete the auto-created root CNAME file
git pull origin main
git rm CNAME
git commit -m "Remove auto-created root CNAME (conflicts with html-site/CNAME)"
git push origin main
```

Or use GitHub UI:
1. Go to repository root
2. Click on `CNAME` file
3. Click trash icon to delete
4. Commit with message "Remove root CNAME"

### Prevention

The repository now includes `/CNAME` in `.gitignore` to prevent this file from being committed in the future. However, GitHub may still try to create it, so you may need to delete it again if the issue recurs.

---

## Quick Diagnostic Checklist

Run through this checklist to identify the root cause:

- [ ] **Repository files are correct**
  - [ ] `html-site/CNAME` file exists and contains `bintobetter.org`
  - [ ] `html-site/.nojekyll` file exists (empty file)
  - [ ] `html-site/index.html` file exists
  - [ ] No `CNAME` file in repository root directory

- [ ] **GitHub Pages is enabled**
  - [ ] Go to repository **Settings** → **Pages**
  - [ ] Source should be set to **GitHub Actions** (not Branch)
  - [ ] Custom domain field should show `bintobetter.org`
  - [ ] HTTPS should be enabled (checkbox checked)

- [ ] **Deployment workflow has run successfully**
  - [ ] Go to **Actions** tab in repository
  - [ ] Check if "Deploy to GitHub Pages" workflow exists
  - [ ] Check if workflow has run successfully on `main` branch
  - [ ] Review logs for any errors

- [ ] **DNS is configured correctly**
  - [ ] Domain's A records point to GitHub Pages IP addresses
  - [ ] DNS propagation is complete (can take 24-48 hours)

---

## Root Cause Analysis

### Cause 1: GitHub Pages Not Enabled

**Symptoms:**
- 404 error saying "Site not found"
- No deployments visible in Actions tab

**Solution:**
1. Go to repository **Settings** → **Pages**
2. Under "Build and deployment":
   - **Source**: Select **GitHub Actions** (not "Deploy from a branch")
3. Under "Custom domain":
   - Enter `bintobetter.org`
   - Click **Save**
4. Wait a few minutes for GitHub to verify the domain
5. Enable **Enforce HTTPS** checkbox (appears after domain verification)

**Why this happens:**
GitHub Pages must be explicitly enabled in repository settings. The workflow alone is not sufficient.

---

### Cause 2: Deployment Workflow Has Not Run

**Symptoms:**
- No workflow runs visible in Actions tab
- Or workflow runs exist but all failed

**Solution:**

**Option A: Trigger Manual Deployment**
1. Go to **Actions** tab
2. Click "Deploy to GitHub Pages" workflow
3. Click **Run workflow** button
4. Select `main` branch
5. Click **Run workflow**
6. Wait for workflow to complete (usually 1-2 minutes)

**Option B: Push to Main Branch**
1. Merge any pending PRs to `main` branch
2. Workflow will automatically trigger
3. Check Actions tab to monitor progress

**Verify workflow succeeded:**
1. Go to **Actions** tab
2. Click on the latest workflow run
3. Verify both "Build for GitHub Pages" and "Deploy to GitHub Pages" jobs completed successfully
4. Check for green checkmarks ✅

**Why this happens:**
The deployment workflow (`.github/workflows/deploy.yml`) only runs when code is pushed to the `main` branch. If no commits have been made to `main`, the workflow hasn't deployed the site.

---

### Cause 3: Custom Domain Not Configured in GitHub Settings

**Symptoms:**
- Site works at `https://freeforcharity.github.io/FFC-EX-bintobetter.org/` (though assets may be broken)
- 404 error at `https://bintobetter.org`
- CNAME file exists in `html-site/` but domain doesn't work

**Solution:**
1. Go to repository **Settings** → **Pages**
2. Scroll to **Custom domain** section
3. Enter `bintobetter.org` in the text field
4. Click **Save**
5. GitHub will verify domain ownership (may take a few minutes)
6. Once verified, enable **Enforce HTTPS**

**Important:**
The `CNAME` file in `html-site/` is necessary but not sufficient. The custom domain must ALSO be configured in GitHub Pages settings. Both are required.

**Why this happens:**
GitHub Pages requires two-way configuration:
1. CNAME file in the deployed artifact (tells GitHub what domain to expect)
2. Custom domain in settings (tells GitHub to accept requests for that domain)

---

### Cause 4: DNS Not Configured or Propagated

**Symptoms:**
- GitHub Pages shows domain is verified
- Workflow deployed successfully
- Still getting 404 at custom domain
- Or DNS lookup fails for the domain

**Solution:**

**Step 1: Verify DNS Configuration**

The domain `bintobetter.org` must have DNS records pointing to GitHub Pages.

**Required A records** (for apex domain):
```
Type: A
Name: @ (or bintobetter.org)
Value: 185.199.108.153

Type: A
Name: @ (or bintobetter.org)
Value: 185.199.109.153

Type: A
Name: @ (or bintobetter.org)
Value: 185.199.110.153

Type: A
Name: @ (or bintobetter.org)
Value: 185.199.111.153
```

**Optional CNAME record** (for www subdomain):
```
Type: CNAME
Name: www
Value: freeforcharity.github.io
```

**Step 2: Verify DNS Propagation**

Use these commands to check DNS:

```bash
# Check if A records exist
dig bintobetter.org +short

# Should return GitHub Pages IPs:
# 185.199.108.153
# 185.199.109.153
# 185.199.110.153
# 185.199.111.153

# Check DNS propagation status
nslookup bintobetter.org

# Or use online tools:
# https://www.whatsmydns.net/#A/bintobetter.org
```

**Step 3: Wait for Propagation**

DNS changes can take 24-48 hours to propagate globally. If you just updated DNS:
- Wait at least 1-2 hours
- Clear your browser cache
- Try accessing from incognito/private mode
- Try from a different network/device

**Why this happens:**
Even if GitHub Pages is perfectly configured, if DNS doesn't point to GitHub's servers, requests to `bintobetter.org` won't reach GitHub Pages.

---

### Cause 5: CNAME File in Wrong Location

**Symptoms:**
- Site serves README.md instead of index.html
- 404 errors for custom domain
- GitHub Pages shows custom domain but site doesn't work

**Solution:**
1. Check if CNAME exists in repository root:
   ```bash
   ls -la | grep CNAME
   ```

2. If a CNAME file exists in repository root, **DELETE IT**:
   ```bash
   git rm CNAME
   git commit -m "Remove incorrect root CNAME file"
   git push origin main
   ```

3. Verify CNAME exists in `html-site/`:
   ```bash
   cat html-site/CNAME
   # Should output: bintobetter.org
   ```

**Why this happens:**
If a CNAME file exists in the repository root, GitHub Pages may serve files from the root directory instead of from the deployed artifact (`html-site/` directory). This causes the README.md to be served as the homepage.

The CNAME file MUST be inside `html-site/` so it gets included in the deployment artifact.

---

## Step-by-Step Verification Process

Follow these steps in order to systematically identify and fix the issue:

### Step 1: Verify Repository Files (5 minutes)

```bash
# Clone repository
git clone https://github.com/FreeForCharity/FFC-EX-bintobetter.org.git
cd FFC-EX-bintobetter.org

# Check for root CNAME (should NOT exist)
ls -la | grep CNAME
# Expected: No output

# Check html-site CNAME (MUST exist)
cat html-site/CNAME
# Expected: bintobetter.org

# Check .nojekyll (MUST exist)
ls -la html-site/.nojekyll
# Expected: -rw-r--r-- ... .nojekyll

# Check index.html (MUST exist)
ls -la html-site/index.html
# Expected: -rw-r--r-- ... index.html
```

**If any file is missing or incorrect, fix it before proceeding.**

### Step 2: Verify GitHub Pages Settings (5 minutes)

1. Go to: `https://github.com/FreeForCharity/FFC-EX-bintobetter.org/settings/pages`

2. Verify configuration:
   - **Source**: Should show "GitHub Actions"
   - **Custom domain**: Should show "bintobetter.org" with green checkmark ✅
   - **Enforce HTTPS**: Should be checked

3. If custom domain is not configured:
   - Enter `bintobetter.org`
   - Click **Save**
   - Wait for verification (may take 1-10 minutes)
   - Enable **Enforce HTTPS** after verification

### Step 3: Verify Deployment Workflow (10 minutes)

1. Go to: `https://github.com/FreeForCharity/FFC-EX-bintobetter.org/actions`

2. Check latest "Deploy to GitHub Pages" workflow run:
   - Should have green checkmark ✅
   - Should show "Deploy to GitHub Pages" completed successfully
   - Click on the run to see detailed logs

3. If no recent workflow runs exist:
   - Click "Deploy to GitHub Pages" workflow
   - Click **Run workflow**
   - Select `main` branch
   - Click **Run workflow**
   - Wait for completion (~1-2 minutes)

4. If workflow failed:
   - Click on the failed run
   - Review error messages in logs
   - Common issues:
     - Permission errors (check repository settings → Actions → General → Workflow permissions)
     - Missing files (verify html-site/ directory has all files)

### Step 4: Verify DNS Configuration (15-30 minutes)

```bash
# Check current DNS records
dig bintobetter.org +short

# Should return (in any order):
# 185.199.108.153
# 185.199.109.153
# 185.199.110.153
# 185.199.111.153
```

**If DNS is incorrect:**

1. Log into domain registrar (e.g., Google Domains, Namecheap, GoDaddy, Cloudflare)
2. Navigate to DNS settings for `bintobetter.org`
3. Add/update A records as shown above
4. Save changes
5. Wait 1-2 hours for propagation (can take up to 48 hours)

**If using Cloudflare:**
- See `CLOUDFLARE_SETUP.md` for specific configuration
- Ensure proxy status is set to "Proxied" (orange cloud)

### Step 5: Test and Verify (5 minutes)

After fixing any issues found above:

1. **Clear browser cache** (Ctrl+Shift+Del or Cmd+Shift+Del)

2. **Test in incognito/private mode**:
   - Open incognito window
   - Navigate to `https://bintobetter.org`
   - Should load the BinToBetter homepage

3. **Verify HTTPS**:
   - URL should show `https://` (not `http://`)
   - Browser should show secure lock icon 🔒

4. **Test navigation**:
   - Click navigation links
   - Verify all sections load
   - Check that images and CSS load correctly

5. **Test policy pages**:
   - Visit `https://bintobetter.org/privacy-policy.html`
   - Visit `https://bintobetter.org/cookie-policy.html`
   - Visit `https://bintobetter.org/terms-of-service.html`

---

## Common Error Patterns

### Pattern 1: Works on GitHub Pages URL, 404 on Custom Domain

**Symptoms:**
- ✅ `https://freeforcharity.github.io/FFC-EX-bintobetter.org/` works (maybe with broken assets)
- ❌ `https://bintobetter.org` shows 404

**Root Cause:**
Custom domain not configured in GitHub Pages settings, or DNS not pointing to GitHub.

**Fix:**
1. Configure custom domain in Settings → Pages
2. Verify DNS A records point to GitHub Pages IPs
3. Wait for DNS propagation

### Pattern 2: Shows README Instead of Website

**Symptoms:**
- Site loads but shows repository README.md content
- Not the actual BinToBetter website

**Root Cause:**
CNAME file exists in repository root, causing GitHub to serve root files instead of deployed artifact.

**Fix:**
```bash
git rm CNAME  # Remove from root
git commit -m "Remove root CNAME file"
git push origin main
```

### Pattern 3: 404 for All Pages Including Homepage

**Symptoms:**
- Homepage shows 404
- All pages show 404
- "Site not found - GitHub Pages" error

**Root Cause:**
GitHub Pages not enabled, or deployment workflow never ran.

**Fix:**
1. Enable GitHub Pages in Settings → Pages
2. Manually trigger deployment workflow
3. Verify workflow completes successfully

### Pattern 4: Homepage Loads But Assets (CSS/Images) Don't

**Symptoms:**
- ✅ Homepage loads (but looks broken)
- ❌ CSS not applied
- ❌ Images show as broken

**Root Cause:**
This is actually a different issue (asset path problem), but appears related.

**Note:**
This is **NOT** a 404 GitHub Pages issue. This is an asset path configuration issue. The site is deployed correctly, but asset paths are wrong.

**Fix:**
Not applicable for current 404 issue. See separate documentation for asset path troubleshooting.

---

## Emergency Checklist

If the site is completely broken and you need it working ASAP:

1. **Verify CNAME file** (1 minute):
   ```bash
   cat html-site/CNAME
   # Must output: bintobetter.org
   ```

2. **Enable GitHub Pages** (2 minutes):
   - Settings → Pages → Source: GitHub Actions
   - Custom domain: `bintobetter.org`

3. **Trigger deployment** (3 minutes):
   - Actions → Deploy to GitHub Pages → Run workflow → main

4. **Verify DNS** (1 minute):
   ```bash
   dig bintobetter.org +short
   # Must include: 185.199.108.153, 185.199.109.153, etc.
   ```

5. **Wait and test** (5-60 minutes):
   - If DNS was just configured, wait up to 1 hour
   - If DNS was already configured, wait 5 minutes after deployment
   - Test in incognito: `https://bintobetter.org`

---

## Getting Help

If you've followed all steps above and the issue persists:

1. **Document your findings**:
   - Which steps succeeded ✅
   - Which steps failed ❌
   - Error messages from workflow logs
   - DNS lookup results
   - Screenshots of GitHub Pages settings

2. **Check these resources**:
   - [GitHub Pages Documentation](https://docs.github.com/en/pages)
   - [Troubleshooting GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/troubleshooting-404-errors-for-github-pages-sites)
   - [GitHub Custom Domain Docs](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)

3. **Contact support**:
   - Repository maintainers: See `CONTRIBUTORS.md`
   - Free For Charity team: See `SUPPORT.md`
   - GitHub Support (for GitHub Pages issues)

---

## Prevention

To prevent this issue from recurring:

1. **Never add CNAME to repository root** - always keep it in `html-site/` only
2. **Monitor deployments** - set up notifications for workflow failures
3. **Monitor DNS** - set up alerts for DNS changes or expiration
4. **Document custom domain** - ensure team knows about bintobetter.org dependency
5. **Test before merging** - always verify deployment workflow runs successfully on main

---

## Related Documentation

- `DEPLOYMENT.md` - Full deployment guide and configuration
- `GITHUB_PAGES_FIX.md` - **Different issue:** Fix for when README.md is served instead of website (caused by root CNAME file). The current 404 issue is different - the site isn't deployed at all.
- `CLOUDFLARE_SETUP.md` - Cloudflare configuration for performance (includes GitHub Pages DNS setup)
- `SUPPORT.md` - How to get help
