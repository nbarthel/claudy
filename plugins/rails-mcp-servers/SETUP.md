# Rails MCP Servers Setup Guide

This guide explains how to configure API keys and environment variables for the Rails MCP Servers plugin.

## Quick Start

### 1. Copy Environment Template

```bash
# In your Rails project directory
cp .env.example .env
```

### 2. Configure API Key (Optional)

Edit `.env` and add your Rails documentation API key:

```bash
RAILS_DOCS_API_KEY=your_api_key_here
```

**Note**: The API key is optional. The plugin works with the free tier if no key is provided.

### 3. Verify Configuration

```bash
# Check that your .env file is loaded
cat .env
```

## Configuration Options

### Rails Documentation API Key

**Variable**: `RAILS_DOCS_API_KEY`

**Purpose**: Authenticates with Rails documentation API for enhanced access

**Where to get it**:
- Contact Rails documentation provider
- Or use the free tier (leave blank)

**Example**:
```bash
RAILS_DOCS_API_KEY=sk_rails_1234567890abcdef
```

### Rails Version

**Variable**: `RAILS_VERSION`

**Purpose**: Specifies which Rails version documentation to use

**Default**: `8.0`

**Supported versions**:
- `7.0` - Rails 7.0.x
- `7.1` - Rails 7.1.x
- `8.0` - Rails 8.0.x
- `edge` - Rails edge (development)

**Example**:
```bash
RAILS_VERSION=8.0
```

### Filesystem Allowed Directories

**Variable**: `ALLOWED_DIRECTORIES`

**Purpose**: Comma-separated list of directories the filesystem MCP server can access

**Default**: `app,config,db,lib,spec,test`

**Example**:
```bash
ALLOWED_DIRECTORIES=app,config,db,lib,spec,test,custom
```

## Security Best Practices

### 1. Never Commit .env Files

Ensure `.env` is in your `.gitignore`:

```bash
echo ".env" >> .gitignore
```

### 2. Use Environment Variables in CI/CD

For production/staging environments, set environment variables directly:

```bash
# In GitHub Actions
env:
  RAILS_DOCS_API_KEY: ${{ secrets.RAILS_DOCS_API_KEY }}

# In Heroku
heroku config:set RAILS_DOCS_API_KEY=your_key

# In Docker
docker run -e RAILS_DOCS_API_KEY=your_key ...
```

### 3. Restrict Filesystem Access

Only allow necessary directories in `ALLOWED_DIRECTORIES`:

```bash
# Minimal access for code review only
ALLOWED_DIRECTORIES=app,spec

# Full access for development
ALLOWED_DIRECTORIES=app,config,db,lib,spec,test
```

## Installation Methods

### Method 1: Plugin Installation (Copies .env.example)

When you install via `/plugin install`, the `.env.example` file is automatically copied to your project:

```bash
/plugin install rails-mcp-servers@claudy
# .env.example is copied to your project
cp .env.example .env
# Edit .env with your configuration
```

### Method 2: Manual Setup

If you installed manually or need to reconfigure:

```bash
# Copy template from plugin directory
cp path/to/claudy/plugins/rails-mcp-servers/.env.example .env

# Edit with your settings
vim .env
```

## Troubleshooting

### API Key Not Working

**Problem**: Rails docs not loading or authentication errors

**Solutions**:

1. **Verify API key format**:
   ```bash
   # Should start with sk_rails_ or similar
   echo $RAILS_DOCS_API_KEY
   ```

2. **Check .env is loaded**:
   ```bash
   # In your project
   cat .env | grep RAILS_DOCS_API_KEY
   ```

3. **Restart Claude Code**:
   ```bash
   # Exit and restart Claude Code to reload environment
   exit
   claude
   ```

4. **Test without API key**:
   ```bash
   # Try with free tier
   RAILS_DOCS_API_KEY= claude
   ```

### Environment Variables Not Loading

**Problem**: Configuration changes not taking effect

**Solutions**:

1. **Check file location**:
   ```bash
   # .env must be in project root
   ls -la .env
   ```

2. **Verify file format**:
   ```bash
   # No spaces around =
   # Correct: RAILS_VERSION=8.0
   # Wrong:   RAILS_VERSION = 8.0
   cat .env
   ```

3. **Reload environment**:
   ```bash
   # Restart Claude Code session
   exit
   claude
   ```

### Filesystem Access Denied

**Problem**: MCP server can't read/write files

**Solutions**:

1. **Check allowed directories**:
   ```bash
   echo $ALLOWED_DIRECTORIES
   ```

2. **Verify directory exists**:
   ```bash
   # Directory must exist in your Rails project
   ls -la app config db
   ```

3. **Check permissions**:
   ```bash
   # Ensure directories are readable/writable
   chmod -R u+rw app config db
   ```

## Advanced Configuration

### Per-Environment Settings

Create environment-specific configuration:

```bash
# .env.development
RAILS_DOCS_API_KEY=dev_key
RAILS_VERSION=edge

# .env.production
RAILS_DOCS_API_KEY=prod_key
RAILS_VERSION=8.0

# Load appropriate file
export ENV=development
source .env.$ENV
```

### Team Sharing (Without Secrets)

Share configuration template with your team:

```bash
# .env.example (commit this)
RAILS_DOCS_API_KEY=
RAILS_VERSION=8.0

# .env (in .gitignore, each team member configures)
RAILS_DOCS_API_KEY=their_actual_key
RAILS_VERSION=8.0
```

### Docker Integration

```dockerfile
# Dockerfile
ENV RAILS_VERSION=8.0

# docker-compose.yml
services:
  app:
    env_file:
      - .env
    environment:
      - RAILS_DOCS_API_KEY=${RAILS_DOCS_API_KEY}
```

## Examples

### Example 1: Free Tier Usage

```bash
# .env
RAILS_VERSION=8.0
ALLOWED_DIRECTORIES=app,config,db,spec
# No API key needed for free tier
```

### Example 2: Premium Access

```bash
# .env
RAILS_DOCS_API_KEY=sk_rails_abc123xyz
RAILS_VERSION=8.0
ALLOWED_DIRECTORIES=app,config,db,lib,spec,test
```

### Example 3: Restricted Access

```bash
# .env - Code review only
RAILS_VERSION=8.0
ALLOWED_DIRECTORIES=app,spec
# Minimal filesystem access for security
```

## FAQ

**Q: Is the API key required?**
A: No, the plugin works with free tier documentation access.

**Q: Where do I get an API key?**
A: Contact the Rails documentation provider or use the free tier.

**Q: Can I use different Rails versions per project?**
A: Yes, set `RAILS_VERSION` in each project's `.env` file.

**Q: What happens if I don't set RAILS_VERSION?**
A: Defaults to 8.0 (latest stable).

**Q: Can I add custom directories to ALLOWED_DIRECTORIES?**
A: Yes, add comma-separated paths relative to project root.

**Q: Is my API key secure?**
A: Keep `.env` in `.gitignore` and never commit it. Use secrets management in production.

## Support

For issues with configuration:

1. Check this guide
2. Verify `.env` file format
3. Test with defaults (no customization)
4. Check Claude Code logs
5. Open GitHub issue with error details

## Version

Setup guide for rails-mcp-servers v0.1.1+
