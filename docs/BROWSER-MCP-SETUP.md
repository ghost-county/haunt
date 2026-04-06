# Browser MCP Setup Guide

> Browser automation for Claude Code using MCP (Model Context Protocol) servers

## Overview

Browser MCP enables Claude to interact with web browsers for testing, automation, and web scraping tasks. This guide documents the installation and configuration of browser automation MCP servers for use with Claude Code.

## What is Browser MCP?

Browser MCP servers provide Claude with tools to:
- Navigate to URLs
- Click elements and fill forms
- Take screenshots
- Extract content from web pages
- Execute JavaScript
- Automate browser interactions

## Available MCP Browser Solutions

### Option 1: Playwright MCP (Recommended)

**Package:** `@automatalabs/mcp-server-playwright`

**Pros:**
- Uses Playwright (modern, actively maintained)
- Supports multiple browsers (Chrome, Firefox, Safari)
- Better cross-platform support
- Active development and community

**Installation:**

```bash
npm install -g @automatalabs/mcp-server-playwright
```

**MCP Configuration:**

Add to your Claude Code MCP configuration (`~/.config/claude/mcp_config.json` or Claude Code settings):

```json
{
  "mcpServers": {
    "playwright": {
      "command": "mcp-server-playwright",
      "args": [],
      "env": {}
    }
  }
}
```

### Option 2: Puppeteer MCP (Alternative)

**Package:** `puppeteer-mcp-server`

**Note:** The official `@modelcontextprotocol/server-puppeteer` is deprecated. Use the community fork instead.

**Pros:**
- Lightweight
- Chrome/Chromium focused
- Lower resource usage

**Installation:**

```bash
npm install -g puppeteer-mcp-server
```

**MCP Configuration:**

```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "puppeteer-mcp-server",
      "args": [],
      "env": {}
    }
  }
}
```

### Option 3: Browserbase MCP (Commercial)

**Package:** `@browserbasehq/mcp-server-browserbase`

**Pros:**
- Cloud-based browser instances
- No local browser management
- Built for production use
- Includes Stagehand AI navigation

**Cons:**
- Requires API key and subscription
- Not free for production use

**Installation:**

```bash
npm install -g @browserbasehq/mcp-server-browserbase
```

**MCP Configuration:**

```json
{
  "mcpServers": {
    "browserbase": {
      "command": "mcp-server-browserbase",
      "args": [],
      "env": {
        "BROWSERBASE_API_KEY": "your-api-key-here",
        "BROWSERBASE_PROJECT_ID": "your-project-id"
      }
    }
  }
}
```

## Configuration for Claude Code

### Method 1: Via Claude Code UI

1. Open Claude Code
2. Go to **Settings** → **Model Context Protocol (MCP)**
3. Click **Add MCP Server**
4. Select or enter:
   - **Name:** `playwright` (or `puppeteer`, `browserbase`)
   - **Command:** `mcp-server-playwright` (or equivalent)
   - **Arguments:** Leave empty `[]`
   - **Environment Variables:** Leave empty `{}` (unless using Browserbase)
5. Click **Save**
6. Restart Claude Code to activate the server

### Method 2: Manual Configuration File

