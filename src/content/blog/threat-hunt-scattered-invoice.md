---
title: "Threat Hunt: Scattered Invoice — BEC via MFA Fatigue"
date: 2026-04-24
description: A walkthrough of incident IR-2026-0225-BEC — tracing a business email compromise from MFA fatigue through inbox rule persistence to a £24,500 wire fraud.
tags:
  - threat-hunting
  - BEC
  - Microsoft Sentinel
  - KQL
  - Scattered Spider
draft: false
---

LogN Pacific Financial Services got a call from their bank. A vendor payment of £24,500 had been redirected to an unknown account. The bank flagged it and froze the funds. Finance said they'd followed standard procedure — they got an email from a known colleague with updated banking details and processed it.

That's how it starts.

This is the writeup for incident **IR-2026-0225-BEC**, a business email compromise I investigated using Microsoft Sentinel. The data sources were `SignInLogs`, `CloudAppEvents`, and `EmailEvents`. Investigation window: February 25, 2026 21:00 UTC to February 26, 2026 00:00 UTC.

![Scattered Invoice — Incident Brief](/images/scattered-invoice-brief.png)

## Background

Finance employee **Mark Smith** (`m.smith@lognpacific.org`) reported something odd the evening of February 25. He was at home watching TV when his phone started buzzing with MFA push notifications. He assumed it was an IT glitch and eventually approved one just to make them stop. The next morning, colleagues found inbox rules nobody recognized. That afternoon, the bank called.

The objective of the investigation: confirm the compromise, identify the attacker's infrastructure, scope what rules were created and what emails were sent, and determine how they got past MFA.

---

## Phase 1: MFA Bypass

The first question was how the attacker authenticated. I pulled Mark's sign-in activity for the investigation window.

```kql
SignInLogs
| where TimeGenerated between (datetime(2026-02-25 21:00:00) .. datetime(2026-02-26 00:00:00))
| where UserPrincipalName == "m.smith@lognpacific.org"
| project TimeGenerated, IPAddress, Location, DeviceDetail, Status, MfaDetail
| order by TimeGenerated asc
```

The logs showed a burst of MFA push requests from IP `205.147.16.190` starting around 21:45 UTC — all initially denied or timed out. Then at **21:51:04 UTC**, one was approved. Session ID: `00225cfa-a0ff-fb46-a079-5d152fcdf72a`. That session ID appears on every malicious action that follows.

The device detail on the approved sign-in was the immediate tell: a **Linux machine running Firefox 147.0**. Mark's normal device is a managed Windows endpoint. Same user, same credentials — completely different OS and browser fingerprint.

This is **MFA fatigue (T1621)**. No phishing page, no credential stuffing — just repeated push notifications until the user approves one to make them stop. It exploits the user, not the technology.

---

## Phase 2: Inbox Rule Persistence

Within minutes of authentication, the attacker opened Outlook Web and created two inbox rules. I found them in `CloudAppEvents`.

```kql
CloudAppEvents
| where TimeGenerated between (datetime(2026-02-25 21:51:00) .. datetime(2026-02-26 00:00:00))
| where AccountId == "m.smith@lognpacific.org"
| where ActionType == "New-InboxRule"
| project TimeGenerated, ActionType, RawEventData
| order by TimeGenerated asc
```

Two rules, both named to be invisible at a glance:

**Rule `"."`** — forwards any email with `invoice`, `payment`, `wire`, or `transfer` in the subject to `insights@duck.com`. `StopProcessingRules` enabled.

**Rule `".."`** — captures Microsoft security alert emails and suppresses them. Same `StopProcessingRules` flag.

The design is deliberate. The first rule gives the attacker a live feed of every finance-relevant email thread. The second ensures that any risky sign-in alerts or authentication anomaly notifications Microsoft sends to the mailbox are silently discarded — Mark never sees them. The attacker buys time while the account looks normal.

This is **Email Hiding Rules (T1564.008)**.

---

## Phase 3: Thread Hijacking and the Wire Transfer

With monitoring set up, the attacker looked for an active payment conversation. I pulled outbound email from the compromised session.

```kql
EmailEvents
| where TimeGenerated between (datetime(2026-02-25 21:51:00) .. datetime(2026-02-26 00:00:00))
| where SenderFromAddress == "m.smith@lognpacific.org"
| project TimeGenerated, SenderFromAddress, RecipientEmailAddress, Subject, NetworkMessageId
| order by TimeGenerated asc
```

The attacker found an active vendor payment thread and replied into it, impersonating Mark. The email went to colleague **J. Reynolds** with updated banking details for an upcoming wire transfer. Reynolds had no reason to question it — it came from Mark's real account, in an existing thread, in Mark's name.

Reynolds processed it. £24,500 moved to the attacker's account. The receiving bank flagged it as suspicious, froze the funds, and called LogN Pacific's fraud department — which is what surfaced the incident at all.

---

## Attribution

The TTP profile maps cleanly to **Scattered Spider** (UNC3944):

- MFA fatigue as the primary initial access method
- Finance department specifically targeted
- BEC as the end objective
- No malware — entirely living off the victim's own cloud tooling (Outlook Web, inbox rules, legitimate email forwarding)
- Use of privacy-focused infrastructure to receive exfiltrated data (Duck.com forwarding)

This group has been linked to the MGM Resorts and Caesars Entertainment breaches using the same MFA fatigue → account takeover → BEC chain. The `insights@duck.com` forwarding destination is consistent with their pattern of using disposable, privacy-preserving addresses to avoid exposing attacker-controlled infrastructure.

---

## MITRE ATT&CK

| Technique | ID | What happened |
|---|---|---|
| MFA Request Generation | T1621 | Repeated push notifications until Mark approved one |
| Email Hiding Rules | T1564.008 | Two inbox rules to forward finance emails and suppress security alerts |
| Internal Spearphishing | T1534 | Thread hijacking to impersonate Mark with J. Reynolds |
| Financial Theft | T1657 | £24,500 wire fraud to attacker-controlled account |

---

## What caught it — and what didn't

The bank's fraud detection caught the unusual wire and froze the funds. That's the only reason this surfaced when it did. Without that external flag, the inbox rules would have continued running silently and the attacker would have had ongoing visibility into finance email threads indefinitely.

Nothing internal caught it in real time:
- No alert fired on the device anomaly at sign-in (Linux vs. managed Windows endpoint)
- No alert fired on inbox rule creation
- No monitoring on external forwarding destinations

All three are detectable in Sentinel. None were configured. The attacker didn't need to be clever about evasion — the detection content simply wasn't there.

The detection gaps are the real finding here. The attack itself isn't sophisticated. MFA fatigue is a solved problem: number matching and additional context in push notifications eliminate it almost entirely. Inbox rule creation to external domains is a one-query alert. The attacker succeeded because standard hardening wasn't in place, not because they did anything technically impressive.
