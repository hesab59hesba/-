# Design Patterns Library

## Layout Patterns

### 1. Bento Grid
Asymmetric card grid inspired by Apple promotional materials and Japanese bento boxes.
```css
.bento-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}
.card--wide  { grid-column: span 2; }
.card--tall  { grid-row: span 2; }
.card--full  { grid-column: span 4; }
.card--half  { grid-column: span 2; }
```
Best for: Feature showcases, portfolio highlights, stats dashboards, product feature overviews.

### 2. Split Screen
Two-column layout, often with visual on one side, content on the other.
Best for: Hero sections, about pages, product descriptions.

### 3. Full-Screen Sections
Each section takes full viewport height, creating a storyboarding effect as user scrolls.
```css
section { min-height: 100svh; display: flex; align-items: center; }
```
Best for: Immersive storytelling, product reveals, agency portfolios.

### 4. Staggered Masonry
Cards flow in staggered vertical rhythm, not aligned to rigid rows.
Best for: Blog feeds, image galleries, case study previews.

### 5. Concentric / Radial
Content arranged around a central focal point (circle, orb, hero image).
Best for: Product launches, announcement pages, award sites.

### 6. Asymmetric Breakout
Content intentionally breaks out of standard container — images extend beyond max-width, text overlaps imagery.
Best for: Creative studios, experimental portfolios, avant-garde brands.

### 7. Centered Column
Single-column, centered content with generous side whitespace.
Best for: Editorial layouts, long-form narratives, minimal products.

### 8. Horizontal Cascade
Cards or elements cascade from left to right with decreasing scale/opacity.
Best for: Timeline views, team slides, process explanations.

### 9. Overlay Modal / Drawer
Full-screen or half-screen overlay that slides in or fades over content.
Best for: Project detail pages, pricing tiers, newsletter signup.

### 10. Floating Island
Sticky element that floats at bottom or side of viewport (cart, chat, progress bar).
Best for: E-commerce, reading progress, floating nav.

## Typography Patterns

### Hero Headline Treatments
| Treatment | Technique | Example |
|---|---|---|
| Gradient fill | `background-clip: text` with gradient | Words that shimmer between two colors |
| Stroke only | `color: transparent; -webkit-text-stroke: 1px currentColor` | Outline letters over busy background |
| Masked video/image | `background-clip: text` with image instead of gradient | Photos inside headlines |
| Letter-by-letter reveal | Each span wraps in `<span>` with stagger animation | Text enters frame character by character |
| Oversized + subtle | Font-size 12vw+ with very low opacity behind main text | Background anchor text |
| Dual-weight contrast | Bold H1 paired with light/italic supporting headline | "We design" in 900 weight next to "that matter" in 200 italic |

### Text Decoration Elements
| Element | Use | Implementation |
|---|---|---|
| Eyebrow / label | Section identifier above heading | Mono font, small, uppercase, tracking |
| Date stamp | When something was made | Right-aligned, mono, small size |
| Number counter | Statistics that animate | Large, bold, counted up from zero |
| Callout quote | Key statement in large type | Serif, oversized, centered or left-aligned with left border |
| Pull quote | Highlighted excerpt from body | Italic serif, larger than body, decorative quotation marks |
| Tag / pill | Category or status indicator | Rounded, filled or outlined, compact |

## Interaction Patterns

### Card Hover States
```
Basic: translateY(-4px) + box-shadow increase
3D Tilt: perspective(800px) rotateX/Y based on mouse position
Image Zoom: nested image scales 1.05x inside overflow-hidden container
Border Glow: conic-gradient spinning border on hover
Lift + Accent: slide up + accent-colored shadow bloom
```

### Button Micro-Animations
```
Primary CTA: fills with gradient on hover, slight scale down (press feel)
Secondary: border color transitions, text color shifts to accent
Ghost: subtle background fade-in
Icon: arrow translates right on hover, chevron rotates
Loading: spinning dots, progress bar fill, skeleton pulse
```

### Navigation Patterns
```
Standard: horizontal links in fixed top bar
Pill Nav: centered rounded navigation with logo centered
Floating Dock: macOS-style dock at bottom of screen
Hamburger Overlay: full-screen menu covering entire viewport on mobile
Scroll-linked: nav becomes glassmorphic after scrolling past hero
Minimal: nav disappears on scroll-down, reappears on scroll-up
```

### Form Input Patterns
```
Underline only: bottom border animates to accent color on focus
Filled: background transitions from transparent to surface-color
Floating label: label moves from inside input to above it on focus
Segmented: radio buttons styled as toggle pills
Range slider: custom styled range with gradient track
Multi-step: form progress shown as numbered steps with connecting line
```

## Visual Element Patterns

### Section Dividers
```
Line: thin 1px border-top or border-bottom
Angle: diagonal clip-path on section edge
Wave: SVG path between sections
Gradient fade: section background transitions into next via gradient
Space: pure whitespace, no divider needed (most Dribbble-worthy approach)
Overlap: previous section's element extends slightly into next
```

