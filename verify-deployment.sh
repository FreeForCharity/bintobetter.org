#!/bin/bash

# BinToBetter GitHub Pages Deployment Verification Script
# This script checks if the repository is correctly configured for GitHub Pages deployment

# Note: Do not use 'set -e' as we want to continue checking all tests even if some fail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

echo "=================================="
echo "BinToBetter Deployment Verification"
echo "=================================="
echo ""

# Function to print test result
print_result() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        [ -n "$message" ] && echo "  → $message"
        ((PASSED++))
    elif [ "$status" = "FAIL" ]; then
        echo -e "${RED}✗${NC} $test_name"
        [ -n "$message" ] && echo "  → $message"
        ((FAILED++))
    elif [ "$status" = "WARN" ]; then
        echo -e "${YELLOW}⚠${NC} $test_name"
        [ -n "$message" ] && echo "  → $message"
        ((WARNINGS++))
    fi
    echo ""
}

# Test 1: Check if we're in the correct directory
echo "Running verification tests..."
echo ""

if [ ! -d "html-site" ]; then
    print_result "Repository structure" "FAIL" "html-site directory not found. Run this script from the repository root."
    exit 1
fi
print_result "Repository structure" "PASS" "html-site directory exists"

# Test 2: Check CNAME file in html-site
if [ ! -f "html-site/CNAME" ]; then
    print_result "CNAME file location" "FAIL" "html-site/CNAME not found"
else
    CNAME_CONTENT=$(cat html-site/CNAME | tr -d '\n' | tr -d ' ')
    if [ "$CNAME_CONTENT" = "bintobetter.org" ]; then
        print_result "CNAME file content" "PASS" "Contains correct domain: bintobetter.org"
    else
        print_result "CNAME file content" "FAIL" "Expected 'bintobetter.org', found '$CNAME_CONTENT'"
    fi
fi

# Test 3: Check for CNAME in root (should NOT exist)
if [ -f "CNAME" ]; then
    print_result "Root CNAME check" "FAIL" "CNAME file exists in repository root - THIS WILL BREAK DEPLOYMENT"
    echo "  → ACTION REQUIRED: Delete the root CNAME file:"
    echo "     git rm CNAME"
    echo "     git commit -m 'Remove incorrect root CNAME'"
    echo "     git push origin main"
    echo ""
else
    print_result "Root CNAME check" "PASS" "No CNAME in root directory (correct)"
fi

# Test 4: Check .nojekyll file
if [ ! -f "html-site/.nojekyll" ]; then
    print_result ".nojekyll file" "FAIL" ".nojekyll not found in html-site"
    echo "  → ACTION REQUIRED: Create the file:"
    echo "     touch html-site/.nojekyll"
    echo "     git add html-site/.nojekyll"
    echo "     git commit -m 'Add .nojekyll file'"
    echo "     git push origin main"
    echo ""
else
    print_result ".nojekyll file" "PASS" ".nojekyll exists in html-site"
fi

# Test 5: Check index.html
if [ ! -f "html-site/index.html" ]; then
    print_result "index.html" "FAIL" "index.html not found in html-site"
else
    INDEX_SIZE=$(wc -c < html-site/index.html)
    if [ "$INDEX_SIZE" -gt 1000 ]; then
        print_result "index.html" "PASS" "Exists and appears valid ($INDEX_SIZE bytes)"
    else
        print_result "index.html" "WARN" "Exists but seems small ($INDEX_SIZE bytes)"
    fi
fi

# Test 6: Check deployment workflow
if [ ! -f ".github/workflows/deploy.yml" ]; then
    print_result "Deployment workflow" "FAIL" ".github/workflows/deploy.yml not found"
else
    # Check if workflow has correct permissions
    if grep -q "pages: write" .github/workflows/deploy.yml; then
        print_result "Workflow permissions" "PASS" "Deployment workflow has correct permissions"
    else
        print_result "Workflow permissions" "FAIL" "Workflow missing 'pages: write' permission"
    fi
    
    # Check if workflow deploys from html-site
    if grep -q "path: ./html-site" .github/workflows/deploy.yml; then
        print_result "Workflow path" "PASS" "Workflow deploys from ./html-site"
    else
        print_result "Workflow path" "FAIL" "Workflow not configured to deploy from ./html-site"
    fi
fi

# Test 7: Check CSS directory
if [ ! -d "html-site/css" ]; then
    print_result "CSS directory" "WARN" "html-site/css directory not found"
else
    print_result "CSS directory" "PASS" "CSS directory exists"
fi

# Test 8: Check images directory
if [ ! -d "html-site/images" ]; then
    print_result "Images directory" "WARN" "html-site/images directory not found"
else
    print_result "Images directory" "PASS" "Images directory exists"
fi

# Test 9: Check JavaScript directory
if [ ! -d "html-site/js" ]; then
    print_result "JavaScript directory" "WARN" "html-site/js directory not found"
else
    print_result "JS directory" "PASS" "JavaScript directory exists"
fi

# Test 10: Check favicon
if [ ! -f "html-site/favicon.ico" ]; then
    print_result "Favicon" "WARN" "favicon.ico not found"
else
    print_result "Favicon" "PASS" "favicon.ico exists"
fi

# Test 11: DNS Check (optional, requires internet)
echo "=================================="
echo "Optional: DNS Verification"
echo "=================================="
echo ""
echo "Checking DNS configuration for bintobetter.org..."
echo ""

if command -v dig &> /dev/null; then
    DNS_RESULT=$(dig bintobetter.org +short 2>/dev/null || echo "")
    
    if [ -z "$DNS_RESULT" ]; then
        print_result "DNS lookup" "WARN" "Could not resolve bintobetter.org (DNS may not be configured yet)"
    else
        # Check if any of the GitHub Pages IPs are present
        GITHUB_IPS=("185.199.108.153" "185.199.109.153" "185.199.110.153" "185.199.111.153")
        FOUND_GITHUB_IP=false
        
        for IP in "${GITHUB_IPS[@]}"; do
            if echo "$DNS_RESULT" | grep -q "$IP"; then
                FOUND_GITHUB_IP=true
                break
            fi
        done
        
        if [ "$FOUND_GITHUB_IP" = true ]; then
            print_result "DNS configuration" "PASS" "Domain points to GitHub Pages"
            echo "  DNS records found:"
            echo "$DNS_RESULT" | while read -r line; do
                echo "    $line"
            done
            echo ""
        else
            print_result "DNS configuration" "WARN" "Domain does not point to GitHub Pages IPs"
            echo "  Found IPs:"
            echo "$DNS_RESULT" | while read -r line; do
                echo "    $line"
            done
            echo ""
            echo "  Expected GitHub Pages IPs:"
            for IP in "${GITHUB_IPS[@]}"; do
                echo "    $IP"
            done
            echo ""
        fi
    fi
else
    print_result "DNS lookup" "WARN" "'dig' command not available - skipping DNS check"
fi

# Summary
echo "=================================="
echo "Verification Summary"
echo "=================================="
echo ""
echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${RED}Failed:${NC}   $FAILED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    echo ""
    echo "Next steps to deploy:"
    echo "1. Commit and push changes to main branch"
    echo "2. Go to GitHub Actions tab to monitor deployment"
    echo "3. Visit https://bintobetter.org after deployment completes"
    echo ""
    echo "If the site still shows 404 after deployment:"
    echo "→ See TROUBLESHOOTING_404.md for detailed troubleshooting steps"
    exit 0
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo ""
    echo "Please fix the issues above before deploying."
    echo "See TROUBLESHOOTING_404.md for detailed guidance."
    exit 1
fi
