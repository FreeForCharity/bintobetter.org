# BinToBetter Website

## 📄 Pure HTML Static Website

This repository contains the **BinToBetter** website built with pure HTML, CSS, and JavaScript - no build process required!

### Quick Links

- 🌐 **[Live Site](https://bintobetter.org/)** - Production website
- 📂 **[HTML Site Files](./html-site/)** - All website files
- ♻️ **[GitHub Repository](https://github.com/FreeForCharity/bintobetter.org)** - Source code

---

## Organization

**BinToBetter** is a youth-led nonprofit organization dedicated to reducing community waste and promoting environmental sustainability.

**Mission**: BinToBetter transforms used tennis balls, e-waste, and hard-to-recycle plastics into valuable tools for schools, seniors, and students. Through hands-on recycling initiatives and educational workshops, we demonstrate that waste reduction isn't just possible—it's powerful.

**Primary Contact**: info@bintobetter.org

---

## Repository Structure

```
html-site/                      # Production website (deployed to GitHub Pages)
├── index.html                 # Main homepage
├── css/                       # Stylesheets
│   └── styles.css            # All site styles
├── js/                        # JavaScript files
│   └── main.js               # Site functionality
├── images/                    # Image assets (WebP optimized)
├── svgs/                      # SVG icons
├── videos/                    # Video files
├── privacy-policy.html        # Privacy policy page
├── cookie-policy.html         # Cookie policy page
├── terms-of-service.html      # Terms of service page
├── CNAME                      # Custom domain configuration (bintobetter.org)
└── *.png, *.ico, *.webmanifest # Icons and manifest files

tests/                         # Playwright E2E tests for HTML site
├── *.spec.ts                 # Test files
└── README.md                  # Testing documentation

docs-backup/                   # Archived documentation
└── *.md                       # Historical reference files
```

---

## Website Features

### Homepage Sections
- **Hero Section** - Welcome message with call-to-action buttons
- **Mission Section** - Mission statement about waste reduction and youth empowerment
- **Our Impact** - Impact numbers with animated counters (tennis balls repurposed, e-waste recycled, etc.)
- **Community Impact** - Testimonials from schools and community partners
- **Volunteer Section** - Call to action for youth volunteers
- **Events Section** - Community events and collection drives
- **Donate Section** - Support our recycling programs
- **Why It Matters** - Environmental impact, community benefits, youth leadership
- **Programs Section** - Tennis ball recycling, e-waste workshops, plastic repurposing
- **FAQ Section** - Accordion-style questions about our recycling programs
- **Team Section** - Youth leaders and volunteers

### Navigation & Layout
- **Sticky Header** - Navigation with mobile hamburger menu
- **Mobile Menu** - Slide-out panel with overlay
- **Footer** - Links, social media, contact info
- **Smooth Scrolling** - To section anchors
- **Active Nav Highlighting** - Based on scroll position

### Policy Pages
All legal and policy information is available on separate pages:
- Privacy Policy
- Cookie Policy
- Terms of Service

---

## Deployment

The site is automatically deployed to the custom apex domain when changes are pushed to the `main` branch.

- **Production URL**: https://bintobetter.org/
- **Deployment**: Via GitHub Actions (`.github/workflows/deploy.yml`) to GitHub Pages with custom domain
- **Custom Domain**: Configured via `CNAME` file in `html-site/` directory
- **No Build Step**: Pure HTML files are served directly from the `html-site/` directory

### ⚠️ Custom Domain Dependency

**Important**: This site has a critical dependency on the custom domain (bintobetter.org). All asset paths are root-relative (e.g., `/css/styles.css`, `/images/`), which requires the site to be served from a domain root.

**Implications**:
- The site will **NOT** work if accessed via the GitHub Pages subpath URL (https://freeforcharity.github.io/bintobetter.org/)
- The `CNAME` file in `html-site/` is critical for proper deployment
- If the custom domain expires, becomes misconfigured, or is removed, the site will be broken

**Operational Requirements**:
1. **Domain Renewal**: Ensure bintobetter.org domain renewal is monitored and automated
2. **CNAME File**: Never remove or modify the `html-site/CNAME` file without updating asset paths
3. **Monitoring**: Set up alerts for domain expiration and SSL certificate renewal

**Contingency Plan**:
If the custom domain becomes unavailable and the site needs to work on the GitHub Pages URL, you must:
1. Restore the basePath prefix to all asset paths (revert to the commit before basePath removal, or manually add the prefix)
2. Update all `/css/` → `/bintobetter.org/css/`
3. Update all `/images/` → `/bintobetter.org/images/`
4. Update all navigation `/#section` → `/bintobetter.org/#section`

---

## Local Development

No build process or dependencies required! Simply open the HTML files in your browser:

```bash
# Clone the repository
git clone https://github.com/FreeForCharity/bintobetter.org.git
cd bintobetter.org

# Open in browser
cd html-site
open index.html  # macOS
# or
xdg-open index.html  # Linux
# or just double-click index.html in Windows
```

### Using a Local HTTP Server (Optional)

For testing features that require a web server (like cookies or CORS):

```bash
# Using Python (usually pre-installed)
cd html-site
python3 -m http.server 8000
# Visit http://localhost:8000

# Or using PHP (if installed)
cd html-site
php -S localhost:8000

# Or using Node.js http-server (if you have Node installed)
npx http-server html-site -p 8000
```

---

## Testing

The repository includes Playwright E2E tests to validate HTML site functionality:

```bash
# Install dependencies (first time only)
npm install

# Run all tests
npm test

# Run tests with UI
npm run test:ui

# Run tests in headed mode (see browser)
npm run test:headed
```

Tests validate:
- Page loading and navigation
- Image rendering
- Cookie consent functionality
- Form functionality
- Social media links
- Copyright information
- Mobile responsiveness

See [tests/README.md](./tests/README.md) for detailed testing documentation.

---

## Making Changes

1. Edit HTML, CSS, or JavaScript files in the `html-site/` directory
2. Test locally in your browser
3. Commit and push to the `main` branch
4. GitHub Actions will automatically deploy to GitHub Pages

### File Organization

- **HTML**: Main structure and content in `*.html` files
- **CSS**: All styles in `html-site/css/styles.css`
- **JavaScript**: Functionality in `html-site/js/main.js`
- **Assets**: Images in `images/`, SVGs in `svgs/`, videos in `videos/`

---

## CNCF-Compliant Open Source Project

This repository follows **Cloud Native Computing Foundation (CNCF)** standards for governance, security, and community practices. We are committed to transparency, inclusive participation, and professional project management.

### Project Governance and Policies

- 📜 **[LICENSE](./LICENSE)** - Apache 2.0 open source license
- 🤝 **[CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)** - Community standards (Contributor Covenant 2.1)
- ⚖️ **[GOVERNANCE.md](./GOVERNANCE.md)** - Decision-making processes
- 👥 **[MAINTAINERS.md](./MAINTAINERS.md)** - Repository maintainers and their roles
- 🎉 **[CONTRIBUTORS.md](./CONTRIBUTORS.md)** - Recognition of all contributors
- 🔒 **[SECURITY.md](./SECURITY.md)** - Vulnerability reporting and security practices
- 🛡️ **[THREAT-MODEL.md](./THREAT-MODEL.md)** - Security threat analysis
- 🌟 **[ADOPTERS.md](./ADOPTERS.md)** - Organizations using this template
- 🤝 **[CONTRIBUTING.md](./CONTRIBUTING.md)** - How to contribute
- 💬 **[SUPPORT.md](./SUPPORT.md)** - How to get help
- 🔗 **[EXTERNAL_DEPENDENCIES.md](./EXTERNAL_DEPENDENCIES.md)** - Third-party services
- 📖 **[CITATION.cff](./CITATION.cff)** - Citation information for academic use
- 📝 **[CHANGELOG.md](./CHANGELOG.md)** - Release notes and version history

**Why CNCF Alignment?** Following CNCF standards strengthens project credibility, simplifies onboarding of contributors, and prepares us for cloud-native ecosystem integrations.

---

## Contributing

We welcome contributions! Please see our [Contributing Guide](./CONTRIBUTING.md) for details on:
- Code of Conduct
- How to submit issues
- How to submit pull requests
- Coding standards

---

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.

---

## Historical Context

This repository was created using the Free For Charity website template and converted to serve the BinToBetter nonprofit organization. The template provides a professional, accessible, and performant static HTML website structure that was adapted for BinToBetter's mission of waste reduction and environmental sustainability.
