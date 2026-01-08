# GitHub Pages Dual Deployment Support

## Overview

The BinToBetter website now supports **dual deployment** to both:
1. **Custom apex domain**: https://bintobetter.org (via CNAME)
2. **GitHub Pages subdirectory**: https://freeforcharity.github.io/FFC-EX-bintobetter.org/

This ensures the site is accessible even if the custom domain configuration fails or during DNS propagation delays.

## Problem

Previously, the site used root-relative paths (e.g., `/css/styles.css`, `/images/logo.webp`) which only work when the site is served from a domain root. This caused a 404 error when:

- Custom domain DNS was not properly configured
- Accessing the site via the GitHub Pages subdirectory URL
- During initial deployment before custom domain propagation

## Solution

### BasePath Detection Script

Each HTML file now includes an inline JavaScript that:

1. **Detects the deployment environment** by checking `window.location.hostname`
2. **Identifies GitHub Pages** by checking if hostname ends with `.github.io`
3. **Extracts the repository name** from the URL path
4. **Injects a `<base>` tag** dynamically for GitHub Pages deployment
5. **Leaves paths unchanged** for custom domain deployment

### How It Works

#### Custom Domain (bintobetter.org)
```javascript
// hostname: "bintobetter.org"
// pathname: "/index.html"
// Result: No base tag injected
// All paths remain: /css/styles.css, /images/logo.webp
```

#### GitHub Pages Subdirectory (freeforcharity.github.io/FFC-EX-bintobetter.org/)
```javascript
// hostname: "freeforcharity.github.io"
// pathname: "/FFC-EX-bintobetter.org/index.html"
// Result: <base href="https://freeforcharity.github.io/FFC-EX-bintobetter.org/">
// Paths resolve to: /FFC-EX-bintobetter.org/css/styles.css, etc.
```

## Implementation Details

### Inline Script Location

The basePath detection script is inlined in the `<head>` section of every HTML file:
- `html-site/index.html`
- `html-site/privacy-policy.html`
- `html-site/cookie-policy.html`
- `html-site/terms-of-service.html`

**Important**: The script MUST be the first element after `<head>` to ensure it runs before any resources load.

### Code Structure

```html
<head>
  <!-- BasePath detection must run FIRST for GitHub Pages support -->
  <script>
    (function() {
      'use strict';
      
      const hostname = window.location.hostname;
      const pathname = window.location.pathname;
      const isGitHubPages = hostname.endsWith('.github.io');
      
      let basePath = '/';
      
      if (isGitHubPages) {
        const pathSegments = pathname.split('/').filter(segment => segment);
        if (pathSegments.length > 0) {
          basePath = '/' + pathSegments[0] + '/';
        }
      }
      
      window.BASE_PATH = basePath;
      
      if (basePath !== '/') {
        const baseTag = document.createElement('base');
        baseTag.href = window.location.origin + basePath;
        const head = document.head || document.getElementsByTagName('head')[0];
        if (head.firstChild) {
          head.insertBefore(baseTag, head.firstChild);
        } else {
          head.appendChild(baseTag);
        }
      }
    })();
  </script>
  
  <meta charset="UTF-8" />
  <!-- Rest of head content -->
</head>
```

## Testing

### Automated Tests

BasePath functionality is tested in `tests/basepath.spec.ts`:

```bash
npm run test tests/basepath.spec.ts
```

Tests verify:
- ✅ No base tag for custom domain (localhost)
- ✅ Correct basePath extraction for GitHub Pages URLs
- ✅ CSS loads correctly
- ✅ Images load correctly
- ✅ Repository name extraction from various URL paths

### Manual Testing

#### Test Custom Domain (Simulated with localhost)

```bash
npm run preview
# Visit http://localhost:8000
# Open browser console and check: window.BASE_PATH (should be "/")
# Verify: No <base> tag in HTML
```

#### Test GitHub Pages Deployment

Deploy to GitHub Pages and visit:
```
https://freeforcharity.github.io/FFC-EX-bintobetter.org/
```

