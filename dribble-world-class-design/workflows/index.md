# Dribbble World-Class Design — Skill Index

This skill enables producing Dribbble-worthy, award-level designs across any category: software, games, tech companies, creative agencies, e-commerce, portfolios, and more.

## How to Use This Skill

When triggered by a design request:

1. **Read this file** for routing and workflow selection
2. **Read SKILL.md** at the base — this is your primary operating manual
3. **Follow the Phase 1-2-3 process** defined in SKILL.md
4. **Cross-reference** token catalogs, pattern libraries, and anti-slop checklist as needed
5. **Produce the design** following the output format in SKILL.md

## File Structure

```
SKILL.md                         ← Primary operating manual (always read first)
tokens/
  └── token-examples.md          ← Pre-composed token systems by category
patterns/
  ├── layout-patterns.md         ← Layout, typography, interaction, color patterns
  └── component-recipes.md       ← Ready-to-use CSS components
references/
  ├── motion-system.md           ← Animation timings, patterns, GSAP recipes
  └── anti-slop-checklist.md     ← Patterns to catch and fix before shipping
```

## Quick Reference Decision Tree

```
User requests a design
│
├─ Is it a landing page / marketing site / portfolio?
│  └─→ Use SKILL.md Expressive mode + Hero section patterns
│
├─ Is it a dashboard / admin panel / data interface?
│  └─→ Use SKILL.md Convention-Plus mode + Dashboard patterns
│
├─ Is it a game UI or interactive experience?
│  └─→ Use SKILL.md Game/Interactive mode + Motion System reference
│
├─ Is it enterprise / fintech / B2B?
│  └─→ Use SKILL.md Corporate mode + Trust-first color palette
│
├─ Is it e-commerce / product / retail?
│  └─→ Use SKILL.md E-Commerce mode + Visual merchandising patterns
│
└─ Is it a single component (button, card, form)?
   └─→ Use component-recipes.md + apply theme from tokens/token-examples.md
```

## Token Selection Guide

When choosing a color theme from SKILL.md's catalog:

| Domain | Recommended Theme | Why |
|---|---|---|
| Creative agency | Aurora (Light Vibrant) | Expressive, colorful, portfolio-friendly |
| SaaS / Software | Midnight Pro or Aurora | Dark for dev tools, light for friendly products |
| Gaming | Neon Tokyo or Cyber Violet | High contrast, energetic, thematic |
| Tech startup | Cyber Violet or Neon Tokyo | Futuristic, innovative, dark-preferred |
| Fintech | Nordic Frost or Mono Noir | Trustworthy, precise, professional |
| E-commerce / Fashion | Flora or Editorial Cream | Warm, natural, lifestyle-oriented |
| Health / Wellness | Flora | Organic, calming, nature-aligned |
| Luxury / Premium | Mono Noir | Refined, minimal, expensive feeling |
| Kids / Education | Pastel Pop | Playful, approachable, energetic |
| Food / Hospitality | Lava | Warm, appetizing, inviting |

## Workflow Integration

This skill works alongside:
- **frontend-design**: Use when building actual HTML/CSS code; load frontend-design for execution guidance
- **design-blueprint**: Use when a structured spec (DESIGN.md) is needed before implementation
- **product-design**: Use when designing full product interfaces beyond just visual presentation

For best results:
1. Load this skill for direction, theme, and category-specific guidance
2. Load frontend-design for CSS/HTML execution specifics (environment constraints, system fonts)
3. Load design-blueprint if user needs a DESIGN.md specification document before coding

## Self-Check Before Every Output

Run through these steps mentally before responding:

1. [ ] Did I choose a specific theme/palette or compose a custom one? (Not generic purple-blue)
2. [ ] Are my font pairings distinctive and deliberate? (Not Inter-only everywhere)
3. [ ] Does this design have ONE signature element? (Not everything is memorable)
4. [ ] Am I checking against the anti-slop checklist? (At least U1-U5 checked)
5. [ ] Is the response categorized correctly for its domain? (Software ≠ gaming ≠ e-commerce)
6. [ ] Are there real content placeholders, not lorem ipsum? 
7. [ ] Does the token system include all necessary CSS variables?
8. [ ] Have I considered responsive behavior for the design?
9. [ ] Are animations purposeful, not scattered everywhere?
10. [ ] Is accessibility addressed (contrast, focus states, reduced-motion)?
