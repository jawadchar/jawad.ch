---
title: Building this blog
date: 2026-02-22
description: Notes on migrating from Hugo to Astro and setting up the Obsidian-to-Netlify publishing workflow.
tags:
  - meta
  - astro
  - obsidian
draft: false
---

I've wanted a personal site for a while — somewhere to document my work, write about what I'm learning in cybersecurity, and have something more useful than a LinkedIn profile to point people to. This post covers how I got here: the initial Hugo attempt, why I abandoned it, and how the current Astro setup works.

## Starting with Hugo

Hugo seemed like the obvious choice. It's fast, well-documented, and the GitHub Pages integration is zero-config. I picked the `hugo-blog-awesome` theme and had something running locally in about an hour.

Then the friction started.

### hugo-extended

The first thing I hit was that the theme required `hugo-extended` — the build that includes Sass support — rather than the standard Hugo binary. If you install the wrong one, your site builds without error but renders completely wrong, with no CSS. The fix is straightforward once you know what to look for:

```bash
hugo version
# should output something like: hugo v0.X.X+extended
```

If `+extended` isn't in the output, reinstall:

```powershell
choco install hugo-extended
```

### Dart Sass

The extended build handles Sass compilation, but it needs an actual Sass implementation. Hugo deprecated LibSass in v0.153.0 in favor of Dart Sass. Without it, the build fails silently on some setups and throws deprecation warnings on others.

```bash
choco install sass
```

After that, `hugo server` finally rendered the theme correctly.

### .Site.Author deprecation

The third problem hit after upgrading Hugo past v0.124.0. The theme's templates were using `.Site.Author`, which got deprecated in favor of `[params.author]` in `hugo.toml`. The site would build, but the RSS feed threw template errors.

Fix — update `hugo.toml`:

```toml
[params.author]
  name = "Jawad Charafeddine"
  email = "contact@jawad.ch"
```

Then update the RSS template to replace every instance of:

```
{{ .Site.Author.email }}
```

with:

```
{{ .Site.Params.author.email }}
```

At this point everything worked, but I'd spent most of a day on tooling issues rather than actually writing content. And I kept running into the same underlying problem: I wanted a portfolio *and* a blog, and Hugo themes are built for one or the other. Getting both in the same site meant either frankensteining a theme or writing a lot of custom template code in Hugo's Go-template syntax, which isn't my idea of a good time.

## Why I switched to Astro

A few things made Astro the right call for this specific project:

**Component model.** Astro lets you build the layout as actual components — header, footer, cards — without fighting a theming system. I could write exactly the portfolio structure I wanted without inheriting someone else's opinions about it.

**Content Collections.** Astro has first-class support for Markdown/MDX blog posts with typed frontmatter, automatic slug generation, and a clean API for listing and rendering posts. The Hugo equivalent works, but requires more boilerplate.

**Tailwind integration.** Tailwind v4 + Astro is a one-line Vite plugin. The whole dark/light theme system — CSS variables, the toggle, the `prefers-color-scheme` fallback — took maybe two hours to wire up from scratch.

**Obsidian compatibility.** This was the deciding factor. I take notes in Obsidian, and I wanted to write blog posts there too and have them publish automatically. Hugo can be made to work with Obsidian, but the wikilink syntax (`![[image.png]]`) requires a custom preprocessor. Astro's remark plugin system made it straightforward to add that transformer — a small `remarkObsidian.mjs` file that rewrites wikilinks to standard Markdown image syntax before the build runs.

## The publishing pipeline

The current setup:

1. Write a post in Obsidian — the `blogposts/` folder in my vault is symlinked to `src/content/blog/` in the repo.
2. Save the file. Obsidian Git picks it up within seconds, commits, and pushes to GitHub.
3. Netlify detects the push and rebuilds. The site is live in under a minute.

Images work the same way — the Obsidian attachments folder is symlinked to `public/images/`, so anything I paste into a note is automatically available at build time.

The whole thing runs without me touching a terminal after initial setup. That's the workflow I wanted.

## What's next

I'll be posting writeups here for security projects, home lab findings, and detection engineering work — the kind of content that's too long for a GitHub README but worth documenting somewhere. If you're building something similar and have questions about the Hugo → Astro migration or the Obsidian pipeline, feel free to reach out.