Edit `~/.config/claude/mcp_config.json` (create if it doesn't exist):

```json
{
  "mcpServers": {
    "playwright": {
      "command": "mcp-server-playwright",
      "args": [],
      "env": {}
    }
  }
}
```

Or on macOS, the config might be at:
```
~/Library/Application Support/Claude/mcp_config.json
```

## Verification Steps

Once installed and configured, verify the MCP server is working:

### 1. Check MCP Server Status

In Claude Code, look for the MCP indicator in the status bar or settings panel. You should see `playwright` (or your chosen server) listed as "Connected" or "Active".

### 2. Test Basic Navigation

Ask Claude to perform a simple browser task:

```
Can you navigate to https://example.com and take a screenshot?
```

Expected behavior:
- Claude should invoke the browser automation tools
- Navigate to the URL
- Return a screenshot or confirmation

### 3. Test Element Interaction

```
Navigate to https://httpbin.org/forms/post and fill out the form with test data.
```

Expected behavior:
- Claude should locate form elements
- Fill in fields with appropriate test data
- Optionally submit the form

### 4. Test Content Extraction

```
Go to https://news.ycombinator.com and extract the top 3 story titles.
```

Expected behavior:
- Claude navigates to the page
- Identifies story title elements
- Returns extracted text

## Common Use Cases

### E2E Testing

Claude can generate and run Playwright tests:

```
Create a Playwright test that:
1. Logs into the app at http://localhost:3000
2. Navigates to /dashboard
3. Clicks the "Create New" button
4. Verifies the modal appears
```

### Web Scraping

```
Scrape product prices from https://example-shop.com/products and return as JSON.
```

### Visual Regression Testing

```
Navigate to http://localhost:3000/landing and take screenshots at:
- Desktop (1920x1080)
- Tablet (768x1024)
- Mobile (375x667)
```

### Form Automation

```
Fill out the contact form at https://example.com/contact with:
- Name: Test User
- Email: test@example.com
- Message: Automated testing message
```

## Troubleshooting

### Issue: MCP Server Not Found

**Symptom:** Claude Code shows "playwright" as "Not Found" or "Error"

**Solution:**
1. Verify installation: `which mcp-server-playwright`
2. Ensure global npm bin is in PATH: `echo $PATH | grep npm`
3. Re-install: `npm install -g @automatalabs/mcp-server-playwright`
4. Restart Claude Code

### Issue: Browser Not Launching

**Symptom:** "Failed to launch browser" or timeout errors

**Solution (Playwright):**
1. Install browser binaries: `npx playwright install`
2. Verify Chromium installed: `npx playwright install chromium`
3. Check permissions: `ls -la ~/.cache/ms-playwright/`

**Solution (Puppeteer):**
1. Puppeteer downloads Chromium automatically on install
2. If missing: `npm install -g puppeteer --unsafe-perm=true`

### Issue: Headless Mode Issues

**Symptom:** Screenshots are blank or elements not found

**Solution:**
Most MCP servers run in headless mode by default. To debug visually:

**For Playwright:**
```json
{
  "mcpServers": {
    "playwright": {
      "command": "mcp-server-playwright",
      "args": ["--headed"],
      "env": {}
    }
  }
}
```

**For Puppeteer:**
```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "puppeteer-mcp-server",
      "args": ["--no-headless"],
      "env": {}
    }
  }
}
```

### Issue: Permission Denied

**Symptom:** `EACCES` or permission errors

**Solution:**
1. Check npm global prefix: `npm config get prefix`
2. Fix permissions: `sudo chown -R $USER ~/.npm`
3. Or use nvm/volta to manage Node versions without sudo

### Issue: Port Already in Use

**Symptom:** "Address already in use" or "Port 3000 in use"

**Solution:**
1. MCP servers use stdio (not HTTP), so this shouldn't happen
2. If it does, check for zombie processes: `ps aux | grep playwright`
3. Kill if needed: `pkill -f playwright`

## Integration with Haunt Framework

### Adding to Agent Tool Access

To enable browser automation for Dev agents, update agent character sheets:

```yaml
---
name: gco-dev
description: Implementation agent with browser testing capabilities.
tools: Glob, Grep, Read, Write, Edit, Bash, mcp__playwright
---
```

Note: The `mcp__playwright` syntax allows agent access to all tools from the `playwright` MCP server.

### Example: Automated E2E Testing

```
/summon dev "Create Playwright test for login flow"

Agent will:
1. Generate test file in tests/e2e/login.spec.ts
2. Use Browser MCP to verify test works locally
3. Commit passing test
```

### Example: Visual QA

```
/qa REQ-123 --format=playwright

Generates test scenarios with:
- Browser navigation
- Element interaction
- Screenshot capture
- Assertion checks
```

## Advanced Configuration

### Custom Browser Arguments

```json
{
  "mcpServers": {
    "playwright": {
      "command": "mcp-server-playwright",
      "args": [
        "--browser=firefox",
        "--timeout=30000",
        "--viewport=1920x1080"
      ],
      "env": {}
    }
  }
}
```

### Proxy Configuration

```json
{
  "mcpServers": {
    "playwright": {
      "command": "mcp-server-playwright",
      "args": [],
      "env": {
        "HTTP_PROXY": "http://proxy.example.com:8080",
        "HTTPS_PROXY": "http://proxy.example.com:8080"
      }
    }
  }
}
```

### Debugging with Verbose Logs

```json
{
  "mcpServers": {
    "playwright": {
      "command": "mcp-server-playwright",
      "args": ["--verbose"],
      "env": {
        "DEBUG": "pw:api"
      }
    }
  }
}
```

## Security Considerations

### Sensitive Data

- Never store API keys or credentials in browser automation scripts
- Use environment variables for secrets: `process.env.TEST_PASSWORD`
- Avoid navigating to untrusted sites with production credentials

### Sandboxing

- Browser MCP runs with your user permissions
- Be cautious with file downloads and uploads
- Review generated automation scripts before running

### Rate Limiting

- Respect target website rate limits
- Add delays between requests if scraping
- Use headless mode for production tests (faster, less resource intensive)

## Next Steps

1. **Install Playwright MCP** (recommended starting point)
2. **Configure in Claude Code** settings
3. **Verify with simple test** (navigate to example.com)
4. **Integrate with Haunt agents** (add to tool access)
5. **Create E2E test suite** using `/qa` command (once REQ-197 is complete)

## References

- [Playwright Documentation](https://playwright.dev/)
- [Puppeteer Documentation](https://pptr.dev/)
- [MCP Specification](https://modelcontextprotocol.io/)
- [Automata Labs MCP Server](https://github.com/Automata-Labs-team/MCP-Server-Playwright)
- [Browserbase MCP Server](https://www.browserbase.com/)

## Related Requirements

- **REQ-196:** Create `/qa` command for test scenario generation
- **REQ-197:** Playwright test generation integration
- **REQ-198:** Exploratory test charter generation

---

**Last Updated:** 2025-12-15
**Haunt Framework Version:** 2.0
