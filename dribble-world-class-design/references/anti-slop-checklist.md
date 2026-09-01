# Design Anti-Slop Checklist

This is the definitive list of patterns that make a design look AI-generated rather than human-crafted. Flag each one before presenting. If any hit, revise.

## Universal Tells (apply to every category)

| # | Pattern | What It Looks Like | Why It Fails | Fix |
|---|---|---|---|---|
| **U1** | Generic gradient hero | Purple-to-blue radial glow on dark bg | Appears on literally every AI landing page | Pick a gradient tied to the actual brand/domain |
| **U2** | Rounded-16px card grid | 6 identical cards with icon + title + 2 lines | Template appearance, zero personality | Vary radii, drop shadows, remove cards entirely, use asymmetric grids |
| **U3** | Emoji decoration | Headlines with 🚀✨💡 or bullet points with emojis | Unprofessional, instantly reads as AI | Use SVG icons, CSS shapes, or typographic markers |
| **U4** | Isometric illustrations | 3D angled people/objects/boxes at angles | Stale from 2020, overused by AI | Use CSS gradients, abstract shapes, or typography |
| **U5** | Floating stat trios | "47% YoY" / "10K+" / "3x faster" in uniform cards | Feels manufactured | Ground stats in real data context; show them naturally |
| **U6** | Every CTA is primary filled | Every section ends with a giant orange button | Conversion spam appearance | One primary CTA per section max; use contextual linking |
| **U7** | Vaporware copy | "seamlessly unlock your team's potential" | Says nothing specific | Write real, concrete, specific text |
| **U8** | Em-dash abuse | Using — everywhere for dramatic pause | Stylistic tell | Use commas, colons, or sentence breaks instead |
| **U9** | Pure white on pure black | #ffffff text on #000000 background | Harsh, unrealistic | Use near-black (#08080c) and off-white (#f5f5f5) |
| **U10** | Same font for everything | One sans-serif, same weight, no scale | Flat personality | Pair display with body; use mono for data/captions |
| **U11** | lorem ipsum anywhere | Placeholder Latin text visible | Instant AI tell | Use realistic placeholder text matching content length |
| **U12** | Everything animated | Every element fades/slides/morphs/dances | Distracting, cheap feeling | Max 1 orchestrated sequence + individual micro-interactions |

## Category-Specific Anti-Patterns

### Landing Pages
| Pattern | Problem | Fix |
|---|---|---|
| Hero with stock photo person | Feels corporate and generic | Use gradient, illustration, product mockup, or typography |
| "Trusted by" logo carousel without real brands | Fake social proof | Either use real partner names or skip the section |
| 7+ features listed identically | Feature dump, not persuasion | Group into 3-4 pillars; show, don't tell |
| Testimonial with avatar circle + quote | Template testimonial block | Vary layouts; add role/company context; stagger alignment |
| Footer with 5 link columns | Cluttered, unfocused | 3-4 columns max; prioritize real navigation |

### SaaS / Dashboard
| Pattern | Problem | Fix |
|---|---|---|
| Chart with rainbow colors | Every bar different color | Use one accent color; muted bars for context |
| Sidebar nav with 15+ items | Navigation overwhelm | Group into categories; collapse secondary sections |
| Data table with no empty state | Broken experience when no data | Design empty state with illustration + CTA |
| Status badges that aren't color-coded by severity | Red/yellow/green without standard meaning | Use green=good, yellow=warning, red=critical convention |
| Modal that blocks everything for minor info | Overly aggressive | Use slide-over or tooltip for lightweight info |

### Portfolio
| Pattern | Problem | Fix |
|---|---|---|
| "View Project" on every card | Repetitive interaction | Vary CTAs: some say "Case Study," "View Live," "Watch Video" |
| All project images same aspect ratio | Monotonous grid | Mix portrait, landscape, square ratios naturally |
| Skills section with progress bars | Arbitrary percentage display | List skills descriptively; show them in context of work |
| Contact form with no real value prop | Why should they contact? | Add why-contact reasoning before the form |
| Year displayed but no project description | Empty context | Always pair year/project name with 1-line what/why |

### E-Commerce
| Pattern | Problem | Fix |
|---|---|---|
| Price shown as "$99" with strikethrough "$199" | Fake discount psychology | Real pricing only; honest discounts |
| "Free shipping" banner on every page | Banner blindness | Contextual placement near cart/checkout only |
| Product grid with no filtering | Overwhelming catalog | Add category filters, sort options, search |
| Star rating without review count | "4.9 stars" with no basis | Always show "(128 reviews)" or similar |
| Image gallery with identical thumbnails | No product detail | Show product from multiple angles; zoom capability |

### Gaming UI
| Pattern | Problem | Fix |
|---|---|---|
| Everything bright neon on black | Visual fatigue, hard to read | Limit neon to key accents; rest can be matte/solid |
| Health/mana bars everywhere on non-game UI | Genre confusion | Only use RPG elements when appropriate |
| Pixel font for all text | Unreadable at small sizes | Pixel font for titles only; clean sans for body |
| Character select with no context | What game is this? | Always include game title, genre, platform info |

### Corporate / Enterprise
| Pattern | Problem | Fix |
|---|---|---|
| Stock photo handshake/team meeting | The most generic image possible | Real photos, abstract graphics, or data visualization |
| "Our values" as 4 rounded squares | Boring value proposition | Tell stories about values through case studies |
| CTA saying "Learn More" on every section | CTA fatigue | Vary CTAs by section purpose: "See Report," "Book Demo," "Explore" |
| Accordion FAQ that hides critical info | Critical info behind clicks | Put most important info above the fold |
| Certification logos in footer row | Wasted space | Integrate certifications into relevant content sections |

## Self-Correction Process

Before presenting ANY design:

1. Read through the Universal Tells table above
2. For each item, ask: "Does my design exhibit this pattern?"
3. If yes to U1-U5: this is high-probability AI detection. Revise immediately.
4. If yes to U6-U12: reduce or eliminate these patterns.
5. Check category-specific patterns too.
6. Say out loud: "Would a designer at a real studio produce this?" If not, iterate.

The goal isn't to avoid ALL common patterns — some are standards for good reason. The goal is to avoid patterns that appear **because the model is averaging toward the median training distribution** rather than making **specific choices driven by the brief**. A gradient hero is fine if it's the *actual* brand color. A card grid is fine if the content *benefits* from that structure. It's the undifferentiated default that kills quality.
