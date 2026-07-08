# jawad.ch — Project Context

## What This Is

Jawad Charafeddine's professional portfolio and blog. Primary audience: potential employers, SOC hiring managers, and peer practitioners in blue-team/detection engineering. The site is a living proof-of-work — every post and project card should demonstrate real hands-on capability.

**Live site:** jawad.ch  
**LinkedIn:** linkedin.com/in/jawadchar  
**GitHub:** linked from portfolio

---

## Stack

- **Framework:** Astro 5.7
- **Styling:** Tailwind CSS 4.1
- **Content:** MDX / Markdown via Astro Content Collections (`src/content/blog/`)
- **Deploy:** Netlify via GitHub push
- **Writing workflow:** Obsidian → symlink → `src/content/blog/` → git push → auto-deploy

---

## Jawad's Professional Identity

- **Title:** Cybersecurity Analyst · Blue Team · SOC · Agentic AI Engineering
- **Current role:** Cybersecurity Support Analyst at LogN Pacific (Dec 2025–present)
- **Certs:** CompTIA Security+, CompTIA CySA+
- **Education:** B.S. Psychology, Biology Minor — University of Houston
- **Core skills:** Microsoft Sentinel / KQL, Defender for Endpoint, Tenable, MITRE ATT&CK, NIST frameworks, PowerShell, Python, Bash
- **Differentiator:** Combines traditional SOC depth (detection, threat hunting, vuln management) with agentic AI engineering (Claude API, tool-use patterns)
- **Resume on site:** v2.8.4 (updated 2026-07-08)

---

## Blog Voice & Style Guide

**Tone:** Technical but accessible. Writes for practitioners who already understand the domain — no hand-holding on basics, but no jargon for its own sake.

**Structure pattern:**
1. Problem statement or scenario hook
2. Investigation/build narrative (chronological or architectural)
3. Technical detail with inline evidence (KQL, code, output)
4. Outcome + honest assessment of limitations or gaps

**What makes a post work here:**
- Grounded in a real thing Jawad built or investigated (not hypothetical)
- Shows the *reasoning*, not just the result
- Includes something copy-pasteable or immediately actionable (query, snippet, config)
- Ends with a clear takeaway or "what I'd do differently"

**What to avoid:**
- Generic "intro to X" content without a personal angle
- Padding or summary sections that repeat what was already said
- Overclaiming AI capabilities or tool sophistication

---

## Current Blog Posts

| Title | Date | Tags | Notes |
|-------|------|------|-------|
| Building this blog | 2026-02-22 | meta, astro, obsidian | Hugo → Astro migration, Obsidian publishing pipeline |
| Threat Hunt: Scattered Invoice — BEC via MFA Fatigue | 2026-04-24 | threat-hunting, BEC, Sentinel, KQL | IR-2026-0225-BEC writeup; MFA fatigue → inbox rules → £24,500 wire fraud |
| I Built an AI Agent to Triage Sentinel Alerts | 2026-04-26 | SOC, AI, Sentinel, Python, MITRE | Claude-powered agentic triage; KQL + IOC enrichment + MITRE mapping |
| What Leading Threat Intel Actually Taught Me About SOC Work | 2026-05-11 | threat-intelligence, SOC, MITRE ATT&CK, blue-team, reflection | Personal/reflective; sourced from LinkedIn post; covers IOC-vs-TTP ordering, actor profiling, intel pipeline feeding detection eng |

**Cadence so far:** ~1–2 posts/month (Feb–May 2026, then gap). No em dashes in post body — Jawad's preference.

---

## Blog Pipeline — Suggested Posts

Ordered by priority (portfolio coverage + employer signal value):

### Tier 1 — High priority (directly tied to portfolio projects)

1. **Vulnerability Management: Building a Program from Scratch**  
   Walk through the full VM program built in the home lab — asset discovery, Tenable scanning, CVSS triage, remediation tracking, reporting. Ties to: Vulnerability Management Program + Programmatic Vulnerability Remediations repos.

2. **Threat Hunt: TOR Browser Detection**  
   Parallel format to the Scattered Invoice post — scenario setup, hypothesis, KQL hunt, findings. Demonstrates repeatable threat hunt methodology.

3. **Hardening Windows with DISA STIGs: Automation Over Clicking**  
   How the PowerShell/Bash STIG remediation scripts work, what STIGs actually check for, how to run them safely in a lab vs. prod. Ties to: DISA STIG Remediations repo.

4. **KQL Maps: Visualizing Threat Data in Sentinel**  
   The why and how behind geo-mapping Sentinel data. Practical use case, gotchas with IP enrichment, what it communicates to stakeholders.

### Tier 2 — Medium priority (skills demonstration)

5. **Building a Detection: From MITRE Technique to Sentinel Alert Rule**  
   End-to-end walkthrough of translating a MITRE ATT&CK technique (e.g. T1059 or T1078) into a working KQL detection with tuning notes.

6. **MFA Fatigue: The Defense Side**  
   Follow-up to Scattered Invoice — what controls would have stopped/slowed the attack. Number-matching MFA, Conditional Access, alert rules.

7. **Home Lab Architecture: Building a SOC on a Budget**  
   The infrastructure behind the posts — what's running, why, how it's networked. Useful anchor post that gives context to all other lab writeups.

### Tier 3 — Lower priority / LinkedIn-sourced ideas

8. **Internet-Facing Asset Detection: What Azure Exposes by Default**  
   Asset exposure audit methodology, NSG misconfigs, public IP sprawl.

9. **Extending the AI Triage Agent: Adding Memory and Escalation Logic**  
   Follow-up to the triage agent post — next-iteration improvements.

10. **From Psychology to Cybersecurity: An Honest Retrospective**  
    Career transition story. High engagement potential on LinkedIn; employer-friendly narrative.

---

## Suggested Posting Timeline

**Goal:** 2 posts/month, sustainable. Alternating between investigation/hunt posts and build/tool posts.

| Month | Post |
|-------|------|
| July 2026 | Vulnerability Management Program writeup |
| July 2026 | TOR Browser Threat Hunt |
| August 2026 | DISA STIG Automation |
| August 2026 | Building a Detection End-to-End |
| September 2026 | KQL Maps |
| September 2026 | MFA Fatigue: Defense Side |
| October 2026 | Home Lab Architecture |
| October 2026 | Internet-Facing Asset Detection |
| November 2026 | AI Triage Agent: Follow-up |
| November 2026 | Psychology → Cybersecurity retrospective |

---

## Maintenance Instructions for Claude

**When a new blog post is published:**
- Add it to the "Current Blog Posts" table above
- Remove it from the pipeline list
- Note any style or tone observations that should inform future posts

**When a project is added/updated on the portfolio:**
- Update the projects section in the user memory file
- Check if any pipeline post ideas should be promoted to Tier 1

**When Jawad shares LinkedIn posts:**
- Extract topic angles and add relevant ones to Tier 3 pipeline
- Look for recurring themes that suggest audience interest

**When site config or stack changes:**
- Update the Stack section above

**Goal:** This file should always reflect the current state of the blog so any new Claude conversation can orient immediately without re-reading the codebase.