Expected behavior:
1. Page loads without 404 errors
2. All CSS, images, and assets load correctly
3. Navigation links work properly
4. Browser console shows: `window.BASE_PATH === "/FFC-EX-bintobetter.org/"`
5. HTML contains: `<base href="https://freeforcharity.github.io/FFC-EX-bintobetter.org/">`

## Deployment Scenarios

### Scenario 1: Custom Domain Active
- **URL**: https://bintobetter.org
- **Behavior**: Paths remain root-relative
- **BASE_PATH**: `/`
- **Base Tag**: None

### Scenario 2: GitHub Pages Subdirectory
- **URL**: https://freeforcharity.github.io/FFC-EX-bintobetter.org/
- **Behavior**: Base tag injected with repository path
- **BASE_PATH**: `/FFC-EX-bintobetter.org/`
- **Base Tag**: `<base href="https://freeforcharity.github.io/FFC-EX-bintobetter.org/">`

### Scenario 3: DNS Propagation Delay
During custom domain DNS propagation, users can:
1. Wait for DNS to propagate (24-48 hours)
2. **OR** Access via GitHub Pages URL immediately

## Benefits

1. **Resilience**: Site remains accessible even if custom domain fails
2. **Fast Access**: No waiting for DNS propagation
3. **Development**: Easier testing with GitHub Pages URLs
4. **Backward Compatible**: Custom domain deployment unchanged
5. **Zero Build Changes**: No modification to deployment workflow needed

## Maintenance

### Adding New HTML Pages

When creating new HTML pages, **always include the basePath detection script** as the first element in `<head>`:

```html
<!doctype html>
<html lang="en">
  <head>
    <!-- BasePath detection must run FIRST for GitHub Pages support -->
    <script>
    // Copy the entire basePath detection script from index.html
    </script>
    
    <!-- Rest of your head content -->
  </head>
</html>
```

### Updating the Script

If you need to modify the basePath logic:

1. Update the script in **all HTML files** (index.html, privacy-policy.html, cookie-policy.html, terms-of-service.html)
2. Update tests in `tests/basepath.spec.ts`
3. Run tests: `npm test tests/basepath.spec.ts`
4. Test both deployment scenarios manually

## Troubleshooting

### Assets Not Loading on GitHub Pages

**Symptom**: CSS, images, or other assets show 404 errors on GitHub Pages subdirectory URL

**Solution**:
1. Check browser console for `window.BASE_PATH` value
2. Verify `<base>` tag exists in HTML: `document.querySelector('base')`
3. Ensure basePath script is present and runs first in `<head>`
4. Clear browser cache and hard refresh (Ctrl+F5)

### Base Tag Appearing on Custom Domain

**Symptom**: `<base>` tag is injected when visiting custom domain

**Solution**:
1. Check the hostname detection logic in basePath script
2. Ensure hostname does NOT end with `.github.io`
3. Verify `window.BASE_PATH === '/'`

### Navigation Links Broken

**Symptom**: Links between pages don't work on GitHub Pages

**Solution**:
1. Verify all internal links use root-relative paths: `/privacy-policy.html`
2. Check that `<base>` tag is properly set
3. Test navigation: `http://localhost:8000` should work the same as GitHub Pages

## SEO Considerations

### Canonical URL

The `<base>` tag affects how browsers interpret relative URLs but does NOT affect canonical URLs. Search engines will continue to index the custom domain (bintobetter.org) as configured in:

- `CNAME` file
- Meta tags
- Sitemap
- Robots.txt

### Duplicate Content

GitHub Pages subdirectory URL (freeforcharity.github.io/FFC-EX-bintobetter.org/) and custom domain (bintobetter.org) serve the same content. To prevent duplicate content issues:

1. Custom domain is set via CNAME - GitHub Pages automatically redirects
2. Meta tags reference custom domain
3. Canonical URLs use custom domain
4. Sitemap uses custom domain

## References

- [HTML `<base>` Element - MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/base)
- [GitHub Pages Custom Domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
- [Configuring a subdomain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages)
