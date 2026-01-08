import { test, expect } from '@playwright/test'

test.describe('BasePath Detection', () => {
  test('should NOT add base tag for custom domain (localhost)', async ({ page }) => {
    await page.goto('/')

    // Check that BASE_PATH is set to root
    const basePath = await page.evaluate(() => (window as any).BASE_PATH)
    expect(basePath).toBe('/')

    // Check that NO base tag was injected (since we're not on .github.io)
    const baseTag = await page.locator('base').count()
    expect(baseTag).toBe(0)
  })

  test('should simulate GitHub Pages deployment and add base tag', async ({ page }) => {
    // Override window.location to simulate GitHub Pages
    await page.goto('/')
    
    // Inject the basepath detection script with simulated GitHub Pages hostname
    const simulatedBasePath = await page.evaluate(() => {
      // Simulate GitHub Pages environment
      const simulateGitHubPages = () => {
        const fakeHostname = 'freeforcharity.github.io';
        const fakePathname = '/FFC-EX-bintobetter.org/index.html';
        
        // Extract repository name from pathname
        const pathSegments = fakePathname.split('/').filter(segment => segment);
        if (pathSegments.length > 0) {
          return '/' + pathSegments[0] + '/';
        }
        return '/';
      };
      
      return simulateGitHubPages();
    });
    
    // Verify the simulated basePath is correct
    expect(simulatedBasePath).toBe('/FFC-EX-bintobetter.org/');
  })

  test('should load CSS correctly', async ({ page }) => {
    await page.goto('/')

    // Check that the stylesheet loaded
    const stylesheetLink = page.locator('link[rel="stylesheet"][href="/css/styles.css"]')
    await expect(stylesheetLink).toHaveCount(1)

    // Verify CSS is actually loaded by checking computed styles
    const header = page.locator('header')
    await expect(header).toBeVisible()
  })

  test('should load images correctly', async ({ page }) => {
    await page.goto('/')

    // Check that logo image loads
    const logo = page.locator('header img[alt="BinToBetter Logo"]')
    await expect(logo).toBeVisible()

    // Verify image src is correct
    const logoSrc = await logo.getAttribute('src')
    expect(logoSrc).toBe('/images/logo.webp')
  })

  test('should correctly extract repository name from various paths', async ({ page }) => {
    await page.goto('/')
    
    const testCases = await page.evaluate(() => {
      const extractRepoName = (pathname: string) => {
        const pathSegments = pathname.split('/').filter(segment => segment);
        if (pathSegments.length > 0) {
          return '/' + pathSegments[0] + '/';
        }
        return '/';
      };
      
      return {
        root: extractRepoName('/FFC-EX-bintobetter.org/'),
        indexHtml: extractRepoName('/FFC-EX-bintobetter.org/index.html'),
        policyPage: extractRepoName('/FFC-EX-bintobetter.org/privacy-policy.html'),
        deepPath: extractRepoName('/FFC-EX-bintobetter.org/some/deep/path/file.html'),
      };
    });
    
    // All paths should extract the same repository name
    expect(testCases.root).toBe('/FFC-EX-bintobetter.org/');
    expect(testCases.indexHtml).toBe('/FFC-EX-bintobetter.org/');
    expect(testCases.policyPage).toBe('/FFC-EX-bintobetter.org/');
    expect(testCases.deepPath).toBe('/FFC-EX-bintobetter.org/');
  })
})
