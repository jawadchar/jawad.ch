---
title: "What Leading Threat Intel Actually Taught Me About SOC Work"
date: 2026-05-11
tags: [threat-intelligence, SOC, MITRE ATT&CK, blue-team, reflection]
draft: false
description: >
  I'm leading the Threat Intelligence function in a 50-person SOC build
  against a live cyber range. Here's what the role actually looks like
  and what it changed about how I think about detection work.
---

I've been doing blue team work long enough to have opinions about threat
intelligence. Specifically, that a lot of what gets called "threat intel"
in practice is just IOC feeds: a rotating list of IPs and hashes that
get ingested, maybe matched against once, and forgotten.

So when I took on the Threat Intel lead role in a large-scale SOC build
project I'm part of (50 contributors, six specialized functions, live
cyber range, real attacker activity), I had to figure out what *useful*
threat intelligence actually looks like when it has to feed a real
operations team.

Here's what I found.

## The setup

This isn't a home lab or a simulation. The project is building a fully
operational 24/7 SOC from the ground up, across five phases and roughly
150 deliverables, managed by Jenna Frank. The stack is full Microsoft
enterprise: Sentinel, Defender for Endpoint, Azure Log Analytics, with
Suricata at the network layer and TheHive for case management. The six
functions (Detection Engineering, Process and Documentation, Triage and
IR, Threat Intel, Infrastructure, and Honeynet Ops) are all
interdependent, led by Brad Han, Katie Plaster, Elizabeth Harnisch,
Reginald Deroslard, Derek Heinish, Josh Madakor, and myself. What my
team produces gets consumed immediately by real people doing real shifts.

That last part is what made it feel different. In a lot of labs, you can
produce something, commit it, and move on. Here, if I ship a bad actor
profile or a poorly-mapped TTP, an analyst is going to open their shift
brief and make decisions based on it.

## What threat intel actually does in this context

On paper, my team owns four things: the IOC library, threat actor
profiling, ATT&CK TTP mapping, and the intelligence pipeline that feeds
shift briefings and detection rule requests.

In practice, those four things are deeply intertwined, and the order you
think about them matters.

The mistake I nearly made early on was starting with IOCs. They're
concrete, they're queryable, and they feel productive. Paste a block of
malicious IPs into a watchlist, write a Sentinel analytic rule, done.
But IOCs without actor context are nearly useless for anything except
reactive triage. An IP address doesn't tell you *what the attacker is
likely to do next* or *which detection gaps they'll exploit*.

So I flipped the order. Actor profiling first.

We pick threat actors relevant to the environment we're defending
(industry vertical, geography, known tooling) and build out their TTP
profile against MITRE ATT&CK. Not just "this group uses T1566 phishing"
but: which sub-techniques, what specific lure types, what do their
initial access attempts look like in telemetry, and what do they pivot
to after initial foothold?

That TTP map is what drives the IOC library. IOCs become meaningful when
they're attached to a specific actor's behavior chain: this hash belongs
to Cobalt Strike beacon infrastructure used by this group, and here's
what the C2 check-in pattern looks like so detection engineering can
write a behavioral rule instead of just a hash match.

And the behavioral rule is what actually survives when the attacker
rotates infrastructure. Which they always do.

## The intelligence pipeline

The end product that matters most is what feeds analyst shifts: a
structured brief that gives the on-call team context before they open
their alert queue.

What we landed on is a tiered format:

- **Active threats:** Actors or campaigns with confirmed activity in the
  range during the current window
- **Watch list:** TTPs observed in the wild that map to gaps in our
  current detection coverage
- **Detection requests:** Specific asks to Detection Engineering, with
  MITRE ID, data source, and the KQL skeleton if we have one

That last piece, handing off a detection request with a KQL skeleton,
was the thing that made the feedback loop feel real. Detection
Engineering doesn't have to reverse-engineer what we're worried about;
we give them enough to build from.

## What this changed about how I think

I came into this with a detection-first bias. KQL, Sentinel analytics,
tuning alert logic: that's the work that feels most tangible. Threat
intel always seemed one step removed from the actual detection.

Leading the intel function taught me that the removal is the point. The
value of threat intel isn't in the alerts it directly generates. It's in
the *direction* it gives to the people and systems generating alerts. A
good actor profile makes a detection engineer's time more precise. A
good shift brief makes a triage analyst's decisions faster.

The intel function is a force multiplier. It only works if the output is
specific, current, and tied to something the downstream team can act on.
Vague reports about APT groups don't accomplish that. A ranked list of
TTPs with detection coverage gaps and a KQL draft does.

I'm still in the middle of building this out. Phase 1 is just underway,
so I'll have more to say once we're further in. But if you're building a
SOC lab and wondering whether to carve out a threat intel function or
just fold it into detection: carve it out. It changes how the whole
operation thinks.
