/**
 * remarkObsidian.mjs
 *
 * Handles two Obsidian image formats so posts render correctly in Astro:
 *
 *   1. Wikilink images:   ![[image.png]]  or  ![[image.png|alt text]]
 *   2. Standard markdown: ![alt](attachments/image.png)
 *
 * Both are rewritten to reference /images/<filename> (served from public/images/).
 */

import { visit } from 'unist-util-visit';

export function remarkObsidian() {
  return (tree) => {
    // ── Pass 1: Transform ![[image]] wikilink syntax ─────────────────────────
    visit(tree, 'paragraph', (node) => {
      const newChildren = [];

      for (const child of node.children) {
        if (child.type !== 'text') {
          newChildren.push(child);
          continue;
        }

        const wikiImageRe = /!\[\[([^\]|]+?)(?:\|([^\]]*))?\]\]/g;
        let lastIndex = 0;
        let match;

        while ((match = wikiImageRe.exec(child.value)) !== null) {
          // Text before the match
          if (match.index > lastIndex) {
            newChildren.push({ type: 'text', value: child.value.slice(lastIndex, match.index) });
          }

          const rawSrc = match[1].trim();
          const alt = (match[2] ?? rawSrc).trim();
          // Keep only the filename — strip any leading path components
          const filename = rawSrc.split(/[/\\]/).pop();

          newChildren.push({
            type: 'image',
            url: `/images/${filename}`,
            alt,
            title: null,
          });

          lastIndex = match.index + match[0].length;
        }

        if (lastIndex < child.value.length) {
          newChildren.push({ type: 'text', value: child.value.slice(lastIndex) });
        }
      }

      node.children = newChildren;
    });

    // ── Pass 2: Fix relative image paths (standard markdown from Obsidian) ───
    // Transforms  attachments/image.png  →  /images/image.png
    visit(tree, 'image', (node) => {
      if (!node.url) return;
      if (node.url.startsWith('http') || node.url.startsWith('/')) return;

      const filename = node.url.split(/[/\\]/).pop();
      node.url = `/images/${filename}`;
    });
  };
}
