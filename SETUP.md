# jawad.ch — Setup Guide

Complete setup from zero to live site in ~30 minutes.

---

## Prerequisites

### 1. Install Node.js
```powershell
choco install nodejs-lts
```
Then close and reopen your terminal. Verify:
```powershell
node --version   # should be v22+
npm --version
```

### 2. Install dependencies
```powershell
cd C:\Users\jawad\jawad.ch
npm install
```

### 3. Add the Agave Nerd Font
Download from: https://github.com/ryanoasis/nerd-fonts/releases/latest
- Find `Agave.zip`, download and extract
- Copy `AgaveNerdFont-Regular.woff2` and `AgaveNerdFont-Bold.woff2` into `public/fonts/`

If the font files aren't present, the site falls back gracefully to JetBrains Mono / Cascadia Code / system monospace.

### 4. Add your resume PDF
Copy your resume PDF to:
```
public/Jawad_Charafeddine_Resume.pdf
```

---

## Local Development

```powershell
npm run dev
```
Opens at http://localhost:4321

---

## Obsidian → GitHub Auto-Deploy Setup

### Step 1 — Run the symlink setup script (one-time, as Administrator)
```powershell
# Right-click PowerShell → "Run as Administrator"
cd C:\Users\jawad\jawad.ch
.\setup-obsidian-sync.ps1
```

This creates two directory junctions in your Obsidian vault:
- `vault\blogposts` → `repo\src\content\blog`  (your posts land here)
- `vault\attachments` → `repo\public\images`  (images land here)

### Step 2 — Configure Obsidian
In Obsidian: **Settings → Files & Links**
- **Default location for new attachments:** `attachments`
- **Use [[Wikilinks]]:** OFF (optional — either works, the site handles both)

### Step 3 — Install Obsidian Git plugin
1. **Settings → Community Plugins → Browse** → search "Obsidian Git" → Install → Enable
2. In Obsidian Git settings:
   - **Auto commit after file change:** ON
   - **Auto push after commit:** ON  
   - **Commit message:** `blog: {{date}} auto-commit`
   - **Pull changes before push:** ON

### Step 4 — Initialize the git repo and push to GitHub
```powershell
cd C:\Users\jawad\jawad.ch
git init
git add .
git commit -m "initial commit"
git branch -M main
git remote add origin https://github.com/jawadchar/<your-repo-name>.git
git push -u origin main
```

---

## Netlify Setup (one-time)

1. Go to https://app.netlify.com → **Add new site → Import an existing project**
2. Connect GitHub → select your repo
3. Build settings (auto-detected from `netlify.toml`):
   - **Build command:** `npm run build`
   - **Publish directory:** `dist`
   - **Node version:** `22`
4. Click **Deploy site**

### Connect jawad.ch domain
1. In Netlify: **Site settings → Domain management → Add custom domain**
2. Add `jawad.ch`
3. Netlify will give you nameservers or a CNAME — update your domain registrar's DNS
4. Enable **HTTPS** (free via Let's Encrypt — Netlify does this automatically)

### Enable Netlify Forms (contact form)
No extra config needed — Netlify auto-detects the `data-netlify="true"` attribute.
Check submissions at: **Netlify dashboard → Forms**

---

## Writing a Blog Post

1. Open Obsidian → navigate to the `blogposts` folder
2. Create a new note with this frontmatter:

```yaml
---
title: My Post Title
date: 2026-04-20
description: One-sentence summary shown in the post list.
tags:
  - threat-hunting
  - kql
draft: false
---

Your content here...
```

3. Add images with either syntax — both work:
   - Obsidian wikilink: `![[image.png]]`
   - Standard markdown: `![alt text](attachments/image.png)`

4. Save. Obsidian Git auto-commits and pushes within seconds.
5. Netlify detects the push and deploys. Live in ~60 seconds.

### Draft posts
Set `draft: true` in frontmatter — the post builds but won't appear in the blog list or be accessible.

---

## File Structure

```
jawad.ch/
├── src/
│   ├── content/blog/        ← Blog posts (symlinked from Obsidian)
│   ├── lib/remarkObsidian.mjs  ← Obsidian image syntax transformer
│   ├── pages/
│   │   ├── index.astro      ← Homepage
│   │   ├── blog/            ← Blog list + post pages
│   │   └── contact.astro    ← Contact form
│   ├── layouts/             ← Page shells
│   ├── components/          ← Reusable UI components
│   └── styles/global.css    ← Theme + Tailwind
├── public/
│   ├── fonts/               ← Agave Nerd Font (add manually)
│   ├── images/              ← Blog images (symlinked from Obsidian attachments)
│   └── Jawad_Charafeddine_Resume.pdf  ← Add manually
├── netlify.toml
└── setup-obsidian-sync.ps1  ← Run once as Admin
```