### Decorative Elements
```
Gradient blobs: blurred circles with slow float animation
Grid patterns: subtle repeating dot or line pattern at low opacity
Noise/grain: SVG feTurbulence filter overlaid at 0.02 opacity
Geometric shapes: rotated squares, circles, triangles placed deliberately
Lines and rules: hairline dividers, angled lines, dashed connections
Mesh gradients: overlapping radial gradients creating fluid color fields
Particle canvas: tsparticles for hero backgrounds with connected nodes
```

### Image Treatment Patterns
```
Rounded corners: 16-24px radius matching overall design system
Mask overlays: image clipped to shape (circle, blob, custom polygon)
Double exposure: two images blended with multiply or screen blend mode
Polaroid style: white border with caption below, slight rotation
Floating frames: multiple image layers at different depths with shadows
Edge-to-edge: full-bleed to screen edge, no margins
Aspect ratio lock: consistent ratios across all images (4:3, 16:9, 1:1)
Desaturate on load, color on hover: grayscale → color transition
```

## Color Treatment Patterns

### Background Treatments
```
Solid: single flat color (cleanest, most professional)
Gradient wash: very soft gradient spanning entire section (5-15% opacity colors)
Mesh gradient: overlapping radial gradients creating fluid color fields
Pattern + solid: subtle repeating pattern (dots, lines, grid) over base color
Image overlay: photograph or illustration with color tint overlay
Glassmorphic: frosted glass panels layered over colorful backgrounds
Noise + gradient: gradient base with SVG noise texture on top
```

### Accent Application
```
Single accent: one color used for CTAs, links, active states, hover effects
Dual accent: primary + secondary used in gradients and alternating contexts
Accent bands: section-level stripes of accent color between content blocks
Accent dots/bullets: interactive indicators colored with accent
Accent borders: 2-3px accent-colored borders on focused/hovered elements
Gradient text: headings or keywords using accent gradient as fill
Glow effects: box-shadow or filter drop-shadow in accent color
```

## Component Patterns by Category

### SaaS / Software Components
- Feature comparison table with highlighted "popular" tier
- Pricing toggle (monthly/annual) with animated price swap
- Dashboard screenshot in floating window with scroll parallax
- API code block with syntax highlighting and copy button
- Status/uptime indicator (green dot, percentage, trend arrow)
- Integration logos grid (partner ecosystem)
- Testimonial carousel with auto-scroll + manual arrows
- CTA section with email input inline

### Gaming Components
- Character select cards with flip animation
- Stats/attributes bars with gradient fill animation
- Leaderboard table with rank medals (gold/silver/bronze icons)
- Achievement badges with unlock glow effect
- System requirements presented as spec cards
- Replay/game highlights video embed
- Character ability icon grid
- Tournament bracket visualization

### E-Commerce Components
- Product image gallery with thumbnail strip
- Size/color selector with live preview
- Cart drawer sliding from right
- Wishlist heart icon with fill animation
- Customer review stars with average rating
- Add to cart quantity stepper
- Shipping estimator input
- Recently viewed carousel

### Portfolio Components
- Project filter tabs with elastic indicator
- Full-screen project overlay with smooth crossfade
- Client logo strip (grayscale, hover to color)
- Process timeline with connecting lines
- Skills/expertise tags with proficiency levels
- Open work/investigation statement section
- Testimonials embedded in narrative text
- Calendar availability widget for booking

### Tech Startup Components
- Team member cards with hover photo reveal
- Funding/metrics ticker (valuation, users, revenue)
- Technology stack logos in organized grid
- Blog/article preview cards
- Event/conference speaker card
- Download whitepaper or report CTA
- Community Discord/Slack join banner
- Open source repo preview with star count

### Education Platform Components
- Course card with progress ring
- Lesson preview modal with video placeholder
- Student testimonial with avatar and quote
- Certification badge showcase
- Enrollment countdown timer
- Curriculum accordion with expandable modules
- Instructor profile card
- Study group/community forum preview

## Dark/Light Mode Strategies

### Automatic Detection
```css
@media (prefers-color-scheme: dark) {
  :root { --bg: #08080c; --text: #e8e8ed; /* dark values */ }
}
:root { --bg: #f8f7f4; --text: #1a1a1a; /* default light */ }
```

### Manual Toggle Pattern
- Toggle switch in navbar (sun/moon icon morphs)
- Stores preference in localStorage
- Applies `data-theme="dark"` or `data-theme="light"` to `<html>`
- All CSS variables change based on `[data-theme]` selectors

### Hybrid Approach (Recommended)
- Default to light for creative/lifestyle brands
- Default to dark for dev tools/fintech/AI
- Allow theme toggle for power users
- Consider system preference as starting point
